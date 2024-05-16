pageextension 50001 "Posting Preview" extends "CADBR Posting Preview G/L Ent"
{
    layout
    {
        addafter(GLAccountNo)
        {
            field("No. 2"; Rec."No. 2")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the No. 2 field.';
            }
        }
    }
}