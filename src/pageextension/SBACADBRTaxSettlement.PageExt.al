pageextension 50023 "SBA CADBR Tax Settlement" extends "CADBR Tax Settlement"
{

    actions
    {
        addafter(ExpSintegra)
        {
            action(NFTSSP)
            {
                Caption = 'NFTS SP';
                ToolTip = 'NFTS SP';
                ApplicationArea = All;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Category4;
                Image = ExportAttachment;
                PromotedIsBig = true;
                Visible = true;

                trigger OnAction()
                var

                begin
                    rec.Testfield("Start Date");
                    rec.TestField("End Date");

                    ExportNfts.RunNewFile(rec."Branch Code", rec."Start Date", rec."End Date");
                    Message('Exported NFTS');

                end;
            }

        }
    }
    var
        ExportNfts: Codeunit "Export NFTS";
}
