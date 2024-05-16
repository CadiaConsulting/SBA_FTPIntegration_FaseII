table 50007 "Integration Rcpt Jnl Apply"
{
    Caption = 'Integration Receipt Journal Apply';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Journal Template Name"; Code[10])
        {
            Caption = 'Journal Template Name';
            DataClassification = CustomerContent;
        }
        field(2; "Journal Batch Name"; Code[10])
        {
            Caption = 'Journal Batch Name';
            DataClassification = CustomerContent;
        }
        field(3; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(4; "Account Type"; Enum "Gen. Journal Account Type")
        {
            Caption = 'Account Type';
            DataClassification = CustomerContent;
        }
        field(5; "Account No."; Code[20])
        {
            Caption = 'Account No.';
            DataClassification = CustomerContent;
        }
        field(6; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            DataClassification = CustomerContent;
        }
        field(7; "Document Type"; Enum "Gen. Journal Document Type")
        {
            Caption = 'Document Type';
            DataClassification = CustomerContent;
        }
        field(8; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = CustomerContent;
        }
        field(9; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(10; "Bal. Account Type"; Enum "Gen. Journal Account Type")
        {
            Caption = 'Bal. Account Type';
            DataClassification = CustomerContent;
        }
        field(11; "Bal. Account No."; Code[20])
        {
            Caption = 'Bal. Account No.';
            DataClassification = CustomerContent;
        }
        field(12; Amount; Decimal)
        {
            Caption = 'Amount';
            DataClassification = CustomerContent;
        }
        field(13; "dimension 1"; Code[20])
        {
            Caption = 'dimension 1';
            DataClassification = CustomerContent;
        }
        field(14; "dimension 2"; Code[20])
        {
            Caption = 'dimension 2';
            DataClassification = CustomerContent;
        }
        field(15; "dimension 3"; Code[20])
        {
            Caption = 'dimension 3';
            DataClassification = CustomerContent;
        }
        field(16; "dimension 4"; Code[20])
        {
            Caption = 'dimension 4';
            DataClassification = CustomerContent;
        }
        field(17; "dimension 5"; Code[20])
        {
            Caption = 'dimension 5';
            DataClassification = CustomerContent;
        }
        field(18; "dimension 6"; Code[20])
        {
            Caption = 'dimension 6';
            DataClassification = CustomerContent;
        }
        field(19; "Applies-to Doc. Type"; Enum "Gen. Journal Document Type")
        {
            Caption = 'Applies-to Doc. Type';
            DataClassification = CustomerContent;
        }
        field(20; "Applies-to Doc. No."; Code[20])
        {
            Caption = 'Applies-to Doc. No.';
            DataClassification = CustomerContent;
        }
        field(21; "External Document No."; Code[20])
        {
            Caption = 'External Document No.';
            DataClassification = CustomerContent;
        }

        field(98; Status; enum "Integration Import Status")
        {
            Caption = 'Status';

        }
        field(99; "Posting Message"; text[200])
        {
            Caption = 'Posting Message';
        }
        field(100; "Error Order"; Integer)
        {
            Caption = 'Error Order';
            FieldClass = FlowField;
            CalcFormula = count("Integration Rcpt Jnl Apply" where("Document No." = field("Document No."),
                                                            "Status" = filter(2 | 6)));
        }
        field(110; "Errors Import Excel"; Integer)
        {
            Caption = 'Errors Import Excel';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = count(IntegrationErros where("Integration Type" = filter(10),
                                                        "Document No." = field("Document No."),
                                                        "Line No." = field("Line No."),
                                                        "excel File name" = field("excel File name")));
        }
        field(115; "Excel File Name"; text[200])
        {
            Caption = 'Excel File Name';
            Editable = false;
        }

    }
    keys
    {
        key(PK; "Journal Template Name", "Journal Batch Name", "Line No.")
        {
            Clustered = true;
        }
        key("Key2"; Status)
        {

        }
    }

}
