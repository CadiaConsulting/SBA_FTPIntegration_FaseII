tableextension 50010 INTSalesLine extends "Sales Line"
{
    fields
    {
        // Add changes to table fields here
        field(50010; "TAX FROM BILLING APP (PIS)"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'TAX FROM BILLING APP (PIS)';
        }
        field(50011; "TAX FROM BILLING APP (COFINS)"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'TAX FROM BILLING APP (COFINS)';
        }
    }

}