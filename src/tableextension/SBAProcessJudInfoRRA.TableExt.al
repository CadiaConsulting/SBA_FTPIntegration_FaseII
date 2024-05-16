tableextension 50028 "SBA Process Jud - Info RRA" extends "CADBR Process Jud - Info RRA"
{
    fields
    {
        field(50000; "Tax Settlement No."; integer)
        {
            Caption = 'Tax Settlement No.';
            DataClassification = ToBeClassified;
            TableRelation = "CADBR REINFSet-R4000_10_80";
        }
    }
}
