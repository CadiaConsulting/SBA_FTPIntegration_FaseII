codeunit 50013 "Integration Purchase"
{
    procedure CreatePurchase(var IntPurchase: Record "Integration Purchase")
    var
        IntegrationPurchase: Record "Integration Purchase";
        DialogReviewPurchaseLbl: label 'Review Purchase Order   #1#############', Comment = '#1 IntegrationPurchase';
        IPByDocBuffer: Record "Integration Purchase" temporary;
    begin

        StartTime := CurrentDateTime;

        IntegrationPurchaseBuffer.Reset();
        IntegrationPurchaseBuffer.DeleteAll();

        IntegrationPurchase.Reset();
        IntegrationPurchase.CopyFilters(IntPurchase);
        IntegrationPurchase.SetFilter(Status, '%1|%2|%3', IntegrationPurchase.Status::Imported,
                                                       IntegrationPurchase.Status::"Data Error",
                                                       IntegrationPurchase.Status::Reviewed);
        IntegrationPurchase.SetFilter("Document Errors Import Excel", '%1', 0);
        if not IntegrationPurchase.IsEmpty then begin
            IntegrationPurchase.FindSet();
            repeat
                IPByDocBuffer.Init();
                IPByDocBuffer."Document No." := IntegrationPurchase."Document No.";
                if IPByDocBuffer.Insert() then;
            until IntegrationPurchase.Next() = 0;
        end;

        if IPByDocBuffer.FindFirst() then
            repeat
                IntegrationPurchase.Reset();
                IntegrationPurchase.SetRange("Document No.", IPByDocBuffer."Document No.");
                IntegrationPurchase.SetFilter(Status, '%1|%2|%3', IntegrationPurchase.Status::Imported,
                                                                  IntegrationPurchase.Status::"Data Error",
                                                                  IntegrationPurchase.Status::Reviewed);
                if IntegrationPurchase.Find('-') then begin
                    if GuiAllowed then
                        WindDialog.Open(DialogReviewPurchaseLbl);
                    repeat
                        //if IntegrationPurchase.Status <> IntegrationPurchase.Status::Reviewed then begin

                        if GuiAllowed then
                            WindDialog.Update(1, IntegrationPurchase."Document No.");
                        IntegrationPurchase."Posting Message" := '';
                        IntegrationPurchase."Municipio Code" := '';
                        if not ValidateIntPurchase(IntegrationPurchase) then;

                    //end;
                    until IntegrationPurchase.Next() = 0;

                    if GuiAllowed then
                        WindDialog.Close();

                end;

            until IPByDocBuffer.Next() = 0;

        Commit();

        if CreatePurchaseByDoc() then;

        if GuiAllowed then
            WindDialog.Close();
        if GuiAllowed then
            Message('Começou em %1 e terminou em %2', StartTime, CurrentDateTime);
    end;

    local procedure CreatePurchaseByDoc(): Boolean;
    var
        RecordToCreate: Record "Integration Purchase";
        MarkAllDataErrorLbl: label 'The document has data errors in other fields.';
        DialogCrePurchaseLbl: label 'Create Purchase Order   #1#############', Comment = '#1 IntegrationPurchase';
    begin

        if GuiAllowed then
            WindDialog.Open(DialogCrePurchaseLbl);

        IntegrationPurchaseBuffer.Reset();
        if IntegrationPurchaseBuffer.FindSet() then
            repeat
                IntegrationPurchaseBuffer.SetAutoCalcFields("Error Order");

                if GuiAllowed then
                    WindDialog.Update(1, IntegrationPurchaseBuffer."Document No.");
                if IntegrationPurchaseBuffer."Error Order" = 0 then begin

                    RecordToCreate.Reset();
                    RecordToCreate.SetRange("Document No.", IntegrationPurchaseBuffer."Document No.");
                    RecordToCreate.SetFilter(Status, '<>%1', RecordToCreate.Status::"Data Error");
                    if RecordToCreate.FindSet() then
                        CreatePurchaseOrder(RecordToCreate);


                end else begin
                    FilterRecordToCreate(RecordToCreate);
                    if not RecordToCreate.IsEmpty then begin
                        RecordToCreate.FindSet();
                        RecordToCreate.ModifyAll(Status, RecordToCreate.Status::"Data Error");
                    end;

                    FilterRecordToCreateErrorMessage(RecordToCreate);
                    if not RecordToCreate.IsEmpty then begin
                        RecordToCreate.FindSet();
                        RecordToCreate.ModifyAll("Posting Message", MarkAllDataErrorLbl);
                    end;
                end;
            until IntegrationPurchaseBuffer.Next() = 0;
    end;

    procedure PostPurchase(var IntPurchase: Record "Integration Purchase")
    var
        IntegrationPurchase: Record "Integration Purchase";
        IntPurStatus: Record "Integration Purchase";
    begin
        IntegrationPurchase.Reset();
        IntegrationPurchase.CopyFilters(IntPurchase);
        IntegrationPurchase.SetFilter(Status, '%1|%2', IntegrationPurchase.Status::Created, IntegrationPurchase.Status::Exported);
        IntegrationPurchase.CalcFields("Error Order");
        IntegrationPurchase.SetFilter("Error Order", '%1', 0);
        IntegrationPurchase.SetRange(Rejected, false);
        IntegrationPurchase.SetRange("Release to Post", true);
        if IntegrationPurchase.Find('-') then
            repeat
                ClearLastError();
                if not CreatePostOrder(IntegrationPurchase) then begin
                    IntegrationPurchase."Posting Message" := copystr(GetLastErrorText(), 1, 200);
                    IntegrationPurchase.Status := IntegrationPurchase.Status::"Data Error";
                    IntegrationPurchase.Modify();

                    IntPurStatus.Reset();
                    IntPurStatus.SetRange("Document No.", IntegrationPurchase."Document No.");
                    IntPurStatus.ModifyAll(Status, IntPurStatus.Status::"Data Error");
                    IntPurStatus.ModifyAll("Posting Message", copystr(GetLastErrorText(), 1, 200));


                end else begin
                    integrationPurchase.Status := IntegrationPurchase.Status::Posted;
                    IntegrationPurchase.Modify();

                    IntPurStatus.Reset();
                    IntPurStatus.SetRange("Document No.", IntegrationPurchase."Document No.");
                    IntPurStatus.ModifyAll(Status, IntPurStatus.Status::Posted);

                end;

            until IntegrationPurchase.Next() = 0;
    end;

    procedure CreatePurchaseOrder(IntegrationPurchase: Record "Integration Purchase")
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        IntPurStatus: Record "Integration Purchase";
        DocAttac: Record "Document Attachment";
        TempBlob: Codeunit "Temp Blob";
        CADBRMunicipio: Record "CADBR Municipio";
        IPLines: Record "Integration Purchase";
        ReleasePurchaseDocument: Codeunit "Release Purchase Document";
    begin

        PurchaseHeader.Reset();
        if not PurchaseHeader.Get(PurchaseHeader."Document Type"::Order, IntegrationPurchase."Document No.") then begin
            // PurchaseHeader."Posting No." := '';
            // PurchaseHeader.Modify();
            // PurchaseHeader.Delete(true);
            //end else begin

            PurchaseHeader.Init();
            PurchaseHeader."Document Type" := PurchaseHeader."Document Type"::Order;
            PurchaseHeader.Validate("CADBR Branch Code", IntegrationPurchase."Shortcut Dimension 6 Code");
            PurchaseHeader.validate("No.", IntegrationPurchase."document No.");
            PurchaseHeader.InitRecord();
            PurchaseHeader.validate("Buy-from Vendor No.", IntegrationPurchase."Buy-from Vendor No.");
            PurchaseHeader."Order Date" := IntegrationPurchase."Order Date";
            PurchaseHeader.validate("Posting Date", IntegrationPurchase."Order Date");
            PurchaseHeader."Document Date" := IntegrationPurchase."Order Date";

            PurchaseHeader."Vendor Invoice No." := IntegrationPurchase."Vendor Invoice No.";
            // PurchaseHeader."Posting No." := IntegrationPurchase."Document No.";

            if IntegrationPurchase."Tax Area Code" <> '' then
                PurchaseHeader.Validate("CADBR Taxes Matrix Code", IntegrationPurchase."Tax Area Code");

            PurchaseHeader.Receive := true;
            PurchaseHeader.Invoice := true;

            PurchaseHeader."IRRF Ret" += IntegrationPurchase."IRRF Ret";
            PurchaseHeader."CSRF Ret" += IntegrationPurchase."CSRF Ret";
            PurchaseHeader."INSS Ret" += IntegrationPurchase."INSS Ret";
            PurchaseHeader."ISS Ret" += IntegrationPurchase."ISS Ret";
            PurchaseHeader."PIS Credit" += IntegrationPurchase."PIS Credit";
            PurchaseHeader."Cofins Credit" += IntegrationPurchase."Cofins Credit";
            PurchaseHeader."DIRF" += IntegrationPurchase.DIRF;
            PurchaseHeader."PO Total" := IntegrationPurchase."PO Total";
            PurchaseHeader.Insert();

            PurchaseHeader.AddLink(IntegrationPurchase."Doc. URL", IntegrationPurchase."Doc. URL");

            PurchaseHeader.Status := PurchaseHeader.Status::Open;
            if IntegrationPurchase."Shortcut Dimension 1 Code" <> '' then
                PurchaseHeader.ValidateShortcutDimCode(1, IntegrationPurchase."Shortcut Dimension 1 Code");
            if IntegrationPurchase."Shortcut Dimension 2 Code" <> '' then
                PurchaseHeader.ValidateShortcutDimCode(2, IntegrationPurchase."Shortcut Dimension 2 Code");
            if IntegrationPurchase."Shortcut Dimension 3 Code" <> '' then
                PurchaseHeader.ValidateShortcutDimCode(3, IntegrationPurchase."Shortcut Dimension 3 Code");
            if IntegrationPurchase."Shortcut Dimension 4 Code" <> '' then
                PurchaseHeader.ValidateShortcutDimCode(4, IntegrationPurchase."Shortcut Dimension 4 Code");
            if IntegrationPurchase."Shortcut Dimension 5 Code" <> '' then
                PurchaseHeader.ValidateShortcutDimCode(5, IntegrationPurchase."Shortcut Dimension 5 Code");
            if IntegrationPurchase."Shortcut Dimension 6 Code" <> '' then
                PurchaseHeader.ValidateShortcutDimCode(6, IntegrationPurchase."Shortcut Dimension 6 Code");

            PurchaseHeader.Validate("CADBR Service Delivery City", IntegrationPurchase."Municipio Code");

            if IntegrationPurchase."Fiscal Document Type" <> '' then
                PurchaseHeader."CADBR Fiscal Document Type" := IntegrationPurchase."Fiscal Document Type";
            PurchaseHeader.Modify();

            //Purchase Line
            PurchaseLine.Reset();
            if PurchaseLine.get(PurchaseLine."Document Type"::Order, IntegrationPurchase."document No.", IntegrationPurchase."Line No.") then
                PurchaseLine.Delete(true);

            IPLines.Reset();
            IPLines.SetRange("Document No.", IntegrationPurchase."document No.");
            if not IPLines.IsEmpty then begin
                IPLines.FindSet();
                repeat

                    PurchaseLine.Init();
                    PurchaseLine."Document Type" := PurchaseLine."Document Type"::Order;
                    PurchaseLine."Document No." := IPLines."document No.";
                    PurchaseLine."Line No." := IPLines."Line No.";

                    if IPLines.Type = IPLines.Type::Item then
                        PurchaseLine.Type := PurchaseLine.Type::Item;

                    PurchaseLine.Validate("No.", IPLines."Item No.");

                    // > Ajuste temporario

                    if (IPLines."Item No." in
                            ['1628012', '1639012', '1644012', '1645012', '1646012', '1647012', '1657012',
                             '1662012', '1668012', '1670012', '1672012', '1679012', '1681012']) and
                        (IPLines."Shortcut Dimension 2 Code" = 'OI  2,113 - GUARANI')
                    then
                        PurchaseLine.Validate("Gen. Prod. Posting Group", '4.2.01.0001')
                    else

                        // < Ajuste temporario

                        if IPLines."Gen. Prod. Posting Group" <> '' then
                            PurchaseLine.Validate("Gen. Prod. Posting Group", IPLines."Gen. Prod. Posting Group");

                    PurchaseLine.Description := IPLines.Description;
                    PurchaseLine.validate(Quantity, IPLines.Quantity);
                    PurchaseLine.validate("Direct Unit Cost", IPLines."Direct Unit Cost Excl. Vat");
                    PurchaseLine."CADBR Service Code" := IPLines."Service Code";
                    PurchaseLine."VAT Calculation Type" := PurchaseLine."VAT Calculation Type"::"Sales Tax";
                    PurchaseLine."Tax Liable" := true;
                    PurchaseLine."CADBR Operation Type" := PurchaseHeader."CADBR Operation Type";
                    if IPLines."Shortcut Dimension 1 Code" <> '' then begin
                        PurchaseLine.ValidateShortcutDimCode(1, IPLines."Shortcut Dimension 1 Code");
                        PurchaseLine."Shortcut Dimension 1 Code" := IPLines."Shortcut Dimension 1 Code";
                    end;
                    if IPLines."Shortcut Dimension 2 Code" <> '' then begin
                        PurchaseLine.ValidateShortcutDimCode(2, IPLines."Shortcut Dimension 2 Code");
                        PurchaseLine."Shortcut Dimension 2 Code" := IPLines."Shortcut Dimension 2 Code";
                    end;
                    if IPLines."Shortcut Dimension 3 Code" <> '' then
                        PurchaseLine.ValidateShortcutDimCode(3, IPLines."Shortcut Dimension 3 Code");
                    if IPLines."Shortcut Dimension 4 Code" <> '' then
                        PurchaseLine.ValidateShortcutDimCode(4, IPLines."Shortcut Dimension 4 Code");
                    if IPLines."Shortcut Dimension 5 Code" <> '' then
                        PurchaseLine.ValidateShortcutDimCode(5, IPLines."Shortcut Dimension 5 Code");
                    if IPLines."Shortcut Dimension 6 Code" <> '' then
                        PurchaseLine.ValidateShortcutDimCode(6, IPLines."Shortcut Dimension 6 Code");
                    PurchaseLine.Insert();

                    IPLines."Posting Message" := '';
                    IPLines.Status := IPLines.Status::Created;
                    IPLines.Modify();

                until IPLines.Next() = 0;
            end;

            CalcTax(PurchaseHeader, false);
            if not ValidateCodMun(PurchaseHeader) then
                if not ValidatePostAcc(PurchaseHeader) then
                    exit;

            // if PurchaseHeader."CADBR Taxes Matrix Code" = 'SEM IMP' then
            //     ReleasePurchaseDocument.Run(PurchaseHeader)
            // else if PurchaseHeader."Tax Area Code" <> '' then // GAP08-004b
            //     ReleasePurchaseDocument.Run(PurchaseHeader)

            if IntegrationPurchase."Tax Area Code" <> '' then
                ReleasePurchaseDocument.Run(PurchaseHeader);

        end else begin

            IntPurStatus.Reset();
            IntPurStatus.SetRange("Document No.", IntegrationPurchase."Document No.");
            if IntegrationPurchase.Status = IntegrationPurchase.Status::Reviewed then
                IntPurStatus.ModifyAll(Status, IntPurStatus.Status::Created);
            IntPurStatus.ModifyAll("Posting Message", PurchaseHeader."Posting Message");

        end;

    end;

    [TryFunction]
    procedure CreatePostOrder(IntegrationPurchase: Record "Integration Purchase")
    var
        PurchaseHeader: Record "Purchase Header";
        IntPurchase: Record "Integration Purchase";
        PurchPost: codeunit "Purch.-Post";
    begin
        booHideDialog := false;

        Clear(PurchPost);

        if PurchaseHeader.get(PurchaseHeader."Document Type"::Order, IntegrationPurchase."document No.") then begin
            PurchaseHeader."Posting No." := PurchaseHeader."No.";
            PurchaseHeader.Modify();

            PurchPost.Run(PurchaseHeader);
            //MarkAsPosted(IntegrationPurchase, IntPurchase)
            //else
            //MarkAsNotPosted(IntegrationPurchase, IntPurchase);
        end else
            if IntegrationPurchase.Status <> IntegrationPurchase.Status::Posted then begin
                IntPurchase.Reset();
                IntPurchase.SetRange("Document No.", IntegrationPurchase."document No.");
                if IntPurchase.FindFirst() then
                    if IntPurchase.Status = IntPurchase.Status::Posted then begin
                        IntegrationPurchase.Status := IntegrationPurchase.Status::Posted;
                        IntegrationPurchase.Modify();
                    end;
            end;
    end;

    procedure ValidateIntPurchase(var IntegrationPurchase: Record "Integration Purchase"): Boolean;
    var
        Vendor: Record Vendor;
        Item: Record Item;
        PostCode: Record "Post Code";
        VendorErr: label 'Vendor %1 Not Found', Comment = '%1 - vendor No.';
        Item01Err: label ' - Item %1 Not Found', Comment = '%1 - Item No.';
        GL01Err: label ' - G/L Account not sent by GP';
        GL02Err: label ' - G/L Account GP %1 different from G/L Account %2', Comment = '%1 - G/L Accoun No. , %2 - G/L Accoun No.';
        MatrixErr: label 'Tax Matriz Not Found on Vendor %1', Comment = '%1 - Vendor No.';
        VendGenBusPostGroupErr: Label 'Please configure Gen. Bus. Posting Group on vendor %1.';
        ItemGenProdPostGroupErr: Label 'Please configure Gen. Prod. Posting Group on item %1.';
        ItemTypeErr: Label 'The Type must be diferent of %1 for Item %2.';
    begin

        if not Vendor.Get(IntegrationPurchase."Buy-from Vendor No.") then
            IntegrationPurchase."Posting Message" := MergePostingMessage(IntegrationPurchase."Posting Message", StrSubstNo(VendorErr, IntegrationPurchase."Buy-from Vendor No."));

        if Vendor."CADBR Taxes Matrix" = '' then
            IntegrationPurchase."Posting Message" := MergePostingMessage(IntegrationPurchase."Posting Message", StrSubstNo(MatrixErr, IntegrationPurchase."Buy-from Vendor No."));

        if Vendor."Gen. Bus. Posting Group" = '' then
            IntegrationPurchase."Posting Message" := MergePostingMessage(IntegrationPurchase."Posting Message", StrSubstNo(VendGenBusPostGroupErr, IntegrationPurchase."Buy-from Vendor No."));

        if not Item.get(IntegrationPurchase."Item No.") then
            IntegrationPurchase."Posting Message" := MergePostingMessage(IntegrationPurchase."Posting Message", StrSubstNo(Item01Err, IntegrationPurchase."Item No."))
        else begin
            if Item."Gen. Prod. Posting Group" = '' then
                IntegrationPurchase."Posting Message" := MergePostingMessage(IntegrationPurchase."Posting Message", StrSubstNo(ItemGenProdPostGroupErr, Item."No."));
            if Item.Type = Item.Type::Inventory then
                IntegrationPurchase."Posting Message" := MergePostingMessage(IntegrationPurchase."Posting Message", StrSubstNo(ItemTypeErr, Format(Item.Type), Item."No."));
        end;

        CheckAccount(IntegrationPurchase, Vendor, Item);
        CheckMunicipios(IntegrationPurchase);

        if IntegrationPurchase."Shortcut Dimension 1 Code" <> '' then
            if not ValidateDim(1, IntegrationPurchase."Shortcut Dimension 1 Code") then
                CreateDim(1, IntegrationPurchase."Shortcut Dimension 1 Code");

        if IntegrationPurchase."Shortcut Dimension 2 Code" <> '' then
            if not ValidateDim(2, IntegrationPurchase."Shortcut Dimension 2 Code") then
                CreateDim(2, IntegrationPurchase."Shortcut Dimension 2 Code");

        if IntegrationPurchase."Shortcut Dimension 3 Code" <> '' then
            if not ValidateDim(3, IntegrationPurchase."Shortcut Dimension 3 Code") then
                CreateDim(3, IntegrationPurchase."Shortcut Dimension 3 Code");

        if IntegrationPurchase."Shortcut Dimension 4 Code" <> '' then
            if not ValidateDim(4, IntegrationPurchase."Shortcut Dimension 4 Code") then
                CreateDim(4, IntegrationPurchase."Shortcut Dimension 4 Code");

        if IntegrationPurchase."Shortcut Dimension 5 Code" <> '' then
            if not ValidateDim(5, IntegrationPurchase."Shortcut Dimension 5 Code") then
                CreateDim(5, IntegrationPurchase."Shortcut Dimension 5 Code");

        if IntegrationPurchase."Shortcut Dimension 6 Code" <> '' then
            if not ValidateDim(6, IntegrationPurchase."Shortcut Dimension 6 Code") then
                CreateDim(6, IntegrationPurchase."Shortcut Dimension 6 Code");


        InsertPurchaseBuffer(IntegrationPurchase);

        if IntegrationPurchase."Posting Message" <> '' then begin
            IntegrationPurchase.Status := IntegrationPurchase.Status::"Data Error";
            IntegrationPurchase.Modify();
            exit(true);

        end else begin

            IntegrationPurchase.Status := IntegrationPurchase.Status::Reviewed;
            IntegrationPurchase.Modify();

        end;
    end;

    procedure ValidateDim(DimSeq: Integer; ValueDim: Code[20]): Boolean
    var
        DimensionValue: Record "Dimension Value";
        GeneralLedgerSetup: Record "General Ledger Setup";

    begin
        GeneralLedgerSetup.Get();

        if DimSeq = 1 then
            DimensionCode := GeneralLedgerSetup."Shortcut Dimension 1 Code";
        if DimSeq = 2 then
            DimensionCode := GeneralLedgerSetup."Shortcut Dimension 2 Code";
        if DimSeq = 3 then
            DimensionCode := GeneralLedgerSetup."Shortcut Dimension 3 Code";
        if DimSeq = 4 then
            DimensionCode := GeneralLedgerSetup."Shortcut Dimension 4 Code";
        if DimSeq = 5 then
            DimensionCode := GeneralLedgerSetup."Shortcut Dimension 5 Code";
        if DimSeq = 6 then
            DimensionCode := GeneralLedgerSetup."Shortcut Dimension 6 Code";
        if DimSeq = 7 then
            DimensionCode := GeneralLedgerSetup."Shortcut Dimension 7 Code";
        if DimSeq = 8 then
            DimensionCode := GeneralLedgerSetup."Shortcut Dimension 8 Code";

        DimensionValue.Reset();
        exit(DimensionValue.Get(DimensionCode, ValueDim));
    end;

    procedure CreateDim(DimSeq: Integer; ValueDim: Code[20]): Boolean
    var
        DimensionValue: Record "Dimension Value";

    begin
        DimensionValue.Init();
        DimensionValue.Validate("Dimension Code", DimensionCode);
        DimensionValue.Validate(Code, ValueDim);
        DimensionValue.Name := ValueDim;
        DimensionValue."Dimension Value Type" := DimensionValue."Dimension Value Type"::Standard;
        if DimSeq in [1, 2] then
            DimensionValue."Global Dimension No." := DimSeq;

        DimensionValue.Insert(true);
    end;

    procedure CalcTax(FromPurchaseHeader: Record "Purchase Header"; FromRelease: Boolean): Boolean;
    var
        PurchaseHeader: Record "Purchase Header";
        TempTaxAmountLine: Record "CADBR Tax Amount Line" temporary;
        ModTaxAmountLine: Record "CADBR Modified Tax Amount Line";
        PPSetup: Record "Purchases & Payables Setup";
        TaxCalculate: codeunit "CADBR Tax Calculate";
        IPTaxes: Record "Integration Purchase";
        IRRFExist: Boolean;
    begin
        PPSetup.Get();
        Clear(IRRFExist);

        if PurchaseHeader.get(FromPurchaseHeader."Document Type"::Order, FromPurchaseHeader."No.") then begin

            TempTaxAmountLine.Reset();
            TempTaxAmountLine.DeleteAll();
            TaxCalculate.CalculatePurchDoc(PurchaseHeader, TempTaxAmountLine);

            IPTaxes.Reset();
            IPTaxes.SetRange("Document No.", FromPurchaseHeader."No.");
            if not IPTaxes.IsEmpty then begin

                IPTaxes.FindSet();
                repeat
                    TempTaxAmountLine.Reset();
                    TempTaxAmountLine.SetRange("Document Type", PurchaseHeader."Document Type");
                    TempTaxAmountLine.SetRange("Document No.", IPTaxes."Document No.");
                    TempTaxAmountLine.SetRange("Document Line No.", IPTaxes."Line No.");
                    if not TempTaxAmountLine.IsEmpty then begin
                        TempTaxAmountLine.FindSet();

                        ResetIpTaxesAmounts(IPTaxes);
                        TempTaxAmountLine.findset();
                        repeat
                            case TempTaxAmountLine."Tax Identification" of

                                TempTaxAmountLine."tax identification"::PCC:
                                    begin
                                        IPTaxes."Order CSRF Ret" := Abs(TempTaxAmountLine."Tax Amount") + Abs(TempTaxAmountLine."Payment/Receipt Amount");
                                        IPTaxes."Tax % Order CSRF Ret" := TempTaxAmountLine."Tax %";

                                        if (PPSetup."Activate Auxiliary Taxes") Then begin

                                            DeleteOldModTaxLine(PurchaseHeader, ModTaxAmountLine, IPTaxes, TempTaxAmountLine);
                                            InsertModTaxAmountLine(PurchaseHeader, TempTaxAmountLine, ModTaxAmountLine, IPTaxes);

                                        end;

                                    end;

                                TempTaxAmountLine."Tax identification"::"INSS Ret.":
                                    begin
                                        IPTaxes."Order INSS Ret" := Abs(TempTaxAmountLine."Tax Amount") + Abs(TempTaxAmountLine."Payment/Receipt Amount");
                                        IPTaxes."Tax % Order INSS Ret" := TempTaxAmountLine."Tax %";

                                        if (PPSetup."Activate Auxiliary Taxes") Then begin

                                            DeleteOldModTaxLine(PurchaseHeader, ModTaxAmountLine, IPTaxes, TempTaxAmountLine);
                                            InsertModTaxAmountLine(PurchaseHeader, TempTaxAmountLine, ModTaxAmountLine, IPTaxes);


                                        end;
                                    end;

                                TempTaxAmountLine."Tax identification"::"ISS Ret.":
                                    begin
                                        IPTaxes."Order ISS Ret" := Abs(TempTaxAmountLine."Tax Amount") + Abs(TempTaxAmountLine."Payment/Receipt Amount");
                                        IPTaxes."Tax % Order ISS Ret" := TempTaxAmountLine."Tax %";

                                        if (PPSetup."Activate Auxiliary Taxes") Then begin

                                            DeleteOldModTaxLine(PurchaseHeader, ModTaxAmountLine, IPTaxes, TempTaxAmountLine);
                                            InsertModTaxAmountLine(PurchaseHeader, TempTaxAmountLine, ModTaxAmountLine, IPTaxes);

                                        end;
                                    end;

                                TempTaxAmountLine."Tax identification"::PIS:
                                    begin
                                        IPTaxes."Order PIS Credit" := Abs(TempTaxAmountLine."Tax Amount") + Abs(TempTaxAmountLine."Payment/Receipt Amount");

                                    end;

                                TempTaxAmountLine."Tax identification"::COFINS:
                                    begin
                                        IPTaxes."Order Cofins Credit" := Abs(TempTaxAmountLine."Tax Amount") + Abs(TempTaxAmountLine."Payment/Receipt Amount");
                                    end;

                                TempTaxAmountLine."Tax identification"::IRRF:
                                    begin
                                        IRRFExist := true;

                                        if (IPTaxes.DIRF <> 0) and (TempTaxAmountLine."Payment/Receipt Base" <> 0) then begin

                                            if IPTaxes.DIRF <> IPTaxes."Order IRRF Ret" then begin
                                                TempTaxAmountLine."Tax Amount" := IPTaxes.DIRF;
                                                IPTaxes."Order DIRF Ret" := IPTaxes.DIRF;

                                                DeleteOldModTaxLine(PurchaseHeader, ModTaxAmountLine, IPTaxes, TempTaxAmountLine);
                                                InsertModTaxAmountLine(PurchaseHeader, TempTaxAmountLine, ModTaxAmountLine, IPTaxes);
                                            end;
                                        end else begin
                                            if Abs(TempTaxAmountLine."Tax Amount") <> 0 then
                                                IPTaxes."Order IRRF Ret" := Abs(TempTaxAmountLine."Tax Amount");
                                            if Abs(TempTaxAmountLine."Payment/Receipt Amount") <> 0 then
                                                IPTaxes."Order IRRF Ret" := Abs(TempTaxAmountLine."Payment/Receipt Amount");

                                            IPTaxes."Tax % Order IRRF Ret" := TempTaxAmountLine."Tax %";
                                        end;

                                        if (PPSetup."Activate Auxiliary Taxes") and (TempTaxAmountLine."Tax Base Amount" <> 0) then begin

                                            if IPTaxes."IRRF Ret" <> IPTaxes."Order IRRF Ret" then begin
                                                TempTaxAmountLine."Tax Amount" := IPTaxes."IRRF Ret";
                                                IPTaxes."Order DIRF Ret" := IPTaxes."IRRF Ret";

                                                DeleteOldModTaxLine(PurchaseHeader, ModTaxAmountLine, IPTaxes, TempTaxAmountLine);
                                                InsertModTaxAmountLine(PurchaseHeader, TempTaxAmountLine, ModTaxAmountLine, IPTaxes);
                                            end;
                                        end else begin

                                            if Abs(TempTaxAmountLine."Tax Amount") <> 0 then
                                                IPTaxes."Order IRRF Ret" := Abs(TempTaxAmountLine."Tax Amount");
                                            if Abs(TempTaxAmountLine."Payment/Receipt Amount") <> 0 then
                                                IPTaxes."Order IRRF Ret" := Abs(TempTaxAmountLine."Payment/Receipt Amount");
                                            IPTaxes."Tax % Order IRRF Ret" := TempTaxAmountLine."Tax %";

                                        end;

                                        if (IPTaxes."Order IRRF Ret" <> 0) and (IPTaxes.DIRF = 0) then
                                            IPTaxes."Order DIRF Ret" := 0;

                                        if (IPTaxes."Order IRRF Ret" <> 0) and (IPTaxes.DIRF <> 0) then begin
                                            IPTaxes."Order DIRF Ret" := IPTaxes."Order IRRF Ret";
                                            IPTaxes."Order IRRF Ret" := 0;
                                        end;


                                    end;

                            end;
                        until TempTaxAmountLine.next() = 0;

                    end;

                    if (IPTaxes.DIRF <> 0) then
                        IPTaxes."Order DIRF Ret" := IPTaxes.DIRF;

                    if IRRFExist = false then begin
                        IPTaxes."Order IRRF Ret" := IPTaxes.DIRF;
                        IPTaxes."Order Dirf Ret" := IPTaxes.DIRF;
                    end;

                    IPTaxes.Modify();

                until IPTaxes.Next() = 0;
            end;
        end;
        //if FromRelease then
        ConsolidateTaxes(PurchaseHeader);

    end;

    [TryFunction]
    procedure ValidatePostAcc(var FromPurchaseHeader: Record "Purchase Header")
    var
        PurchaseHeader: Record "Purchase Header";
        PurcLine: Record "Purchase Line";
        TempTaxAmountLine: Record "CADBR Tax Amount Line" temporary;
        TaxCalculate: codeunit "CADBR Tax Calculate";
        IntegrationPurchase: Record "Integration Purchase";
        IntPurStatus: Record "Integration Purchase";
        TaxPostingAccts: Record "CADBR Tax Posting Accounts";
        Text001: label 'A tax account setup for the tax %1 wasn''t found.';
        ExitBoo: Boolean;

    begin

        if PurchaseHeader.get(FromPurchaseHeader."Document Type"::Order, FromPurchaseHeader."No.") then begin
            PurchaseHeader."Posting Message" := '';

            TempTaxAmountLine.Reset();
            TempTaxAmountLine.DeleteAll();
            TaxCalculate.CalculatePurchDoc(PurchaseHeader, TempTaxAmountLine);

            PurcLine.Reset();
            PurcLine.SetRange("Document Type", PurchaseHeader."Document Type");
            PurcLine.SetRange("Document No.", PurchaseHeader."No.");
            if PurcLine.FindSet() then
                repeat
                    TempTaxAmountLine.Reset();
                    TempTaxAmountLine.SetRange("Document Type", PurchaseHeader."Document Type");
                    TempTaxAmountLine.SetRange("Document No.", PurchaseHeader."No.");
                    TempTaxAmountLine.SetRange("Document Line No.", PurcLine."Line No.");
                    if TempTaxAmountLine.FindSet() then begin
                        repeat
                            ExitBoo := false;

                            TempTaxAmountLine.SetAutoCalcFields("Posting - Payable Tax", "Posting - Expense", "Posting - Tax Credit");

                            if TempTaxAmountLine."Posting - Payable Tax" or TempTaxAmountLine."Posting - Expense" or TempTaxAmountLine."Posting - Tax Credit" then begin

                                if TempTaxAmountLine."Tax Jurisdiction Code" <> '' then begin
                                    TaxPostingAccts.Reset;
                                    TaxPostingAccts.SetRange("Tax Identification", TempTaxAmountLine."Tax Identification");
                                    TaxPostingAccts.SetRange("Filter Type", TaxPostingAccts."filter type"::Jurisdiction);
                                    TaxPostingAccts.SetRange("Filter Code", TempTaxAmountLine."Tax Jurisdiction Code");
                                    if TaxPostingAccts.FindFirst then
                                        ExitBoo := true;
                                end;

                                if PurchaseHeader."Pay-to Vendor No." <> '' then begin
                                    TaxPostingAccts.Reset;
                                    TaxPostingAccts.SetRange("Tax Identification", TempTaxAmountLine."Tax Identification");
                                    TaxPostingAccts.SetRange("Filter Type", TaxPostingAccts."filter type"::Vend);
                                    TaxPostingAccts.SetRange("Filter Code", PurchaseHeader."Pay-to Vendor No.");
                                    if TaxPostingAccts.FindFirst then
                                        ExitBoo := true;
                                end;

                                if PurcLine."Gen. Prod. Posting Group" <> '' then begin
                                    TaxPostingAccts.Reset;
                                    TaxPostingAccts.SetRange("Tax Identification", TempTaxAmountLine."Tax Identification");
                                    TaxPostingAccts.SetRange("Filter Type", TaxPostingAccts."filter type"::GenProd);
                                    TaxPostingAccts.SetRange("Filter Code", PurcLine."Gen. Prod. Posting Group");
                                    if TaxPostingAccts.FindFirst then
                                        ExitBoo := true;
                                end;
                                if PurcLine."Gen. Bus. Posting Group" <> '' then begin
                                    TaxPostingAccts.Reset;
                                    TaxPostingAccts.SetRange("Tax Identification", TempTaxAmountLine."Tax Identification");
                                    TaxPostingAccts.SetRange("Filter Type", TaxPostingAccts."filter type"::GenBus);
                                    TaxPostingAccts.SetRange("Filter Code", PurcLine."Gen. Bus. Posting Group");
                                    if TaxPostingAccts.FindFirst then
                                        ExitBoo := true;
                                end;

                                if ExitBoo = false then begin
                                    TaxPostingAccts.Reset;
                                    TaxPostingAccts.SetRange("Tax Identification", TempTaxAmountLine."Tax Identification");
                                    TaxPostingAccts.SetRange("Filter Type", TaxPostingAccts."filter type"::" ");
                                    TaxPostingAccts.SetRange("Filter Code", '');
                                    if not TaxPostingAccts.FindFirst then
                                        PurchaseHeader."Posting Message" := StrSubstNo(Text001, TaxPostingAccts.GetFilter(TaxPostingAccts."Tax Identification"));
                                end;

                            end;

                        until TempTaxAmountLine.next() = 0;

                    end;

                until PurcLine.Next() = 0;

            if PurchaseHeader."Posting Message" <> '' then
                FromPurchaseHeader."Posting Message" := PurchaseHeader."Posting Message";

        end;
    end;

    procedure ValidateCodMun(Var FromPurchaseHeader: Record "Purchase Header"): Boolean;
    var
        PurchaseHeader: Record "Purchase Header";
        TempTaxAmountLine: Record "CADBR Tax Amount Line" temporary;
        ModTaxAmountLine: Record "CADBR Modified Tax Amount Line";
        DocFiscal: Record "CADBR Fiscal Document Type";
        TaxCalculate: codeunit "CADBR Tax Calculate";
        ISSRetExist: Boolean;
        Vendor: Record Vendor;
        IntegrationPurchase: Record "Integration Purchase";
        IntPurStatus: Record "Integration Purchase";
        CodMunErr: label 'Specify Service Delivery City';
    begin
        Clear(ISSRetExist);

        Commit();

        if PurchaseHeader.get(FromPurchaseHeader."Document Type"::Order, FromPurchaseHeader."No.") then begin

            TempTaxAmountLine.Reset();
            TempTaxAmountLine.DeleteAll();
            TaxCalculate.CalculatePurchDoc(PurchaseHeader, TempTaxAmountLine);

            TempTaxAmountLine.Reset();
            TempTaxAmountLine.SetRange("Document Type", PurchaseHeader."Document Type");
            TempTaxAmountLine.SetRange("Document No.", FromPurchaseHeader."No.");
            if not TempTaxAmountLine.IsEmpty then begin
                TempTaxAmountLine.FindSet();

                repeat
                    case TempTaxAmountLine."Tax Identification" of

                        TempTaxAmountLine."Tax identification"::"ISS Ret.":
                            begin
                                ISSRetExist := true;
                            end;

                    end;
                until TempTaxAmountLine.next() = 0;
            end;


            if ISSRetExist then begin
                Vendor.Get(FromPurchaseHeader."Buy-from Vendor No.");
                if (Vendor."Territory Code" <> 'SP') and (FromPurchaseHeader."CADBR Service Delivery City" = '') then begin

                    IntegrationPurchase.Reset();
                    IntegrationPurchase.SetRange("Document No.", PurchaseHeader."No.");
                    if IntegrationPurchase.FindFirst() then begin

                        IntegrationPurchase."Posting Message" := CodMunErr;
                        IntegrationPurchase.Status := IntegrationPurchase.Status::"Data Error";
                        IntegrationPurchase.Modify();

                        IntPurStatus.Reset();
                        IntPurStatus.SetRange("Document No.", IntegrationPurchase."Document No.");
                        IntPurStatus.ModifyAll("Posting Message", IntegrationPurchase."Posting Message");
                        IntPurStatus.ModifyAll(Status, IntegrationPurchase.Status);

                        FromPurchaseHeader."Posting Message" := IntegrationPurchase."Posting Message";
                        FromPurchaseHeader.Status := PurchaseHeader.Status::Open;
                        //PurchaseHeader.Modify();

                        exit(false);
                    end;
                end;
            end;
        end else
            exit(true);
    end;

    procedure PurchRealse(var
                              IntPurchase: Record "Integration Purchase")
    var
        IntegrationPurchase: Record "Integration Purchase";
        intPurch: Record "Integration Purchase";
        PurchHeader: Record "Purchase Header";
        PurchLine: Record "Purchase Line";
    begin

        IntegrationPurchase.Reset();
        IntegrationPurchase.CopyFilters(IntPurchase);
        IntegrationPurchase.SetFilter(Status, '%1|%2|%3|%4|%5', IntegrationPurchase.Status::Imported,
                                                       IntegrationPurchase.Status::"Data Error",
                                                       IntegrationPurchase.Status::Created,
                                                       IntegrationPurchase.Status::Reviewed,
                                                       IntegrationPurchase.Status::Exported);
        if not IntegrationPurchase.IsEmpty then begin
            IntegrationPurchase.FindSet();
            repeat
                PurchHeader.Reset();
                PurchHeader.SetRange("No.", IntegrationPurchase."Document No.");
                if PurchHeader.Find('-') then
                    repeat

                        PurchHeader."Posting Message" := '';

                        if not StatusOrder(PurchHeader) then begin
                            IntegrationPurchase."Posting Message" := GetLastErrorText;
                            IntegrationPurchase.Modify();

                            intPurch.Reset();
                            intPurch.SetRange("Document No.", PurchHeader."No.");
                            intPurch.ModifyAll("Posting Message", PurchHeader."Posting Message");
                            intPurch.ModifyAll(Status, intPurch.Status::"Data Error");

                            PurchHeader."Posting Message" := IntegrationPurchase."Posting Message";
                            PurchHeader.Status := PurchHeader.Status::Open;
                            PurchHeader.Modify();

                            PurchLine.Reset();
                            PurchLine.SetRange("Document Type", PurchHeader."Document Type");
                            PurchLine.SetRange("Document No.", PurchHeader."No.");
                            PurchLine.ModifyAll("Status SBA", PurchLine."Status SBA"::Open);


                        end else begin

                            if PurchHeader."Posting Message" <> '' then begin

                                PurchHeader.Status := PurchHeader.Status::Open;
                                PurchHeader.Modify();

                                PurchLine.Reset();
                                PurchLine.SetRange("Document Type", PurchHeader."Document Type");
                                PurchLine.SetRange("Document No.", PurchHeader."No.");
                                PurchLine.ModifyAll("Status SBA", PurchLine."Status SBA"::Open);

                                intPurch.Reset();
                                intPurch.SetRange("Document No.", PurchHeader."No.");
                                intPurch.ModifyAll("Posting Message", PurchHeader."Posting Message");
                                intPurch.ModifyAll(Status, intPurch.Status::"Data Error");

                            end;
                        End;

                    until PurchHeader.Next() = 0;

            until IntegrationPurchase.Next() = 0;
        end;

    end;

    procedure UnderAnalysis(var IntPurchase: Record "Integration Purchase")
    var
        IntegrationPurchase: Record "Integration Purchase";
        intPurch: Record "Integration Purchase";
        PurchHeader: Record "Purchase Header";
        PurchLine: Record "Purchase Line";
        UserSetup: Record "User Setup";

    begin

        UserSetup.Reset();
        UserSetup.Get(USERID);
        if UserSetup."Review PO" then begin

            IntegrationPurchase.Reset();
            IntegrationPurchase.CopyFilters(IntPurchase);
            IntegrationPurchase.SetFilter(Status, '%1|%2|%3|%4|%5', IntegrationPurchase.Status::Imported,
                                                           IntegrationPurchase.Status::"Data Error",
                                                           IntegrationPurchase.Status::Created,
                                                           IntegrationPurchase.Status::Reviewed,
                                                           IntegrationPurchase.Status::Exported);
            if not IntegrationPurchase.IsEmpty then begin
                IntegrationPurchase.FindSet();
                repeat
                    PurchHeader.Reset();
                    PurchHeader.SetRange("No.", IntegrationPurchase."Document No.");
                    if PurchHeader.Find('-') then
                        repeat

                            PurchLine.reset;
                            PurchLine.SetRange("Document Type", PurchHeader."Document Type");
                            PurchLine.SetRange("Document No.", PurchHeader."No.");
                            PurchLine.Setrange(Type, PurchLine.Type::" ");
                            PurchLine.DeleteAll();

                            PurchHeader."Posting Message" := '';

                            if not StatusOrderUnderAnalysis(PurchHeader) then begin
                                IntegrationPurchase."Posting Message" := CopyStr(GetLastErrorText, 1, 200);
                                IntegrationPurchase.Modify();

                                intPurch.Reset();
                                intPurch.SetRange("Document No.", PurchHeader."No.");
                                intPurch.ModifyAll("Posting Message", PurchHeader."Posting Message");
                                intPurch.ModifyAll(Status, intPurch.Status::"Data Error");

                                PurchHeader."Posting Message" := IntegrationPurchase."Posting Message";
                                PurchHeader.Status := PurchHeader.Status::Open;
                                PurchHeader.Modify();

                            end else begin

                                if PurchHeader."Posting Message" <> '' then begin

                                    PurchHeader.Status := PurchHeader.Status::Open;
                                    PurchHeader.Modify();

                                    PurchLine.SetRange("Document Type", PurchHeader."Document Type");
                                    PurchLine.SetRange("Document No.", PurchHeader."No.");
                                    PurchLine.SetFilter(Type, '<>%1', PurchLine.Type::" ");
                                    PurchLine.ModifyAll("Status SBA", PurchLine."Status SBA"::Open);


                                    intPurch.Reset();
                                    intPurch.SetRange("Document No.", PurchHeader."No.");
                                    intPurch.ModifyAll("Posting Message", PurchHeader."Posting Message");
                                    intPurch.ModifyAll(Status, intPurch.Status::"Data Error");

                                end else begin

                                    intPurch.Reset();
                                    intPurch.SetRange("Document No.", PurchHeader."No.");
                                    intPurch.ModifyAll("Posting Message", PurchHeader."Posting Message");
                                    intPurch.ModifyAll(Status, intPurch.Status::Created);

                                    PurchHeader.Status := PurchHeader.Status::"Under Analysis";
                                    PurchHeader.Modify();
                                    PurchLine.Reset;

                                    PurchLine.SetRange("Document Type", PurchHeader."Document Type");
                                    PurchLine.SetRange("Document No.", PurchHeader."No.");
                                    PurchLine.SetFilter(Type, '<>%1', PurchLine.Type::" ");
                                    PurchLine.ModifyAll("Status SBA", PurchLine."Status SBA"::"Under Analysis");

                                end;

                            end;


                        until PurchHeader.Next() = 0;

                until IntegrationPurchase.Next() = 0;
            end;
        end else
            error('Usuario %1 sem Permissão para Revisar o Pedido', USERID);

    end;

    [TryFunction]
    procedure StatusOrderUnderAnalysis(Var PurchaseHeader: Record "Purchase Header")
    begin

        CalcTax(PurchaseHeader, false);

        ReleasePurcDocValidate(PurchaseHeader);

        if not ValidateCodMun(PurchaseHeader) then;

        if not ValidatePostAcc(PurchaseHeader) then;

    end;

    [TryFunction]
    procedure StatusOrder(PurchaseHeader: Record "Purchase Header")
    var
        PurchLine: Record "Purchase Line";
        intPurch: Record "Integration Purchase";
    begin
        PurchaseHeader.Status := PurchaseHeader.Status::Released;

        PurchLine.reset;
        PurchLine.SetRange("Document Type", PurchaseHeader."Document Type");
        PurchLine.SetRange("Document No.", PurchaseHeader."No.");
        PurchLine.Setrange(Type, PurchLine.Type::" ");
        PurchLine.DeleteAll();

        PurchaseHeader.Modify();

        PurchLine.Reset;
        PurchLine.SetRange("Document Type", PurchaseHeader."Document Type");
        PurchLine.SetRange("Document No.", PurchaseHeader."No.");
        PurchLine.ModifyAll("Status SBA", PurchLine."Status SBA"::Released);

        ReleasePurcDocValidate(PurchaseHeader);

        CalcTax(PurchaseHeader, false);
        if not ValidateCodMun(PurchaseHeader) then;

        if not ValidatePostAcc(PurchaseHeader) then;

        if PurchaseHeader."Posting Message" <> '' then begin
            PurchaseHeader.Status := PurchaseHeader.Status::Open;
            PurchaseHeader.Modify();

            intPurch.Reset();
            intPurch.SetRange("Document No.", PurchaseHeader."No.");
            intPurch.ModifyAll("Posting Message", PurchaseHeader."Posting Message");
            intPurch.ModifyAll(Status, intPurch.Status::"Data Error");

            PurchLine.Reset;
            PurchLine.SetRange("Document Type", PurchaseHeader."Document Type");
            PurchLine.SetRange("Document No.", PurchaseHeader."No.");
            PurchLine.ModifyAll("Status SBA", PurchLine."Status SBA"::Open);

        end;
    end;

    procedure PurchOpen(var IntPurchase: Record "Integration Purchase")
    var
        IntegrationPurchase: Record "Integration Purchase";
        PurchHeader: Record "Purchase Header";
        PurchLine: Record "Purchase Line";
        UserSetup: Record "User Setup";
    begin

        IntegrationPurchase.Reset();
        IntegrationPurchase.CopyFilters(IntPurchase);
        IntegrationPurchase.SetFilter(Status, '%1|%2|%3|%4|%5', IntegrationPurchase.Status::Imported,
                                                       IntegrationPurchase.Status::"Data Error",
                                                       IntegrationPurchase.Status::Created,
                                                       IntegrationPurchase.Status::Reviewed,
                                                       IntegrationPurchase.Status::Exported);
        if not IntegrationPurchase.IsEmpty then begin
            IntegrationPurchase.FindSet();
            repeat

                UserSetup.Reset();
                UserSetup.Get(USERID);
                if not UserSetup."Open PO" then
                    error('Usuario %1 sem Permissão para Reabrir o Pedido', USERID);

                PurchHeader.Reset();
                PurchHeader.SetRange("No.", IntegrationPurchase."Document No.");
                if PurchHeader.Find('-') then
                    repeat
                        PurchHeader.Status := PurchHeader.Status::Open;
                        PurchHeader.Modify();

                        PurchLine.Reset;
                        PurchLine.SetRange("Document Type", PurchHeader."Document Type");
                        PurchLine.SetRange("Document No.", PurchHeader."No.");
                        PurchLine.SetFilter(Type, '<>%1', PurchLine.Type::" ");
                        PurchLine.ModifyAll("Status SBA", PurchLine."Status SBA"::Open);

                    until PurchHeader.Next() = 0;

                if PurchHeader."Posting Message" <> '' then begin
                    IntegrationPurchase.Status := IntegrationPurchase.Status::"Data Error";
                    IntegrationPurchase.Modify();
                end else begin
                    IntegrationPurchase.Status := IntegrationPurchase.Status::Created;
                    IntegrationPurchase.Modify();
                end;

            until IntegrationPurchase.Next() = 0;
        end;

    end;

    local procedure ConsolidateTaxes(PurchaseHeader: Record "Purchase Header")
    var
        IPOrder: Record "Integration Purchase";
        SumTaxes: array[7] of Decimal;
    begin
        if PurchaseHeader."Document Type" <> PurchaseHeader."Document Type"::Order then
            exit;
        IPOrder.Reset();
        IPOrder.SetRange("Document No.", PurchaseHeader."No.");
        if not IPOrder.IsEmpty then begin
            IPOrder.FindSet();
            repeat
                SumTaxes[1] += IPOrder."Order IRRF Ret";
                SumTaxes[2] += IPOrder."Order CSRF Ret";
                SumTaxes[3] += IPOrder."Order INSS Ret";
                SumTaxes[4] += IPOrder."Order ISS Ret";
                SumTaxes[5] += IPOrder."Order PIS Credit";
                SumTaxes[6] += IPOrder."Order Cofins Credit";
                SumTaxes[7] += IPOrder."Order DIRF Ret";

            until IPOrder.Next() = 0;
        end;

        IPOrder.Reset();
        IPOrder.SetRange("Document No.", PurchaseHeader."No.");
        if not IPOrder.IsEmpty then begin
            IPOrder.FindSet();
            IPOrder.ModifyAll("Order IRRF Ret", SumTaxes[1]);
            IPOrder.ModifyAll("Order CSRF Ret", SumTaxes[2]);
            IPOrder.ModifyAll("Order INSS Ret", SumTaxes[3]);
            IPOrder.ModifyAll("Order ISS Ret", SumTaxes[4]);
            IPOrder.ModifyAll("Order PIS Credit", SumTaxes[5]);
            IPOrder.ModifyAll("Order Cofins Credit", SumTaxes[6]);
            IPOrder.ModifyAll("Order DIRF Ret", SumTaxes[7]);
        end;
    end;

    local procedure InsertPurchaseBuffer(var IntegrationPurchase: Record "Integration Purchase")
    begin
        IntegrationPurchaseBuffer.Init();
        IntegrationPurchaseBuffer."Excel File Name" := IntegrationPurchase."Excel File Name";
        IntegrationPurchaseBuffer."Document No." := IntegrationPurchase."Document No.";
        if IntegrationPurchaseBuffer.Insert() then;

        Commit();

    end;

    local procedure FilterRecordToCreate(var RecordToCreate: Record "Integration Purchase")
    begin
        RecordToCreate.Reset();
        RecordToCreate.SetRange("Excel File Name", IntegrationPurchaseBuffer."Excel File Name");
        RecordToCreate.SetRange("Document No.", IntegrationPurchaseBuffer."Document No.");
    end;

    local procedure FilterRecordToCreateErrorMessage(var RecordToCreate: Record "Integration Purchase")
    begin
        RecordToCreate.Reset();
        RecordToCreate.SetRange("Excel File Name", IntegrationPurchaseBuffer."Excel File Name");
        RecordToCreate.SetRange("Document No.", IntegrationPurchaseBuffer."Document No.");
        RecordToCreate.SetFilter("Posting Message", '%1', '');
    end;

    local procedure DimFilterUsgaap(var IntegrationPurchase: Record "Integration Purchase"; var Usgaap: Record "From/To US GAAP"): Boolean
    begin
        Usgaap.SetRange("Dimension 1", IntegrationPurchase."Shortcut Dimension 1 Code");
        Usgaap.SetRange("Dimension 2", IntegrationPurchase."Shortcut Dimension 2 Code");
        Usgaap.SetRange("Dimension 3", IntegrationPurchase."Shortcut Dimension 3 Code");
        Usgaap.SetRange("Dimension 4", IntegrationPurchase."Shortcut Dimension 4 Code");
        Usgaap.SetRange("Dimension 5", IntegrationPurchase."Shortcut Dimension 5 Code");
        Usgaap.SetRange("Dimension 6", IntegrationPurchase."Shortcut Dimension 6 Code");
    end;

    local procedure CheckMunicipios(var IntegrationPurchase: Record "Integration Purchase")
    var
        CADBRMunicipio: Record "CADBR Municipio";
        MunicipioErr: Label 'The Municipio %1, does not exist on %2.';
        MunicipioPostCodeErr: Label 'The Municipio %1 found trough Post Code, does not exist on %2.';
        MunicipioCityErr: Label 'The Municipio %1 found trough City, does not exist on %2.';
        CEPErr: Label 'The CEP %1 does not exist.';
        CityErr: Label 'The city %1 does not exist';
        MultiCEPErr: Label 'There are more than 1 Municipio for post code %1.';
        MultiCityErr: Label 'There are more than 1 Municipio for city %1.';
        LastMunicipioByCEP: Text;
        CountMunicipioByCEP: Integer;
        LastMunicipioByCity: Text;
        CountMunicipioByCity: Integer;
        INTPostCode: Query INTPostCode;
        INTMunicipioByCity: Query INTMunicipioByCity;
        RunPostCode: Boolean;
        RunCity: Boolean;
    begin
        if IntegrationPurchase."Municipio Code" = '' then begin
            if IntegrationPurchase."Post Code" <> '' then begin

                Clear(LastMunicipioByCEP);
                Clear(CountMunicipioByCEP);
                RunPostCode := true;
                INTPostCode.SetRange(CEP, IntegrationPurchase."Post Code");
                INTPostCode.SetFilter(Municipio, '<>%1', '0');
                INTPostCode.Open();
                while INTPostCode.Read() and (CountMunicipioByCEP < 3) do begin
                    if LastMunicipioByCEP <> INTPostCode.Municipio then begin
                        LastMunicipioByCEP := INTPostCode.Municipio;
                        CountMunicipioByCEP += 1;
                        if CountMunicipioByCEP = 1 then
                            IntegrationPurchase."Municipio Code" := INTPostCode.Municipio
                        else
                            IntegrationPurchase."Municipio Code" := '';
                    end;
                end;

                INTPostCode.Close();
            end;
        end;

        if IntegrationPurchase."Municipio Code" = '' then begin
            if IntegrationPurchase."Local Service Provision" <> '' then begin

                Clear(LastMunicipioByCity);
                Clear(CountMunicipioByCity);
                RunCity := true;
                INTMunicipioByCity.SetRange(City, IntegrationPurchase."Local Service Provision");
                INTMunicipioByCity.Open();
                while INTMunicipioByCity.Read() and (CountMunicipioByCity < 3) do begin
                    if LastMunicipioByCity <> INTMunicipioByCity.Municipio then begin
                        LastMunicipioByCity := INTMunicipioByCity.Municipio;
                        CountMunicipioByCity += 1;
                        if CountMunicipioByCity = 1 then
                            IntegrationPurchase."Municipio Code" := INTMunicipioByCity.Municipio
                        else
                            IntegrationPurchase."Municipio Code" := '';
                    end;
                end;
                INTMunicipioByCity.Close();

            end;
        end;

        if IntegrationPurchase."Municipio Code" <> '' then begin
            if not CADBRMunicipio.Get(IntegrationPurchase."Municipio Code") then begin
                if IntegrationPurchase."Post Code" <> '' then begin
                    if RunPostCode then begin
                        if CountMunicipioByCEP = 0 then
                            IntegrationPurchase."Posting Message" := MergePostingMessage(IntegrationPurchase."Posting Message", StrSubstNo(CEPErr, IntegrationPurchase."Post Code"));
                        if CountMunicipioByCEP > 1 then
                            IntegrationPurchase."Posting Message" := MergePostingMessage(IntegrationPurchase."Posting Message", StrSubstNo(MultiCEPErr, IntegrationPurchase."Post Code"));
                    end;
                end;
                if IntegrationPurchase."Local Service Provision" <> '' then begin
                    if RunCity then begin
                        if CountMunicipioByCity = 0 then
                            IntegrationPurchase."Posting Message" := MergePostingMessage(IntegrationPurchase."Posting Message", StrSubstNo(CityErr, IntegrationPurchase."Local Service Provision"));
                        if CountMunicipioByCity > 1 then
                            IntegrationPurchase."Posting Message" := MergePostingMessage(IntegrationPurchase."Posting Message", StrSubstNo(MultiCityErr, IntegrationPurchase."Local Service Provision"));
                    end;
                end;
                if RunCity then
                    IntegrationPurchase."Posting Message" := MergePostingMessage(IntegrationPurchase."Posting Message", StrSubstNo(MunicipioPostCodeErr, IntegrationPurchase."Municipio Code", CADBRMunicipio.TableCaption))
                else
                    if RunPostCode then
                        IntegrationPurchase."Posting Message" := MergePostingMessage(IntegrationPurchase."Posting Message", StrSubstNo(MunicipioCityErr, IntegrationPurchase."Municipio Code", CADBRMunicipio.TableCaption))
                    else
                        IntegrationPurchase."Posting Message" := MergePostingMessage(IntegrationPurchase."Posting Message", StrSubstNo(MunicipioErr, IntegrationPurchase."Municipio Code", CADBRMunicipio.TableCaption));

            end;
        end;
    end;

    local procedure CheckAccount(var IntegrationPurchase: Record "Integration Purchase"; var Vendor: Record Vendor; var Item: Record Item)
    var
        GeneralPostingSetup: Record "General Posting Setup";
        GLAccount: Record "G/L Account";
        Usgaap: Record "From/To US GAAP";
        GenProdPostGroupExistErr: Label 'Gen. Prod. Posting Group % does not exist.';
    begin
        IntegrationPurchase."Gen. Prod. Posting Group" := '';

        Usgaap.Reset();
        Usgaap.SetRange("US GAAP", IntegrationPurchase."Item No.");
        DimFilterUsgaap(IntegrationPurchase, Usgaap);
        if not Usgaap.IsEmpty then begin
            Usgaap.FindSet();
            if Usgaap."BR GAAP" <> Item."Gen. Prod. Posting Group" then
                if GeneralPostingSetup.Get(Vendor."Gen. Bus. Posting Group", Usgaap."BR GAAP") then
                    IntegrationPurchase."Gen. Prod. Posting Group" := Usgaap."BR GAAP"
                else
                    IntegrationPurchase."Posting Message" := MergePostingMessage(IntegrationPurchase."Posting Message", StrSubstNo(GenProdPostGroupExistErr, Usgaap."BR GAAP"));

        end else begin
            Usgaap.Reset();
            Usgaap.SetRange("US GAAP", IntegrationPurchase."Item No.");
            if not Usgaap.IsEmpty then begin
                Usgaap.FindSet();
                if Usgaap."BR GAAP" <> Item."Gen. Prod. Posting Group" then
                    if GeneralPostingSetup.Get(Vendor."Gen. Bus. Posting Group", Usgaap."BR GAAP") then
                        IntegrationPurchase."Gen. Prod. Posting Group" := Usgaap."BR GAAP"
                    else
                        IntegrationPurchase."Posting Message" := MergePostingMessage(IntegrationPurchase."Posting Message", StrSubstNo(GenProdPostGroupExistErr, Usgaap."BR GAAP"));


            end else begin
                GLAccount.Reset();
                GLAccount.SetCurrentKey("No. 2");
                GLAccount.SetRange("No. 2", IntegrationPurchase."Item No.");
                if not GLAccount.IsEmpty then begin
                    GLAccount.FindSet();
                    if GLAccount."No." <> Item."Gen. Prod. Posting Group" then
                        if GeneralPostingSetup.Get(Vendor."Gen. Bus. Posting Group", GLAccount."No.") then
                            IntegrationPurchase."Gen. Prod. Posting Group" := GLAccount."No."
                        else
                            IntegrationPurchase."Posting Message" := MergePostingMessage(IntegrationPurchase."Posting Message", StrSubstNo('Gen. Bus. Posting Group % Does not exist.', GLAccount."No."));

                end;
            end;
        end;
    end;

    local procedure MergePostingMessage(OldMessage: text; AddMessage: text): Text
    var
        IntegrationPurchase: Record "Integration Purchase";
    begin
        if OldMessage <> '' then
            exit(CopyStr(AddMessage + '|' + OldMessage, 1, MaxStrLen(IntegrationPurchase."Posting Message")))
        else
            exit(CopyStr(AddMessage, 1, MaxStrLen(IntegrationPurchase."Posting Message")));
    end;

    procedure CalcTaxFRomPurchaseOrder(PurchaseHeader: Record "Purchase Header"; PurchaseLine: Record "Purchase Line"): Boolean;
    var
        IntegrationPurchase: Record "Integration Purchase";
        TempTaxAmountLine: Record "CADBR Tax Amount Line" temporary;
        ModTaxAmountLine: Record "CADBR Modified Tax Amount Line";
        TaxCalculate: codeunit "CADBR Tax Calculate";
    begin
        IF IntegrationPurchase.GET(PurchaseLine."Document No.", PurchaseLine."Line No.") THEN begin
            TempTaxAmountLine.Reset();
            TempTaxAmountLine.DeleteAll();
            TaxCalculate.CalculatePurchDoc(PurchaseHeader, TempTaxAmountLine);

            TempTaxAmountLine.Reset();
            TempTaxAmountLine.SetRange("Tax Identification", TempTaxAmountLine."tax identification"::IRRF);
            TempTaxAmountLine.SetRange("Document Line No.", IntegrationPurchase."Line No.");
            if TempTaxAmountLine.FindFirst() then begin
                IntegrationPurchase."Order IRRF Ret" := Abs(TempTaxAmountLine."Tax Amount");
                IntegrationPurchase."Tax % Order IRRF Ret" := TempTaxAmountLine."Tax %";

                TempTaxAmountLine."Tax Amount" := IntegrationPurchase.DIRF;

                if ModTaxAmountLine.Get(39, ModTaxAmountLine."Document Type"::Order, PurchaseHeader."No.",
                    IntegrationPurchase."Line No.", PurchaseLine."Tax Area Code", TempTaxAmountLine."Tax Jurisdiction Code") then
                    ModTaxAmountLine.Delete();

                ModTaxAmountLine.Reset;
                ModTaxAmountLine.SetRange("Table ID", Database::"Purchase Line");
                ModTaxAmountLine.SetRange("Document Type", ModTaxAmountLine."Document Type"::Order);
                ModTaxAmountLine.SetRange("Document No.", PurchaseHeader."No.");
                ModTaxAmountLine.SetRange("Document Line No.", PurchaseLine."Line No.");
                //  ModTaxAmountLine.SetRange("Tax Area Code", PurchaseLine."Tax Area Code");
                if not ModTaxAmountLine.IsEmpty then
                    ModTaxAmountLine.DeleteAll();

                ModTaxAmountLine.Init();
                ModTaxAmountLine."Table ID" := 39;
                ModTaxAmountLine."Document Type" := ModTaxAmountLine."Document Type"::Order;
                ModTaxAmountLine."Document No." := PurchaseHeader."No.";
                ModTaxAmountLine."Document Line No." := IntegrationPurchase."Line No.";
                ModTaxAmountLine."Tax Amount" := IntegrationPurchase.DIRF;
                ModTaxAmountLine."Tax Base Amount" := TempTaxAmountLine."Tax Base Amount";
                ModTaxAmountLine."Payment/Receipt Base" := TempTaxAmountLine."Payment/Receipt Base";
                ModTaxAmountLine."Exempt Basis Amount" := TempTaxAmountLine."Exempt Basis Amount";
                ModTaxAmountLine."Others Basis Amount" := TempTaxAmountLine."Others Basis Amount";
                ModTaxAmountLine."Tax %" := TempTaxAmountLine."Tax %";
                ModTaxAmountLine."Tax Area Code" := PurchaseLine."Tax Area Code";
                ModTaxAmountLine."Tax Base Amount" := TempTaxAmountLine."Tax Base Amount";
                ModTaxAmountLine."Tax Identification" := TempTaxAmountLine."Tax Identification";
                ModTaxAmountLine."Tax Jurisdiction Code" := TempTaxAmountLine."Tax Jurisdiction Code";
                ModTaxAmountLine."Tax Posting Code" := TempTaxAmountLine."Tax Posting Code";
                ModTaxAmountLine."User ID" := UserId;
                ModTaxAmountLine.Insert();

                if (IntegrationPurchase."Order IRRF Ret" <> 0) and (IntegrationPurchase.DIRF = 0) then
                    IntegrationPurchase."Order DIRF Ret" := 0;

                if (IntegrationPurchase."Order IRRF Ret" <> 0) and (IntegrationPurchase.DIRF <> 0) then begin
                    IntegrationPurchase."Order DIRF Ret" := IntegrationPurchase."Order IRRF Ret";
                    IntegrationPurchase."Order IRRF Ret" := 0;
                end;

            end else begin

                IntegrationPurchase."Order IRRF Ret" := 0;
                IntegrationPurchase."Order Dirf Ret" := 0;
            end;

            IntegrationPurchase."Order CSRF Ret" := 0;
            IntegrationPurchase."Order IRRF Ret" := 0;
            IntegrationPurchase."Order INSS Ret" := 0;
            IntegrationPurchase."Order ISS Ret" := 0;
            IntegrationPurchase."Order INSS Ret" := 0;
            IntegrationPurchase."Order Cofins Credit" := 0;
            IntegrationPurchase."Order PIS Credit" := 0;
            IntegrationPurchase."Tax % Order CSRF Ret" := 0;
            IntegrationPurchase."Tax % Order DIRF Ret" := 0;
            IntegrationPurchase."Tax % Order INSS Ret" := 0;
            IntegrationPurchase."Tax % Order IRRF Ret" := 0;
            IntegrationPurchase."Tax % Order ISS Ret" := 0;

            TempTaxAmountLine.Reset();
            TempTaxAmountLine.SetRange("Tax Identification", TempTaxAmountLine."tax identification"::PCC);
            TempTaxAmountLine.SetRange("Document Line No.", IntegrationPurchase."Line No.");
            if TempTaxAmountLine.FindFirst() then begin
                IntegrationPurchase."Order CSRF Ret" := Abs(TempTaxAmountLine."Tax Amount");
                IntegrationPurchase."Tax % Order CSRF Ret" := TempTaxAmountLine."Tax %";
            end;

            TempTaxAmountLine.Reset();
            TempTaxAmountLine.SetRange("Tax Identification", TempTaxAmountLine."tax identification"::"INSS Ret.");
            TempTaxAmountLine.SetRange("Document Line No.", IntegrationPurchase."Line No.");
            if TempTaxAmountLine.FindFirst() then begin
                IntegrationPurchase."Order INSS Ret" := Abs(TempTaxAmountLine."Tax Amount");
                IntegrationPurchase."Tax % Order INSS Ret" := TempTaxAmountLine."Tax %";
            end;

            TempTaxAmountLine.Reset();
            TempTaxAmountLine.SetRange("Tax Identification", TempTaxAmountLine."tax identification"::"ISS Ret.");
            TempTaxAmountLine.SetRange("Document Line No.", IntegrationPurchase."Line No.");
            if TempTaxAmountLine.FindFirst() then begin
                IntegrationPurchase."Order ISS Ret" := Abs(TempTaxAmountLine."Tax Amount");
                IntegrationPurchase."Tax % Order ISS Ret" := TempTaxAmountLine."Tax %";
            end;

            TempTaxAmountLine.Reset();
            TempTaxAmountLine.SetRange("Tax Identification", TempTaxAmountLine."tax identification"::PIS);
            TempTaxAmountLine.SetRange("Document Line No.", IntegrationPurchase."Line No.");
            if TempTaxAmountLine.FindFirst() then
                IntegrationPurchase."Order PIS Credit" := Abs(TempTaxAmountLine."Tax Amount");

            TempTaxAmountLine.Reset();
            TempTaxAmountLine.SetRange("Tax Identification", TempTaxAmountLine."tax identification"::COFINS);
            TempTaxAmountLine.SetRange("Document Line No.", IntegrationPurchase."Line No.");
            if TempTaxAmountLine.FindFirst() then
                IntegrationPurchase."Order Cofins Credit" := Abs(TempTaxAmountLine."Tax Amount");

            IntegrationPurchase.Modify();

        end;

    end;

    local procedure ResetIpTaxesAmounts(var IPTaxes: Record "Integration Purchase")
    begin
        IPTaxes."Order CSRF Ret" := 0;
        IPTaxes."Order IRRF Ret" := 0;
        IPTaxes."Order INSS Ret" := 0;
        IPTaxes."Order ISS Ret" := 0;
        IPTaxes."Order INSS Ret" := 0;
        IPTaxes."Order Cofins Credit" := 0;
        IPTaxes."Order PIS Credit" := 0;

        IPTaxes."Tax % Order CSRF Ret" := 0;
        IPTaxes."Tax % Order DIRF Ret" := 0;
        IPTaxes."Tax % Order INSS Ret" := 0;
        IPTaxes."Tax % Order IRRF Ret" := 0;
        IPTaxes."Tax % Order ISS Ret" := 0;

    end;

    local procedure InsertModTaxAmountLine(var PurchaseHeader: Record "Purchase Header"; var TempTaxAmountLine: Record "CADBR Tax Amount Line" temporary; var ModTaxAmountLine: Record "CADBR Modified Tax Amount Line"; var IPTaxes: Record "Integration Purchase")
    var
        TaxProgression: Record "CADBR Tax Progression Table";
        PurchLine: Record "Purchase Line";
        Qtdline: Integer;

    begin

        TaxProgression.Reset();
        TaxProgression.SetRange("Tax Jurisdiction Code", TempTaxAmountLine."Tax Jurisdiction Code");
        //TaxProgression.setfilter("Tax %", '<>%1', 0);
        TaxProgression.SetFilter("Min Tax Base", '..%1', IPTaxes.DIRF);
        if TaxProgression.FindLast() then;

        PurchLine.Reset();
        PurchLine.SetRange("Document Type", PurchaseHeader."Document Type");
        PurchLine.SetRange("Document No.", PurchaseHeader."No.");
        Qtdline := PurchLine.Count();


        ModTaxAmountLine.Init();
        ModTaxAmountLine."Table ID" := 39;
        ModTaxAmountLine."Document Type" := ModTaxAmountLine."Document Type"::Order;
        ModTaxAmountLine."Document No." := PurchaseHeader."No.";
        ModTaxAmountLine."Document Line No." := IPTaxes."Line No.";

        ModTaxAmountLine."Payment/Receipt Base" := TempTaxAmountLine."Payment/Receipt Base";
        ModTaxAmountLine."Tax Base Amount" := TempTaxAmountLine."Tax Base Amount";
        ModTaxAmountLine."Exempt Basis Amount" := TempTaxAmountLine."Exempt Basis Amount";
        ModTaxAmountLine."Others Basis Amount" := TempTaxAmountLine."Others Basis Amount";

        if TempTaxAmountLine."Tax %" <> 0 then
            ModTaxAmountLine."Tax %" := TempTaxAmountLine."Tax %"
        else
            ModTaxAmountLine."Tax %" := TaxProgression."Tax %";

        if TempTaxAmountLine."tax identification" = TempTaxAmountLine."tax identification"::PCC then begin
            ModTaxAmountLine."Payment/Receipt Amount" := IPTaxes."CSRF Ret" / Qtdline;
            IPTaxes."Tax % Order CSRF Ret" := ModTaxAmountLine."Tax %";
        end;

        if TempTaxAmountLine."tax identification" = TempTaxAmountLine."tax identification"::"INSS Ret." then begin
            ModTaxAmountLine."Tax Amount" := (IPTaxes."INSS Ret" / Qtdline);
            IPTaxes."Tax % Order INSS Ret" := ModTaxAmountLine."Tax %";
        end;

        if TempTaxAmountLine."tax identification" = TempTaxAmountLine."tax identification"::"ISS Ret." then begin
            ModTaxAmountLine."Tax Amount" := (IPTaxes."ISS Ret" / Qtdline);
            IPTaxes."Tax % Order ISS Ret" := ModTaxAmountLine."Tax %";
        end;

        if TempTaxAmountLine."tax identification" = TempTaxAmountLine."tax identification"::IRRF then begin

            If IPTaxes."IRRF Ret" <> 0 then begin
                ModTaxAmountLine."Tax Amount" := (IPTaxes."IRRF Ret" / Qtdline);
                IPTaxes."Tax % Order IRRF Ret" := ModTaxAmountLine."Tax %";

            end;

            if IPTaxes.DIRF <> 0 then begin
                ModTaxAmountLine."Payment/Receipt Amount" := IPTaxes.DIRF;
                IPTaxes."Tax % Order DIRF Ret" := ModTaxAmountLine."Tax %";
            end;
        end;

        if ModTaxAmountLine."Payment/Receipt Amount" = 0 then
            ModTaxAmountLine."Payment/Receipt Base" := 0;

        if ModTaxAmountLine."Tax Amount" = 0 then begin
            ModTaxAmountLine."Tax Base Amount" := 0;
            ModTaxAmountLine."Exempt Basis Amount" := 0;
            ModTaxAmountLine."Others Basis Amount" := 0;
            // ModTaxAmountLine."Tax %" := 0;
        end;

        ModTaxAmountLine."Tax Area Code" := PurchaseHeader."Tax Area Code";
        ModTaxAmountLine."Tax Base Amount" := TempTaxAmountLine."Tax Base Amount";
        ModTaxAmountLine."Tax Identification" := TempTaxAmountLine."Tax Identification";
        ModTaxAmountLine."Tax Jurisdiction Code" := TempTaxAmountLine."Tax Jurisdiction Code";
        ModTaxAmountLine."Tax Posting Code" := TempTaxAmountLine."Tax Posting Code";
        ModTaxAmountLine."User ID" := UserId;
        ModTaxAmountLine.Insert();
    end;

    local procedure DeleteOldModTaxLine(var PurchaseHeader: Record "Purchase Header"; var ModTaxAmountLine: Record "CADBR Modified Tax Amount Line"; var IPTaxes: Record "Integration Purchase"; var TempTaxAmountLine: Record "CADBR Tax Amount Line" temporary)
    begin
        ModTaxAmountLine.Reset;
        ModTaxAmountLine.SetRange("Table ID", Database::"Purchase Line");
        ModTaxAmountLine.SetRange("Document Type", ModTaxAmountLine."Document Type"::Order);
        ModTaxAmountLine.SetRange("Document No.", PurchaseHeader."No.");
        ModTaxAmountLine.SetRange("Document Line No.", IPTaxes."Line No.");
        ModTaxAmountLine.SetRange("Tax Area Code", TempTaxAmountLine."Tax Area Code");
        ModTaxAmountLine.SetRange("Tax Jurisdiction Code", TempTaxAmountLine."Tax Jurisdiction Code");
        if not ModTaxAmountLine.IsEmpty then
            ModTaxAmountLine.DeleteAll();
    end;

    local procedure MarkAsPosted(var IntegrationPurchase: Record "Integration Purchase"; var IntPurchase: Record "Integration Purchase")
    begin
        //IntPurchase.Reset();
        //IntPurchase.SetRange("Document No.", IntegrationPurchase."document No.");
        //if not IntPurchase.IsEmpty then begin
        //    IntPurchase.FindSet();
        //    IntPurchase.ModifyAll(Status, IntPurchase.Status::Posted);
        //end;
    end;

    local procedure MarkAsNotPosted(var IntegrationPurchase: Record "Integration Purchase"; var IntPurchase: Record "Integration Purchase")
    begin
        //IntPurchase.Reset();
        //IntPurchase.SetRange("Document No.", IntegrationPurchase."document No.");
        //if not IntPurchase.IsEmpty then begin
        //    IntPurchase.FindSet();
        ////   IntPurchase.ModifyAll(Status, IntPurchase.Status::"Data Error");
        //   IntPurchase.ModifyAll("Posting Message", CopyStr('Error Posting - ' + GetLastErrorText, 1, MaxStrLen(IntPurchase."Posting Message")));
        // end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnBeforePostPurchaseDoc', '', false, false)]
    local procedure OnBeforePostPurchaseDocPurchasePost(var HideProgressWindow: Boolean)
    begin
        HideProgressWindow := booHideDialog;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnBeforeCheckHeaderPostingType', '', false, false)]
    local procedure OnBeforeCheckHeaderPostingTypePurchasePost(var IsHandled: Boolean)
    begin
        IsHandled := booIsHandled;
    end;

    // [EventSubscriber(ObjectType::Table, database::"Purchase Header", 'OnValidateVATBaseAmountPercOnBeforeUpdatePurchAmountLines', '', false, false)]
    // local procedure OnValidateVATBaseAmountPercOnBeforeUpdatePurchAmountLines(var IsHandled: Boolean)
    // begin
    //     IsHandled := true;
    // end;


    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnAfterModifyEvent', '', false, false)]
    local procedure OnAfterModifyEvent_PurchaseLine(RunTrigger: Boolean; var Rec: Record "Purchase Line"; var xRec: Record "Purchase Line")
    var
        PurchaseHeader: Record "Purchase Header";
        IntegrationPurchase: Record "Integration Purchase";
        CADBRModifiedTaxAmountLine: Record "CADBR Modified Tax Amount Line";
    begin
        if not RunTrigger then
            exit;

        if Rec."Document Type" <> Rec."Document Type"::Order then
            exit;

        if Rec."Tax Area Code" = xRec."Tax Area Code" then
            exit;

        if PurchaseHeader.Get(Rec."Document Type", Rec."Document No.") then begin
            if PurchaseHeader.DIRF <> 0 then begin
                CalcTaxFRomPurchaseOrder(PurchaseHeader, Rec);
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnAfterAssignItemValues', '', false, false)]
    local procedure OnAfterAssignItemValues_PurchaseLine(var PurchLine: Record "Purchase Line"; Item: Record Item; CurrentFieldNo: Integer; PurchHeader: Record "Purchase Header")
    var

    begin
        PurchLine."CADBR Service Code" := Item."CADBR Service Code";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Release Purchase Document", 'OnAfterManualReleasePurchaseDoc', '', false, false)]
    local procedure OnBeforeReleasePurchaseDoc_CodeunitReleasePurchaseDocument(var PurchaseHeader: Record "Purchase Header")
    var
        IntegrationPurchase: Record "Integration Purchase";
        intPurch: Codeunit "Integration Purchase";
        UserSetup: Record "User Setup";
        PurchLine: Record "Purchase Line";
    begin
        if PurchaseHeader."Document Type" <> PurchaseHeader."Document Type"::Order then
            exit;

        UserSetup.Reset();
        UserSetup.Get(USERID);
        if UserSetup."Release PO" then begin

            PurchaseHeader."Posting Message" := '';
            PurchaseHeader.Modify();

            PurchLine.reset;
            PurchLine.SetRange("Document Type", PurchaseHeader."Document Type");
            PurchLine.SetRange("Document No.", PurchaseHeader."No.");
            PurchLine.Setrange(Type, PurchLine.Type::" ");
            PurchLine.DeleteAll();

            intPurch.ReleasePurcDocValidate(PurchaseHeader);

            CalcTax(PurchaseHeader, true);
            if not ValidateCodMun(PurchaseHeader) then;
            if not ValidatePostAcc(PurchaseHeader) then;

            if PurchaseHeader."Posting Message" <> '' then begin
                PurchaseHeader.Status := PurchaseHeader.Status::Open;
                PurchaseHeader.Modify();

                PurchLine.Reset;
                PurchLine.SetRange("Document Type", PurchaseHeader."Document Type");
                PurchLine.SetRange("Document No.", PurchaseHeader."No.");
                PurchLine.SetFilter(Type, '<>%1', PurchLine.Type::" ");
                PurchLine.ModifyAll("Status SBA", PurchLine."Status SBA"::Open);

                IntegrationPurchase.Reset();
                IntegrationPurchase.SetRange("Document No.", PurchaseHeader."No.");
                IntegrationPurchase.ModifyAll("Posting Message", PurchaseHeader."Posting Message");
                IntegrationPurchase.ModifyAll(Status, IntegrationPurchase.Status::"Data Error");

            end else begin

                IntegrationPurchase.Reset();
                IntegrationPurchase.SetRange("Document No.", PurchaseHeader."No.");
                IntegrationPurchase.ModifyAll("Posting Message", PurchaseHeader."Posting Message");
                IntegrationPurchase.ModifyAll(Status, IntegrationPurchase.Status::Created);

            end;


        end else
            error('Usuario %1 sem Permissão para Liberar Pedido', USERID);



    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterCopyGenJnlLineFromPurchHeader', '', false, false)]
    local procedure OnAfterCopyGenJnlLineFromPurchHeader_TableGenJournalLine(var GenJournalLine: Record "Gen. Journal Line"; PurchaseHeader: Record "Purchase Header")
    begin
        GenJournalLine."Service Delivery City" := PurchaseHeader."CADBR Service Delivery City";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Vendor Ledger Entry", 'OnAfterCopyVendLedgerEntryFromGenJnlLine', '', false, false)]
    local procedure OnAfterCopyVendLedgerEntryFromGenJnlLine_TableVendorLedgerEntry(GenJournalLine: Record "Gen. Journal Line"; var VendorLedgerEntry: Record "Vendor Ledger Entry")
    begin
        VendorLedgerEntry."Service Delivery City" := GenJournalLine."Service Delivery City";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnAfterInitVendLedgEntry', '', false, false)]
    local procedure Codeunit_12_OnAfterInitVendLedgEntry(var VendorLedgerEntry: Record "Vendor Ledger Entry"; GenJournalLine: Record "Gen. Journal Line")
    var
        PurchaseHeader: Record "Purchase Header";
        PurchInvHeader: Record "Purch. Inv. Header";

    begin
        VendorLedgerEntry.CalcFields("CADBR Order No.");

        PurchaseHeader.Reset();
        PurchaseHeader.SetRange("No.", VendorLedgerEntry."CADBR Order No.");
        PurchaseHeader.SetRange("Buy-from Vendor No.", VendorLedgerEntry."Vendor No.");
        PurchaseHeader.SetRange("Vendor Invoice No.", VendorLedgerEntry."External Document No.");
        if PurchaseHeader.FindFirst() then
            VendorLedgerEntry."Service Delivery City" := PurchaseHeader."CADBR Service Delivery City"
        else begin
            if PurchInvHeader.Get(VendorLedgerEntry."Document No.") then
                VendorLedgerEntry."Service Delivery City" := PurchInvHeader."CADBR Service Delivery City";
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnAfterValidateEvent', 'Reason Code', false, false)]

    local procedure PurchaseHeaderOnAfterValidateEventReasonCode(var Rec: Record "Purchase Header"; var xRec: Record "Purchase Header")
    var
        IntegPurch: Record "Integration Purchase";
        ReasonCode: Record "Reason Code";
    begin

        IntegPurch.Reset();
        IntegPurch.setrange("Document No.", rec."No.");
        if IntegPurch.Find('-') then
            repeat
                IntegPurch."Reason Code" := rec."Reason Code";
                if (Rec."Reason Code" <> '') and ReasonCode.Get(rec."Reason Code") then begin
                    IntegPurch."Reason Description" := ReasonCode.Description;
                end;

                if Rec."Reason Code" <> '' then
                    IntegPurch.Rejected := true
                else
                    IntegPurch.Rejected := false;

                IntegPurch.Modify();
            until IntegPurch.Next() = 0;

    end;


    procedure ReleasePurcDocValidate(var PurchaseHeader: Record "Purchase Header");
    var
        PurcLine: Record "Purchase Line";
        PurchSetup: Record "Purchases & Payables Setup";
        purchInvHeader: Record "Purch. Inv. Header";
        TaxPostAcc: Record "CADBR Tax Posting Accounts";
        intPurch: Record "Integration Purchase";
        FiscalDoc: Record "CADBR Fiscal Document Type";
        CSTImpostos: Record "CADBR CST Impostos";
        DocumentAlreadyExists: label 'The %1 document no. already exists for Vendor %2 - %3.';
        DocumentAndSerieAlreadyExists: label 'The Document No. %1 and Print Serie %2 already exists for Vendor %3 - %4.';
        DocumentSerieAndFiscalDocTypeAlreadyExists: label 'The Document No. %1, Print Serie %2 and Fiscal Doc. Type %3 already exists for Vendor %4 - %5.';
        Label50001: Label 'PIS/COFINS Credit Calculation Base Code. must have a value in Line';
        Label50002: Label 'Unit Cost. Direct Excl. CUBA must have a value in Line';
        Label50003: Label 'Origin Code. must have a value in Line 1.';
        Label50014: Label 'Payment Terms Code must have a value in Header.';
        Label50005: Label 'The document date cannot be greater than the registration date.';
        Label50006: Label 'Payment.-a Address. must have a value in Header.';
        Label50007: Label 'Vendor Invoice No. must have a value in Header.';
        Label50008: Label 'The Print series does not match the Print Series';
        Label50019: Label 'NFe Reference key must have a value in Header.';
        Label50010: Label 'The NF-e key series does not match the Print Series';
        Label50011: Label 'The NF-e key number does not match the Tax Nº.';
        PrintSerie: Integer;
        InvoiceNo: Integer;


    begin
        PurchSetup.Get;

        if PurchaseHeader."Payment Terms Code" = '' then
            PurchaseHeader."Posting Message" := Label50014;

        if PurchaseHeader."Document Date" > PurchaseHeader."Posting Date" then
            PurchaseHeader."Posting Message" := Label50005;

        if PurchaseHeader."Pay-to Address" = '' then
            PurchaseHeader."Posting Message" := Label50006;

        if PurchaseHeader."Vendor Invoice No." = '' then
            PurchaseHeader."Posting Message" := Label50007;

        if FiscalDoc.Get(PurchaseHeader."CADBR Fiscal Document Type") then begin
            if (FiscalDoc."Series Mandatory") then
                if PurchaseHeader."CADBR Print Serie" = '' then
                    PurchaseHeader."Posting Message" := Label50008;

            PurchaseHeader.CalcFields("CADBR Access Key");

            if FiscalDoc."Document Model" = '55' then
                if PurchaseHeader."CADBR Access Key" = '' then
                    PurchaseHeader."Posting Message" := Label50019
                else begin
                    Evaluate(PrintSerie, PurchaseHeader."CADBR Print Serie");
                    Evaluate(InvoiceNo, PurchaseHeader."Vendor Invoice No.");

                    if CopyStr(PurchaseHeader."CADBR Access Key", 23 + 3 - StrLen(Format(PrintSerie)), StrLen(Format(PrintSerie))) <> Format(PrintSerie) then
                        PurchaseHeader."Posting Message" := Label50010;

                    if CopyStr(PurchaseHeader."CADBR Access Key", 26 + 9 - StrLen(Format(InvoiceNo)), StrLen(Format(InvoiceNo))) <> Format(InvoiceNo) then
                        PurchaseHeader."Posting Message" := Label50011;
                end;
        end;

        if PurchaseHeader."Vendor Invoice No." <> '' then begin

            TaxPostAcc.Reset();
            TaxPostAcc.SetRange("Payable Account Type", TaxPostAcc."Payable Account Type"::Vendor);
            TaxPostAcc.SetRange("Payable Account No.", PurchaseHeader."Pay-to Vendor No.");
            if not TaxPostAcc.FindFirst() then
                if PurchaseHeader."Document Type" in [PurchaseHeader."document type"::Order, PurchaseHeader."document type"::Invoice] then begin
                    purchInvHeader.SetCurrentkey("Pay-to Vendor No.", "Vendor Invoice No.", "CADBR Print Serie");
                    purchInvHeader.SetRange("Pay-to Vendor No.", PurchaseHeader."Pay-to Vendor No.");
                    purchInvHeader.SetRange("Vendor Invoice No.", PurchaseHeader."Vendor Invoice No.");
                    case PurchSetup."CADBR Validation for Vendor Doc." of
                        PurchSetup."CADBR Validation for Vendor Doc."::"Vendor Doc. No. + Print Serie":
                            purchInvHeader.SetRange("CADBR Print Serie", PurchaseHeader."CADBR Print Serie");
                        PurchSetup."CADBR Validation for Vendor Doc."::"Vendor Doc. No. + Print Serie + Fiscal Doc. Type":
                            begin
                                purchInvHeader.SetRange("CADBR Print Serie", PurchaseHeader."CADBR Print Serie");
                                purchInvHeader.SetRange("CADBR Fiscal Document Type", PurchaseHeader."CADBR Fiscal Document Type");
                            end;
                    end;
                    purchInvHeader.SetRange("CADBR Credit Memos", false);
                    if purchInvHeader.Count > 0 then
                        case PurchSetup."CADBR Validation for Vendor Doc." of
                            PurchSetup."CADBR Validation for Vendor Doc."::"Vendor Doc. No. + Print Serie":
                                PurchaseHeader."Posting Message" := StrSubstNo(DocumentAndSerieAlreadyExists, PurchaseHeader."Vendor Invoice No.", PurchaseHeader."CADBR Print Serie", PurchaseHeader."Pay-to Vendor No.", PurchaseHeader."Pay-to Name");
                            PurchSetup."CADBR Validation for Vendor Doc."::"Vendor Doc. No. + Print Serie + Fiscal Doc. Type":
                                PurchaseHeader."Posting Message" := StrSubstNo(DocumentSerieAndFiscalDocTypeAlreadyExists, PurchaseHeader."Vendor Invoice No.", PurchaseHeader."CADBR Print Serie", PurchaseHeader."CADBR Fiscal Document Type", PurchaseHeader."Pay-to Vendor No.", PurchaseHeader."Pay-to Name");
                            else
                                PurchaseHeader."Posting Message" := StrSubstNo(DocumentAlreadyExists, PurchaseHeader."Vendor Invoice No.", PurchaseHeader."Pay-to Vendor No.", PurchaseHeader."Pay-to Name");
                        end;
                end;
        end;

        PurcLine.Reset();
        PurcLine.SetRange("Document Type", PurchaseHeader."Document Type");
        PurcLine.SetRange("Document No.", PurchaseHeader."No.");
        if PurcLine.FindSet() then
            repeat
                if PurcLine."CADBR Origin Code" = '' then
                    PurchaseHeader."Posting Message" := Label50003;

                if PurcLine."Direct Unit Cost" = 0 then
                    PurchaseHeader."Posting Message" := Label50002;

                if PurcLine."CADBR Base Calculation Credit Code" = '' then begin

                    if CSTImpostos.get(CSTImpostos."Tax Type"::PIS, PurcLine."CADBR PIS CST Code") then
                        if CSTImpostos."Tax Credit" then
                            PurchaseHeader."Posting Message" := Label50001;

                    if CSTImpostos.get(CSTImpostos."Tax Type"::COFINS, PurcLine."CADBR COFINS CST Code") then
                        if CSTImpostos."Tax Credit" then
                            PurchaseHeader."Posting Message" := Label50001;

                end;

            until PurcLine.Next() = 0;

    end;


    var
        DimensionCode: Code[20];
        booHideDialog: Boolean;
        booIsHandled: Boolean;
        WindDialog: Dialog;
        StartTime: DateTime;
        IntegrationPurchaseBuffer: Record IntegrationPurchaseBuffer;
}