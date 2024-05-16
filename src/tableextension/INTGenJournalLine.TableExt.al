tableextension 50014 "INTGenJournalLine" extends "Gen. Journal Line"
{
    fields
    {
        field(50000; "Service Delivery City"; Code[7])
        {
            DataClassification = ToBeClassified;
            Caption = 'Service Delivery City';
            TableRelation = "CADBR Municipio";
        }
    }

}