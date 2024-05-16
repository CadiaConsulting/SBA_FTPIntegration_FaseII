pageextension 50016 "INTSalesReturnOrderList" extends "Sales Return Order List"
{
    actions
    {
        addlast(processing)
        {
            action(DeleteRecords)
            {
                Caption = 'Delete Records';
                ApplicationArea = All;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                Image = Delete;
                PromotedIsBig = true;
                Visible = true;

                trigger OnAction()
                var
                    SalesHeader: Record "Sales Header";
                begin
                    CurrPage.SetSelectionFilter(SalesHeader);
                    SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::"Return Order");
                    if not SalesHeader.IsEmpty then begin
                        if Confirm('You will delete %1 records, do you want to continue?', false, Format(SalesHeader.Count())) then begin
                            SalesHeader.ModifyAll("Posting No.", '');
                            SalesHeader.DeleteAll(true);
                        end;
                    end;

                end;
            }
        }
    }
}