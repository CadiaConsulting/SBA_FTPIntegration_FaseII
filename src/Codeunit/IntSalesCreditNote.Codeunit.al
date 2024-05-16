codeunit 50012 IntSalesCreditNote
{
    procedure CreateSalesCredit(var InsSalescred: Record IntSalesCreditNote)
    var
        IntSalesCreditNote: Record IntSalesCreditNote;
        DialogCreSalesLbl: label 'Create Sales Return Order   #1#############', Comment = '#1 IntegrationSalesReturn';
    begin

        IntSalesCreditNote.Reset();
        IntSalesCreditNote.CopyFilters(InsSalescred);
        IntSalesCreditNote.SetFilter(Status, '%1|%2', IntSalesCreditNote.Status::Imported,
                                                   IntSalesCreditNote.Status::"Data Error");
        if IntSalesCreditNote.Find('-') then begin
            if GuiAllowed then
                WindDialog.Open(DialogCreSalesLbl);
            repeat
                if GuiAllowed then
                    WindDialog.Update(1, IntSalesCreditNote."No.");

                IntSalesCreditNote."Posting Message" := '';
                IntSalesCreditNote.Modify();

                if not ValidateIntSalesCredit(IntSalesCreditNote) then;

            until IntSalesCreditNote.Next() = 0;

            if GuiAllowed then
                WindDialog.Close();
        end;

        IntSalesCreditNote.Reset();
        IntSalesCreditNote.CopyFilters(InsSalescred);
        IntSalesCreditNote.SetFilter(Status, '%1|%2', IntSalesCreditNote.Status::Imported,
                                                   IntSalesCreditNote.Status::"Data Error");
        IntSalesCreditNote.CalcFields("Error Order");
        IntSalesCreditNote.SetFilter("Error Order", '%1', 0);
        if IntSalesCreditNote.Find('-') then begin
            if GuiAllowed then
                WindDialog.Open(DialogCreSalesLbl);
            repeat
                if GuiAllowed then
                    WindDialog.Update(1, IntSalesCreditNote."No.");

                IntSalesCreditNote."Posting Message" := '';
                IntSalesCreditNote.Modify();

                if not ValidateIntSalesCredit(IntSalesCreditNote) then
                    CreateSalesCreditOrder(IntSalesCreditNote);

            until IntSalesCreditNote.Next() = 0;

            if GuiAllowed then
                WindDialog.Close();
        end;
    end;

    procedure PostSalesCredit(var InsSalescred: Record IntSalesCreditNote)
    var
        IntSalesCreditNote: Record IntSalesCreditNote;
    begin
        IntSalesCreditNote.Reset();
        IntSalesCreditNote.CopyFilters(InsSalescred);
        IntSalesCreditNote.SetFilter(Status, '%1', IntSalesCreditNote.Status::Created);
        IntSalesCreditNote.CalcFields("Error Order");
        IntSalesCreditNote.SetFilter("Error Order", '%1', 0);
        if IntSalesCreditNote.Find('-') then
            repeat

                CreatePostCredit(IntSalesCreditNote);
                Commit();

            until IntSalesCreditNote.Next() = 0;

    end;

    procedure CreateSalesCreditOrder(IntSalescreditNote: Record IntSalesCreditNote)
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        IntSalesCredi: Record IntSalesCreditNote;
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
        Cust: Record Customer;
        taxesMatrix: Record "CADBR Taxes Matrix";
        TaxConfig: Record "CADBR Tax Setup Sales Purchase";
        TempTaxAmountLine: Record "CADBR Tax Amount Line" temporary;
        TaxCalculate: codeunit "CADBR Tax Calculate";
    begin

        SalesHeader.Reset();
        if not SalesHeader.Get(SalesHeader."Document Type"::"Return Order", IntSalescreditNote."No.") then begin

            SalesHeader.Init();
            SalesHeader."Document Type" := SalesHeader."Document Type"::"Return Order";
            SalesHeader."No." := IntSalescreditNote."No.";
            SalesHeader.Validate("CADBR Branch Code", IntSalescreditNote."Shortcut Dimension 6 Code");
            SalesHeader.Validate("Sell-to Customer No.", IntSalescreditNote."Sell-to Customer No.");
            SalesHeader."Your Reference" := IntSalescreditNote."Your Reference";
            SalesHeader."Order Date" := IntSalescreditNote."Order Date";
            SalesHeader."Posting Date" := IntSalescreditNote."Posting Date";
            SalesHeader."Document Date" := IntSalescreditNote."Document Date";
            SalesHeader."VAT Reporting Date" := IntSalescreditNote."Posting Date";

            if IntSalescreditNote."External Document No." <> '' then
                SalesHeader."External Document No." := IntSalescreditNote."External Document No."
            else
                SalesHeader."External Document No." := IntSalescreditNote."Your Reference";

            if IntSalescreditNote."Customer Posting Group" <> '' then
                SalesHeader."Customer Posting Group" := IntSalescreditNote."Customer Posting Group";

            if IntSalescreditNote."Freight Billed To" = IntSalescreditNote."Freight Billed To"::"Without Freight" then
                SalesHeader."CADBR Freight Billed To" := SalesHeader."CADBR Freight Billed To"::"Without Freight";

            //Matrix Start
            Cust.get(SalesHeader."Sell-to Customer No.");

            if SalesHeader."CADBR operation type" = '' then
                if Cust."Integration Taxes Matrix" <> '' then
                    SalesHeader."CADBR Taxes Matrix Code" := cust."Integration Taxes Matrix";

            taxesMatrix.Get(SalesHeader."CADBR Taxes Matrix Code");
            SalesHeader.Validate("CADBR Operation Nature", taxesMatrix."Operation Nature");
            SalesHeader.Validate("CADBR Operation Type", taxesMatrix."Operation Type");
            SalesHeader.Validate("CADBR Fiscal Document Type", taxesMatrix."Fiscal Document Type");
            SalesHeader.Validate("Shipment Method Code", taxesMatrix."Shipment Method Code");

            if SalesHeader."CADBR End User" then
                case SalesHeader."CADBR Customer Situation" of
                    SalesHeader."CADBR Customer Situation"::"Same state":
                        SalesHeader.Validate("CADBR CFOP Code", taxesMatrix."CFOP - End User Same State");
                    SalesHeader."CADBR Customer Situation"::"Other state":
                        SalesHeader.Validate("CADBR CFOP Code", taxesMatrix."CFOP - End User Outside State");
                end
            else
                case SalesHeader."CADBR Customer Situation" of
                    SalesHeader."CADBR Customer Situation"::"Same state":
                        SalesHeader.Validate("CADBR CFOP Code", taxesMatrix."CFOP - Same State");
                    SalesHeader."CADBR Customer Situation"::"Other state":
                        SalesHeader.Validate("CADBR CFOP Code", taxesMatrix."CFOP - Outside State");
                    SalesHeader."CADBR Customer Situation"::"Outside Brasill":
                        SalesHeader.Validate("CADBR CFOP Code", taxesMatrix."CFOP - Outside Brazil");
                end;

            if taxesMatrix."Tax Area Code" <> '' then
                SalesHeader."Tax Area Code" := taxesMatrix."Tax Area Code"
            else
                SalesHeader."Tax Area Code" := Cust."Tax Area Code";

            SalesHeader.Validate("Payment Terms Code");
            //Matrix End
            SalesHeader.Receive := true;
            SalesHeader.Invoice := true;
            SalesHeader."Posting No." := IntSalescreditNote."No.";

            SalesHeader.Insert();

            SalesHeader.Status := SalesHeader.Status::Open;

            SalesHeader.ValidateShortcutDimCode(1, IntSalescreditNote."Shortcut Dimension 1 Code");
            SalesHeader.ValidateShortcutDimCode(2, IntSalescreditNote."Shortcut Dimension 2 Code");
            SalesHeader.ValidateShortcutDimCode(3, IntSalescreditNote."Shortcut Dimension 3 Code");
            SalesHeader.ValidateShortcutDimCode(4, IntSalescreditNote."Shortcut Dimension 4 Code");
            SalesHeader.ValidateShortcutDimCode(5, IntSalescreditNote."Shortcut Dimension 5 Code");
            SalesHeader.ValidateShortcutDimCode(6, IntSalescreditNote."Shortcut Dimension 6 Code");

            SalesHeader.Modify();

        end;

        //Sales Line
        SalesLine.Reset();
        if not SalesLine.get(SalesLine."Document Type"::"Return Order", IntSalescreditNote."No.", IntSalescreditNote."Line No.") then begin

            SalesLine.Init();
            SalesLine."Document Type" := SalesLine."Document Type"::"Return Order";
            SalesLine."Document No." := IntSalescreditNote."No.";
            SalesLine."Line No." := IntSalescreditNote."Line No.";

            if IntSalescreditNote.Type = IntSalescreditNote.Type::Item then
                SalesLine.Type := SalesLine.Type::Item;

            SalesLine.Validate("No.", IntSalescreditNote."Item No.");
            SalesLine.Description := IntSalescreditNote.Description;
            SalesLine.validate(Quantity, IntSalescreditNote.Quantity);
            SalesLine.validate("Unit Price", IntSalescreditNote."Unit Price" +
                                             IntSalescreditNote."Tax From Billing APP (PIS)" +
                                             IntSalescreditNote."Tax From Billing APP (COFINS)");

            SalesLine."VAT Calculation Type" := SalesLine."VAT Calculation Type"::"Sales Tax";
            SalesLine."Tax Liable" := true;
            SalesLine."CADBR Operation Type" := SalesHeader."CADBR Operation Type";

            //Matrix Start
            if SalesHeader."CADBR operation type" = '' then begin
                if Cust."Integration Taxes Matrix" <> '' then begin
                    TaxesMatrix.get(Cust."Integration Taxes Matrix");
                    if TaxesMatrix."Tax Area Code" <> '' then
                        SalesLine."Tax Area Code" := TaxesMatrix."Tax Area Code";

                end;

                TaxConfig.Reset();
                TaxConfig.SetCurrentKey(Goal, "Type Code", "Item Code Ncm", "Vendor Code", "Customer Code", "UF Input", "UF Output", "Branch Code", "Local Service Provision", "Service Code");
                TaxConfig.SetRange(Goal, 1);
                TaxConfig.SetRange("Type Code", 1);
                TaxConfig.SetRange("Item Code Ncm", SalesLine."No.");
                TaxConfig.SetRange("Customer code", SalesLine."Sell-to Customer No.");
                TaxConfig.SetRange("Branch Code", SalesLine."CADBR Branch Code");
                TaxConfig.setrange("Local Service Provision", '');
                if TaxConfig.FindFirst() then begin
                    if SalesLine."CADBR Operation Type" = '' then
                        SalesLine."Tax Area Code" := TaxConfig."Tax Area Code output"
                end else begin
                    TaxConfig.Reset();
                    TaxConfig.SetCurrentKey(Goal, "Type Code", "Item Code Ncm", "Vendor Code", "Customer Code", "UF Input", "UF Output", "Branch Code", "Local Service Provision", "Service Code");
                    TaxConfig.SetRange(Goal, 1);
                    TaxConfig.SetRange("Type Code", 2);
                    TaxConfig.SetRange("Item Code Ncm", SalesLine."CADBR NCM Code");
                    TaxConfig.SetRange("Customer code", SalesLine."Sell-to Customer No.");
                    TaxConfig.SetRange("Branch Code", SalesLine."CADBR Branch Code");
                    TaxConfig.setrange("Local Service Provision", '');
                    if TaxConfig.FindFirst() then begin
                        if SalesLine."CADBR Operation Type" = '' then
                            SalesLine."Tax Area Code" := TaxConfig."Tax Area Code output"
                    end else begin
                        TaxConfig.Reset();
                        TaxConfig.SetCurrentKey(Goal, "Type Code", "Item Code Ncm", "Vendor Code", "Customer Code", "UF Input", "UF Output", "Branch Code", "Local Service Provision", "Service Code");
                        TaxConfig.SetRange(Goal, 1);
                        TaxConfig.SetRange("Type Code", 1);
                        TaxConfig.SetRange("Item Code Ncm", SalesLine."No.");
                        TaxConfig.SetRange("Customer code", '');
                        TaxConfig.SetRange("Branch Code", SalesLine."CADBR Branch Code");
                        TaxConfig.setrange("Local Service Provision", '');
                        if TaxConfig.FindFirst() then begin
                            if SalesLine."CADBR Operation Type" = '' then
                                SalesLine."Tax Area Code" := TaxConfig."Tax Area Code output"
                        end else begin
                            TaxConfig.Reset();
                            TaxConfig.SetCurrentKey(Goal, "Type Code", "Item Code Ncm", "Vendor Code", "Customer Code", "UF Input", "UF Output", "Branch Code", "Local Service Provision", "Service Code");
                            TaxConfig.SetRange(Goal, 1);
                            TaxConfig.SetRange("Type Code", 2);
                            TaxConfig.SetRange("Item Code Ncm", SalesLine."CADBR NCM Code");
                            TaxConfig.SetRange("Customer code", '');
                            TaxConfig.SetRange("Branch Code", SalesLine."CADBR Branch Code");
                            TaxConfig.setrange("Local Service Provision", '');
                            if TaxConfig.FindFirst() then begin
                                if SalesLine."CADBR Operation Type" = '' then
                                    SalesLine."Tax Area Code" := TaxConfig."Tax Area Code output"
                            end else begin
                                TaxConfig.Reset();
                                TaxConfig.SetCurrentKey(Goal, "Type Code", "Item Code Ncm", "Vendor Code", "Customer Code", "UF Input", "UF Output", "Branch Code", "Local Service Provision", "Service Code");
                                TaxConfig.SetRange(Goal, 1);
                                TaxConfig.SetRange("Item Code Ncm", '');
                                TaxConfig.SetRange("Customer code", SalesLine."Sell-to Customer No.");
                                TaxConfig.SetRange("UF Output", '');
                                TaxConfig.SetRange("Branch Code", SalesLine."CADBR Branch Code");
                                if TaxConfig.FindFirst() then begin
                                    if SalesLine."CADBR Operation Type" = '' then
                                        SalesLine."Tax Area Code" := TaxConfig."Tax Area Code output"
                                end else begin
                                    TaxConfig.Reset();
                                    TaxConfig.SetCurrentKey(Goal, "Type Code", "Item Code Ncm", "Vendor Code", "Customer Code", "UF Input", "UF Output", "Branch Code", "Local Service Provision", "Service Code");
                                    TaxConfig.SetRange(Goal, 1);
                                    TaxConfig.SetRange("Item Code Ncm", '');
                                    TaxConfig.SetRange("Customer code", '');
                                    TaxConfig.SetRange("UF Output", SalesHeader."CADBR sell-to Territory Code");
                                    TaxConfig.SetRange("Branch Code", SalesLine."CADBR Branch Code");
                                    if TaxConfig.FindFirst() then begin
                                        if SalesLine."CADBR Operation Type" = '' then
                                            SalesLine."Tax Area Code" := TaxConfig."Tax Area Code output"
                                    end else
                                        if SalesHeader."CADBR Service Delivery City" <> '' then begin
                                            TaxConfig.Reset();
                                            TaxConfig.SetCurrentKey(Goal, "Type Code", "Item Code Ncm", "Vendor Code", "Customer Code", "UF Input", "UF Output", "Branch Code", "Local Service Provision", "Service Code");
                                            TaxConfig.SetRange(Goal, 1);
                                            TaxConfig.SetRange("Type Code", 1);
                                            TaxConfig.SetRange("Item Code Ncm", SalesLine."No.");
                                            TaxConfig.SetRange("Customer code", '');
                                            TaxConfig.SetRange("Branch Code", SalesLine."CADBR Branch Code");
                                            TaxConfig.SetRange("Local Service Provision", SalesHeader."CADBR Service Delivery City");
                                            if TaxConfig.FindFirst() then
                                                if SalesLine."CADBR Operation Type" = '' then
                                                    SalesLine."Tax Area Code" := TaxConfig."Tax Area Code output"

                                        end;

                                end;
                            end;
                        end;
                    end;
                end;
            end;
            //Matrix End

            SalesLine."TAX FROM BILLING APP (PIS)" := IntSalescreditNote."Tax From Billing APP (PIS)";
            SalesLine."TAX FROM BILLING APP (COFINS)" := IntSalescreditNote."Tax From Billing APP (COFINS)";

            SalesLine.ValidateShortcutDimCode(1, IntSalescreditNote."Shortcut Dimension 1 Code");
            SalesLine.ValidateShortcutDimCode(2, IntSalescreditNote."Shortcut Dimension 2 Code");
            SalesLine.ValidateShortcutDimCode(3, IntSalescreditNote."Shortcut Dimension 3 Code");
            SalesLine.ValidateShortcutDimCode(4, IntSalescreditNote."Shortcut Dimension 4 Code");
            SalesLine.ValidateShortcutDimCode(5, IntSalescreditNote."Shortcut Dimension 5 Code");
            SalesLine.ValidateShortcutDimCode(6, IntSalescreditNote."Shortcut Dimension 6 Code");

            SalesLine.Insert();

            IntSalescreditNote."Posting Message" := '';
            IntSalescreditNote.Status := IntSalescreditNote.Status::Created;
            IntSalescreditNote.Modify();
        end;

        if SalesHeader.get(SalesHeader."Document Type"::"Return Order", IntSalesCreditNote."No.") then begin

            TempTaxAmountLine.Reset();
            TempTaxAmountLine.DeleteAll();
            TaxCalculate.CalculateSalesDoc(SalesHeader, TempTaxAmountLine);

            TempTaxAmountLine.Reset();
            TempTaxAmountLine.SetRange("Tax Identification", TempTaxAmountLine."tax identification"::PIS);
            TempTaxAmountLine.SetRange("Document Line No.", IntSalesCreditNote."Line No.");
            if TempTaxAmountLine.FindFirst() then
                IntSalesCreditNote."Tax (PIS) Line" := Abs(TempTaxAmountLine."Tax Amount");

            TempTaxAmountLine.Reset();
            TempTaxAmountLine.SetRange("Tax Identification", TempTaxAmountLine."tax identification"::COFINS);
            TempTaxAmountLine.SetRange("Document Line No.", IntSalesCreditNote."Line No.");
            if TempTaxAmountLine.FindFirst() then
                IntSalesCreditNote."Tax (cofins) Line" := Abs(TempTaxAmountLine."Tax Amount");

            IntSalesCreditNote.Modify();

        end;

        SalesReceivablesSetup.Get();
        if IntSalesCredi.Get(IntSalesCreditNote."No.", 1) then begin

            IntSalesCredi.Calcfields("Tax (COFINS) Order");
            IntSalesCredi.Calcfields("Tax (PIS) Order");

            if (IntSalesCredi."Tax (COFINS) Order" <> 0) and (IntSalesCredi."Tax From Billing APP (COFINS)" = 0) then
                IntSalesCreditNote."Posting Message" += '-Dif COFINS error';

            if (IntSalesCredi."Tax (COFINS) Order" = 0) and (IntSalesCredi."Tax From Billing APP (COFINS)" <> 0) then
                IntSalesCreditNote."Posting Message" += '-Dif COFINS error';

            if IntSalesCredi."Tax (COFINS) Order" <> IntSalesCredi."Tax From Billing APP (COFINS)" then
                if IntSalesCredi."Tax From Billing APP (COFINS)" <> 0 then
                    if Abs(1 - (IntSalesCredi."Tax (COFINS) Order" / IntSalesCredi."Tax From Billing APP (COFINS)")) >
                            SalesReceivablesSetup."Int Tax Difference Allowed" then
                        IntSalesCreditNote."Posting Message" += '-Dif COFINS error';


            if (IntSalesCredi."Tax (PIS) Order" <> 0) and (IntSalesCredi."Tax From Billing APP (PIS)" = 0) then
                IntSalesCreditNote."Posting Message" += '-Dif COFINS error';

            if (IntSalesCredi."Tax (PIS) Order" = 0) and (IntSalesCredi."Tax From Billing APP (PIS)" <> 0) then
                IntSalesCreditNote."Posting Message" += '-Dif COFINS error';

            if IntSalesCredi."Tax (PIS) Order" <> IntSalesCredi."Tax From Billing APP (PIS)" then
                if IntSalesCredi."Tax From Billing APP (PIS)" <> 0 then
                    if Abs(1 - (IntSalesCredi."Tax (PIS) Order" / IntSalesCredi."Tax From Billing APP (PIS)")) >
                            SalesReceivablesSetup."Int Tax Difference Allowed" then
                        IntSalesCreditNote."Posting Message" += '-Dif PIS error';

            if IntSalesCreditNote."Posting Message" <> '' then
                IntSalesCreditNote.Status := IntSalesCreditNote.Status::"Data Error";

            IntSalesCreditNote.Modify();

        end;

    end;

    procedure CreatePostCredit(IntSalescreditNote: Record IntSalesCreditNote)
    var
        SalesHeader: Record "Sales Header";
        IntSalesRet: Record IntSalesCreditNote;
        SalesPost: codeunit "sales-post";

    begin
        booHideDialog := true;

        if SalesHeader.get(SalesHeader."Document Type"::"Return Order", IntSalescreditNote."No.") then begin
            SalesPost.Run(SalesHeader);
            IntSalescreditNote.Status := IntSalescreditNote.Status::Posted;
            IntSalescreditNote.Modify();
        end else
            if IntSalescreditNote.Status <> IntSalescreditNote.Status::Posted then begin
                IntSalesRet.Reset();
                IntSalesRet.SetRange("No.", IntSalescreditNote."No.");
                if IntSalesRet.FindFirst() then
                    if IntSalesRet.Status = IntSalesRet.Status::Posted then begin
                        IntSalescreditNote.Status := IntSalescreditNote.Status::Posted;
                        IntSalescreditNote.Modify();

                    end;
            end;

    end;

    procedure ValidateIntSalesCredit(IntSalesCreditNote: Record IntSalesCreditNote): Boolean;
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

        IntSalesCreditNote."Posting Message" := '';
        IntSalesCreditNote.Modify();

        if not Customer.Get(IntSalesCreditNote."Sell-to Customer No.") then begin
            IntSalesCreditNote."Posting Message" := StrSubstNo(Cust01Err, IntSalesCreditNote."Sell-to Customer No.");
            IntSalesCreditNote.Modify();
        end;

        if not Item.get(IntSalesCreditNote."Item No.") then begin
            IntSalesCreditNote."Posting Message" += StrSubstNo(Item01Err, IntSalesCreditNote."Item No.");
            IntSalesCreditNote.Modify();
        end;

        if IntSalesCreditNote."G/L Account" = '' then begin
            IntSalesCreditNote."Posting Message" += GL01Err;
            IntSalesCreditNote.Modify();
        end else
            if GeneralPostingSetup.get(Customer."Gen. Bus. Posting Group", Item."Gen. Prod. Posting Group") then
                if GLAccount.Get(GeneralPostingSetup."Sales Account") then
                    if (GLAccount."No. 2" <> IntSalesCreditNote."G/L Account") then begin
                        Usgaap.Reset();
                        Usgaap.SetRange("US GAAP", IntSalesCreditNote."G/L Account");
                        Usgaap.SetRange("BR GAAP", GeneralPostingSetup."Sales Account");
                        if not Usgaap.FindFirst() then begin
                            IntSalesCreditNote."Posting Message" += StrSubstNo(GL02Err, IntSalesCreditNote."G/L Account", GeneralPostingSetup."Sales Account");
                            IntSalesCreditNote.Modify();
                        end;
                    end;

        if IntSalesCreditNote."Shortcut Dimension 1 Code" <> '' then
            if not ValidateDim(1, IntSalesCreditNote."Shortcut Dimension 1 Code") then
                CreateDim(1, IntSalesCreditNote."Shortcut Dimension 1 Code");

        if IntSalesCreditNote."Shortcut Dimension 2 Code" <> '' then
            if not ValidateDim(2, IntSalesCreditNote."Shortcut Dimension 2 Code") then
                CreateDim(2, IntSalesCreditNote."Shortcut Dimension 2 Code");

        if IntSalesCreditNote."Shortcut Dimension 3 Code" <> '' then
            if not ValidateDim(3, IntSalesCreditNote."Shortcut Dimension 3 Code") then
                CreateDim(3, IntSalesCreditNote."Shortcut Dimension 3 Code");

        if IntSalesCreditNote."Shortcut Dimension 4 Code" <> '' then
            if not ValidateDim(4, IntSalesCreditNote."Shortcut Dimension 4 Code") then
                CreateDim(4, IntSalesCreditNote."Shortcut Dimension 4 Code");

        if IntSalesCreditNote."Shortcut Dimension 5 Code" <> '' then
            if not ValidateDim(5, IntSalesCreditNote."Shortcut Dimension 5 Code") then
                CreateDim(5, IntSalesCreditNote."Shortcut Dimension 5 Code");

        if IntSalesCreditNote."Shortcut Dimension 6 Code" <> '' then
            if not ValidateDim(6, IntSalesCreditNote."Shortcut Dimension 6 Code") then
                CreateDim(6, IntSalesCreditNote."Shortcut Dimension 6 Code");

        if IntSalesCreditNote."Posting Message" <> '' then begin
            IntSalesCreditNote.Status := IntSalesCreditNote.Status::"Data Error";
            IntSalesCreditNote.Modify();

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

    [EventSubscriber(ObjectType::Table, database::"Sales Header", 'OnBeforeConfirmDeletion', '', false, false)]
    local procedure SalesHeaderOnBeforeConfirmDeletion(var SalesHeader: Record "Sales Header")
    begin

        SalesHeader."Posting No." := '';


    end;

    var
        DimensionCode: Code[20];
        booHideDialog: Boolean;
        booIsHandled: Boolean;
        WindDialog: Dialog;

}