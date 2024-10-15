table 50013 "Integration Purchase"
{
    Caption = 'Integration Purchase';
    DataClassification = CustomerContent;
    LookupPageId = "Integration Purchase";

    fields
    {

        field(1; "Document No."; Code[20])
        {
            Caption = 'Document No.';
        }
        field(2; "Order Date"; Date)
        {
            Caption = 'Order Date';
        }

        field(3; "Additional Description"; Text[100])
        {
            Caption = 'Additional Description';
        }
        field(4; "Doc. URL"; Text[250])
        {
            Caption = 'Doc. URL';
            ExtendedDatatype = URL;
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
        field(60; "Rejected"; Boolean)
        {
            Caption = 'Rejected';
        }
        field(61; "Local Service Provision"; Text[60])
        {
            Caption = 'Local Service Provision';
        }
        field(62; "Municipio Code"; Code[20])
        {
            Caption = 'Municipio Code';
        }
        field(63; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
        }
        field(64; "Release to Post"; Boolean)
        {
            Caption = 'Release to Post';
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
            CalcFormula = count("Integration Purchase" where("Document No." = field("Document No."),
                                                            "Status" = filter(2 | 6)));
        }
        field(110; "Errors Import Excel"; Integer)
        {
            Caption = 'Errors Import Excel';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = count(IntegrationErros where("Integration Type" = filter(2),
                                                        "Document No." = field("Document No."),
                                                        "Line No." = field("Line No.")));
        }
        field(111; "Document Errors Import Excel"; Integer)
        {
            Caption = 'Document Errors Import Excel';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = count(IntegrationErros where("Integration Type" = filter(2),
                                                        "Document No." = field("Document No.")));
        }
        field(115; "Excel File Name"; text[200])
        {
            Caption = 'Excel File Name';
            Editable = false;
        }
        field(116; "Purch Post Excel File Name"; text[200])
        {
            Caption = 'Purch Post Excel File Name';
            Editable = false;
        }

        field(117; "Exported Excel Purch. Tax Name"; text[200])
        {
            Caption = 'Exported Excel Purch. Tax Name';
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
            ObsoleteState = Removed;
        }
        field(250; "Tax % Order IRRF Ret"; Decimal)
        {
            Caption = 'Tax % Order IRRF Ret';
        }
        field(251; "Tax % Order CSRF Ret"; Decimal)
        {
            Caption = 'Tax % Order CSRF Ret';
        }
        field(252; "Tax % Order INSS Ret"; Decimal)
        {
            Caption = 'Tax % Order INSS Ret';
        }
        field(253; "Tax % Order ISS Ret"; Decimal)
        {
            Caption = 'Tax % Order ISS Ret';
        }
        field(256; "Tax % Order DIRF Ret"; Decimal)
        {
            Caption = 'Tax % Order DIRF Ret';
        }


    }

    keys
    {
        key("Key1"; "Document No.", "Line No.", "Excel File Name")
        {
            Clustered = true;
        }
        key("Key2"; "Excel File Name", "Document No.", "Line No.")
        {

        }
        key("Key3"; Status, "Document No.", "Line No.")
        {

        }
        key("Key4"; "Document No.", "Order Date")
        {

        }

        key("Key5"; "Excel File Name", Status)
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