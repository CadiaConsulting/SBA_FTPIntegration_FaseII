pageextension 50029 INTPurchaseInvoiceSubForm extends "Posted Purch. Invoice Subform"
{
    actions
    {

        addafter(DocAttach)
        {
            action(UpdateLIne)
            {
                Caption = 'Update Line';
                ApplicationArea = Basic, Suite;
                Image = ViewOrder;
                ToolTip = 'Update Line';

                trigger OnAction()
                var
                    UpdatePurchLine: Page PurchLineEdit;
                    PurchLine: Record "Purch. Inv. Line";
                begin
                    CurrPage.SetSelectionFilter(PurchLine);
                    PurchLine.CopyFilters(Rec);
                    PAGE.Run(PAGE::PurchLineEdit, PurchLine);

                end;
            }
        }

    }

}