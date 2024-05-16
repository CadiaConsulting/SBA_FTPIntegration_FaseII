table 50006 "Integration Vendor"
{
    Caption = 'Integration Vendor';
    DataClassification = CustomerContent;
    LookupPageId = "Integration Vendor";

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
        }
        field(2; Name; Text[100])
        {
            Caption = 'Name';
        }
        field(3; "Search Name"; Text[50])
        {
            Caption = 'Search Name';
        }
        field(4; Category; Code[50])
        {
            Caption = 'Category';
        }
        field(5; "Post Code"; Code[20])
        {
            Caption = 'Post Code';
        }
        field(6; Country; Text[30])
        {
            Caption = 'Country';
        }
        field(7; "Territory Code"; Code[10])
        {
            Caption = 'Territory Code';
        }
        field(8; City; Text[30])
        {
            Caption = 'City';
        }
        field(9; Address; Text[100])
        {
            Caption = 'Address';
        }
        field(10; "Address 2"; Text[50])
        {
            Caption = 'Address 2';
        }
        field(11; Number; Text[12])
        {
            Caption = 'Number';
        }
        field(12; "Phone No."; Text[30])
        {
            Caption = 'Phone No.';
        }
        field(13; "Phone No. 2"; Text[30])
        {
            Caption = 'Phone No. 2';
        }
        field(14; "E-Mail"; Text[80])
        {
            Caption = 'E-Mail';
        }
        field(15; "C.N.P.J./C.P.F."; Code[20])
        {
            Caption = 'C.N.P.J./C.P.F.';
        }
        field(16; Status; enum "IntegrationCustomerVendorStatu")
        {
            Caption = 'Status';
        }
        field(18; "Posting Message"; text[200])
        {
            Caption = 'Posting Message';
        }
        field(19; "Error Order"; Integer)
        {
            Caption = 'Error Order';
            FieldClass = FlowField;
            CalcFormula = count("Integration Customer" where("No." = field("No."),
                                                            "Status" = filter(2 | 6)));
        }
        field(20; "Errors Import Excel"; Integer)
        {
            Caption = 'Errors Import Excel';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = count(IntegrationErros where("Integration Type" = filter(Vendor),
                                                        "document No." = field("No.")));
        }
        field(21; "Excel File Name"; text[200])
        {
            Caption = 'Excel File Name';
            Editable = false;
        }
        field(22; "Address 3"; Text[50])
        {
            Caption = 'Address 3';
        }
        field(23; "Payment Terms Code"; Code[10])
        {
            Caption = 'Payment Terms Code';
        }
        field(24; "Payment Method Code"; Code[10])
        {
            Caption = 'Payment Method Code';
        }
    }
    keys
    {
        key(PK; "No.")
        {
            Clustered = true;
        }
    }
}
