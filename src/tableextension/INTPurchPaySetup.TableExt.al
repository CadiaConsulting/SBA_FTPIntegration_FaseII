tableextension 50006 INTPurchPaySetup extends "Purchases & Payables Setup"
{
    fields
    {
        // Add changes to table fields here
        field(50010; "Item Serv. Landlord"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Item Serv. Landlord';
            TableRelation = Item where(Type = filter('Service'));

        }

        field(50020; "Activate Auxiliary Taxes"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Activate Auxiliary Taxes';

        }
    }

}