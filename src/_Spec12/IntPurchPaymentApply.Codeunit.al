codeunit 50071 "IntPurchPaymentApply"
{
    SingleInstance = true;
    procedure CreateApply(var IntPurchPayApply: Record IntPurchPaymentApply)
    var
        DialogCrePaymentJournalLbl: label 'Apply Payment Journal   #1#############', Comment = '#1 IntRcptJournalApply';
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        ApplyingVendorLedgerEntry: Record "Vendor Ledger Entry";
        VendEntryApplyPostedEntries: Codeunit "VendEntry-Apply Posted Entries";
        ApplyUnapplyParameters: Record "Apply Unapply Parameters";
        GLSetup: Record "General Ledger Setup";
        GenJnlBatch: Record "Gen. Journal Batch";
        VendEntrySetApplID: Codeunit "Vend. Entry-SetAppl.ID";
        HoldVendorApplyEntries: Codeunit "Hold Vendor Apply Entries";
    begin

        RecordToApply.Reset();
        RecordToApply.CopyFilters(IntPurchPayApply);
        RecordToApply.SetFilter(Status, '%1|%2|%3', RecordToApply.Status::Imported,
                                                   RecordToApply.Status::"Data Error",
                                                   RecordToApply.Status::Created);

        if RecordToApply.Find('-') then begin
            if GuiAllowed then
                WindDialog.Open(DialogCrePaymentJournalLbl);
            repeat
                if GuiAllowed then
                    WindDialog.Update(1, RecordToApply."Document No.");

                RecordToApply."Posting Message" := '';
                RecordToApply.Modify();

                if not ValidateIntPaymJournalApply(RecordToApply) then begin


                    VendorLedgerEntry.Reset();
                    VendorLedgerEntry.SetRange("Vendor No.", RecordToApply."Account No.");
                    VendorLedgerEntry.SetRange("Document No.", RecordToApply."Document No.");
                    VendorLedgerEntry.SetRange("Document Type", RecordToApply."Document Type");
                    VendorLedgerEntry.FindFirst();
                    VendorLedgerEntry.Validate("Applies-to ID", RecordToApply."Document No.");
                    VendorLedgerEntry.Modify();

                    ApplyingVendorLedgerEntry.Reset();
                    ApplyingVendorLedgerEntry.SetRange("Vendor No.", RecordToApply."Account No.");
                    ApplyingVendorLedgerEntry.SetRange("Document No.", RecordToApply."Applies-to Doc. No.");
                    ApplyingVendorLedgerEntry.SetRange(Open, true);

                    ApplyingVendorLedgerEntry.SetAutoCalcFields("Remaining Amount");

                    ApplyingVendorLedgerEntry.FindFirst();
                    ApplyingVendorLedgerEntry.Validate("Applies-to ID", RecordToApply."Document No.");

                    if Abs(ApplyingVendorLedgerEntry."Remaining Amount") >= RecordToApply.Amount then
                        ApplyingVendorLedgerEntry.Validate("Amount to Apply", -RecordToApply.Amount)
                    else
                        ApplyingVendorLedgerEntry.Validate("Amount to Apply", ApplyingVendorLedgerEntry."Remaining Amount");

                    ApplyingVendorLedgerEntry.validate("Posting Date", RecordToApply."Posting Date");
                    ApplyingVendorLedgerEntry.Modify();

                    Commit();

                    ApplyUnapplyParameters.CopyFromVendLedgEntry(ApplyingVendorLedgerEntry);
                    if GLSetup."Journal Templ. Name Mandatory" then begin
                        GLSetup.TestField("Apply Jnl. Template Name");
                        GLSetup.TestField("Apply Jnl. Batch Name");
                        ApplyUnapplyParameters."Journal Template Name" := GLSetup."Apply Jnl. Template Name";
                        ApplyUnapplyParameters."Journal Batch Name" := GLSetup."Apply Jnl. Batch Name";
                    end;

                    BindSubscription(VendEntryApplyPostedEntries);
                    HoldVendorApplyEntries.SetApplyIntegration(true, ApplyingVendorLedgerEntry."Amount to Apply");
                    VendEntryApplyPostedEntries.ApplyVendEntryFormEntry(VendorLedgerEntry);
                    HoldVendorApplyEntries.SetApplyIntegration(false, 0);
                    UnbindSubscription(VendEntryApplyPostedEntries);

                    VendEntryApplyPostedEntries.Apply(ApplyingVendorLedgerEntry, ApplyUnapplyParameters);

                    RecordToApply.Status := RecordToApply.Status::Posted;
                    RecordToApply.Modify();
                    Commit();

                end;

            until RecordToApply.Next() = 0;

            if GuiAllowed then
                WindDialog.Close();

        end;

    end;

    procedure ValidateIntPaymJournalApply(var RecordToCheck: Record IntPurchPaymentApply): Boolean;
    var
        Vendor: Record Vendor;
        GeneralPostingSetup: Record "General Posting Setup";
        GLAccount: Record "G/L Account";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        Appl01Err: label 'Document %1 is Closed', Comment = '%1 - Document No.';
        VendorNotFoundLbl: Label 'the Vendor %1 does not exist.';
    begin

        if not Vendor.Get(RecordToCheck."Account No.") then begin
            RecordToCheck."Posting Message" := StrSubstNo(VendorNotFoundLbl, RecordToCheck."Account No.");
            RecordToCheck.Modify();
        end;

        VendorLedgerEntry.Reset();
        VendorLedgerEntry.SetRange("Vendor No.", RecordToCheck."Account No.");
        VendorLedgerEntry.SetFilter("Document No.", '%1|%2', RecordToCheck."Document No.", RecordToCheck."Applies-to Doc. No.");
        VendorLedgerEntry.SetRange(open, true);
        if not VendorLedgerEntry.FindFirst Then
            RecordToCheck."Posting Message" := StrSubstNo(Appl01Err, RecordToCheck."Document No.");
        RecordToCheck.Modify();

        if RecordToCheck."Posting Message" <> '' then begin
            RecordToCheck.Status := RecordToCheck.Status::"Data Error";
            RecordToCheck.Modify();
            exit(true);
        end;

    end;

    var
        DimensionCode: Code[20];
        WindDialog: Dialog;
        RecordToApply: Record IntPurchPaymentApply;


    [EventSubscriber(Objecttype::Codeunit, Codeunit::"VendEntry-Apply Posted Entries", 'OnApplyVendEntryFormEntryOnAfterVendLedgEntrySetFilters', '', false, false)]
    local procedure OnApplyApplyVendEntryFormEntryOnAfterCustLedgEntrySetFilters(var ApplyToVendLedgEntry: Record "Vendor Ledger Entry"; var VendorLedgEntry: Record "Vendor Ledger Entry"; var IsHandled: Boolean)
    var
        HoldVendorApplyEntries: Codeunit "Hold Vendor Apply Entries";
    begin

        if HoldVendorApplyEntries.IsApplyIntegration then begin
            IsHandled := true;
            Clear(VendorLedgEntry);
            VendorLedgEntry."Applying Entry" := false;
            VendorLedgEntry."Applies-to ID" := '';
            VendorLedgEntry."Amount to Apply" := 0;
        end;

    end;

}
