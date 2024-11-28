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
            field("Posting Message"; rec."Posting Message")
            {
                ApplicationArea = All;
                ToolTip = 'Posting Message';
            }
            field("Vendor Invoice No."; rec."Vendor Invoice No.")
            {
                ApplicationArea = All;
                ToolTip = 'Número da NF';
            }
            field("CADBR Fiscal Document Type"; rec."CADBR Fiscal Document Type")
            {
                ApplicationArea = All;
                ToolTip = 'Tipo Documento Fiscal';
            }
            field("CADBR Print Serie"; rec."CADBR Print Serie")
            {
                ApplicationArea = All;
                ToolTip = 'Série Impressão';
            }
            field("CADBR CFOP Code"; rec."CADBR CFOP Code")
            {
                ApplicationArea = All;
                ToolTip = 'Cod. CFOP';
            }
            field("CADBR Service Delivery City"; rec."CADBR Service Delivery City")
            {
                ApplicationArea = All;
                ToolTip = 'Município Prestação Serviço';
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
                    intPur: Record "Integration Purchase";
                begin
                    CurrPage.SetSelectionFilter(PurchaseHeader);

                    PurchaseHeader.SetRange("Document Type", PurchaseHeader."Document Type"::Order);
                    if not PurchaseHeader.IsEmpty then begin
                        if Confirm('You will delete %1 records, do you want to continue?', false, Format(PurchaseHeader.Count())) then begin
                            if PurchaseHeader.FindSet() then
                                repeat

                                    intPur.Reset();
                                    intPur.SetRange("Document No.", PurchaseHeader."No.");
                                    if not intPur.IsEmpty then
                                        intPur.ModifyAll(Status, intpur.Status::Cancelled);

                                    PurchaseHeader."Posting No." := '';
                                    PurchaseHeader.Modify();
                                    PurchaseHeader.Delete(true);

                                until PurchaseHeader.Next() = 0;

                        end;
                    end;

                end;
            }
        }

        addAfter(Reopen)
        {

            action(UnderAnalysis)
            {
                Caption = 'Under Analysis';
                ApplicationArea = Suite;
                Image = Undo;
                trigger OnAction()
                var
                    IntPurchase: Record "Integration Purchase";
                    IntegrationPurchase: Codeunit "Integration Purchase";
                    PurchaseHead: Record "Purchase Header";
                    Label50020: Label 'Under Analysis';
                begin

                    CurrPage.SetSelectionFilter(PurchaseHead);
                    PurchaseHead.FindSet();
                    repeat
                        IntPurchase.Reset();
                        IntPurchase.SetRange("Document No.", rec."No.");
                        if IntPurchase.FindFirst() then begin
                            IntPurchase.Reset();
                            IntPurchase.SetRange("Document No.", IntPurchase."Document No.");
                            IntPurchase.SetRange("Line No.", IntPurchase."Line No.");
                            IntPurchase.SetRange("Excel File Name", IntPurchase."Excel File Name");
                            if IntPurchase.FindFirst() then
                                IntegrationPurchase.UnderAnalysis(IntPurchase);
                        end;

                    until PurchaseHead.Next() = 0;

                    CurrPage.SaveRecord();
                    CurrPage.Update();
                    Message(Label50020);

                end;
            }

        }
    }
}