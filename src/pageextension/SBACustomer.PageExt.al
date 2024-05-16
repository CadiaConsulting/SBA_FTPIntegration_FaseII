pageextension 50002 "SBA Customer" extends "Customer Card"
{
    layout
    {
        addafter("CADBR Taxes Matrix")
        {
            field("Integration Taxes Matrix "; rec."Integration Taxes Matrix")
            {
                ApplicationArea = All;
                ToolTip = 'Integration Taxes Matrix';
            }
        }
    }
}
