table 50015 "Integration Landlord"
{
    Caption = 'Integration Landlord';
    DataClassification = CustomerContent;
    LookupPageId = "Integration Landlord";

    fields
    {

        field(1; "Document No."; Code[20])
        {
            Caption = 'Document No.';
        }
        field(2; "Document Date"; Date)
        {
            Caption = 'Document Date';
        }
        field(3; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
        }
        field(5; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }

        field(6; "Buy-from Vendor No."; Code[20])
        {
            Caption = 'Buy-from Vendor No.';
        }
        field(7; Type; enum IntegrationSalesType)
        {
            Caption = 'Type';
        }
        field(8; "Item No."; Code[20])
        {
            Caption = 'No.';
        }

        field(9; Description; Text[100])
        {
            Caption = 'Description';
        }

        field(10; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DecimalPlaces = 0 : 5;
        }
        field(11; "Direct Unit Cost Excl. Vat"; Decimal)
        {
            Caption = 'Direct Unit Cost Excl. Vat';
        }

        field(12; Amount; Decimal)
        {
            Caption = 'Amount';
            DecimalPlaces = 0 : 5;
        }

        field(15; "Entity Category"; Text[100])
        {
            Caption = 'Entity Category';
        }
        field(16; "Number Vendor No."; Code[20])
        {
            Caption = 'Number Vendor No.';
        }
        field(22; "Tax Area Code"; Code[20])
        {
            Caption = 'Tax Area Code';

        }

        field(29; "Shortcut Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
        }
        field(30; "Shortcut Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code';
        }
        field(31; "Shortcut Dimension 3 Code"; Code[20])
        {
            CaptionClass = '1,2,3';
            Caption = 'Shortcut Dimension 3 Code';
        }
        field(32; "Shortcut Dimension 4 Code"; Code[20])
        {
            CaptionClass = '1,2,4';
            Caption = 'Shortcut Dimension 4 Code';
        }
        field(33; "Shortcut Dimension 5 Code"; Code[20])
        {
            CaptionClass = '1,2,5';
            Caption = 'Shortcut Dimension 5 Code';
        }
        field(34; "Shortcut Dimension 6 Code"; Code[20])
        {
            CaptionClass = '1,2,6';
            Caption = 'Shortcut Dimension 6 Code';
        }

        field(35; "Vendor Invoice No."; Code[20])
        {
            Caption = 'Vendor Invoice No.';
        }
        field(40; "G/L Account"; Code[20])
        {
            Caption = 'G/L Account';
        }

        field(50; "IRRF Ret"; Decimal)
        {
            Caption = 'IRRF Ret';
        }
        field(51; "CSRF Ret"; Decimal)
        {
            Caption = 'CSRF Ret';
        }
        field(52; "INSS Ret"; Decimal)
        {
            Caption = 'INSS Ret';
        }
        field(53; "ISS Ret"; Decimal)
        {
            Caption = 'ISS Ret';
        }
        field(54; "PIS Credit"; Decimal)
        {
            Caption = 'PIS Credit';
        }
        field(55; "Cofins Credit"; Decimal)
        {
            Caption = 'Cofins Credit';
        }
        field(56; "DIRF"; Decimal)
        {
            Caption = 'DIRF';
        }
        field(57; "PO Total"; Decimal)
        {
            Caption = 'PO Total';
        }

        field(63; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
        }

        field(65; "Paid Date"; Date)
        {
            Caption = 'Paid Date';
        }

        field(91; "Post Code"; Code[20])
        {
            Caption = 'Post Code';
        }
        field(92; "Fiscal Document Type"; Code[10])
        {
            Caption = 'Fiscal Document Type';
        }
        field(93; "Service Code"; Code[20])
        {
            Caption = 'Service Code';
        }
        field(73; "Reason Code"; Code[10])
        {
            Caption = 'Reason Code';
            Editable = false;
            TableRelation = "Reason Code";

        }
        field(74; "Reason Description"; text[100])
        {
            Caption = 'Reason Description';
            Editable = false;
        }
        field(95; "Gen. Prod. Posting Group"; Code[20])
        {
            Caption = 'Gen. Prod. Posting Group';
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
            CalcFormula = count("Integration Landlord" where("Document No." = field("Document No."),
                                                            "Status" = filter(2 | 6)));
        }
        field(110; "Errors Import Excel"; Integer)
        {
            Caption = 'Errors Import Excel';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = count(IntegrationErros where("Integration Type" = filter(15),
                                                        "Document No." = field("Document No."),
                                                        "Line No." = field("Line No.")));
        }
        field(115; "Excel File Name"; text[200])
        {
            Caption = 'Excel File Name';
            Editable = false;
        }
        field(120; "Status PO"; enum "Purchase Document Status")
        {
            Caption = 'Status PO';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup("Purchase Header".Status where("No." = field("Document No."),
                                                                "Document Type" = filter(Order)));
        }

        field(150; "Order IRRF Ret"; Decimal)
        {
            Caption = 'Order IRRF Ret';
        }
        field(151; "Order CSRF Ret"; Decimal)
        {
            Caption = 'Order CSRF Ret';
        }
        field(152; "Order INSS Ret"; Decimal)
        {
            Caption = 'Order INSS Ret';
        }
        field(153; "Order ISS Ret"; Decimal)
        {
            Caption = 'Order ISS Ret';
        }
        field(154; "Order PIS Credit"; Decimal)
        {
            Caption = 'Order PIS Credit';
        }
        field(155; "Order Cofins Credit"; Decimal)
        {
            Caption = 'Order Cofins Credit';
        }
        field(156; "Order DIRF Ret"; Decimal)
        {
            Caption = 'Order DIRF Ret';
        }
        field(200; "Not Dif. Impostos"; Boolean)
        {
            Caption = 'Not Dif. Impostos';
            Editable = false;
        }


    }

    keys
    {
        key("Key1"; "Entry No.")
        {
            Clustered = true;
        }
        key("Key2"; "Excel File Name", "Document No.", "Line No.")
        {

        }
        key("Key3"; Status, "Document No.", "Line No.")
        {

        }
        key("Key4"; "Document No.", "Line No.")
        {

        }
        key("Key5"; Status, "Buy-from Vendor No.")
        {

        }
    }

    var


    trigger OnInsert()
    begin

    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin

    end;

}