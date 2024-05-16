page 50008 "VAT Entry Update"
{
    ApplicationArea = All;
    Caption = 'VAT Entry Update';
    PageType = List;
    SourceTable = "VAT Entry";
    UsageCategory = History;
    Permissions = tabledata "VAT Entry" = m;
    DeleteAllowed = false;
    InsertAllowed = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = All;
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;
                }
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = All;
                }

                field("Type"; Rec."Type")
                {
                    ApplicationArea = All;
                }
                field("CADBR Branch Code"; Rec."CADBR Branch Code")
                {
                    ApplicationArea = All;
                }
                field("CADBR Invoice Line No."; Rec."CADBR Invoice Line No.")
                {
                    ApplicationArea = All;
                }
                field("CADBR Invoice Line Type"; Rec."CADBR Invoice Line Type")
                {
                    ApplicationArea = All;
                }
                field("CADBR CFOP Code"; Rec."CADBR CFOP Code")
                {
                    ApplicationArea = All;
                }
                field("CADBR No."; Rec."CADBR No.")
                {
                    ApplicationArea = All;
                }
                field("CADBR Tax Identification"; Rec."CADBR Tax Identification")
                {
                    ApplicationArea = All;
                }
                field(Base; Rec.Base)
                {
                    ApplicationArea = All;
                    Editable = true;
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;
                    Editable = true;
                }
                field("CADBR Payment/Receipt Base"; Rec."CADBR Payment/Receipt Base")
                {
                    ApplicationArea = All;
                    Editable = true;
                }
                field("CADBR Tax %"; Rec."CADBR Tax %")
                {
                    ApplicationArea = All;
                    Editable = true;
                }
                field("CADBR Payment Date"; Rec."CADBR Payment Date")
                {
                    ApplicationArea = All;
                    Editable = true;
                }
                field("CADBR Service Type REINF"; Rec."CADBR Service Type REINF")
                {
                    ApplicationArea = All;
                    Editable = true;
                }
            }
        }
    }
}