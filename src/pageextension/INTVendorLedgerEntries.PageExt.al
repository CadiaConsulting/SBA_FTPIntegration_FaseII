pageextension 50014 "INTVendorLedgerEntries" extends "Vendor Ledger Entries"
{
    layout
    {
        addlast(Control1)
        {
            field("Service Delivery City"; Rec."Service Delivery City")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Service Delivery City field.';
                Editable = false;
            }
            field(Integrated; Rec.Integrated)
            {
                ApplicationArea = All;
                ToolTip = 'Specifies if the record were exported.';
            }
            field("SBA Applies-to Doc. No."; Rec."SBA Applies-to Doc. No.")
            {
                ApplicationArea = All;
            }
        }
    }
}