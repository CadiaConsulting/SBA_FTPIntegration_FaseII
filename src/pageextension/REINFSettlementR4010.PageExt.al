pageextension 50027 "REINF Settlement - R4010" extends "CADBR REINF Settlement - R4000"
{
    actions
    {
        addafter("Import XLS")
        {
            group(ImportSBA)
            {
                Caption = 'SBA Import';
                action("Import XLS 4010 SBA")
                {
                    Caption = 'Importar XLS 4010 SBA';
                    ApplicationArea = Basic;
                    Image = Excel;

                    trigger OnAction()

                    begin
                        REINFSett.Reset();
                        ReinfSett.SetRange("No.", rec."No.");
                        ReinfSett.FIND('-');
                        ImportDataExcel.Run(REINFSett);
                    end;
                }
                action("ProcessJudInfRRA")
                {
                    Caption = 'Process Jud - Inf RRA';
                    ApplicationArea = Basic;
                    Image = Process;
                    RunObject = Page "CADBR Process Jud - Info RRA";
                    RunPagelink = "Tax Settlement No." = field("No.");
                }
            }
        }
    }
    var
        ImportDataExcel: Codeunit "SBA REINF Import Data Excel";
        REINFSett: Record "CADBR REINFSet-R4000_10_80";
}
