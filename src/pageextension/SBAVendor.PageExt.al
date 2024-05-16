pageextension 50003 "SBA Vendor" extends "Vendor Card"
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
            field("Regime de Tributacao"; rec."Regime de Tributacao")
            {
                ApplicationArea = All;
                ToolTip = 'Regime de Tributacao';
            }
        }
    }
}
