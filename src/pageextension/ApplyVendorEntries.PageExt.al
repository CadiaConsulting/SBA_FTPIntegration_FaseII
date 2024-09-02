pageextension 50008 "Apply Vendor Entries-Ext" extends "CADBR Apply Vendor Entries"
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
            field("City Name"; rec."City Name")
            {
                ApplicationArea = All;
                ToolTip = 'City Name';
            }
        }
    }
}