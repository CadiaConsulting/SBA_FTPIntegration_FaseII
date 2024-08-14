pageextension 50009 "Apply Vendor EntriesSt-Ext" extends "Apply Vendor Entries"
{
    layout
    {
        addafter("Document Type")
        {
            field("Document Date"; rec."Document Date")
            {
                ApplicationArea = All;
                ToolTip = 'Document Date';
            }
            field("Service Delivery City"; rec."Service Delivery City")
            {
                ApplicationArea = All;
                ToolTip = 'Service Delivery City';
            }
        }
    }
}