codeunit 50004 "Integration Rcpt Jnl Apply"
{
    SingleInstance = true;
    procedure CreateApply(var IntRecJournalApp: Record "Integration Rcpt Jnl Apply")
    var
        DialogCreReceiptJournalLbl: label 'Create Receipt Journal   #1#############', Comment = '#1 IntRcptJournalApply';
        CustLedgEntry: Record "Cust. Ledger Entry";
        ApplyingCustLedgEntry: Record "Cust. Ledger Entry";
        CLE: Record "Cust. Ledger Entry";
        CustEntryApplyPostEntries: Codeunit "CustEntry-Apply Posted Entries";
        ApplyUnapplyParameters: Record "Apply Unapply Parameters";
        GLSetup: Record "General Ledger Setup";
        GenJnlBatch: Record "Gen. Journal Batch";
        CustEntrySetApplID: Codeunit "Cust. Entry-SetAppl.ID";
        AppyEntriesIntegration: Codeunit "Hold Apply Entries";
        PostDateOld: Date;
    begin

        gvIntRcptJournalApply.Reset();
        gvIntRcptJournalApply.CopyFilters(IntRecJournalApp);
        gvIntRcptJournalApply.SetFilter(Status, '%1|%2|%3', gvIntRcptJournalApply.Status::Imported,
                                                   gvIntRcptJournalApply.Status::"Data Error",
                                                   gvIntRcptJournalApply.Status::Created);

        if gvIntRcptJournalApply.Find('-') then begin
            if GuiAllowed then
                WindDialog.Open(DialogCreReceiptJournalLbl);
            repeat
                if GuiAllowed then
                    WindDialog.Update(1, gvIntRcptJournalApply."Document No.");

                gvIntRcptJournalApply."Posting Message" := '';
                gvIntRcptJournalApply.Modify();

                if not ValidateIntRcptJournalApply(gvIntRcptJournalApply) then begin


                    CustLedgEntry.Reset();
                    CustLedgEntry.SetCurrentKey("Customer No.", "Document No.", Open);
                    CustLedgEntry.SetRange("Customer No.", gvIntRcptJournalApply."Account No.");
                    CustLedgEntry.SetRange("Document No.", gvIntRcptJournalApply."Document No.");
                    //CustLedgEntry.SetRange("Document Type", CustLedgEntry."Document Type"::Payment);
                    //CustLedgEntry.SetRange("Document Type", gvIntRcptJournalApply."Document Type");
                    CustLedgEntry.FindFirst();
                    CustLedgEntry.Validate("Applies-to ID", gvIntRcptJournalApply."Document No.");
                    CustLedgEntry.Modify();

                    ApplyingCustLedgEntry.Reset();
                    ApplyingCustLedgEntry.SetCurrentKey("Customer No.", "Document No.", Open);
                    ApplyingCustLedgEntry.SetRange("Customer No.", gvIntRcptJournalApply."Account No.");
                    //ApplyingCustLedgEntry.SetRange("Remaining Amount", gvIntRcptJournalApply.Amount);
                    ApplyingCustLedgEntry.SetRange("Document No.", gvIntRcptJournalApply."Applies-to Doc. No.");
                    ApplyingCustLedgEntry.SetRange(Open, true);

                    ApplyingCustLedgEntry.SetAutoCalcFields("Remaining Amount");

                    ApplyingCustLedgEntry.FindFirst();
                    ApplyingCustLedgEntry.Validate("Applies-to ID", gvIntRcptJournalApply."Document No.");

                    if ApplyingCustLedgEntry."Remaining Amount" >= gvIntRcptJournalApply.Amount then
                        ApplyingCustLedgEntry.Validate("Amount to Apply", gvIntRcptJournalApply.Amount)
                    else
                        ApplyingCustLedgEntry.Validate("Amount to Apply", ApplyingCustLedgEntry."Remaining Amount");

                    //aqui
                    PostDateOld := ApplyingCustLedgEntry."Posting Date";
                    //ApplyingCustLedgEntry.validate("Posting Date", gvIntRcptJournalApply."Posting Date");
                    ApplyingCustLedgEntry.validate("Posting Date", CustLedgEntry."Posting Date");
                    ApplyingCustLedgEntry.Modify();

                    //Commit();

                    ApplyUnapplyParameters.CopyFromCustLedgEntry(ApplyingCustLedgEntry);
                    if GLSetup."Journal Templ. Name Mandatory" then begin
                        GLSetup.TestField("Apply Jnl. Template Name");
                        GLSetup.TestField("Apply Jnl. Batch Name");
                        ApplyUnapplyParameters."Journal Template Name" := GLSetup."Apply Jnl. Template Name";
                        ApplyUnapplyParameters."Journal Batch Name" := GLSetup."Apply Jnl. Batch Name";
                    end;

                    BindSubscription(CustEntryApplyPostEntries);
                    AppyEntriesIntegration.SetApplyIntegration(true, ApplyingCustLedgEntry."Amount to Apply");
                    CustEntryApplyPostEntries.ApplyCustEntryFormEntry(CustLedgEntry);
                    AppyEntriesIntegration.SetApplyIntegration(false, 0);
                    UnbindSubscription(CustEntryApplyPostEntries);

                    CustEntryApplyPostEntries.Apply(ApplyingCustLedgEntry, ApplyUnapplyParameters);

                    //aqui
                    //Commit();

                    CLE.Get(ApplyingCustLedgEntry."Entry No.");
                    CLE."Posting Date" := PostDateOld;
                    CLE.Modify();

                    gvIntRcptJournalApply.Status := gvIntRcptJournalApply.Status::Posted;
                    gvIntRcptJournalApply.Modify();
                    Commit();

                end;


            until gvIntRcptJournalApply.Next() = 0;

            if GuiAllowed then
                WindDialog.Close();

        end;

    end;

    procedure ValidateIntRcptJournalApply(var IntRcptJournalApply: Record "Integration Rcpt Jnl Apply"): Boolean;
    var
        Vendor: Record Vendor;
        Customer: Record Customer;
        Item: Record Item;
        GeneralPostingSetup: Record "General Posting Setup";
        GLAccount: Record "G/L Account";
        CustLedgEntry: Record "Cust. Ledger Entry";
        Cust01Err: label 'Customer %1 Not Found', Comment = '%1 - Customer No.';
        Item01Err: label ' - Item %1 Not Found', Comment = '%1 - Item No.';
        GL01Err: label ' - G/L Account not sent by GP';
        GL02Err: label ' - G/L Account GP %1 different from G/L Account %2', Comment = '%1 - G/L Accoun No. , %2 - G/L Accoun No.';
        Appl01Err: label 'Document %1 Closed', Comment = '%1 - Document No.';
        Appl02Err: label 'Document %1 Sem Saldo para aplicar', Comment = '%1 - Document No.';

    begin

        if not Customer.Get(IntRcptJournalApply."Account No.") then begin
            IntRcptJournalApply."Posting Message" := StrSubstNo(Cust01Err, IntRcptJournalApply."Account No.");
            IntRcptJournalApply.Modify();
        end;

        CustLedgEntry.Reset();
        CustLedgEntry.SetRange("Customer No.", gvIntRcptJournalApply."Account No.");
        CustLedgEntry.SetFilter("Document No.", '%1|%2', gvIntRcptJournalApply."Document No.", gvIntRcptJournalApply."Applies-to Doc. No.");
        CustLedgEntry.SetRange(open, true);
        if not CustLedgEntry.FindFirst() then begin
            IntRcptJournalApply."Posting Message" := StrSubstNo(Appl01Err, IntRcptJournalApply."Document No.");
            IntRcptJournalApply.Modify();

        end else begin

            CustLedgEntry.CalcFields("Remaining Amount");
            if Abs(IntRcptJournalApply.Amount) > Abs(CustLedgEntry."Remaining Amount") then begin
                IntRcptJournalApply."Posting Message" := StrSubstNo(Appl02Err, IntRcptJournalApply."Document No.");
                IntRcptJournalApply.Modify();
            end;

        end;

        if IntRcptJournalApply."Account No." = '' then begin
            IntRcptJournalApply."Posting Message" += GL01Err;
            IntRcptJournalApply.Modify();
        end else
            if GeneralPostingSetup.get(Vendor."Gen. Bus. Posting Group", Item."Gen. Prod. Posting Group") then
                if GLAccount.Get(GeneralPostingSetup."Purch. Credit Memo Account") then
                    if (GLAccount."No. 2" <> IntRcptJournalApply."Account No.") then begin
                        IntRcptJournalApply."Posting Message" += StrSubstNo(GL02Err, IntRcptJournalApply."Account No.", GeneralPostingSetup."Sales Account");
                        IntRcptJournalApply.Modify();
                    end;

        // if IntRcptJournalApply."dimension 1" <> '' then
        //     if not ValidateDim(1, IntRcptJournalApply."dimension 1") then
        //         CreateDim(1, IntRcptJournalApply."dimension 1");

        // if IntRcptJournalApply."dimension 2" <> '' then
        //     if not ValidateDim(2, IntRcptJournalApply."dimension 2") then
        //         CreateDim(2, IntRcptJournalApply."dimension 2");

        // if IntRcptJournalApply."dimension 3" <> '' then
        //     if not ValidateDim(3, IntRcptJournalApply."dimension 3") then
        //         CreateDim(3, IntRcptJournalApply."dimension 3");

        // if IntRcptJournalApply."dimension 4" <> '' then
        //     if not ValidateDim(4, IntRcptJournalApply."dimension 4") then
        //         CreateDim(4, IntRcptJournalApply."dimension 4");

        // if IntRcptJournalApply."dimension 5" <> '' then
        //     if not ValidateDim(5, IntRcptJournalApply."dimension 5") then
        //         CreateDim(5, IntRcptJournalApply."dimension 5");

        // if IntRcptJournalApply."dimension 6" <> '' then
        //     if not ValidateDim(6, IntRcptJournalApply."dimension 6") then
        //         CreateDim(6, IntRcptJournalApply."dimension 6");

        if IntRcptJournalApply."Posting Message" <> '' then begin
            IntRcptJournalApply.Status := IntRcptJournalApply.Status::"Data Error";
            IntRcptJournalApply.Modify();

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

    var
        DimensionCode: Code[20];
        WindDialog: Dialog;
        Page25: Page 25;
        Page623: Page 623;
        Page232: Page 232;
        gvIntRcptJournalApply: Record "Integration Rcpt Jnl Apply";


    [EventSubscriber(Objecttype::Codeunit, Codeunit::"CustEntry-Apply Posted Entries", 'OnApplyApplyCustEntryFormEntryOnAfterCustLedgEntrySetFilters', '', false, false)]
    local procedure OnApplyApplyCustEntryFormEntryOnAfterCustLedgEntrySetFilters(var ApplyingCustLedgerEntry: Record "Cust. Ledger Entry"; var CustLedgerEntry: Record "Cust. Ledger Entry"; var IsHandled: Boolean)
    var
        ApplyEntriesIntegration: Codeunit "Hold Apply Entries";
    begin

        if ApplyEntriesIntegration.IsApplyIntegration then begin
            IsHandled := true;
            Clear(CustLedgerEntry);
            CustLedgerEntry."Applying Entry" := false;
            CustLedgerEntry."Applies-to ID" := '';
            CustLedgerEntry."Amount to Apply" := 0;
        end;

    end;

}
