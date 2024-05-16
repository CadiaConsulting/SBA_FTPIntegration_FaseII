table 50002 "Status Files Validation"
{
    Caption = 'Status Files Validation';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(2; Filename; Text[1024])
        {
            Caption = 'Filename';
            DataClassification = CustomerContent;
        }
        field(3; Status; Enum "Status File Validation")
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
        }
        field(4; "Log Message"; Text[1024])
        {
            Caption = 'Log Message';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }
}
