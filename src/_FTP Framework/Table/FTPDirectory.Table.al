table 50003 "FTP Directory"
{
    Caption = 'FTP Directory';
    DataClassification = CustomerContent;
    //TableType = Temporary;

    fields
    {
        field(1; Filename; Text[1024])
        {
            Caption = 'Filename';
            DataClassification = CustomerContent;
        }
        field(2; IsDirectory; Boolean)
        {
            Caption = 'IsDirectory';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; Filename)
        {
            Clustered = true;
        }
    }
}
