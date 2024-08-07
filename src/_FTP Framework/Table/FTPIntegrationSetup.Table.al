table 50001 "FTP Integration Setup"
{
    Caption = 'FTP Integration Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; Integration; enum "FTP Integration Type")
        {
            Caption = 'Integration';
            DataClassification = CustomerContent;
        }
        field(2; "URL Azure"; Text[1024])
        {
            Caption = 'URL Azure';
            DataClassification = CustomerContent;
        }
        field(3; "URL Address FTP"; Text[1024])
        {
            Caption = 'URL Address FTP';
            DataClassification = CustomerContent;
        }
        field(4; "FTP User"; Text[1024])
        {
            Caption = 'FTP User';
            DataClassification = CustomerContent;
        }
        field(5; "FTP Password"; Text[1024])
        {
            Caption = 'FTP Password';
            DataClassification = CustomerContent;
        }

        field(6; "E-mail Rejected File"; Text[250])
        {
            Caption = 'E-mail Rejected File';
            DataClassification = CustomerContent;
        }
        field(7; "E-mail Rejected Data"; Text[250])
        {
            Caption = 'E-mail Rejected Data';
            DataClassification = CustomerContent;
        }
        field(8; "Manage by file"; Boolean)
        {
            Caption = 'Manage by file';
            DataClassification = CustomerContent;
        }
        field(9; "Integration Relation"; Code[20])
        {
            Caption = 'Integration Relation';
            DataClassification = CustomerContent;
        }
        field(10; "Sequence"; Integer)
        {
            Caption = 'Sequence';
            DataClassification = CustomerContent;
        }

        field(11; "Directory"; Text[250])
        {
            Caption = 'Directory';
            DataClassification = CustomerContent;
        }

        field(12; "Error Folder"; Text[250])
        {
            Caption = 'Error Folder';
            DataClassification = CustomerContent;
        }

        field(13; "Imported Folder"; Text[250])
        {
            Caption = 'Imported Folder';
            DataClassification = CustomerContent;
        }


        field(14; "Send Email"; Boolean)
        {
            Caption = 'Send Email';
            DataClassification = CustomerContent;
        }

        field(113; "Prefix File Name"; Text[100])
        {
            Caption = 'Prefix File Name';
            DataClassification = CustomerContent;
        }
        field(114; "Active Prefix File Name"; Boolean)
        {
            Caption = 'Active Prefix File Name';
            DataClassification = CustomerContent;
        }

        field(200; "Import Excel"; Boolean)
        {
            Caption = 'Import Excel';
            DataClassification = CustomerContent;
        }

        field(201; "Create Order"; Boolean)
        {
            Caption = 'Create Order';
            DataClassification = CustomerContent;
        }

        field(203; "Post Order"; Boolean)
        {
            Caption = 'Post Order';
            DataClassification = CustomerContent;
        }
        field(204; "Export Excel"; Boolean)
        {
            Caption = 'Export Excel';
            DataClassification = CustomerContent;
        }
        field(205; "Import Purch Post"; Boolean)
        {
            Caption = 'Import Purch Post';
            DataClassification = CustomerContent;
        }
        field(206; "Suggest Vendor Payments"; Boolean)
        {
            Caption = 'Suggest Vendor Payments';
            DataClassification = CustomerContent;
        }


    }
    keys
    {
        key(PK; "Integration")
        {
            Clustered = true;
        }

        key(FK; "Integration Relation", Sequence)
        {

        }
    }
}
