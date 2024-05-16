tableextension 50003 "SBA Vendor" extends Vendor
{
    fields
    {
        field(50000; "Integration Taxes Matrix"; Code[20])
        {
            Caption = 'Integration Taxes Matrix';
            DataClassification = ToBeClassified;
            TableRelation = "CADBR Taxes Matrix" where(Type = const(Sale));
        }
        field(50001; "Regime de Tributacao"; enum "Vendor Regime")
        {
            Caption = 'Regime de Tributacao';
        }
    }
}
