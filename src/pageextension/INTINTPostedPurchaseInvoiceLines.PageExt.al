pageextension 50025 INTPostedPurchaseInvoiceLines extends "Posted Purchase Invoice Lines"
{
    layout
    {
        // Add changes to page layout here
        addbefore(Description)
        {
            field("Vendor Name"; Rec."Vendor Name")
            {
                ApplicationArea = All;
                ToolTip = 'Vendor Name';
            }
            field("Fiscal Doc. No."; Rec."Fiscal Doc. No.")
            {
                ApplicationArea = All;
                ToolTip = 'Fiscal Doc. No.';
            }
            field("Posting Date"; rec."Posting Date")
            {
                ApplicationArea = all;
                ToolTip = 'Posting Date';
            }
            field("Document Date"; Rec."Document Date")
            {
                ApplicationArea = All;
                ToolTip = 'Document Date';
            }
            field("CADBR Service Code"; rec."CADBR Service Code")
            {
                Caption = 'CADBR Service Code';
                ApplicationArea = all;
                ToolTip = 'CADBR Service Code';
            }
            field("Tax Area Code"; rec."Tax Area Code")
            {
                ApplicationArea = all;
                ToolTip = 'Tax Area Code';
            }

            field("Descricao Area de Imposto"; rec."Descricao Area de Imposto")
            {
                ApplicationArea = all;
                ToolTip = 'Descricao Area de Imposto';
            }

            field("Município Prestação Serviço"; rec."Município Prestação Serviço")
            {
                ApplicationArea = all;
                ToolTip = 'Município Prestação Serviço';
            }
            field("Cidade Prestação Serviço"; Rec."Cidade Prestação Serviço")
            {
                ApplicationArea = all;
                ToolTip = 'Cidade Prestação Serviço';
            }
            field("Município Fornecedor"; rec."Município Fornecedor")
            {
                ApplicationArea = all;
                ToolTip = 'Município Fornecedor';
            }
        }
    }
    actions
    {
        addafter("Item &Tracking Lines")
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
                    CurrPage.SaveRecord();
                    CurrPage.Update();
                end;
            }
        }
    }
}