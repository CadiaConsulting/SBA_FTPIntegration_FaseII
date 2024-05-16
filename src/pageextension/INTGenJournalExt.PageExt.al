pageextension 50018 "INTGenJournalExt" extends "General Journal"
{

    actions
    {
        modify("CADBR &Import from Excel")
        {
            Visible = false;
        }

        addafter("CADBR &Import from Excel")
        {
            action(NewImportExcel)
            {
                Caption = 'Import from SBA Excel File';
                ApplicationArea = Basic, Suite;
                Image = ViewOrder;
                ToolTip = 'Import from Excel SBA format to General Journal.';

                trigger OnAction()
                var
                    ImpGenJnlFromExcel: Codeunit "Imp. GenJnl From Excel";
                begin
                    ImpGenJnlFromExcel.Run(Rec);
                end;
            }
        }

    }
}
