pageextension 50011 INTSalesReceSetup extends "Sales & Receivables Setup"
{
    layout
    {
        // Add changes to page layout here
        addbefore("Document Default Line Type")
        {
            field("Int Tax Difference Allowed"; rec."Int Tax Difference Allowed")
            {
                Caption = 'Int Tax Difference Allowed';
                ApplicationArea = all;
                ToolTip = 'Int Tax Difference Allowed';
            }
        }
    }
}