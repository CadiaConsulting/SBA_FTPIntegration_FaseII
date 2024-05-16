codeunit 50014 "Integration Purchase Return"
{
    procedure CreatePurchaseReturn(var IntPurRet: Record "Integration Purchase Return")
    var
        IntPurchaseReturn: Record "Integration Purchase Return";
        DialogCrePurchaseLbl: label 'Create Purchase Return Order   #1#############', Comment = '#1 IntPurchaseReturn';
    begin

        IntPurchaseReturn.Reset();
        IntPurchaseReturn.CopyFilters(IntPurRet);
        IntPurchaseReturn.SetFilter(Status, '%1|%2', IntPurchaseReturn.Status::Imported,
                                                   IntPurchaseReturn.Status::"Data Error");
        if IntPurchaseReturn.Find('-') then begin
            if GuiAllowed then
                WindDialog.Open(DialogCrePurchaseLbl);
            repeat
                if GuiAllowed then
                    WindDialog.Update(1, IntPurchaseReturn."Document No.");

                IntPurchaseReturn."Posting Message" := '';
                IntPurchaseReturn.Modify();

                if not ValidateIntPurchase(IntPurchaseReturn) then;

            until IntPurchaseReturn.Next() = 0;

            if GuiAllowed then
                WindDialog.Close();

        end;

        IntPurchaseReturn.Reset();
        IntPurchaseReturn.CopyFilters(IntPurRet);
        IntPurchaseReturn.SetFilter(Status, '%1|%2', IntPurchaseReturn.Status::Imported,
                                                   IntPurchaseReturn.Status::"Data Error");
        IntPurchaseReturn.CalcFields("Error Order");
        IntPurchaseReturn.SetFilter("Error Order", '%1', 0);
        if IntPurchaseReturn.Find('-') then begin
            if GuiAllowed then
                WindDialog.Open(DialogCrePurchaseLbl);
            repeat
                if GuiAllowed then
                    WindDialog.Update(1, IntPurchaseReturn."Document No.");

                IntPurchaseReturn."Posting Message" := '';
                IntPurchaseReturn.Modify();

                if not ValidateIntPurchase(IntPurchaseReturn) then
                    CreatePurchaseOrder(IntPurchaseReturn);

            until IntPurchaseReturn.Next() = 0;

            if GuiAllowed then
                WindDialog.Close();

        end;

    end;

    procedure PostPurchaseReturn(var IntPurRet: Record "Integration Purchase Return")
    var
        IntPurchaseReturn: Record "Integration Purchase Return";
    begin
        IntPurchaseReturn.Reset();
        IntPurchaseReturn.CopyFilters(IntPurRet);
        IntPurchaseReturn.SetFilter(Status, '%1', IntPurchaseReturn.Status::Created);
        IntPurchaseReturn.CalcFields("Error Order");
        IntPurchaseReturn.SetFilter("Error Order", '%1', 0);
        if IntPurchaseReturn.Find('-') then
            repeat

                CreatePostOrder(IntPurchaseReturn);

            until IntPurchaseReturn.Next() = 0;

    end;

    procedure CreatePurchaseOrder(IntPurchaseReturn: Record "Integration Purchase Return")
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        taxesMatrix: Record "CADBR Taxes Matrix";
        TaxConfig: Record "CADBR Tax Setup Sales Purchase";
        Vendor: Record Vendor;

    begin

        PurchaseHeader.Reset();
        if not PurchaseHeader.Get(PurchaseHeader."Document Type"::"Return Order", IntPurchaseReturn."Document No.") then begin

            PurchaseHeader.Init();
            PurchaseHeader."Document Type" := PurchaseHeader."Document Type"::"Return Order";
            PurchaseHeader.Validate("CADBR Branch Code", IntPurchaseReturn."Shortcut Dimension 6 Code");
            PurchaseHeader.validate("No.", IntPurchaseReturn."document No.");
            PurchaseHeader.InitRecord();
            PurchaseHeader.validate("Buy-from Vendor No.", IntPurchaseReturn."Buy-from Vendor No.");
            PurchaseHeader."Order Date" := IntPurchaseReturn."Order Date";
            PurchaseHeader.validate("Posting Date", IntPurchaseReturn."Order Date");
            PurchaseHeader."Document Date" := IntPurchaseReturn."Order Date";
            PurchaseHeader."Vendor Invoice No." := IntPurchaseReturn."Vendor Invoice No.";
            PurchaseHeader."Vendor Cr. Memo No." := IntPurchaseReturn."Vendor Invoice No.";

            //Matrix Start
            Vendor.get(PurchaseHeader."Buy-from Vendor No.");

            if PurchaseHeader."CADBR operation type" = '' then
                if Vendor."CADBR Taxes Matrix" <> '' then
                    PurchaseHeader."CADBR Taxes Matrix Code" := Vendor."Integration Taxes Matrix";

            taxesMatrix.Get(PurchaseHeader."CADBR Taxes Matrix Code");
            PurchaseHeader.Validate("CADBR Operation Nature", taxesMatrix."Operation Nature");
            PurchaseHeader.Validate("CADBR Operation Type", taxesMatrix."Operation Type");
            PurchaseHeader.Validate("CADBR Fiscal Document Type", taxesMatrix."Fiscal Document Type");
            PurchaseHeader.Validate("Shipment Method Code", taxesMatrix."Shipment Method Code");

            if PurchaseHeader."CADBR End User" then
                case PurchaseHeader."CADBR Vendor Situation" of
                    PurchaseHeader."CADBR Vendor Situation"::"Same state":
                        PurchaseHeader.Validate("CADBR CFOP Code", taxesMatrix."CFOP - End User Same State");
                    PurchaseHeader."CADBR vendor Situation"::"Other state":
                        PurchaseHeader.Validate("CADBR CFOP Code", taxesMatrix."CFOP - End User Outside State");
                end
            else
                case PurchaseHeader."CADBR vendor Situation" of
                    PurchaseHeader."CADBR vendor Situation"::"Same state":
                        PurchaseHeader.Validate("CADBR CFOP Code", taxesMatrix."CFOP - Same State");
                    PurchaseHeader."CADBR vendor Situation"::"Other state":
                        PurchaseHeader.Validate("CADBR CFOP Code", taxesMatrix."CFOP - Outside State");
                    PurchaseHeader."CADBR vendor Situation"::"Outside Brasill":
                        PurchaseHeader.Validate("CADBR CFOP Code", taxesMatrix."CFOP - Outside Brazil");
                end;

            if taxesMatrix."Tax Area Code" <> '' then
                PurchaseHeader."Tax Area Code" := taxesMatrix."Tax Area Code"
            else
                PurchaseHeader."Tax Area Code" := Vendor."Tax Area Code";

            //Matrix End
            PurchaseHeader.Ship := true;
            PurchaseHeader.Invoice := true;
            PurchaseHeader.Insert();

            PurchaseHeader.Status := PurchaseHeader.Status::Open;
            PurchaseHeader.ValidateShortcutDimCode(1, IntPurchaseReturn."Shortcut Dimension 1 Code");
            PurchaseHeader.ValidateShortcutDimCode(2, IntPurchaseReturn."Shortcut Dimension 2 Code");
            PurchaseHeader.ValidateShortcutDimCode(3, IntPurchaseReturn."Shortcut Dimension 3 Code");
            PurchaseHeader.ValidateShortcutDimCode(4, IntPurchaseReturn."Shortcut Dimension 4 Code");
            PurchaseHeader.ValidateShortcutDimCode(5, IntPurchaseReturn."Shortcut Dimension 5 Code");
            PurchaseHeader.ValidateShortcutDimCode(6, IntPurchaseReturn."Shortcut Dimension 6 Code");

            PurchaseHeader.Modify();

        end;

        //Purchase Line
        PurchaseLine.Reset();
        if not PurchaseLine.get(PurchaseLine."Document Type"::"Return Order", IntPurchaseReturn."document No.", IntPurchaseReturn."Line No.") then begin

            PurchaseLine.Init();
            PurchaseLine."Document Type" := PurchaseLine."Document Type"::"Return Order";
            PurchaseLine."Document No." := IntPurchaseReturn."document No.";
            PurchaseLine."Line No." := IntPurchaseReturn."Line No.";

            if IntPurchaseReturn.Type = IntPurchaseReturn.Type::Item then
                PurchaseLine.Type := PurchaseLine.Type::Item;

            PurchaseLine.Validate("No.", IntPurchaseReturn."Item No.");

            PurchaseLine.Description := IntPurchaseReturn.Description;
            PurchaseLine.validate(Quantity, IntPurchaseReturn.Quantity);
            PurchaseLine.validate("Direct Unit Cost", IntPurchaseReturn."Direct Unit Cost Excl. Vat");

            PurchaseLine."VAT Calculation Type" := PurchaseLine."VAT Calculation Type"::"Sales Tax";
            PurchaseLine."Tax Liable" := true;
            PurchaseLine."CADBR Operation Type" := PurchaseHeader."CADBR Operation Type";

            //Matrix Start
            if PurchaseHeader."CADBR operation type" = '' then begin
                if Vendor."Integration Taxes Matrix" <> '' then begin
                    TaxesMatrix.get(Vendor."Integration Taxes Matrix");
                    if TaxesMatrix."Tax Area Code" <> '' then
                        PurchaseLine."Tax Area Code" := TaxesMatrix."Tax Area Code";

                end;

                TaxConfig.Reset();
                TaxConfig.SetCurrentKey(Goal, "Type Code", "Item Code Ncm", "Vendor Code", "Customer Code", "UF Input", "UF Output", "Branch Code", "Local Service Provision", "Service Code");
                TaxConfig.SetRange(Goal, 2);
                TaxConfig.SetRange("Type Code", 1);
                TaxConfig.SetRange("Item Code Ncm", PurchaseLine."No.");
                TaxConfig.SetRange("vendor code", PurchaseLine."Buy-from Vendor No.");
                TaxConfig.SetRange("Branch Code", PurchaseLine."CADBR Branch Code");
                TaxConfig.setrange("Local Service Provision", '');
                TaxConfig.setrange("Service Code", '');
                if TaxConfig.FindFirst() then begin
                    if PurchaseLine."CADBR Operation Type" = '' then
                        PurchaseLine."Tax Area Code" := TaxConfig."Tax Area Code Input"
                end else begin
                    TaxConfig.Reset();
                    TaxConfig.SetCurrentKey(Goal, "Type Code", "Item Code Ncm", "Vendor Code", "Customer Code", "UF Input", "UF Output", "Branch Code", "Local Service Provision", "Service Code");
                    TaxConfig.SetRange(Goal, 2);
                    TaxConfig.SetRange("Type Code", 2);
                    TaxConfig.SetRange("Item Code Ncm", PurchaseLine."CADBR NCM Code");
                    TaxConfig.SetRange("vendor code", PurchaseLine."Buy-from Vendor No.");
                    TaxConfig.SetRange("Branch Code", PurchaseLine."CADBR Branch Code");
                    TaxConfig.setrange("Local Service Provision", '');
                    TaxConfig.setrange("Service Code", '');
                    if TaxConfig.FindFirst() then begin
                        if PurchaseLine."CADBR operation type" = '' then
                            PurchaseLine."Tax Area Code" := TaxConfig."Tax Area Code Input"
                    end else begin
                        TaxConfig.Reset();
                        TaxConfig.SetCurrentKey(Goal, "Type Code", "Item Code Ncm", "Vendor Code", "Customer Code", "UF Input", "UF Output", "Branch Code", "Local Service Provision", "Service Code");
                        TaxConfig.SetRange(Goal, 2);
                        TaxConfig.SetRange("Type Code", 1);
                        TaxConfig.SetRange("Item Code Ncm", PurchaseLine."No.");
                        TaxConfig.SetRange("Vendor code", '');
                        TaxConfig.SetRange("Branch Code", PurchaseLine."CADBR Branch Code");
                        TaxConfig.setrange("Local Service Provision", '');
                        TaxConfig.setrange("Service Code", '');
                        if TaxConfig.FindFirst() then begin
                            if PurchaseLine."CADBR Operation Type" = '' then
                                PurchaseLine."Tax Area Code" := TaxConfig."Tax Area Code Input"
                        end else begin
                            TaxConfig.Reset();
                            TaxConfig.SetCurrentKey(Goal, "Type Code", "Item Code Ncm", "Vendor Code", "Customer Code", "UF Input", "UF Output", "Branch Code", "Local Service Provision", "Service Code");
                            TaxConfig.SetRange(Goal, 2);
                            TaxConfig.SetRange("Type Code", 2);
                            TaxConfig.SetRange("Item Code Ncm", PurchaseLine."CADBR NCM Code");
                            TaxConfig.SetRange("Vendor code", '');
                            TaxConfig.SetRange("Branch Code", PurchaseLine."CADBR Branch Code");
                            TaxConfig.setrange("Local Service Provision", '');
                            TaxConfig.setrange("Service Code", '');
                            if TaxConfig.FindFirst() then begin
                                if PurchaseLine."CADBR operation type" = '' then
                                    PurchaseLine."Tax Area Code" := TaxConfig."Tax Area Code Input"
                            end else begin
                                TaxConfig.Reset();
                                TaxConfig.SetCurrentKey(Goal, "Type Code", "Item Code Ncm", "Vendor Code", "Customer Code", "UF Input", "UF Output", "Branch Code", "Local Service Provision", "Service Code");
                                TaxConfig.SetRange(Goal, 2);
                                TaxConfig.SetRange("Item Code Ncm", '');
                                TaxConfig.SetRange("vendor code", PurchaseLine."Buy-from Vendor No.");
                                TaxConfig.SetRange("UF input", '');
                                TaxConfig.SetRange("Branch Code", PurchaseLine."CADBR Branch Code");
                                if TaxConfig.FindFirst() then begin
                                    if PurchaseLine."CADBR Operation Type" = '' then
                                        PurchaseLine."Tax Area Code" := TaxConfig."Tax Area Code Input"
                                end else begin
                                    TaxConfig.Reset();
                                    TaxConfig.SetCurrentKey(Goal, "Type Code", "Item Code Ncm", "Vendor Code", "Customer Code", "UF Input", "UF Output", "Branch Code", "Local Service Provision", "Service Code");
                                    TaxConfig.SetRange(Goal, 2);
                                    TaxConfig.SetRange("Item Code Ncm", '');
                                    TaxConfig.SetRange("Vendor code", '');
                                    TaxConfig.SetRange("UF input", PurchaseHeader."CADBR Buy-from Territory Code");
                                    TaxConfig.SetRange("Branch Code", PurchaseLine."CADBR Branch Code");
                                    if TaxConfig.FindFirst() then begin
                                        if PurchaseLine."CADBR Operation Type" = '' then
                                            PurchaseLine."Tax Area Code" := TaxConfig."Tax Area Code Input"
                                    end else begin
                                        TaxConfig.Reset();
                                        TaxConfig.SetCurrentKey(Goal, "Type Code", "Item Code Ncm", "Vendor Code", "Customer Code", "UF Input", "UF Output", "Branch Code", "Local Service Provision", "Service Code");
                                        TaxConfig.SetRange(Goal, 2);
                                        TaxConfig.SetRange("Type Code", 1);
                                        TaxConfig.SetRange("Item Code Ncm", PurchaseLine."No.");
                                        TaxConfig.SetRange("Vendor code", '');
                                        TaxConfig.SetRange("Branch Code", PurchaseLine."CADBR Branch Code");
                                        TaxConfig.Setfilter("Local Service Provision", PurchaseHeader."CADBR Service Delivery City");
                                        TaxConfig.SetRange("Service Code", PurchaseLine."CADBR Service Code");
                                        if TaxConfig.FindFirst() then
                                            if PurchaseLine."CADBR Operation Type" = '' then
                                                PurchaseLine."Tax Area Code" := TaxConfig."Tax Area Code Input"

                                    end;
                                end;
                            end;
                        end;
                    end;
                end;
            End;
            //Matrix End

            PurchaseLine.ValidateShortcutDimCode(1, IntPurchaseReturn."Shortcut Dimension 1 Code");
            PurchaseLine.ValidateShortcutDimCode(2, IntPurchaseReturn."Shortcut Dimension 2 Code");
            PurchaseLine.ValidateShortcutDimCode(3, IntPurchaseReturn."Shortcut Dimension 3 Code");
            PurchaseLine.ValidateShortcutDimCode(4, IntPurchaseReturn."Shortcut Dimension 4 Code");
            PurchaseLine.ValidateShortcutDimCode(5, IntPurchaseReturn."Shortcut Dimension 5 Code");
            PurchaseLine.ValidateShortcutDimCode(6, IntPurchaseReturn."Shortcut Dimension 6 Code");


            PurchaseLine.Insert();

            IntPurchaseReturn.Status := IntPurchaseReturn.Status::Created;
            IntPurchaseReturn.Modify();

            CalcTax(IntPurchaseReturn);


        end;


    end;

    procedure CreatePostOrder(IntPurchaseReturn: Record "Integration Purchase Return")
    var
        PurchaseHeader: Record "Purchase Header";
        IntPurchRet: Record "Integration Purchase Return";
        PurchPost: codeunit "Purch.-Post";


    begin
        booHideDialog := true;

        if PurchaseHeader.get(PurchaseHeader."Document Type"::"Return Order", IntPurchaseReturn."document No.") then begin
            PurchPost.Run(PurchaseHeader);
            IntPurchaseReturn.Status := IntPurchaseReturn.Status::Posted;
            IntPurchaseReturn.Modify();
        end else
            if IntPurchaseReturn.Status <> IntPurchaseReturn.Status::Posted then begin
                IntPurchRet.Reset();
                IntPurchRet.SetRange("document No.", IntPurchaseReturn."document No.");
                if IntPurchRet.FindFirst() then
                    if IntPurchRet.Status = IntPurchRet.Status::Posted then begin
                        IntPurchaseReturn.Status := IntPurchaseReturn.Status::Posted;
                        IntPurchaseReturn.Modify();

                    end;
            end;

    end;


    procedure ValidateIntPurchase(IntPurchaseReturn: Record "Integration Purchase Return"): Boolean;
    var
        Vendor: Record Vendor;
        Item: Record Item;
        GeneralPostingSetup: Record "General Posting Setup";
        GLAccount: Record "G/L Account";
        Usgaap: Record "From/To US GAAP";
        Cust01Err: label 'Customer %1 Not Found', Comment = '%1 - Customer No.';
        Item01Err: label ' - Item %1 Not Found', Comment = '%1 - Item No.';
        GL01Err: label ' - G/L Account not sent by GP';
        GL02Err: label ' - G/L Account GP %1 different from G/L Account %2', Comment = '%1 - G/L Accoun No. , %2 - G/L Accoun No.';

    begin

        if not Vendor.Get(IntPurchaseReturn."Buy-from Vendor No.") then begin
            IntPurchaseReturn."Posting Message" := StrSubstNo(Cust01Err, IntPurchaseReturn."Buy-from Vendor No.");
            IntPurchaseReturn.Modify();
        end;

        if not Item.get(IntPurchaseReturn."Item No.") then begin
            IntPurchaseReturn."Posting Message" += StrSubstNo(Item01Err, IntPurchaseReturn."Item No.");
            IntPurchaseReturn.Modify();
        end else begin

            if Item."Base Unit of Measure" = '' then
                IntPurchaseReturn."Posting Message" += 'Base Unit of Measure Not Found';

            if Item."Sales Unit of Measure" = '' then
                IntPurchaseReturn."Posting Message" += 'Sales Unit of Measure Not Found';

            if Item."Purch. Unit of Measure" = '' then
                IntPurchaseReturn."Posting Message" += 'Purch. Unit of Measure Not Found';

            IntPurchaseReturn.Modify();
        end;

        if IntPurchaseReturn."G/L Account" = '' then begin
            IntPurchaseReturn."Posting Message" += GL01Err;
            IntPurchaseReturn.Modify();
        end else
            if GeneralPostingSetup.get(Vendor."Gen. Bus. Posting Group", Item."Gen. Prod. Posting Group") then
                if GLAccount.Get(GeneralPostingSetup."Purch. Credit Memo Account") then
                    if (GLAccount."No. 2" <> IntPurchaseReturn."G/L Account") then begin
                        Usgaap.Reset();
                        Usgaap.SetRange("US GAAP", IntPurchaseReturn."G/L Account");
                        Usgaap.SetRange("BR GAAP", GeneralPostingSetup."Purch. Account");
                        if not Usgaap.FindFirst() then begin
                            IntPurchaseReturn."Posting Message" += StrSubstNo(GL02Err, IntPurchaseReturn."G/L Account", GeneralPostingSetup."Sales Account");
                            IntPurchaseReturn.Modify();
                        end;
                    end;

        if IntPurchaseReturn."Shortcut Dimension 1 Code" <> '' then
            if not ValidateDim(1, IntPurchaseReturn."Shortcut Dimension 1 Code") then
                CreateDim(1, IntPurchaseReturn."Shortcut Dimension 1 Code");

        if IntPurchaseReturn."Shortcut Dimension 2 Code" <> '' then
            if not ValidateDim(2, IntPurchaseReturn."Shortcut Dimension 2 Code") then
                CreateDim(2, IntPurchaseReturn."Shortcut Dimension 2 Code");

        if IntPurchaseReturn."Shortcut Dimension 3 Code" <> '' then
            if not ValidateDim(3, IntPurchaseReturn."Shortcut Dimension 3 Code") then
                CreateDim(3, IntPurchaseReturn."Shortcut Dimension 3 Code");

        if IntPurchaseReturn."Shortcut Dimension 4 Code" <> '' then
            if not ValidateDim(4, IntPurchaseReturn."Shortcut Dimension 4 Code") then
                CreateDim(4, IntPurchaseReturn."Shortcut Dimension 4 Code");

        if IntPurchaseReturn."Shortcut Dimension 5 Code" <> '' then
            if not ValidateDim(5, IntPurchaseReturn."Shortcut Dimension 5 Code") then
                CreateDim(5, IntPurchaseReturn."Shortcut Dimension 5 Code");

        if IntPurchaseReturn."Shortcut Dimension 6 Code" <> '' then
            if not ValidateDim(6, IntPurchaseReturn."Shortcut Dimension 6 Code") then
                CreateDim(6, IntPurchaseReturn."Shortcut Dimension 6 Code");

        if IntPurchaseReturn."Posting Message" <> '' then begin
            IntPurchaseReturn.Status := IntPurchaseReturn.Status::"Data Error";
            IntPurchaseReturn.Modify();

            exit(true);

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

    procedure CalcTax(IntPurchaseReturn: Record "Integration Purchase Return"): Boolean;
    var
        PurchaseHeader: Record "Purchase Header";
        TempTaxAmountLine: Record "CADBR Tax Amount Line" temporary;
        TaxCalculate: codeunit "CADBR Tax Calculate";

    begin
        if PurchaseHeader.get(PurchaseHeader."Document Type"::Order, IntPurchaseReturn."document No.") then begin

            TempTaxAmountLine.Reset();
            TempTaxAmountLine.DeleteAll();
            TaxCalculate.CalculatePurchDoc(PurchaseHeader, TempTaxAmountLine);

            TempTaxAmountLine.Reset();
            TempTaxAmountLine.SetRange("Tax Identification", TempTaxAmountLine."tax identification"::IRRF);
            TempTaxAmountLine.SetRange("Document Line No.", IntPurchaseReturn."Line No.");
            if TempTaxAmountLine.FindFirst() then
                IntPurchaseReturn."Order IRRF Ret" := Abs(TempTaxAmountLine."Tax Amount");

            TempTaxAmountLine.Reset();
            TempTaxAmountLine.SetRange("Tax Identification", TempTaxAmountLine."tax identification"::"CSL Ret.");
            TempTaxAmountLine.SetRange("Document Line No.", IntPurchaseReturn."Line No.");
            if TempTaxAmountLine.FindFirst() then
                IntPurchaseReturn."Order CSRF Ret" := Abs(TempTaxAmountLine."Tax Amount");

            TempTaxAmountLine.Reset();
            TempTaxAmountLine.SetRange("Tax Identification", TempTaxAmountLine."tax identification"::"INSS Ret.");
            TempTaxAmountLine.SetRange("Document Line No.", IntPurchaseReturn."Line No.");
            if TempTaxAmountLine.FindFirst() then
                IntPurchaseReturn."Order INSS Ret" := Abs(TempTaxAmountLine."Tax Amount");

            TempTaxAmountLine.Reset();
            TempTaxAmountLine.SetRange("Tax Identification", TempTaxAmountLine."tax identification"::"ISS Ret.");
            TempTaxAmountLine.SetRange("Document Line No.", IntPurchaseReturn."Line No.");
            if TempTaxAmountLine.FindFirst() then
                IntPurchaseReturn."Order ISS Ret" := Abs(TempTaxAmountLine."Tax Amount");

            TempTaxAmountLine.Reset();
            TempTaxAmountLine.SetRange("Tax Identification", TempTaxAmountLine."tax identification"::PIS);
            TempTaxAmountLine.SetRange("Document Line No.", IntPurchaseReturn."Line No.");
            if TempTaxAmountLine.FindFirst() then
                IntPurchaseReturn."Order PIS Credit" := Abs(TempTaxAmountLine."Tax Amount");

            TempTaxAmountLine.Reset();
            TempTaxAmountLine.SetRange("Tax Identification", TempTaxAmountLine."tax identification"::COFINS);
            TempTaxAmountLine.SetRange("Document Line No.", IntPurchaseReturn."Line No.");
            if TempTaxAmountLine.FindFirst() then
                IntPurchaseReturn."Order Cofins Credit" := Abs(TempTaxAmountLine."Tax Amount");

            IntPurchaseReturn.Modify();

        end;

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

    var
        DimensionCode: Code[20];
        booHideDialog: Boolean;
        booIsHandled: Boolean;
        WindDialog: Dialog;


}