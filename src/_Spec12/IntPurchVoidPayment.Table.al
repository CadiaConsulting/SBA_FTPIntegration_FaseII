table 50078 "IntPurchVoidPayment"
{
    Caption = 'Integration Purchase Void Payment';
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
        field(4; "Account Type"; Enum "Gen. Journal Account Type")
        {
            Caption = 'Account Type';
            InitValue = Vendor;
            ValuesAllowed = Vendor;
        }
        field(5; "Account No."; Code[20])
        {
            Caption = 'Account No.';
        }
        field(6; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
        }
        field(7; "Document Type"; Enum "Gen. Journal Document Type")
        {
            Caption = 'Document Type';
        }
        field(8; "Document No."; Code[20])
        {
            Caption = 'Document No.';
        }
        field(9; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(10; "Bal. Account Type"; Enum "Gen. Journal Account Type")
        {
            Caption = 'Bal. Account Type';
        }
        field(11; "Bal. Account No."; Text[20])
        {
            Caption = 'Description';
        }
        field(12; Amount; Decimal)
        {
            Caption = 'Amount';
        }
        field(13; "Tax Amount"; Decimal)
        {
            Caption = 'Tax Amount';
        }
        field(14; "Dimension 1"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Dimension 1';
        }
        field(15; "Dimension 2"; Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Dimension 2';
        }
        field(16; "Dimension 3"; Code[20])
        {
            CaptionClass = '1,2,3';
            Caption = 'Dimension 3';
        }
        field(17; "Dimension 4"; Code[20])
        {
            CaptionClass = '1,2,4';
            Caption = 'Dimension 4';
        }
        field(18; "Dimension 5"; Code[20])
        {
            CaptionClass = '1,2,5';
            Caption = 'Dimension 5';
        }
        field(19; "Dimension 6"; Code[20])
        {
            CaptionClass = '1,2,6';
            Caption = 'Dimension 6';
        }
        field(20; "Dimension 7"; Code[20])
        {
            CaptionClass = '1,2,7';
            Caption = 'Dimension 7';
        }
        field(21; "Dimension 8"; Code[20])
        {
            CaptionClass = '1,2,8';
            Caption = 'Dimension 8';
        }
        field(22; "Applies-to Doc. Type"; Enum "Gen. Journal Document Type")
        {
            Caption = 'Applies-to Doc. Type';
        }
        field(23; "Applies-to Doc. No."; Code[20])
        {
            Caption = 'Applies-to Doc. No.';
        }
        field(24; "External Document No."; Code[35])
        {
            Caption = 'External Document No.';
        }
        field(25; "Tax Account No."; Code[20])
        {
            Caption = 'Tax Account No.';
        }
        field(26; "Journal Line No."; Integer)
        {
            Caption = 'Journal Line No.';
            Editable = false;
        }
        field(98; Status; enum "Integration Import Status")
        {
            Caption = 'Status ';
        }
        field(99; "Posting Message"; text[200])
        {
            Caption = 'Posting Message';
        }
        field(100; "Line Errors"; Integer)
        {
            Caption = 'Line Errors';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = count(IntPurchVoidPayment where("Excel File Name" = field("Excel File Name"),
                                                            "Status" = filter(2 | 6)));
        }
        field(110; "Errors Import Excel"; Integer)
        {
            Caption = 'Errors Import Excel';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = count(IntegrationErros where("Integration Type" = filter(16),
                                                        "Excel File Name" = field("Excel File Name")));
        }
        field(115; "Excel File Name"; text[200])
        {
            Caption = 'Excel File Name';
            Editable = false;
        }

        field(257; "Tax Paid"; Boolean)
        {
            Caption = 'Tax Paid';
        }

    }
    keys
    {
        key(PK; "Journal Template Name", "Journal Batch Name", "Line No.", "Excel File Name")
        {
            Clustered = true;
        }

        key(Key1; "Document No.")
        {

        }

        key(Key2; "Excel File Name", "Journal Template Name", "Journal Batch Name", Status)
        {

        }
    }
}
