tableextension 50009 INTPurchaseLine extends "Purchase Line"
{
    fields
    {
        // Add changes to table fields here
        field(50000; "Status SBA"; Enum "Purchase Document Status")
        {
            Caption = 'Status SBA';
            FieldClass = Normal;
            Editable = false;
        }
    }
}
