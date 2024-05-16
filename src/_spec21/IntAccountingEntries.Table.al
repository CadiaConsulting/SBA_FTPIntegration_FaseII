table 50074 "IntAccountingEntries"
{
    Caption = 'Integration Accounting Entries';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Journal Template Name"; Code[10])
        {
            Caption = 'Journal Template Name';
        }
        field(2; "Journal Batch Name"; Code[10])
        {
            Caption = 'Journal Batch Name';
        }
        field(3; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }

        field(4; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            DataClassification = ToBeClassified;
        }
        field(5; "Document Type"; Enum "Gen. Journal Document Type")
        {
            Caption = 'Document Type';
            DataClassification = ToBeClassified;
        }
        field(6; "Account Type"; Enum "Gen. Journal Account Type")
        {
            Caption = 'Account Type';
            DataClassification = ToBeClassified;
        }
        field(7; "Account No."; Code[20])
        {
            Caption = 'Account No.';
            DataClassification = ToBeClassified;
        }
        field(8; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = ToBeClassified;
        }
        field(9; "Bal. Account Type"; Enum "Gen. Journal Account Type")
        {
            Caption = 'Bal. Account Type';
            DataClassification = ToBeClassified;
        }
        field(10; "Bal. Account No."; Code[20])
        {
            Caption = 'Bal. Account No.';
            DataClassification = ToBeClassified;
        }
        field(11; Amount; Decimal)
        {
            Caption = 'Amount';
            DataClassification = ToBeClassified;
        }
        field(12; "Dimension 1"; Code[20])
        {
            Caption = 'Dimension 1';
            DataClassification = ToBeClassified;
        }
        field(13; "Dimension 2"; Code[20])
        {
            Caption = 'Dimension 2';
            DataClassification = ToBeClassified;
        }
        field(14; "Dimension 3"; Code[20])
        {
            Caption = 'Dimension 3';
            DataClassification = ToBeClassified;
        }
        field(15; "Dimension 4"; Code[20])
        {
            Caption = 'Dimension 4';
            DataClassification = ToBeClassified;
        }
        field(16; "Dimension 5"; Code[20])
        {
            Caption = 'Dimension 5';
            DataClassification = ToBeClassified;
        }
        field(17; "Dimension 6"; Code[20])
        {
            Caption = 'Dimension 6';
            DataClassification = ToBeClassified;
        }
        field(18; "Dimension 7"; Code[20])
        {
            Caption = 'Dimension 7';
            DataClassification = ToBeClassified;
        }
        field(19; "Dimension 8"; Code[20])
        {
            Caption = 'Dimension 8';
            DataClassification = ToBeClassified;
        }
        field(20; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = ToBeClassified;
        }
        field(21; "Additional Description"; Text[100])
        {
            Caption = 'Additional Description';
            DataClassification = ToBeClassified;
        }
        field(22; "Branch Code"; Code[20])
        {
            Caption = 'Branch Code';
            DataClassification = ToBeClassified;
        }
        field(23; "BR Account No."; Code[20])
        {
            Caption = 'BR Account No.';
            DataClassification = ToBeClassified;
        }
        field(24; "BR Bal. Account No."; Code[20])
        {
            Caption = 'BR Bal. Account No.';
            DataClassification = ToBeClassified;
        }
        field(25; "Bal. Amount"; Decimal)
        {
            Caption = 'Bal. Amount';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = sum(IntAccountingEntries.Amount where("Excel File Name" = field("Excel File Name"),
                                                                 "Document No." = field("Document No."),
                                                                 "Document Type" = field("Document Type"),
                                                                 "Posting Date" = field("Posting Date")));
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
                                                            "Document No." = field("Document No.")));
        }
        field(110; "Errors Import Excel"; Integer)
        {
            Caption = 'Errors Import Excel';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = count(IntegrationErros where("Integration Type" = filter(14),
                                                        "Excel File Name" = field("Excel File Name")));
        }
        field(115; "Excel File Name"; text[200])
        {
            Caption = 'Excel File Name';
            DataClassification = ToBeClassified;
            Editable = false;
        }
    }
    keys
    {
        key(PK; "Line No.")
        {
            Clustered = true;
        }
        key(Key1; "Excel File Name", "Document Type", "Document No.", "Posting Date")
        {

        }
    }
}
