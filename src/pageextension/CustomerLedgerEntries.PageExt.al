pageextension 50004 CustomerLedgerEntries extends "Customer Ledger Entries"
{
    layout
    {
        addlast(Control1)
        {
            field("SBA Applies-to Doc. No."; Rec."SBA Applies-to Doc. No.")
            {
                ApplicationArea = All;
            }
        }
    }
}