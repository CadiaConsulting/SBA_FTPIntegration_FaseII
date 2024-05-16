table 50011 "IntSalesCreditNote"
{
    Caption = 'Integration Sales Credit Memo';
    DataClassification = CustomerContent;
    LookupPageId = IntegrationSales;

    fields
    {

        field(1; "No."; Code[20])
        {
            Caption = 'No.';
        }
        field(2; "Sell-to Customer No."; Code[20])
        {
            Caption = 'Sell-to Customer No.';
        }

        field(3; "Your Reference"; Text[35])
        {
            Caption = 'Your Reference';
        }
        field(4; "Order Date"; Date)
        {
            Caption = 'Order Date';
        }
        field(5; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
        }

        field(8; "Document Date"; Date)
        {
            Caption = 'Document Date';
        }
        field(9; "External Document No."; Code[35])
        {
            Caption = 'External Document No.';

        }
        field(10; Status; Enum "Integration Import Status")
        {
            Caption = 'Status';

        }
        field(11; "Customer Posting Group"; Code[20])
        {
            Caption = 'Customer Posting Group';
        }
        field(12; "Freight Billed To"; Enum IntegrationSalesFreight)
        {
            Caption = 'Freight Billed To';
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
        field(40; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(41; Type; Enum IntegrationSalesType)
        {
            Caption = 'Type';
        }
        field(42; "Item No."; Code[20])
        {
            Caption = 'No.';
        }

        field(44; Description; Text[100])
        {
            Caption = 'Description';
        }

        field(46; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DecimalPlaces = 0 : 5;
        }
        field(47; "Unit Price"; Decimal)
        {
            Caption = 'Unit Price';
        }

        field(54; "G/L Account"; Code[20])
        {
            Caption = 'G/L Account';
        }
        field(55; "Tax From Billing APP (PIS)"; Decimal)
        {
            Caption = 'Tax From Billing APP (PIS)';
        }
        field(56; "Tax From Billing APP (COFINS)"; Decimal)
        {
            Caption = 'Tax From Billing APP (COFINS)';
        }
        field(57; "Posting Message"; text[200])
        {
            Caption = 'Posting Message';
        }
        field(58; "Tax (PIS) Line"; Decimal)
        {
            Caption = 'Tax (PIS) Line';
            Editable = false;
        }
        field(59; "Tax (COFINS) Line"; Decimal)
        {
            Caption = 'Tax (COFINS) Line';
            Editable = false;
        }
        field(60; "Tax (PIS) Order"; Decimal)
        {
            Caption = 'Tax (PIS) Order';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = sum(IntSalesCreditNote."Tax (PIS) Line" where("No." = field("No.")));
        }
        field(61; "Tax (COFINS) Order"; Decimal)
        {
            Caption = 'Tax (COFINS) Order';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = sum(IntSalesCreditNote."Tax (COFINS) Line" where("No." = field("No.")));
        }
        field(100; "Error Order"; Integer)
        {
            Caption = 'Error Order';
            FieldClass = FlowField;
            CalcFormula = count(IntSalesCreditNote where("No." = field("No."),
                                                            "Status" = filter(2)));
        }
        field(110; "Errors Import Excel"; Integer)
        {
            Caption = 'Errors Import Excel';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = count(IntegrationErros where("Integration Type" = filter(1),
                                                        "Document No." = field("No."),
                                                        "Line No." = field("Line No.")));
        }
        field(115; "Excel File Name"; text[200])
        {
            Caption = 'Excel File Name';
            Editable = false;
        }


    }

    keys
    {
        key("Key1"; "No.", "Line No.")
        {
            Clustered = true;
        }
        key("Key2"; "Excel File Name", "No.", "Line No.")
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