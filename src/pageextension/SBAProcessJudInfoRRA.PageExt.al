pageextension 50031 "SBA Process Jud - Info RRA" extends "CADBR Process Jud - Info RRA"
{
    layout
    {
        addbefore("process type")
        {
            field("Tax Settlement No."; rec."Tax Settlement No.")
            {
                ApplicationArea = All;
            }
        }
    }
}
