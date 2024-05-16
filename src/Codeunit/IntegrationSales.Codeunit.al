codeunit 50010 IntegrationSales
{
    procedure CreateSales(var intSales: Record IntegrationSales)
    var
        IntegrationSales: Record IntegrationSales;
        DialogCreSalesLbl: label 'Create Sales Order   #1#############', Comment = '#1 IntegrationSales';
    begin

        IntegrationSales.Reset();
        IntegrationSales.CopyFilters(intSales);
        IntegrationSales.SetFilter(Status, '%1|%2', IntegrationSales.Status::Imported,
                                                   IntegrationSales.Status::"Data Error");
        if IntegrationSales.Find('-') then begin
            if GuiAllowed then
                WindDialog.Open(DialogCreSalesLbl);
            repeat
                if GuiAllowed then
                    WindDialog.Update(1, IntegrationSales."No.");

                IntegrationSales."Posting Message" := '';
                IntegrationSales.Modify();

                if not ValidateIntSales(IntegrationSales) then;

            until IntegrationSales.Next() = 0;

            if GuiAllowed then
                WindDialog.Close();

        end;

        IntegrationSales.Reset();
        IntegrationSales.CopyFilters(intSales);
        IntegrationSales.SetFilter(Status, '%1|%2', IntegrationSales.Status::Imported,
                                                   IntegrationSales.Status::"Data Error");
        IntegrationSales.CalcFields("Error Order");
        IntegrationSales.SetFilter("Error Order", '%1', 0);
        if IntegrationSales.Find('-') then begin
            if GuiAllowed then
                WindDialog.Open(DialogCreSalesLbl);
            repeat
                if GuiAllowed then
                    WindDialog.Update(1, IntegrationSales."No.");

                IntegrationSales."Posting Message" := '';
                IntegrationSales.Modify();

                if not ValidateIntSales(IntegrationSales) then
                    CreateSalesOrder(IntegrationSales);

            until IntegrationSales.Next() = 0;

            if GuiAllowed then
                WindDialog.Close();

        end;

    end;

    procedure PostSales(var intSales: Record IntegrationSales)
    var
        IntegrationSales: Record IntegrationSales;
    begin
        IntegrationSales.Reset();
        IntegrationSales.CopyFilters(intSales);
        IntegrationSales.SetFilter(Status, '%1', IntegrationSales.Status::Created);
        IntegrationSales.CalcFields("Error Order");
        IntegrationSales.SetFilter("Error Order", '%1', 0);
        if IntegrationSales.Find('-') then
            repeat

                CreatePostOrder(IntegrationSales);
                Commit();

            until IntegrationSales.Next() = 0;

    end;

    procedure CreateSalesOrder(IntegrationSales: Record IntegrationSales)
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
        IntSalesVal: Record IntegrationSales;
        TempTaxAmountLine: Record "CADBR Tax Amount Line" temporary;
        TaxCalculate: codeunit "CADBR Tax Calculate";

    begin

        SalesHeader.Reset();
        if not SalesHeader.Get(SalesHeader."Document Type"::Order, IntegrationSales."No.") then begin

            SalesHeader.Init();
            SalesHeader."Document Type" := SalesHeader."Document Type"::Order;
            SalesHeader."No." := IntegrationSales."No.";
            SalesHeader.Validate("CADBR Branch Code", IntegrationSales."Shortcut Dimension 6 Code");
            SalesHeader.Validate("Sell-to Customer No.", IntegrationSales."Sell-to Customer No.");
            SalesHeader."Your Reference" := IntegrationSales."Your Reference";
            SalesHeader."Order Date" := IntegrationSales."Order Date";
            SalesHeader."Posting Date" := IntegrationSales."Posting Date";
            SalesHeader."Document Date" := IntegrationSales."Document Date";
            SalesHeader."VAT Reporting Date" := IntegrationSales."Posting Date";
            SalesHeader."External Document No." := IntegrationSales."External Document No.";
            SalesHeader.validate("Payment Terms Code");

            if IntegrationSales."Freight Billed To" = IntegrationSales."Freight Billed To"::"Without Freight" then
                SalesHeader."CADBR Freight Billed To" := SalesHeader."CADBR Freight Billed To"::"Without Freight";

            if IntegrationSales."Customer Posting Group" <> '' then
                SalesHeader."Customer Posting Group" := IntegrationSales."Customer Posting Group";

            SalesHeader.Ship := true;
            SalesHeader.Invoice := true;
            SalesHeader."Posting No." := IntegrationSales."No.";
            SalesHeader.Insert();

            SalesHeader.ValidateShortcutDimCode(1, IntegrationSales."Shortcut Dimension 1 Code");
            SalesHeader.ValidateShortcutDimCode(2, IntegrationSales."Shortcut Dimension 2 Code");

            SalesHeader.Status := SalesHeader.Status::Open;

            SalesHeader.ValidateShortcutDimCode(3, IntegrationSales."Shortcut Dimension 3 Code");
            SalesHeader.ValidateShortcutDimCode(4, IntegrationSales."Shortcut Dimension 4 Code");
            SalesHeader.ValidateShortcutDimCode(5, IntegrationSales."Shortcut Dimension 5 Code");
            SalesHeader.ValidateShortcutDimCode(6, IntegrationSales."Shortcut Dimension 6 Code");
            SalesHeader.Modify();

        end;

        //Sales Line
        SalesLine.Reset();
        if not SalesLine.get(SalesLine."Document Type"::Order, IntegrationSales."No.", IntegrationSales."Line No.") then begin

            SalesLine.Init();
            SalesLine."Document Type" := SalesLine."Document Type"::Order;
            SalesLine."Document No." := IntegrationSales."No.";
            SalesLine."Line No." := IntegrationSales."Line No.";

            if IntegrationSales.Type = IntegrationSales.Type::Item then
                SalesLine.Type := SalesLine.Type::Item;

            SalesLine.Validate("No.", IntegrationSales."Item No.");

            SalesLine.Description := IntegrationSales.Description;
            SalesLine.validate(Quantity, IntegrationSales.Quantity);
            SalesLine.validate("Unit Price", IntegrationSales."Unit Price" +
                                             IntegrationSales."Tax From Billing APP (PIS)" +
                                             IntegrationSales."Tax From Billing APP (COFINS)");

            SalesLine."VAT Calculation Type" := SalesLine."VAT Calculation Type"::"Sales Tax";
            SalesLine."Tax Liable" := true;
            SalesLine."CADBR Operation Type" := SalesHeader."CADBR Operation Type";

            SalesLine."TAX FROM BILLING APP (PIS)" := IntegrationSales."Tax From Billing APP (PIS)";
            SalesLine."TAX FROM BILLING APP (COFINS)" := IntegrationSales."Tax From Billing APP (COFINS)";

            SalesLine.ValidateShortcutDimCode(1, IntegrationSales."Shortcut Dimension 1 Code");
            SalesLine.ValidateShortcutDimCode(2, IntegrationSales."Shortcut Dimension 2 Code");
            SalesLine.ValidateShortcutDimCode(3, IntegrationSales."Shortcut Dimension 3 Code");
            SalesLine.ValidateShortcutDimCode(4, IntegrationSales."Shortcut Dimension 4 Code");
            SalesLine.ValidateShortcutDimCode(5, IntegrationSales."Shortcut Dimension 5 Code");
            SalesLine.ValidateShortcutDimCode(6, IntegrationSales."Shortcut Dimension 6 Code");

            SalesLine.Insert();


        end;


        IntegrationSales."Posting Message" := '';
        IntegrationSales.Status := IntegrationSales.Status::Created;
        IntegrationSales.Modify();

        if SalesHeader.get(SalesHeader."Document Type"::Order, IntegrationSales."No.") then begin

            TempTaxAmountLine.Reset();
            TempTaxAmountLine.DeleteAll();
            TaxCalculate.CalculateSalesDoc(SalesHeader, TempTaxAmountLine);

            TempTaxAmountLine.Reset();
            TempTaxAmountLine.SetRange("Tax Identification", TempTaxAmountLine."tax identification"::PIS);
            TempTaxAmountLine.SetRange("Document Line No.", IntegrationSales."Line No.");
            if TempTaxAmountLine.FindFirst() then
                IntegrationSales."Tax (PIS) line" := Abs(TempTaxAmountLine."Tax Amount");

            TempTaxAmountLine.Reset();
            TempTaxAmountLine.SetRange("Tax Identification", TempTaxAmountLine."tax identification"::COFINS);
            TempTaxAmountLine.SetRange("Document Line No.", IntegrationSales."Line No.");
            if TempTaxAmountLine.FindFirst() then
                IntegrationSales."Tax (cofins) Line" := Abs(TempTaxAmountLine."Tax Amount");

            IntegrationSales.Modify();

        end;

        SalesReceivablesSetup.Get();

        if IntSalesVal.Get(IntegrationSales."No.", 1) then begin

            IntSalesVal.calcfields("Tax (COFINS) Order");
            IntSalesVal.calcfields("Tax (PIS) Order");

            if (IntSalesVal."Tax (COFINS) Order" <> 0) and (IntSalesVal."Tax From Billing APP (COFINS)" = 0) then
                IntegrationSales."Posting Message" += '-Dif COFINS error';

            if (IntSalesVal."Tax (COFINS) Order" = 0) and (IntSalesVal."Tax From Billing APP (COFINS)" <> 0) then
                IntegrationSales."Posting Message" += '-Dif COFINS error';

            if IntSalesVal."Tax (COFINS) Order" <> IntSalesVal."Tax From Billing APP (COFINS)" then
                if IntSalesVal."Tax From Billing APP (COFINS)" <> 0 then
                    if Abs(1 - (IntSalesVal."Tax (COFINS) Order" / IntSalesVal."Tax From Billing APP (COFINS)")) >
                            SalesReceivablesSetup."Int Tax Difference Allowed" then
                        IntegrationSales."Posting Message" += '-Dif COFINS error';

            if (IntSalesVal."Tax (PIS) Order" <> 0) and (IntSalesVal."Tax From Billing APP (PIS)" = 0) then
                IntegrationSales."Posting Message" += '-Dif COFINS error';

            if (IntSalesVal."Tax (PIS) Order" = 0) and (IntSalesVal."Tax From Billing APP (PIS)" <> 0) then
                IntegrationSales."Posting Message" += '-Dif COFINS error';

            if IntSalesVal."Tax (PIS) Order" <> IntSalesVal."Tax From Billing APP (PIS)" then
                if IntSalesVal."Tax From Billing APP (PIS)" <> 0 then
                    if Abs(1 - (IntSalesVal."Tax (PIS) Order" / IntSalesVal."Tax From Billing APP (PIS)")) >
                            SalesReceivablesSetup."Int Tax Difference Allowed" then
                        IntegrationSales."Posting Message" += '-Dif PIS error';

            if IntegrationSales."Posting Message" <> '' then
                IntegrationSales.Status := IntegrationSales.Status::"Data Error";

            IntegrationSales.Modify();

        end;

    end;

    procedure CreatePostOrder(IntegrationSales: Record IntegrationSales)
    var
        SalesHeader: Record "Sales Header";
        IntSales: Record IntegrationSales;
        SalesPost: codeunit "sales-post";

    begin
        booHideDialog := true;

        if SalesHeader.get(SalesHeader."Document Type"::Order, IntegrationSales."No.") then begin
            SalesPost.Run(SalesHeader);
            IntegrationSales.Status := IntegrationSales.Status::Posted;
            IntegrationSales.Modify();
        end else
            if IntegrationSales.Status <> IntegrationSales.Status::Posted then begin
                IntSales.Reset();
                IntSales.SetRange("No.", IntegrationSales."No.");
                if IntSales.FindFirst() then
                    if IntSales.Status = IntSales.Status::Posted then begin
                        IntegrationSales.Status := IntegrationSales.Status::Posted;
                        IntegrationSales.Modify();

                    end;
            end;

    end;

    procedure ValidateIntSales(IntegrationSales: Record IntegrationSales): Boolean;
    var
        Customer: Record Customer;
        Item: Record Item;
        GeneralPostingSetup: Record "General Posting Setup";
        GLAccount: Record "G/L Account";
        Usgaap: Record "From/To US GAAP";
        Cust01Err: label 'Customer %1 Not Found', Comment = '%1 - Customer No.';
        Item01Err: label ' - Item %1 Not Found', Comment = '%1 - Item No.';
        GL01Err: label ' - G/L Account not sent by GP';
        GL02Err: label ' - G/L Account GP %1 different from G/L Account %2', Comment = '%1 - G/L Accoun No. , %2 - G/L Accoun No.';

    begin

        if not Customer.Get(IntegrationSales."Sell-to Customer No.") then begin
            IntegrationSales."Posting Message" := StrSubstNo(Cust01Err, IntegrationSales."Sell-to Customer No.");
            IntegrationSales.Modify();
        end;

        if not Item.get(IntegrationSales."Item No.") then begin
            IntegrationSales."Posting Message" += StrSubstNo(Item01Err, IntegrationSales."Item No.");
            IntegrationSales.Modify();
        end;

        if IntegrationSales."G/L Account" = '' then begin
            IntegrationSales."Posting Message" += GL01Err;
            IntegrationSales.Modify();
        end else
            if GeneralPostingSetup.get(Customer."Gen. Bus. Posting Group", Item."Gen. Prod. Posting Group") then
                if GLAccount.Get(GeneralPostingSetup."Sales Account") then
                    if (GLAccount."No. 2" <> IntegrationSales."G/L Account") then begin
                        Usgaap.Reset();
                        Usgaap.SetRange("US GAAP", IntegrationSales."G/L Account");
                        Usgaap.SetRange("BR GAAP", GeneralPostingSetup."Sales Account");
                        if not Usgaap.FindFirst() then begin
                            IntegrationSales."Posting Message" += StrSubstNo(GL02Err, IntegrationSales."G/L Account", GeneralPostingSetup."Sales Account");
                            IntegrationSales.Modify();
                        end;
                    end;

        if IntegrationSales."Shortcut Dimension 1 Code" <> '' then
            if not ValidateDim(1, IntegrationSales."Shortcut Dimension 1 Code") then
                CreateDim(1, IntegrationSales."Shortcut Dimension 1 Code");

        if IntegrationSales."Shortcut Dimension 2 Code" <> '' then
            if not ValidateDim(2, IntegrationSales."Shortcut Dimension 2 Code") then
                CreateDim(2, IntegrationSales."Shortcut Dimension 2 Code");

        if IntegrationSales."Shortcut Dimension 3 Code" <> '' then
            if not ValidateDim(3, IntegrationSales."Shortcut Dimension 3 Code") then
                CreateDim(3, IntegrationSales."Shortcut Dimension 3 Code");

        if IntegrationSales."Shortcut Dimension 4 Code" <> '' then
            if not ValidateDim(4, IntegrationSales."Shortcut Dimension 4 Code") then
                CreateDim(4, IntegrationSales."Shortcut Dimension 4 Code");

        if IntegrationSales."Shortcut Dimension 5 Code" <> '' then
            if not ValidateDim(5, IntegrationSales."Shortcut Dimension 5 Code") then
                CreateDim(5, IntegrationSales."Shortcut Dimension 5 Code");

        if IntegrationSales."Shortcut Dimension 6 Code" <> '' then
            if not ValidateDim(6, IntegrationSales."Shortcut Dimension 6 Code") then
                CreateDim(6, IntegrationSales."Shortcut Dimension 6 Code");

        if IntegrationSales."Posting Message" <> '' then begin
            IntegrationSales.Status := IntegrationSales.Status::"Data Error";
            IntegrationSales.Modify();

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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforePostSalesDoc', '', false, false)]
    local procedure OnBeforePostSalesDocSalesPost(var HideProgressWindow: Boolean)
    begin
        HideProgressWindow := booHideDialog;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforeCheckHeaderPostingType', '', false, false)]
    local procedure OnBeforeCheckHeaderPostingTypeSalesPost(var IsHandled: Boolean)
    begin
        IsHandled := booIsHandled;
    end;

    var
        DimensionCode: Code[20];
        booHideDialog: Boolean;
        booIsHandled: Boolean;
        WindDialog: Dialog;


}