pageextension 50017 "INTPurchaseOrderList" extends "Purchase Order List"
{
    layout
    {
        // Add changes to page layout here
        addbefore("Buy-from Vendor Name")
        {
            field("Buy-from City"; rec."Buy-from City")
            {
                ApplicationArea = All;
                ToolTip = 'Buy-from City';
            }
        }
    }
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
                    PurchaseHeader: Record "Purchase Header";
                begin
                    CurrPage.SetSelectionFilter(PurchaseHeader);
                    PurchaseHeader.SetRange("Document Type", PurchaseHeader."Document Type"::Order);
                    if not PurchaseHeader.IsEmpty then begin
                        if Confirm('You will delete %1 records, do you want to continue?', false, Format(PurchaseHeader.Count())) then begin
                            PurchaseHeader.ModifyAll("Posting No.", '');
                            PurchaseHeader.DeleteAll(true);
                        end;
                    end;

                end;
            }
        }
    }
}