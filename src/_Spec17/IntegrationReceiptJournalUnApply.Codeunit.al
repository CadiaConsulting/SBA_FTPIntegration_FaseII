codeunit 50005 "Integration Rcpt Jnl UnApply"
{
    procedure CreateUnApply(var IntReptJouUnApp: Record "Integration Rcpt Jnl UnApply")
    var
        DialogCreReceiptJournalLbl: label 'Create Receipt Journal   #1#############', Comment = '#1 gvIntRcptJournalUnApply';
        CustEntryApplyPostedEntries: Codeunit "CustEntry-Apply Posted Entries";
        CustLedgEntry: Record "Cust. Ledger Entry";
        DtldCustLedgEntry: Record "Detailed Cust. Ledg. Entry";
        ApplyUnapplyParameters: Record "Apply Unapply Parameters";
        GLSetup: Record "General Ledger Setup";
        GenJnlBatch: Record "Gen. Journal Batch";
    begin

        gvIntRcptJournalUnApply.Reset();
        gvIntRcptJournalUnApply.CopyFilters(IntReptJouUnApp);
        gvIntRcptJournalUnApply.SetFilter(Status, '%1|%2|%3', gvIntRcptJournalUnApply.Status::Imported,
                                                   gvIntRcptJournalUnApply.Status::"Data Error",
                                                   gvIntRcptJournalUnApply.Status::Created);
        if gvIntRcptJournalUnApply.Find('-') then begin
            if GuiAllowed then
                WindDialog.Open(DialogCreReceiptJournalLbl);
            repeat
                if GuiAllowed then
                    WindDialog.Update(1, gvIntRcptJournalUnApply."Document No.");

                gvIntRcptJournalUnApply."Posting Message" := '';
                gvIntRcptJournalUnApply.Modify();

                if not ValidategvIntRcptJournalUnApply(gvIntRcptJournalUnApply) then begin

                    CustLedgEntry.Reset();
                    CustLedgEntry.SetRange("Customer No.", gvIntRcptJournalUnApply."Account No.");
                    CustLedgEntry.SetRange("Document No.", gvIntRcptJournalUnApply."Document No.");
                    //CustLedgEntry.SetRange("Document Type", CustLedgEntry."Document Type"::Payment);
                    CustLedgEntry.SetRange("Document Type", gvIntRcptJournalUnApply."Document Type");
                    CustLedgEntry.FindFirst();

                    DtldCustLedgEntry.Reset();
                    DtldCustLedgEntry.SetRange("Cust. Ledger Entry No.", CustLedgEntry."Entry No.");
                    DtldCustLedgEntry.SetRange("Entry Type", DtldCustLedgEntry."Entry Type"::Application);
                    DtldCustLedgEntry.SetRange(Unapplied, false);
                    DtldCustLedgEntry.FindFirst();

                    Clear(ApplyUnapplyParameters);
                    GLSetup.GetRecordOnce();
                    if GLSetup."Journal Templ. Name Mandatory" then begin
                        GLSetup.TestField("Apply Jnl. Template Name");
                        GLSetup.TestField("Apply Jnl. Batch Name");
                        ApplyUnapplyParameters."Journal Template Name" := GLSetup."Apply Jnl. Template Name";
                        ApplyUnapplyParameters."Journal Batch Name" := GLSetup."Apply Jnl. Batch Name";
                        GenJnlBatch.Get(GLSetup."Apply Jnl. Template Name", GLSetup."Apply Jnl. Batch Name");
                    end;
                    ApplyUnapplyParameters."Document No." := gvIntRcptJournalUnApply."Document No.";
                    ApplyUnapplyParameters."Posting Date" := TODAY;

                    CustEntryApplyPostedEntries.PostUnApplyCustomer(DtldCustLedgEntry, ApplyUnapplyParameters);

                    gvIntRcptJournalUnApply.Status := gvIntRcptJournalUnApply.Status::Posted;
                    gvIntRcptJournalUnApply.Modify();
                end;

            until gvIntRcptJournalUnApply.Next() = 0;

            if GuiAllowed then
                WindDialog.Close();

        end;

    end;

    procedure ValidategvIntRcptJournalUnApply(var gvIntRcptJournalUnApply: Record "Integration Rcpt Jnl UnApply"): Boolean;
    var
        Vendor: Record Vendor;
        Customer: Record Customer;
        CustLedgEntry: Record "Cust. Ledger Entry";
        Item: Record Item;
        GeneralPostingSetup: Record "General Posting Setup";
        GLAccount: Record "G/L Account";
        Cust01Err: label 'Customer %1 Not Found', Comment = '%1 - Customer No.';
        Item01Err: label ' - Item %1 Not Found', Comment = '%1 - Item No.';
        GL01Err: label ' - G/L Account not sent by GP';
        GL02Err: label ' - G/L Account GP %1 different from G/L Account %2', Comment = '%1 - G/L Accoun No. , %2 - G/L Accoun No.';
        Appl01Err: label 'Document %1 Closed', Comment = '%1 - Document No.';

    begin


        if not Customer.Get(gvIntRcptJournalUnApply."Account No.") then begin
            gvIntRcptJournalUnApply."Posting Message" := StrSubstNo(Cust01Err, gvIntRcptJournalUnApply."Account No.");
            gvIntRcptJournalUnApply.Modify();
        end;

        CustLedgEntry.Reset();
        CustLedgEntry.SetRange("Customer No.", gvIntRcptJournalUnApply."Account No.");
        CustLedgEntry.SetFilter("Document No.", '%1|%2', gvIntRcptJournalUnApply."Document No.", gvIntRcptJournalUnApply."Applies-to Doc. No.");
        CustLedgEntry.SetRange(open, false);
        if not CustLedgEntry.FindFirst Then
            gvIntRcptJournalUnApply."Posting Message" := StrSubstNo(Appl01Err, gvIntRcptJournalUnApply."Document No.");
        gvIntRcptJournalUnApply.Modify();

        if gvIntRcptJournalUnApply."Account No." = '' then begin
            gvIntRcptJournalUnApply."Posting Message" += GL01Err;
            gvIntRcptJournalUnApply.Modify();
        end else
            if GeneralPostingSetup.get(Vendor."Gen. Bus. Posting Group", Item."Gen. Prod. Posting Group") then
                if GLAccount.Get(GeneralPostingSetup."Purch. Credit Memo Account") then
                    if (GLAccount."No. 2" <> gvIntRcptJournalUnApply."Account No.") then begin
                        gvIntRcptJournalUnApply."Posting Message" += StrSubstNo(GL02Err, gvIntRcptJournalUnApply."Account No.", GeneralPostingSetup."Sales Account");
                        gvIntRcptJournalUnApply.Modify();
                    end;

        if gvIntRcptJournalUnApply."dimension 1" <> '' then
            if not ValidateDim(1, gvIntRcptJournalUnApply."dimension 1") then
                CreateDim(1, gvIntRcptJournalUnApply."dimension 1");

        if gvIntRcptJournalUnApply."dimension 2" <> '' then
            if not ValidateDim(2, gvIntRcptJournalUnApply."dimension 2") then
                CreateDim(2, gvIntRcptJournalUnApply."dimension 2");

        if gvIntRcptJournalUnApply."dimension 3" <> '' then
            if not ValidateDim(3, gvIntRcptJournalUnApply."dimension 3") then
                CreateDim(3, gvIntRcptJournalUnApply."dimension 3");

        if gvIntRcptJournalUnApply."dimension 4" <> '' then
            if not ValidateDim(4, gvIntRcptJournalUnApply."dimension 4") then
                CreateDim(4, gvIntRcptJournalUnApply."dimension 4");

        if gvIntRcptJournalUnApply."dimension 5" <> '' then
            if not ValidateDim(5, gvIntRcptJournalUnApply."dimension 5") then
                CreateDim(5, gvIntRcptJournalUnApply."dimension 5");

        if gvIntRcptJournalUnApply."dimension 6" <> '' then
            if not ValidateDim(6, gvIntRcptJournalUnApply."dimension 6") then
                CreateDim(6, gvIntRcptJournalUnApply."dimension 6");

        if gvIntRcptJournalUnApply."Posting Message" <> '' then begin
            gvIntRcptJournalUnApply.Status := gvIntRcptJournalUnApply.Status::"Data Error";
            gvIntRcptJournalUnApply.Modify();

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
        gvIntRcptJournalUnApply: Record "Integration Rcpt Jnl UnApply";
        DimensionCode: Code[20];
        WindDialog: Dialog;


}
