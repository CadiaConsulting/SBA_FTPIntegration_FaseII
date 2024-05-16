pageextension 50005 "SBA General Ledger Entries" extends "General Ledger Entries"
{
    layout
    {
        addafter("External Document No.")
        {
            field("Applies-to Doc. Type"; Rec."Applies-to Doc. Type")
            {
                ApplicationArea = Basic;
            }
            field("Applies-to Doc. No."; Rec."Applies-to Doc. No.")
            {
                ApplicationArea = Basic;
            }
        }
    }
}
