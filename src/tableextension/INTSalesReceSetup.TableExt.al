tableextension 50011 INTSalesReceSetup extends "Sales & Receivables Setup"
{
    fields
    {
        // Add changes to table fields here
        field(50010; "Int Tax Difference Allowed"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Integration Tax Difference Allowed';
        }
    }

}