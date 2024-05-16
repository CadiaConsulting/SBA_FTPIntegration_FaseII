page 50007 "From/To US GAAP"
{
    ApplicationArea = All;
    Caption = 'From/To US GAAP';
    PageType = List;
    SourceTable = "From/To US GAAP";
    UsageCategory = Lists;
    
    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("US GAAP"; Rec."US GAAP")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the US GAAP field.';
                }
                field("Dimension 1"; Rec."Dimension 1")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Dimension 1 field.';
                }
                field("Dimension 2"; Rec."Dimension 2")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Dimension 2 field.';
                }
                field("Dimension 3"; Rec."Dimension 3")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Dimension 3 field.';
                }
                field("Dimension 4"; Rec."Dimension 4")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Dimension 4 field.';
                }
                field("Dimension 5"; Rec."Dimension 5")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Dimension 5 field.';
                }
                field("Dimension 6"; Rec."Dimension 6")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Dimension 6 field.';
                }
                field("Dimension 7"; Rec."Dimension 7")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Dimension 7 field.';
                }
                field("Dimension 8"; Rec."Dimension 8")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Dimension 8 field.';
                }
                field("BR GAAP"; Rec."BR GAAP")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the BR GAAP field.';
                }
            }
        }
    }
}
