codeunit 50078 "IntPurchPaymentApplyOriginal"
{
    trigger OnRun()
    begin
        CallCheckData();
    end;

    procedure CheckData(IntPurchPaymentApply: Record IntPurchPaymentApply)
    var
        RecordTocheck: Record IntPurchPaymentApply;
    begin
        RecordTocheck.SetFilter(Status, '%1|%2|%3', IntPurchPaymentApply.Status::Imported, IntPurchPaymentApply.Status::"Data Error", IntPurchPaymentApply.Status::Created);
        if not RecordTocheck.IsEmpty then begin
            RecordTocheck.FindSet();
            repeat
                if ValidateIntPurchPaymentApplyData(RecordTocheck) then
                    // ApplyPaymentJournal(RecordTocheck);
                    ApplyPaymentJournalNewWay2(RecordTocheck);
            until RecordTocheck.Next() = 0;
        end;
    end;

    local procedure ValidateIntPurchPaymentApplyData(var RecordToCheck: Record IntPurchPaymentApply): Boolean
    begin
        RecordToCheck."Posting Message" := '';
        RecordToCheck.Modify();
        CheckLedgerEntries(RecordToCheck);
        if RecordToCheck."Posting Message" <> '' then begin
            RecordToCheck.Status := RecordToCheck.Status::"Data Error";
            RecordToCheck.Modify();
            exit(false);
        end
        else
            exit(true);
    end;

    local procedure CheckLedgerEntries(var RecordToCheck: Record IntPurchPaymentApply)
    var
        PaymentLedger: Record "Vendor Ledger Entry";
        DocumentLedger: Record "Vendor Ledger Entry";
        OpenDocErrorLbl: Label 'Does not exist a open %1 %2 of vendor %3.';
        OpenDocAmountErrorLbl: Label 'Does not exist a open %1 %2 of vendor %3 with remaining amount %4.';
    begin

        PayFilter(RecordToCheck, PaymentLedger);
        if not PaymentLedger.FindSet() then begin
            RecordToCheck."Posting Message" := MergePostingMessage(RecordToCheck."Posting Message", StrSubstNo(OpenDocErrorLbl, RecordToCheck."Document Type", RecordToCheck."Document No.", RecordToCheck."Account No."));
        end
        else begin
            PaymentLedger.CalcFields("Remaining Amount");
            if PaymentLedger."Remaining Amount" <> RecordToCheck.Amount then
                RecordToCheck."Posting Message" := MergePostingMessage(RecordToCheck."Posting Message", StrSubstNo(OpenDocAmountErrorLbl, RecordToCheck."Document Type", RecordToCheck."Document No.", RecordToCheck."Account No.", RecordToCheck.Amount));
        end;

        DocFilter(RecordToCheck, DocumentLedger);
        if not DocumentLedger.FindSet() then begin
            RecordToCheck."Posting Message" := MergePostingMessage(RecordToCheck."Posting Message", StrSubstNo(OpenDocErrorLbl, RecordToCheck."Applies-to Doc. Type", RecordToCheck."Applies-to Doc. No.", -1 * RecordToCheck.Amount));
        end
        else begin
            DocumentLedger.CalcFields("Remaining Amount");
            if DocumentLedger."Remaining Amount" <> (-1 * RecordToCheck.Amount) Then
                RecordToCheck."Posting Message" := MergePostingMessage(RecordToCheck."Posting Message", StrSubstNo(OpenDocAmountErrorLbl, RecordToCheck."Document Type", RecordToCheck."Document No.", RecordToCheck."Account No.", RecordToCheck.Amount));
        end;

    end;

    local procedure ApplyPaymentJournalNewWay(var RecordToAplly: Record IntPurchPaymentApply)
    var
        PaymentLedger: Record "Vendor Ledger Entry";
        DocumentLedger: Record "Vendor Ledger Entry";
        ApplyID: Text;
        ApplicationDate: Date;
        GLSetup: Record "General Ledger Setup";
        ApplyUnapplyParameters: Record "Apply Unapply Parameters";
        VendEntryApplyPostedEntries: Codeunit "VendEntry-Apply Posted Entries";
        VendEntrySetApplID: Codeunit "Vend. Entry-SetAppl.ID";
    begin
        ApplyID := 'INTPAYMENT' + FORMAT(CURRENTDATETIME, 0, '<Year><Month,2><Day,2><Hours24,2><Minutes,2><Seconds,2><Thousands>');
        ApplyID := CopyStr(ApplyID, 1, MaxStrLen(PaymentLedger."Applies-to ID"));

        PayFilter(RecordToAplly, PaymentLedger);
        PaymentLedger.FindFirst();
        PaymentLedger."Applying Entry" := true;
        PaymentLedger.Validate("Applies-to ID", ApplyID);
        PaymentLedger.Validate("Amount to Apply", RecordToAplly.Amount);
        // PaymentLedger.Modify();
        Codeunit.Run(Codeunit::"Vend. Entry-Edit", PaymentLedger);
        Commit();

        DocFilter(RecordToAplly, DocumentLedger);
        DocumentLedger.FindFirst();

        VendEntrySetApplID.SetApplId(DocumentLedger, PaymentLedger, ApplyID);
        Commit();

        ApplicationDate := VendEntryApplyPostedEntries.GetApplicationDate(DocumentLedger);

        ApplyUnapplyParameters.CopyFromVendLedgEntry(DocumentLedger);
        ApplyUnapplyParameters."Posting Date" := ApplicationDate;

        GLSetup.Get();
        if GLSetup."Journal Templ. Name Mandatory" then begin
            GLSetup.TestField("Apply Jnl. Template Name");
            GLSetup.TestField("Apply Jnl. Batch Name");
            ApplyUnapplyParameters."Journal Template Name" := GLSetup."Apply Jnl. Template Name";
            ApplyUnapplyParameters."Journal Batch Name" := GLSetup."Apply Jnl. Batch Name";
        end;

        VendEntryApplyPostedEntries.Apply(DocumentLedger, ApplyUnapplyParameters);

        RecordToAplly.Status := RecordToAplly.Status::Posted;
        RecordToAplly.Modify();
    end;

    local procedure ApplyPaymentJournalNewWay2(var RecordToAplly: Record IntPurchPaymentApply)
    var
        PaymentLedger: Record "Vendor Ledger Entry";
        DocumentLedger: Record "Vendor Ledger Entry";
        ApplyID: Text;
        ApplicationDate: Date;
        GLSetup: Record "General Ledger Setup";
        ApplyUnapplyParameters: Record "Apply Unapply Parameters";
        VendEntryApplyPostedEntries: Codeunit "VendEntry-Apply Posted Entries";
        VendEntrySetApplID: Codeunit "Vend. Entry-SetAppl.ID";
    begin
        ApplyID := 'INTPAYMENT' + FORMAT(CURRENTDATETIME, 0, '<Year><Month,2><Day,2><Hours24,2><Minutes,2><Seconds,2><Thousands>');
        ApplyID := CopyStr(ApplyID, 1, MaxStrLen(PaymentLedger."Applies-to ID"));


        DocFilter(RecordToAplly, DocumentLedger);
        if not DocumentLedger.IsEmpty then begin
            DocumentLedger.FindSet();
            PayFilter(RecordToAplly, PaymentLedger);
            if not PaymentLedger.IsEmpty then begin
                PaymentLedger.FindSet();
                PaymentLedger.CalcFields(Amount);
                DocumentLedger.CalcFields(Amount);
                DocumentLedger."Applying Entry" := true;
                DocumentLedger."Applies-to ID" := ApplyID;
                PaymentLedger."Applies-to ID" := ApplyID;
                DocumentLedger.CalcFields("Remaining Amount");
                DocumentLedger.Validate("Amount to Apply", DocumentLedger."Remaining Amount");
                Codeunit.Run(Codeunit::"Vend. Entry-Edit", DocumentLedger);
                Commit();
                VendEntrySetApplID.SetApplId(PaymentLedger, DocumentLedger, ApplyID);
                ApplicationDate := VendEntryApplyPostedEntries.GetApplicationDate(DocumentLedger);

                GLSetup.Get();
                if GLSetup."Journal Templ. Name Mandatory" then begin
                    GLSetup.TestField("Apply Jnl. Template Name");
                    GLSetup.TestField("Apply Jnl. Batch Name");
                    ApplyUnapplyParameters."Journal Template Name" := GLSetup."Apply Jnl. Template Name";
                    ApplyUnapplyParameters."Journal Batch Name" := GLSetup."Apply Jnl. Batch Name";
                end;

                VendEntryApplyPostedEntries.Apply(DocumentLedger, ApplyUnapplyParameters);

                RecordToAplly.Status := RecordToAplly.Status::Posted;
                RecordToAplly.Modify();
            end;
        end;
    end;

    local procedure ApplyPaymentJournal(var RecordToAplly: Record IntPurchPaymentApply)
    var
        PaymentLedger: Record "Vendor Ledger Entry";
        DocumentLedger: Record "Vendor Ledger Entry";
        ApplyID: Text;
        ApplicationDate: Date;
        GLSetup: Record "General Ledger Setup";
        ApplyUnapplyParameters: Record "Apply Unapply Parameters";
        VendEntryApplyPostedEntries: Codeunit "VendEntry-Apply Posted Entries";
        VendEntrySetApplID: Codeunit "Vend. Entry-SetAppl.ID";
    begin
        ApplyID := 'INTPAYMENT' + FORMAT(CURRENTDATETIME, 0, '<Year><Month,2><Day,2><Hours24,2><Minutes,2><Seconds,2><Thousands>');
        ApplyID := CopyStr(ApplyID, 1, MaxStrLen(PaymentLedger."Applies-to ID"));
        DocFilter(RecordToAplly, DocumentLedger);
        if not DocumentLedger.IsEmpty then begin
            DocumentLedger.FindSet();
            PayFilter(RecordToAplly, PaymentLedger);
            if not PaymentLedger.IsEmpty then begin
                PaymentLedger.FindSet();
                PaymentLedger.CalcFields(Amount);
                DocumentLedger.CalcFields(Amount);
                DocumentLedger."Applying Entry" := true;
                DocumentLedger."Applies-to ID" := ApplyID;
                PaymentLedger."Applies-to ID" := ApplyID;
                DocumentLedger.CalcFields("Remaining Amount");
                DocumentLedger.Validate("Amount to Apply", DocumentLedger."Remaining Amount");
                Codeunit.Run(Codeunit::"Vend. Entry-Edit", DocumentLedger);
                Commit();
                VendEntrySetApplID.SetApplId(PaymentLedger, DocumentLedger, ApplyID);
                ApplicationDate := VendEntryApplyPostedEntries.GetApplicationDate(DocumentLedger);

                GLSetup.Get();
                if GLSetup."Journal Templ. Name Mandatory" then begin
                    GLSetup.TestField("Apply Jnl. Template Name");
                    GLSetup.TestField("Apply Jnl. Batch Name");
                    ApplyUnapplyParameters."Journal Template Name" := GLSetup."Apply Jnl. Template Name";
                    ApplyUnapplyParameters."Journal Batch Name" := GLSetup."Apply Jnl. Batch Name";
                end;

                VendEntryApplyPostedEntries.Apply(DocumentLedger, ApplyUnapplyParameters);

                RecordToAplly.Status := RecordToAplly.Status::Posted;
                RecordToAplly.Modify();
            end;
        end;
    end;

    local procedure MergePostingMessage(OldMessage: text; AddMessage: text): Text
    var
        RecordToCheck: Record IntPurchPaymentApply;
    begin
        if OldMessage <> '' then
            exit(CopyStr(AddMessage + ' ' + OldMessage, 1, MaxStrLen(RecordToCheck."Posting Message")))
        else
            exit(CopyStr(AddMessage, 1, MaxStrLen(RecordToCheck."Posting Message")));
    end;

    local procedure DocFilter(var RecordToFilter: Record IntPurchPaymentApply; var DocumentLedger: Record "Vendor Ledger Entry")
    begin
        DocumentLedger.Reset();
        DocumentLedger.SetCurrentKey("Vendor No.", "Document Type", "Document No.", Open);
        DocumentLedger.SetRange("Vendor No.", RecordToFilter."Account No.");
        DocumentLedger.SetRange("Document No.", RecordToFilter."Applies-to Doc. No.");
        DocumentLedger.SetRange("Document Type", RecordToFilter."Applies-to Doc. Type");
        DocumentLedger.SetRange(Open, true);
    end;

    local procedure PayFilter(var RecordToFilter: Record IntPurchPaymentApply; var PaymentLedger: Record "Vendor Ledger Entry")
    begin
        PaymentLedger.Reset();
        PaymentLedger.SetCurrentKey("Vendor No.", "Document Type", "Document No.", Open);
        PaymentLedger.SetRange("Vendor No.", RecordToFilter."Account No.");
        PaymentLedger.SetRange("Document Type", RecordToFilter."Document Type");
        PaymentLedger.SetRange("Document No.", RecordToFilter."Document No.");
        PaymentLedger.SetRange(Open, true);
    end;

    local procedure CallCheckData()
    var
        IntPurchPaymentApply: Record IntPurchPaymentApply;
        FileToProcessTMP: Record IntPurchPaymentApply temporary;
        LastFile: Text;
    begin
        IntPurchPaymentApply.SetFilter(Status, '%1|%2', IntPurchPaymentApply.Status::Imported, IntPurchPaymentApply.Status::"Data Error");
        if not IntPurchPaymentApply.IsEmpty then begin
            IntPurchPaymentApply.FindSet();
            repeat
                if LastFile <> IntPurchPaymentApply."Excel File Name" then begin
                    FileToProcessTMP."Excel File Name" := IntPurchPaymentApply."Excel File Name";
                    FileToProcessTMP.Insert();
                    LastFile := FileToProcessTMP."Excel File Name";
                end;
            until IntPurchPaymentApply.next = 0;
        end;

        if FileToProcessTMP.FindFirst() then
            repeat
                CheckData(FileToProcessTMP);
            until FileToProcessTMP.Next() = 0;
    end;
}
