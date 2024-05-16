table 50100 "FTP Blob"
{
    Access = Internal;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Primary Key';
        }

        field(2; "BLOB"; Blob)
        {
            DataClassification = CustomerContent;
            Caption = 'BLOB';
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }

}