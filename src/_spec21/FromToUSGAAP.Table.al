table 50075 "From/To US GAAP"
{
    Caption = 'From/To US GAAP';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "US GAAP"; Code[50])
        {
            Caption = 'US GAAP';
            DataClassification = ToBeClassified;
        }
        field(2; "Dimension 1"; Code[20])
        {
            Caption = 'Dimension 1';
            CaptionClass = '1,2,1';
            DataClassification = ToBeClassified;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));
        }
        field(3; "Dimension 2"; Code[20])
        {
            Caption = 'Dimension 2';
            CaptionClass = '1,2,2';
            DataClassification = ToBeClassified;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));
        }
        field(4; "Dimension 3"; Code[20])
        {
            Caption = 'Dimension 3';
            CaptionClass = '1,2,3';
            DataClassification = ToBeClassified;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(3),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));
        }
        field(5; "Dimension 4"; Code[20])
        {
            Caption = 'Dimension 4';
            CaptionClass = '1,2,4';
            DataClassification = ToBeClassified;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(4),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));
        }
        field(6; "Dimension 5"; Code[20])
        {
            Caption = 'Dimension 5';
            CaptionClass = '1,2,5';
            DataClassification = ToBeClassified;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(5),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));
        }
        field(7; "Dimension 6"; Code[20])
        {
            Caption = 'Dimension 6';
            CaptionClass = '1,2,6';
            DataClassification = ToBeClassified;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(6),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));
        }
        field(8; "Dimension 7"; Code[20])
        {
            Caption = 'Dimension 7';
            CaptionClass = '1,2,7';
            DataClassification = ToBeClassified;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(7),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));
        }
        field(9; "Dimension 8"; Code[20])
        {
            Caption = 'Dimension 8';
            CaptionClass = '1,2,8';
            DataClassification = ToBeClassified;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(8),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));
        }
        field(10; "BR GAAP"; Code[20])
        {
            Caption = 'BR GAAP';
            DataClassification = ToBeClassified;
            TableRelation = "G/L Account";
        }
    }
    keys
    {
        key(PK; "US GAAP", "Dimension 1", "Dimension 2", "Dimension 3", "Dimension 4", "Dimension 5", "Dimension 6", "Dimension 7", "Dimension 8")
        {
            Clustered = true;
        }
    }
}
