pageextension 50013 "INTPurchHeader" extends "Purchase Order"
{
    layout
    {
        // Add changes to page layout here
        addbefore(Status)
        {
            // field("Doc. URL"; rec."Doc. URL")
            // {
            //     ApplicationArea = All;
            //     ToolTip = 'Doc. URL';
            // }
            field("IRRF Ret"; rec."IRRF Ret")
            {
                ApplicationArea = All;
                ToolTip = 'IRRF Ret';
            }

            field("CSRF Ret"; rec."CSRF Ret")
            {
                ApplicationArea = All;
                ToolTip = 'CSRF Ret';
            }

            field("INSS Ret"; rec."INSS Ret")
            {
                ApplicationArea = All;
                ToolTip = 'INSS Ret';
            }
            field("ISS Ret"; rec."ISS Ret")
            {
                ApplicationArea = All;
                ToolTip = 'ISS Ret';
            }

            field("PIS Credit"; rec."PIS Credit")
            {
                ApplicationArea = All;
                ToolTip = 'PIS Credit';
            }

            field("Cofins Credit"; rec."Cofins Credit")
            {
                ApplicationArea = All;
                ToolTip = 'Cofins Credit';
            }
            field(DIRF; rec.DIRF)
            {
                ApplicationArea = All;
                ToolTip = 'Dirf';
            }
            field("PO Total"; rec."PO Total")
            {
                ApplicationArea = All;
                ToolTip = 'PO Total';
            }

        }
    }

}