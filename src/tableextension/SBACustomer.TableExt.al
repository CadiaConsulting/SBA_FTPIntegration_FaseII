tableextension 50002 "SBA Customer" extends Customer
{
    fields
    {
        field(50000; "Integration Taxes Matrix"; Code[20])
        {
            Caption = 'Integration Taxes Matrix ';
            DataClassification = ToBeClassified;
            TableRelation = "CADBR Taxes Matrix" where(Type = const(Purchase));
        }
    }
}
