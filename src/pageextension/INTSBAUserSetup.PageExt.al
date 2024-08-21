pageextension 50007 "SBA User Setup" extends "User Setup"
{

    layout
    {
        addafter("Time Sheet Admin.")
        {
            field("Release PO"; Rec."Release PO")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Release PO field.';
            }

            field("Review PO"; Rec."Review PO")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Review PO field.';
            }

            field("Open PO"; Rec."Open PO")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Open PO field.';
            }

        }

    }
}
