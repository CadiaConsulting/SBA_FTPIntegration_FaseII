tableextension 50017 "INTCustLedgerEntryExt" extends "Cust. Ledger Entry"
{
    fields
    {
        field(50000; "SBA Applies-to Doc. No."; Code[20])
        {
            Caption = 'Applies-to Doc. No.';
        }
    }
    keys
    {
        key(ExtKey1; "Customer No.", "Document No.", Open)
        {

        }

    }
}