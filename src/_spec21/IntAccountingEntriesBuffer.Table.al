table 50076 "IntAccountingEntriesBuffer"
{
    Caption = 'IntAccountingEntries';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Document Type"; Enum "Gen. Journal Document Type")
        {
            Caption = 'Document Type';
            DataClassification = ToBeClassified;
        }
        field(2; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = ToBeClassified;
        }
        field(3; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            DataClassification = ToBeClassified;
        }
        field(4; Amount; Decimal)
        {
            Caption = 'Amount';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = sum(IntAccountingEntries.Amount where("Excel File Name" = field("Excel File Name"),
                                                                 "Document No." = field("Document No."),
                                                                 "Document Type" = field("Document Type"),
                                                                 "Posting Date" = field("Posting Date")));
        }
        field(5; "Bal. Amount"; Decimal)
        {
            Caption = 'Bal. Amount';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = - sum(IntAccountingEntries.Amount where("Excel File Name" = field("Excel File Name"),
                                                                 "Document No." = field("Document No."),
                                                                 "Document Type" = field("Document Type"),
                                                                 "Posting Date" = field("Posting Date"),
                                                                 "Bal. Account No." = filter('<>''''')));
        }
        field(98; Status; enum "Integration Import Status")
        {
            Caption = 'Status ';
            DataClassification = ToBeClassified;
        }
        field(99; "Posting Message"; text[200])
        {
            Caption = 'Posting Message';
            DataClassification = ToBeClassified;
        }
        field(100; "Line Errors"; Integer)
        {
            Caption = 'Line Errors';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = count(IntAccountingEntries where("Excel File Name" = field("Excel File Name"),
                                                            "Status" = filter(2 | 6),
                                                            "Document No." = field("Document No."),
                                                            "Document Type" = field("Document Type"),
                                                            "Posting Date" = field("Posting Date")));
        }
        field(115; "Excel File Name"; text[200])
        {
            Caption = 'Excel File Name';
            DataClassification = ToBeClassified;
            // Editable = false;
        }
    }
    keys
    {
        key(PK; "Excel File Name", "Document Type", "Document No.", "Posting Date")
        {
            Clustered = true;
        }
    }
}
