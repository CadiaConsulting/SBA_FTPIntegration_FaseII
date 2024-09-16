tableextension 50009 INTPurchaseLine extends "Purchase Line"
{
    fields
    {
        // Add changes to table fields here
        field(50000; "Status SBA"; Enum "Purchase Document Status")
        {
            Caption = 'Status SBA';
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = Lookup("Purchase Header".Status WHERE("No." = FIELD("Document No."), "Document Type" = field("Document Type")));
        }
    }
}
