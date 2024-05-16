codeunit 50011 "Integration Landlord"
{
    procedure CreatePurchase(var IntPurchase: Record "Integration Landlord")
    var
        IntegrationPurchase: Record "Integration Landlord";
        DialogReviewPurchaseLbl: label 'Review Purchase Order   #1#############', Comment = '#1 IntegrationPurchase';
    begin

        StartTime := CurrentDateTime;

        IntegrationPurchase.Reset();
        IntegrationPurchase.CopyFilters(IntPurchase);
        IntegrationPurchase.SetFilter(Status, '%1|%2|%3', IntegrationPurchase.Status::Imported,
                                                       IntegrationPurchase.Status::"Data Error",
                                                       IntegrationPurchase.Status::Reviewed);
        if not IntegrationPurchase.IsEmpty then begin
            if GuiAllowed then
                WindDialog.Open(DialogReviewPurchaseLbl);

            IntegrationPurchase.FindSet();
            repeat
                if GuiAllowed then
                    WindDialog.Update(1, IntegrationPurchase."Document No.");

                IntegrationPurchase."Posting Message" := '';

                if not ValidateIntPurchase(IntegrationPurchase) then;
                CreatePurchaseOrder(IntegrationPurchase);

            until IntegrationPurchase.Next() = 0;

        end;

        if GuiAllowed then
            WindDialog.Close();
        if GuiAllowed then
            Message('Começou em %1 e terminou em %2', StartTime, CurrentDateTime);
    end;

    procedure PostPurchase(var IntPurchase: Record "Integration Landlord")
    var
        IntegrationPurchase: Record "Integration Landlord";
    begin
        IntegrationPurchase.Reset();
        IntegrationPurchase.CopyFilters(IntPurchase);
        IntegrationPurchase.SetFilter(Status, '%1', IntegrationPurchase.Status::Created);
        IntegrationPurchase.CalcFields("Error Order");
        IntegrationPurchase.SetFilter("Error Order", '%1', 0);
        if IntegrationPurchase.Find('-') then
            repeat
                ClearLastError();
                if not CreatePostOrder(IntegrationPurchase) then begin
                    IntegrationPurchase."Posting Message" := copystr(GetLastErrorText(), 1, 200);
                    IntegrationPurchase.Status := IntegrationPurchase.Status::"Data Error";
                    IntegrationPurchase.Modify();
                end else begin
                    integrationPurchase.Status := IntegrationPurchase.Status::Posted;
                    IntegrationPurchase.Modify();

                end;

            until IntegrationPurchase.Next() = 0;
    end;

    procedure CreatePurchaseOrder(IntLandlord: Record "Integration Landlord")
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        PurPaySetup: Record "Purchases & Payables Setup";
        TempBlob: Codeunit "Temp Blob";
        ReleasePurchaseDocument: Codeunit "Release Purchase Document";
        NoSeriesMgt: Codeunit NoSeriesManagement;
    begin

        PurPaySetup.Get();
        PurPaySetup.Testfield("Item Serv. Landlord");

        PurchaseHeader.Reset();
        if PurchaseHeader.Get(PurchaseHeader."Document Type"::Invoice, IntLandlord."Document No.") then
            PurchaseHeader.Delete(true);

        PurchaseHeader.Init();
        PurchaseHeader."Document Type" := PurchaseHeader."Document Type"::Invoice;
        PurchaseHeader.Validate("CADBR Branch Code", IntLandlord."Shortcut Dimension 6 Code");
        PurchaseHeader."No." := NoSeriesMgt.GetNextNo(PurPaySetup."Invoice Nos.", WorkDate, true);
        PurchaseHeader.InitRecord();
        PurchaseHeader.validate("Buy-from Vendor No.", IntLandlord."Buy-from Vendor No.");
        PurchaseHeader."Order Date" := IntLandlord."Document Date";
        PurchaseHeader.validate("Posting Date", IntLandlord."Document Date");
        PurchaseHeader."Document Date" := IntLandlord."Document Date";

        PurchaseHeader."Vendor Invoice No." := IntLandlord."Vendor Invoice No.";
        // PurchaseHeader."Posting No." := IntLandlord."Document No.";

        if IntLandlord."Tax Area Code" <> '' then
            PurchaseHeader."CADBR Taxes Matrix Code" := IntLandlord."Tax Area Code";

        PurchaseHeader.Receive := true;
        PurchaseHeader.Invoice := true;

        // PurchaseHeader."IRRF Ret" += IntLandlord."IRRF Ret";
        // PurchaseHeader."CSRF Ret" += IntLandlord."CSRF Ret";
        // PurchaseHeader."INSS Ret" += IntLandlord."INSS Ret";
        // PurchaseHeader."ISS Ret" += IntLandlord."ISS Ret";
        // PurchaseHeader."PIS Credit" += IntLandlord."PIS Credit";
        // PurchaseHeader."Cofins Credit" += IntLandlord."Cofins Credit";
        // PurchaseHeader."DIRF" += IntLandlord.DIRF;
        // PurchaseHeader."PO Total" := IntLandlord."PO Total";
        PurchaseHeader.Insert();

        PurchaseHeader.Status := PurchaseHeader.Status::Open;
        if IntLandlord."Shortcut Dimension 1 Code" <> '' then
            PurchaseHeader.ValidateShortcutDimCode(1, IntLandlord."Shortcut Dimension 1 Code");
        if IntLandlord."Shortcut Dimension 2 Code" <> '' then
            PurchaseHeader.ValidateShortcutDimCode(2, IntLandlord."Shortcut Dimension 2 Code");
        if IntLandlord."Shortcut Dimension 3 Code" <> '' then
            PurchaseHeader.ValidateShortcutDimCode(3, IntLandlord."Shortcut Dimension 3 Code");
        if IntLandlord."Shortcut Dimension 4 Code" <> '' then
            PurchaseHeader.ValidateShortcutDimCode(4, IntLandlord."Shortcut Dimension 4 Code");
        if IntLandlord."Shortcut Dimension 5 Code" <> '' then
            PurchaseHeader.ValidateShortcutDimCode(5, IntLandlord."Shortcut Dimension 5 Code");
        if IntLandlord."Shortcut Dimension 6 Code" <> '' then
            PurchaseHeader.ValidateShortcutDimCode(6, IntLandlord."Shortcut Dimension 6 Code");

        // if IntLandlord."Fiscal Document Type" <> '' then
        //     PurchaseHeader."CADBR Fiscal Document Type" := IntLandlord."Fiscal Document Type";

        PurchaseHeader.Modify();
        IntLandlord."Document No." := PurchaseHeader."No.";

        //Purchase Line
        PurchaseLine.Reset();
        if PurchaseLine.get(PurchaseLine."Document Type"::Invoice, IntLandlord."document No.", IntLandlord."Line No.") then
            PurchaseLine.Delete(true);

        PurchaseLine.Init();
        PurchaseLine."Document Type" := PurchaseLine."Document Type"::Invoice;
        PurchaseLine."Document No." := PurchaseHeader."No.";
        PurchaseLine."Line No." := IntLandlord."Line No.";

        PurchaseLine.Type := PurchaseLine.Type::Item;

        PurchaseLine.Validate("No.", PurPaySetup."Item Serv. Landlord");

        // if IntLandlord."Gen. Prod. Posting Group" <> '' then
        //     PurchaseLine.Validate("Gen. Prod. Posting Group", IntLandlord."Gen. Prod. Posting Group");

        PurchaseLine.Description := IntLandlord.Description;
        PurchaseLine.validate(Quantity, IntLandlord.Quantity);
        PurchaseLine.validate("Direct Unit Cost", IntLandlord.Amount);
        // PurchaseLine."CADBR Service Code" := IntLandlord."Service Code";
        PurchaseLine."VAT Calculation Type" := PurchaseLine."VAT Calculation Type"::"Sales Tax";
        PurchaseLine."Tax Liable" := true;
        // PurchaseLine."CADBR Operation Type" := PurchaseHeader."CADBR Operation Type";

        if IntLandlord."Shortcut Dimension 1 Code" <> '' then
            PurchaseLine.ValidateShortcutDimCode(1, IntLandlord."Shortcut Dimension 1 Code");
        if IntLandlord."Shortcut Dimension 2 Code" <> '' then
            PurchaseLine.ValidateShortcutDimCode(2, IntLandlord."Shortcut Dimension 2 Code");
        if IntLandlord."Shortcut Dimension 3 Code" <> '' then
            PurchaseLine.ValidateShortcutDimCode(3, IntLandlord."Shortcut Dimension 3 Code");
        if IntLandlord."Shortcut Dimension 4 Code" <> '' then
            PurchaseLine.ValidateShortcutDimCode(4, IntLandlord."Shortcut Dimension 4 Code");
        if IntLandlord."Shortcut Dimension 5 Code" <> '' then
            PurchaseLine.ValidateShortcutDimCode(5, IntLandlord."Shortcut Dimension 5 Code");
        if IntLandlord."Shortcut Dimension 6 Code" <> '' then
            PurchaseLine.ValidateShortcutDimCode(6, IntLandlord."Shortcut Dimension 6 Code");
        PurchaseLine.Insert();

        IntLandlord."Posting Message" := '';
        IntLandlord.Status := IntLandlord.Status::Created;
        IntLandlord.Modify();

        CalcTax(PurchaseHeader, false);

    end;

    [TryFunction]
    procedure CreatePostOrder(IntegrationPurchase: Record "Integration Landlord")
    var
        PurchaseHeader: Record "Purchase Header";
        IntPurchase: Record "Integration Landlord";
        PurchPost: codeunit "Purch.-Post";
    begin
        booHideDialog := false;

        Clear(PurchPost);

        if PurchaseHeader.get(PurchaseHeader."Document Type"::Order, IntegrationPurchase."document No.") then begin
            PurchaseHeader."Posting No." := PurchaseHeader."No.";
            PurchaseHeader.Modify();

            PurchPost.Run(PurchaseHeader);
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

    procedure ValidateIntPurchase(var IntegrationPurchase: Record "Integration Landlord"): Boolean;
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
        TaxCalculate: codeunit "CADBR Tax Calculate";
        IPTaxes: Record "Integration Landlord";
    begin
        if PurchaseHeader.get(FromPurchaseHeader."Document Type"::Order, FromPurchaseHeader."No.") then begin

            TempTaxAmountLine.Reset();
            TempTaxAmountLine.DeleteAll();
            TaxCalculate.CalculatePurchDoc(PurchaseHeader, TempTaxAmountLine);

            IPTaxes.Reset();
            IPTaxes.SetRange("Document No.", FromPurchaseHeader."No.");
            if not IPTaxes.IsEmpty then begin
                ;
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
                                        IPTaxes."Order CSRF Ret" := Abs(TempTaxAmountLine."Tax Amount");
                                    end;

                                TempTaxAmountLine."Tax identification"::"INSS Ret.":
                                    begin
                                        IPTaxes."Order INSS Ret" := Abs(TempTaxAmountLine."Tax Amount");
                                    end;

                                TempTaxAmountLine."Tax identification"::"ISS Ret.":
                                    begin
                                        IPTaxes."Order ISS Ret" := Abs(TempTaxAmountLine."Tax Amount");
                                    end;

                                TempTaxAmountLine."Tax identification"::PIS:
                                    begin
                                        IPTaxes."Order PIS Credit" := Abs(TempTaxAmountLine."Tax Amount");
                                    end;

                                TempTaxAmountLine."Tax identification"::COFINS:
                                    begin
                                        IPTaxes."Order Cofins Credit" := Abs(TempTaxAmountLine."Tax Amount");
                                    end;
                                TempTaxAmountLine."Tax identification"::IRRF:
                                    begin
                                        if IPTaxes.DIRF <> 0 then begin
                                            // IPTaxes."Order IRRF Ret" := Abs(TempTaxAmountLine."Tax Amount");

                                            if IPTaxes.DIRF <> IPTaxes."Order IRRF Ret" then begin
                                                TempTaxAmountLine."Tax Amount" := IPTaxes.DIRF;
                                                IPTaxes."Order DIRF Ret" := IPTaxes.DIRF;

                                                DeleteOldModTaxLine(PurchaseHeader, ModTaxAmountLine, IPTaxes);
                                                InsertModTaxAmountLine(PurchaseHeader, TempTaxAmountLine, ModTaxAmountLine, IPTaxes);
                                            end;
                                        end else begin
                                            IPTaxes."Order IRRF Ret" := Abs(TempTaxAmountLine."Tax Amount");
                                        end;
                                    end;
                            end;
                        until TempTaxAmountLine.next() = 0;
                    end;
                    IPTaxes.Modify();
                until IPTaxes.Next() = 0;
            end;
        end;
        if FromRelease then
            ConsolidateTaxes(PurchaseHeader);

    end;


    procedure CheckTaxes(var IntPurchase: Record "Integration Landlord")
    var
        IntegrationPurchase: Record "Integration Landlord";

    begin

        IntegrationPurchase.Reset();
        IntegrationPurchase.CopyFilters(IntPurchase);
        IntegrationPurchase.SetFilter(Status, '%1|%2|%3|%4', IntegrationPurchase.Status::Imported,
                                                       IntegrationPurchase.Status::"Data Error",
                                                       IntegrationPurchase.Status::Created,
                                                       IntegrationPurchase.Status::Reviewed);
        if not IntegrationPurchase.IsEmpty then begin
            IntegrationPurchase.FindSet();
            repeat
                if IntegrationPurchase."ISS Ret" = IntegrationPurchase."Order ISS Ret" then
                    IntegrationPurchase."Not Dif. Impostos" := true;

                if IntegrationPurchase."INSS Ret" = IntegrationPurchase."Order INSS Ret" then
                    IntegrationPurchase."Not Dif. Impostos" := true;

                if IntegrationPurchase."IRRF Ret" = IntegrationPurchase."Order IRRF Ret" then
                    IntegrationPurchase."Not Dif. Impostos" := true;

                if IntegrationPurchase."CSRF Ret" = IntegrationPurchase."Order CSRF Ret" then
                    IntegrationPurchase."Not Dif. Impostos" := true;

                if IntegrationPurchase."PIS Credit" = IntegrationPurchase."Order PIS Credit" then
                    IntegrationPurchase."Not Dif. Impostos" := true;

                if IntegrationPurchase."Cofins Credit" = IntegrationPurchase."Order Cofins Credit" then
                    IntegrationPurchase."Not Dif. Impostos" := true;

                if IntegrationPurchase.DIRF = IntegrationPurchase."Order DIRF Ret" then
                    IntegrationPurchase."Not Dif. Impostos" := true;

                IntegrationPurchase.Modify();

            until IntegrationPurchase.Next() = 0;
        end;

    end;

    procedure PurchRealse(var IntPurchase: Record "Integration Landlord")
    var
        IntegrationPurchase: Record "Integration Landlord";
        PurchHeader: Record "Purchase Header";

    begin

        IntegrationPurchase.Reset();
        IntegrationPurchase.CopyFilters(IntPurchase);
        IntegrationPurchase.SetFilter(Status, '%1|%2|%3|%4', IntegrationPurchase.Status::Imported,
                                                       IntegrationPurchase.Status::"Data Error",
                                                       IntegrationPurchase.Status::Created,
                                                       IntegrationPurchase.Status::Reviewed);
        if not IntegrationPurchase.IsEmpty then begin
            IntegrationPurchase.FindSet();
            repeat
                if IntegrationPurchase."Not Dif. Impostos" then begin
                    PurchHeader.Reset();
                    PurchHeader.SetRange("No.", IntegrationPurchase."Document No.");
                    if PurchHeader.Find('-') then
                        repeat
                            if not StatusOrder(PurchHeader) then begin
                                IntegrationPurchase."Posting Message" := GetLastErrorText;
                                IntegrationPurchase.Modify();
                            end;
                        until PurchHeader.Next() = 0;

                end;


            until IntegrationPurchase.Next() = 0;
        end;

    end;

    [TryFunction]
    procedure StatusOrder(PurchaseHeader: Record "Purchase Header")
    var

    begin
        PurchaseHeader.Status := PurchaseHeader.Status::Released;
        PurchaseHeader.Modify();
    end;

    procedure PurchOpen(var IntPurchase: Record "Integration Landlord")
    var
        IntegrationPurchase: Record "Integration Landlord";
        PurchHeader: Record "Purchase Header";

    begin

        IntegrationPurchase.Reset();
        IntegrationPurchase.CopyFilters(IntPurchase);
        IntegrationPurchase.SetFilter(Status, '%1|%2|%3|%4', IntegrationPurchase.Status::Imported,
                                                       IntegrationPurchase.Status::"Data Error",
                                                       IntegrationPurchase.Status::Created,
                                                       IntegrationPurchase.Status::Reviewed);
        if not IntegrationPurchase.IsEmpty then begin
            IntegrationPurchase.FindSet();
            repeat

                PurchHeader.Reset();
                PurchHeader.SetRange("No.", IntegrationPurchase."Document No.");
                if PurchHeader.Find('-') then
                    repeat
                        PurchHeader.Status := PurchHeader.Status::Open;
                        PurchHeader.Modify();

                    until PurchHeader.Next() = 0;

            until IntegrationPurchase.Next() = 0;
        end;

    end;

    local procedure ConsolidateTaxes(PurchaseHeader: Record "Purchase Header")
    var
        IPOrder: Record "Integration Landlord";
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

    local procedure InsertPurchaseBuffer(var IntegrationPurchase: Record "Integration Landlord")
    begin
        IntegrationPurchaseBuffer.Init();
        IntegrationPurchaseBuffer."Excel File Name" := IntegrationPurchase."Excel File Name";
        IntegrationPurchaseBuffer."Document No." := IntegrationPurchase."Document No.";
        if IntegrationPurchaseBuffer.Insert() then;
    end;

    local procedure FilterRecordToCreate(var RecordToCreate: Record "Integration Landlord")
    begin
        RecordToCreate.Reset();
        RecordToCreate.SetRange("Excel File Name", IntegrationPurchaseBuffer."Excel File Name");
        RecordToCreate.SetRange("Document No.", IntegrationPurchaseBuffer."Document No.");
    end;

    local procedure FilterRecordToCreateErrorMessage(var RecordToCreate: Record "Integration Landlord")
    begin
        RecordToCreate.Reset();
        RecordToCreate.SetRange("Excel File Name", IntegrationPurchaseBuffer."Excel File Name");
        RecordToCreate.SetRange("Document No.", IntegrationPurchaseBuffer."Document No.");
        RecordToCreate.SetFilter("Posting Message", '%1', '');
    end;

    local procedure DimFilterUsgaap(var IntegrationPurchase: Record "Integration Landlord"; var Usgaap: Record "From/To US GAAP"): Boolean
    begin
        Usgaap.SetRange("Dimension 1", IntegrationPurchase."Shortcut Dimension 1 Code");
        Usgaap.SetRange("Dimension 2", IntegrationPurchase."Shortcut Dimension 2 Code");
        Usgaap.SetRange("Dimension 3", IntegrationPurchase."Shortcut Dimension 3 Code");
        Usgaap.SetRange("Dimension 4", IntegrationPurchase."Shortcut Dimension 4 Code");
        Usgaap.SetRange("Dimension 5", IntegrationPurchase."Shortcut Dimension 5 Code");
        Usgaap.SetRange("Dimension 6", IntegrationPurchase."Shortcut Dimension 6 Code");
    end;


    local procedure CheckAccount(var IntegrationPurchase: Record "Integration Landlord"; var Vendor: Record Vendor; var Item: Record Item)
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
            if Usgaap."BR GAAP" <> Item."Gen. Prod. Posting Group" then begin
                if GeneralPostingSetup.Get(Vendor."Gen. Bus. Posting Group", Usgaap."BR GAAP") then begin
                    IntegrationPurchase."Gen. Prod. Posting Group" := Usgaap."BR GAAP";
                end else begin
                    IntegrationPurchase."Posting Message" := MergePostingMessage(IntegrationPurchase."Posting Message", StrSubstNo(GenProdPostGroupExistErr, Usgaap."BR GAAP"));
                end;
            end;
        end else begin
            Usgaap.Reset();
            Usgaap.SetRange("US GAAP", IntegrationPurchase."Item No.");
            if not Usgaap.IsEmpty then begin
                Usgaap.FindSet();
                if Usgaap."BR GAAP" <> Item."Gen. Prod. Posting Group" then begin
                    if GeneralPostingSetup.Get(Vendor."Gen. Bus. Posting Group", Usgaap."BR GAAP") then begin
                        IntegrationPurchase."Gen. Prod. Posting Group" := Usgaap."BR GAAP";
                    end else begin
                        IntegrationPurchase."Posting Message" := MergePostingMessage(IntegrationPurchase."Posting Message", StrSubstNo(GenProdPostGroupExistErr, Usgaap."BR GAAP"));
                    end;
                end;
            end else begin
                GLAccount.Reset();
                GLAccount.SetCurrentKey("No. 2");
                GLAccount.SetRange("No. 2", IntegrationPurchase."Item No.");
                if not GLAccount.IsEmpty then begin
                    GLAccount.FindSet();
                    if GLAccount."No." <> Item."Gen. Prod. Posting Group" then begin
                        if GeneralPostingSetup.Get(Vendor."Gen. Bus. Posting Group", GLAccount."No.") then begin
                            IntegrationPurchase."Gen. Prod. Posting Group" := GLAccount."No.";

                        end else begin
                            IntegrationPurchase."Posting Message" := MergePostingMessage(IntegrationPurchase."Posting Message", StrSubstNo('Gen. Bus. Posting Group % Does not exist.', GLAccount."No."));

                        end;
                    end;
                end;
            end;
        end;
    end;

    local procedure MergePostingMessage(OldMessage: text; AddMessage: text): Text
    var
        IntegrationPurchase: Record "Integration Landlord";
    begin
        if OldMessage <> '' then
            exit(CopyStr(AddMessage + '|' + OldMessage, 1, MaxStrLen(IntegrationPurchase."Posting Message")))
        else
            exit(CopyStr(AddMessage, 1, MaxStrLen(IntegrationPurchase."Posting Message")));
    end;

    procedure CalcTaxFRomPurchaseOrder(PurchaseHeader: Record "Purchase Header"; PurchaseLine: Record "Purchase Line"): Boolean;
    var
        IntegrationPurchase: Record "Integration Landlord";
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

                TempTaxAmountLine."Tax Amount" := IntegrationPurchase.DIRF;
                IntegrationPurchase."Order DIRF Ret" := IntegrationPurchase.DIRF;

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
            end;

            IntegrationPurchase."Order CSRF Ret" := 0;
            IntegrationPurchase."Order IRRF Ret" := 0;
            IntegrationPurchase."Order INSS Ret" := 0;
            IntegrationPurchase."Order ISS Ret" := 0;
            IntegrationPurchase."Order INSS Ret" := 0;
            IntegrationPurchase."Order Cofins Credit" := 0;
            IntegrationPurchase."Order PIS Credit" := 0;

            TempTaxAmountLine.Reset();
            TempTaxAmountLine.SetRange("Tax Identification", TempTaxAmountLine."tax identification"::PCC);
            TempTaxAmountLine.SetRange("Document Line No.", IntegrationPurchase."Line No.");
            if TempTaxAmountLine.FindFirst() then
                IntegrationPurchase."Order CSRF Ret" := Abs(TempTaxAmountLine."Tax Amount");

            TempTaxAmountLine.Reset();
            TempTaxAmountLine.SetRange("Tax Identification", TempTaxAmountLine."tax identification"::"INSS Ret.");
            TempTaxAmountLine.SetRange("Document Line No.", IntegrationPurchase."Line No.");
            if TempTaxAmountLine.FindFirst() then
                IntegrationPurchase."Order INSS Ret" := Abs(TempTaxAmountLine."Tax Amount");

            TempTaxAmountLine.Reset();
            TempTaxAmountLine.SetRange("Tax Identification", TempTaxAmountLine."tax identification"::"ISS Ret.");
            TempTaxAmountLine.SetRange("Document Line No.", IntegrationPurchase."Line No.");
            if TempTaxAmountLine.FindFirst() then
                IntegrationPurchase."Order ISS Ret" := Abs(TempTaxAmountLine."Tax Amount");

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

    local procedure ResetIpTaxesAmounts(var IPTaxes: Record "Integration Landlord")
    begin
        IPTaxes."Order CSRF Ret" := 0;
        IPTaxes."Order IRRF Ret" := 0;
        IPTaxes."Order INSS Ret" := 0;
        IPTaxes."Order ISS Ret" := 0;
        IPTaxes."Order INSS Ret" := 0;
        IPTaxes."Order Cofins Credit" := 0;
        IPTaxes."Order PIS Credit" := 0;
    end;

    local procedure InsertModTaxAmountLine(var PurchaseHeader: Record "Purchase Header"; var TempTaxAmountLine: Record "CADBR Tax Amount Line" temporary; var ModTaxAmountLine: Record "CADBR Modified Tax Amount Line"; var IPTaxes: Record "Integration Landlord")
    begin
        ModTaxAmountLine.Init();
        ModTaxAmountLine."Table ID" := 39;
        ModTaxAmountLine."Document Type" := ModTaxAmountLine."Document Type"::Order;
        ModTaxAmountLine."Document No." := PurchaseHeader."No.";
        ModTaxAmountLine."Document Line No." := IPTaxes."Line No.";
        ModTaxAmountLine."Tax Amount" := IPTaxes.DIRF;
        ModTaxAmountLine."Exempt Basis Amount" := TempTaxAmountLine."Exempt Basis Amount";
        ModTaxAmountLine."Others Basis Amount" := TempTaxAmountLine."Others Basis Amount";
        ModTaxAmountLine."Tax %" := TempTaxAmountLine."Tax %";
        ModTaxAmountLine."Tax Area Code" := PurchaseHeader."Tax Area Code";
        ModTaxAmountLine."Tax Base Amount" := TempTaxAmountLine."Tax Base Amount";
        ModTaxAmountLine."Tax Identification" := TempTaxAmountLine."Tax Identification";
        ModTaxAmountLine."Tax Jurisdiction Code" := TempTaxAmountLine."Tax Jurisdiction Code";
        ModTaxAmountLine."Tax Posting Code" := TempTaxAmountLine."Tax Posting Code";
        ModTaxAmountLine."User ID" := UserId;
        ModTaxAmountLine.Insert();
    end;

    local procedure DeleteOldModTaxLine(var PurchaseHeader: Record "Purchase Header"; var ModTaxAmountLine: Record "CADBR Modified Tax Amount Line"; var IPTaxes: Record "Integration Landlord")
    begin
        ModTaxAmountLine.Reset;
        ModTaxAmountLine.SetRange("Table ID", Database::"Purchase Line");
        ModTaxAmountLine.SetRange("Document Type", ModTaxAmountLine."Document Type"::Order);
        ModTaxAmountLine.SetRange("Document No.", PurchaseHeader."No.");
        ModTaxAmountLine.SetRange("Document Line No.", IPTaxes."Line No.");
        if not ModTaxAmountLine.IsEmpty then
            ModTaxAmountLine.DeleteAll();
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

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnAfterModifyEvent', '', false, false)]
    local procedure OnAfterModifyEvent_PurchaseLine(RunTrigger: Boolean; var Rec: Record "Purchase Line"; var xRec: Record "Purchase Line")
    var
        PurchaseHeader: Record "Purchase Header";
        IntegrationPurchase: Record "Integration Landlord";
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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Release Purchase Document", 'OnBeforeReleasePurchaseDoc', '', false, false)]
    local procedure OnBeforeReleasePurchaseDoc_CodeunitReleasePurchaseDocument(var PurchaseHeader: Record "Purchase Header")
    var
        IntegrationPurchase: Record "Integration Landlord";
    begin

        if PurchaseHeader."Document Type" <> PurchaseHeader."Document Type"::Order then
            exit;

        CalcTax(PurchaseHeader, true);

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
        IntegPurch: Record "Integration Landlord";
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

                IntegPurch.Modify();
            until IntegPurch.Next() = 0;

    end;

    var
        DimensionCode: Code[20];
        booHideDialog: Boolean;
        booIsHandled: Boolean;
        WindDialog: Dialog;
        StartTime: DateTime;
        IntegrationPurchaseBuffer: Record IntegrationPurchaseBuffer;
}