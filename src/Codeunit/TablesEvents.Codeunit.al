codeunit 50008 "Table Events"
{
    trigger OnRun()
    begin
    end;

    [EventSubscriber(ObjectType::Table, Database::"Cust. Ledger Entry", 'OnAfterCopyCustLedgerEntryFromGenJnlLine', '', false, false)]
    local procedure Table_21_OnAfterCopyCustLedgerEntryFromGenJnlLine(var CustLedgerEntry: Record "Cust. Ledger Entry"; GenJournalLine: Record "Gen. Journal Line")
    begin
        if GenJournalLine."Applies-to Doc. No." <> '' then
            CustLedgerEntry."SBA Applies-to Doc. No." := GenJournalLine."Applies-to Doc. No."
        else
            CustLedgerEntry."SBA Applies-to Doc. No." := GenJournalLine."CADBR Tax Applies-to Doc. No.";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Vendor Ledger Entry", 'OnAfterCopyVendLedgerEntryFromGenJnlLine', '', false, false)]
    local procedure Table_25_OnAfterCopyVendLedgerEntryFromGenJnlLine(var VendorLedgerEntry: Record "Vendor Ledger Entry"; GenJournalLine: Record "Gen. Journal Line")
    begin
        if GenJournalLine."Applies-to Doc. No." <> '' then
            VendorLedgerEntry."SBA Applies-to Doc. No." := GenJournalLine."Applies-to Doc. No."
        else
            VendorLedgerEntry."SBA Applies-to Doc. No." := GenJournalLine."CADBR Tax Applies-to Doc. No.";
    end;

    [EventSubscriber(ObjectType::Table, Database::"CADBR Operation Type", 'OnBeforeUpdateLineFields', '', false, false)]
    local procedure Table_52006512_OnBeforeUpdateLineFields(purchLine: Record "Purchase Line"; var Handled: Boolean)
    begin
        if (purchLine."No." in
                ['1628012', '1639012', '1644012', '1645012', '1646012', '1647012', '1657012',
                 '1662012', '1668012', '1670012', '1672012', '1679012', '1681012']) and
            (purchLine."Shortcut Dimension 2 Code" = 'OI  2,113 - GUARANI') and
            (purchLine."CADBR Operation Type" = '')
        then
            Handled := true;
    end;

    [EventSubscriber(ObjectType::Table, Database::"CADBR Tax Amount Line", 'OnAfterCopyToVATEntryTable', '', false, false)]
    local procedure Table_52006526_OnAfterCopyToVATEntryTable(var VATEntry: Record "VAT Entry"; PurchLine: Record "Purchase Line"; GlAccountType: Integer; GLAccount: Code[20]);
    var
        Vendor: Record Vendor;
        VendorPostinGroup: Record "Vendor Posting Group";
    begin
        if GLAccountType = 3 then begin
            if vendor.get(GLAccount) then
                if VendorPostinGroup.get(Vendor."Vendor Posting Group") then
                    VATEntry."GL Account Related" := VendorPostinGroup."Payables Account";
        end else
            VATEntry."GL Account Related" := GLAccount;
        VATEntry."Base Calculation Credit Code" := PurchLine."CADBR Base Calculation Credit Code";
    end;

    [EventSubscriber(ObjectType::Table, Database::"CADBR REINF4010 Details", 'OnBeforeFilterVendor', '', false, false)]
    local procedure Table_52007203_OnBeforeFilterVendor(var IsHandled: Boolean)
    begin
        IsHandled := true;
    end;
}
