pageextension 50032 "SBA Purchase Order Statistics" extends "Purchase Order Statistics"
{
    layout
    {

    }

    trigger OnOpenPage()
    begin
        CurrPage.Editable := rec.Status = rec.Status::Open;

    end;

}
