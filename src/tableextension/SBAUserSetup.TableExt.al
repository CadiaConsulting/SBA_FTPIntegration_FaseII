tableextension 50008 "SBA User Setup" extends "User Setup"
{
    fields
    {
        field(50000; "Release PO"; Boolean)
        {
            Caption = 'Release PO';
            DataClassification = ToBeClassified;

        }
        field(50001; "Review PO"; Boolean)
        {
            Caption = 'Review PO';
        }
        field(50002; "Open PO"; Boolean)
        {
            Caption = 'Open PO';
        }
    }
}
