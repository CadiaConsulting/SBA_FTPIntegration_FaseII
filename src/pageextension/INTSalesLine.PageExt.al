pageextension 50010 INTSalesLine extends "Sales Order Subform"
{
    layout
    {
        // Add changes to page layout here
        addbefore("CADBR PIS CST Code")
        {
            field("TAX FROM BILLING APP (PIS)"; rec."TAX FROM BILLING APP (PIS)")
            {
                Caption = 'TAX FROM BILLING APP (PIS)';
                ApplicationArea = all;
                ToolTip = 'TAX FROM BILLING APP (PIS)';
            }
            field("TAX FROM BILLING APP (COFINS)"; rec."TAX FROM BILLING APP (COFINS)")
            {
                Caption = 'TAX FROM BILLING APP (COFINS)';
                ApplicationArea = all;
                ToolTip = 'TAX FROM BILLING APP (COFINS)';
            }

        }
    }

}