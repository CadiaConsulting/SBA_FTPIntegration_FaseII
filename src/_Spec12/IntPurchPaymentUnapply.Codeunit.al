codeunit 50072 "IntPurchPaymentUnapply"
{
    trigger OnRun()
    begin
        CallCheckData();
    end;

    procedure CheckData(var IntPurchPaymentUnapply: Record IntPurchPaymentUnapply)
    var
        RecordTocheck: Record IntPurchPaymentUnapply;
    begin
        RecordTocheck.CopyFilters(IntPurchPaymentUnapply);
        RecordTocheck.SetCurrentKey("Excel File Name", "Journal Template Name", "Journal Batch Name", Status);
        //RecordTocheck.SetRange("Excel File Name", IntPurchPaymentUnapply."Excel File Name");
        //RecordTocheck.SetRange("Journal Template Name", IntPurchPaymentUnapply."Journal Template Name");
        //RecordTocheck.SetRange("Journal Batch Name", IntPurchPaymentUnapply."Journal Batch Name");
        RecordTocheck.SetFilter(Status, '%1|%2', IntPurchPaymentUnapply.Status::Imported, IntPurchPaymentUnapply.Status::"Data Error");
        if not RecordTocheck.IsEmpty then begin
            RecordTocheck.FindSet();
            repeat
                if ValidateIntPurchPaymentApplyData(RecordTocheck) then
                    UnapplyPaymentJournal(RecordTocheck);
            until RecordTocheck.Next() = 0;
        end;
    end;

    local procedure ValidateIntPurchPaymentApplyData(var RecordToCheck: Record IntPurchPaymentUnapply): Boolean
    var
    begin
        RecordToCheck."Posting Message" := '';
        // RecordToCheck.Modify();
        CheckLedgerEntries(RecordToCheck);
        if RecordToCheck."Posting Message" <> '' then begin
            RecordToCheck.Status := RecordToCheck.Status::"Data Error";
            RecordToCheck.Modify();
            exit(false);
        end
        else
            exit(true);

    end;

    local procedure UnapplyPaymentJournal(RecordToUnapply: Record IntPurchPaymentUnapply)
    var
        ApplyUnapplyParameters: Record "Apply Unapply Parameters";
        GLSetup: Record "General Ledger Setup";
        GenJnlBatch: Record "Gen. Journal Batch";

        PaymentLedgerEntry: Record "Vendor Ledger Entry";
        DetailedVendorLedgEntry: Record "Detailed Vendor Ledg. Entry";
        VendEntryApplyPostedEntries: Codeunit "VendEntry-Apply Posted Entries";
    begin
        PayFilter(RecordToUnapply, PaymentLedgerEntry);
        PaymentLedgerEntry.FindFirst();

        DetailedVendorLedgEntry.Reset();
        DetailedVendorLedgEntry.SetCurrentKey("Vendor Ledger Entry No.", "Entry Type", Unapplied);
        DetailedVendorLedgEntry.SetRange("Vendor Ledger Entry No.", PaymentLedgerEntry."Entry No.");
        DetailedVendorLedgEntry.SetRange("Entry Type", DetailedVendorLedgEntry."Entry Type"::Application);
        DetailedVendorLedgEntry.SetRange(Unapplied, false);
        DetailedVendorLedgEntry.FindFirst();

        Clear(ApplyUnapplyParameters);
        GLSetup.GetRecordOnce();
        if GLSetup."Journal Templ. Name Mandatory" then begin
            GLSetup.TestField("Apply Jnl. Template Name");
            GLSetup.TestField("Apply Jnl. Batch Name");
            ApplyUnapplyParameters."Journal Template Name" := GLSetup."Apply Jnl. Template Name";
            ApplyUnapplyParameters."Journal Batch Name" := GLSetup."Apply Jnl. Batch Name";
            GenJnlBatch.Get(GLSetup."Apply Jnl. Template Name", GLSetup."Apply Jnl. Batch Name");
        end;
        ApplyUnapplyParameters."Document No." := RecordToUnapply."Document No.";
        ApplyUnapplyParameters."Posting Date" := RecordToUnapply."Posting Date";

        VendEntryApplyPostedEntries.PostUnApplyVendor(DetailedVendorLedgEntry, ApplyUnapplyParameters);

        RecordToUnapply.Status := RecordToUnapply.Status::Posted;
        RecordToUnapply.Modify();
    end;



    local procedure CheckLedgerEntries(var RecordToCheck: Record IntPurchPaymentUnapply)
    var
        PaymentLedger: Record "Vendor Ledger Entry";
        DocumentLedger: Record "Vendor Ledger Entry";
        OpenDocErrorLbl: Label 'Does not exist a open %1 %2 of vendor %3.';
        OpenDocAmountErrorLbl: Label 'Does not exist a closed %1 %2 of vendor %2 with amount %4.';
    begin

        PayFilter(RecordToCheck, PaymentLedger);
        if not PaymentLedger.FindSet() then begin
            RecordToCheck."Posting Message" := MergePostingMessage(RecordToCheck."Posting Message", StrSubstNo(OpenDocErrorLbl, RecordToCheck."Document Type", RecordToCheck."Document No.", RecordToCheck."Account No."));
            // end
            // else begin
            //     PaymentLedger.CalcFields(Amount);
            //     if PaymentLedger.Amount <> RecordToCheck.Amount then
            //         RecordToCheck."Posting Message" := MergePostingMessage(RecordToCheck."Posting Message", StrSubstNo(OpenDocAmountErrorLbl, RecordToCheck."Document Type", RecordToCheck."Document No.", RecordToCheck."Account No.", RecordToCheck.Amount));
        end;

        DocFilter(RecordToCheck, DocumentLedger);
        if not DocumentLedger.FindSet() then begin
            RecordToCheck."Posting Message" := MergePostingMessage(RecordToCheck."Posting Message", StrSubstNo(OpenDocErrorLbl, RecordToCheck."Applies-to Doc. Type", RecordToCheck."Applies-to Doc. No.", -1 * RecordToCheck.Amount));
            // end
            // else begin
            //     DocumentLedger.CalcFields(Amount);
            //     if DocumentLedger.Amount <> (-1 * RecordToCheck.Amount) Then
            //         RecordToCheck."Posting Message" := MergePostingMessage(RecordToCheck."Posting Message", StrSubstNo(OpenDocAmountErrorLbl, RecordToCheck."Document Type", RecordToCheck."Document No.", RecordToCheck."Account No.", RecordToCheck.Amount));
        end;

    end;

    local procedure MergePostingMessage(OldMessage: text; AddMessage: text): Text
    var
        RecordToCheck: Record IntPurchPaymentUnapply;
    begin
        if OldMessage <> '' then
            exit(CopyStr(AddMessage + ' ' + OldMessage, 1, MaxStrLen(RecordToCheck."Posting Message")))
        else
            exit(CopyStr(AddMessage, 1, MaxStrLen(RecordToCheck."Posting Message")));
    end;

    local procedure DocFilter(var RecordToFilter: Record IntPurchPaymentUnapply; var DocumentLedger: Record "Vendor Ledger Entry")
    begin
        DocumentLedger.Reset();
        DocumentLedger.SetCurrentKey("Vendor No.", "Document Type", "Document No.", Open);
        DocumentLedger.SetRange("Vendor No.", RecordToFilter."Account No.");
        DocumentLedger.SetRange("Document No.", RecordToFilter."Applies-to Doc. No.");
        DocumentLedger.SetRange("Document Type", RecordToFilter."Applies-to Doc. Type");
        //DocumentLedger.SetRange(Open, false);
    end;

    local procedure PayFilter(var RecordToFilter: Record IntPurchPaymentUnapply; var PaymentLedger: Record "Vendor Ledger Entry")
    begin
        PaymentLedger.Reset();
        PaymentLedger.SetCurrentKey("Vendor No.", "Document Type", "Document No.", Open);
        PaymentLedger.SetRange("Vendor No.", RecordToFilter."Account No.");
        PaymentLedger.SetRange("Document Type", RecordToFilter."Document Type");
        PaymentLedger.SetRange("Document No.", RecordToFilter."Document No.");
        //PaymentLedger.SetRange(Open, false);
    end;

    local procedure CallCheckData()
    var
        IntPurchPaymentUnapply: Record IntPurchPaymentUnapply;
        FileToProcessTMP: Record IntPurchPaymentUnapply temporary;
        LastFile: Text;
    begin
        IntPurchPaymentUnapply.SetFilter(Status, '%1|%2', IntPurchPaymentUnapply.Status::Imported, IntPurchPaymentUnapply.Status::"Data Error");
        if not IntPurchPaymentUnapply.IsEmpty then begin
            IntPurchPaymentUnapply.FindSet();
            repeat
                if LastFile <> IntPurchPaymentUnapply."Excel File Name" then begin
                    FileToProcessTMP."Excel File Name" := IntPurchPaymentUnapply."Excel File Name";
                    FileToProcessTMP.Insert();
                    LastFile := FileToProcessTMP."Excel File Name";
                end;
            until IntPurchPaymentUnapply.next = 0;
        end;

        if FileToProcessTMP.FindFirst() then
            repeat
                CheckData(FileToProcessTMP);
            until FileToProcessTMP.Next() = 0;
    end;


}
