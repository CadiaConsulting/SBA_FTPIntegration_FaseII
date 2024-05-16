table 50077 "IntegrationPurchaseBuffer"
{
    Caption = 'Integration Purchase Buffer';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Excel File Name"; text[200])
        {
            Caption = 'Excel File Name';
            Editable = false;
        }

        field(2; "Document No."; Code[20])
        {
            Caption = 'Document No.';
        }

        field(3; "Error Order"; Integer)
        {
            Caption = 'Error Order';
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = count("Integration Purchase" where("Document No." = field("Document No."),
                                                             "Status" = filter(2 | 6)));
        }
        field(4; Lines; Integer)
        {
            Caption = 'Lines';
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = count("Integration Purchase" where("Document No." = field("Document No."),
                                                             "Excel File Name" = field("Excel File Name")));
        }
    }

    keys
    {
        key("Key1"; "Excel File Name", "Document No.")
        {
            Clustered = true;
        }
    }
}
