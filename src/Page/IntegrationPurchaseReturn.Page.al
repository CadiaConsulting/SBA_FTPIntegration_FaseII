page 50016 "Integration Purchase Return"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Integration Purchase Return";
    Caption = 'Integration Purchase Credit Memo';

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Document No."; rec."Document No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Document No.';
                }

                field("Order Date"; rec."Order Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Order Date';
                }

                field("Additional Description"; rec."Additional Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Additional Description';
                }

                field("Doc. URL"; rec."Doc. URL")
                {
                    ApplicationArea = All;
                    ToolTip = 'Doc. URL';
                }

                field("Line No."; rec."Line No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Line No.';
                }
                field("Buy-from Vendor No."; rec."Buy-from Vendor No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Buy-from Vendor No.';
                }

                field(Type; rec."Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Type';
                }
                field("Item No."; rec."Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Item No.';
                }
                field(Description; rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Description';
                }
                field(Quantity; rec.Quantity)
                {
                    ApplicationArea = All;
                    ToolTip = 'Quantity';
                }
                field("Direct Unit Cost Excl. Vat"; rec."Direct Unit Cost Excl. Vat")
                {
                    ApplicationArea = All;
                    ToolTip = 'Direct Unit Cost Excl. Vat';
                }

                field("Shortcut Dimension 1 Code"; rec."Shortcut Dimension 1 Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Shortcut Dimension 1 Code';
                }
                field("Shortcut Dimension 2 Code"; rec."Shortcut Dimension 2 Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Shortcut Dimension 2 Code';
                }
                field("Shortcut Dimension 3 Code"; rec."Shortcut Dimension 3 Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Shortcut Dimension 3 Code';
                }
                field("Shortcut Dimension 4 Code"; rec."Shortcut Dimension 4 Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Shortcut Dimension 4 Code';
                }
                field("Shortcut Dimension 5 Code"; rec."Shortcut Dimension 5 Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Shortcut Dimension 5 Code';
                }
                field("Shortcut Dimension 6 Code"; rec."Shortcut Dimension 6 Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Shortcut Dimension 6 Code';
                }

                field("Vendor Invoice No."; rec."Vendor Invoice No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Vendor Invoice No.';
                }
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

                field("Order IRRF Ret"; rec."Order IRRF Ret")
                {
                    ApplicationArea = All;
                    ToolTip = 'Order IRRF Ret';
                }

                field("Order CSRF Ret"; rec."Order CSRF Ret")
                {
                    ApplicationArea = All;
                    ToolTip = 'Order CSRF Ret';
                }

                field("Order INSS Ret"; rec."Order INSS Ret")
                {
                    ApplicationArea = All;
                    ToolTip = 'Order INSS Ret';
                }
                field("Order ISS Ret"; rec."Order ISS Ret")
                {
                    ApplicationArea = All;
                    ToolTip = 'Order ISS Ret';
                }

                field("Order PIS Credit"; rec."Order PIS Credit")
                {
                    ApplicationArea = All;
                    ToolTip = 'Order PIS Credit';
                }

                field("Order Cofins Credit"; rec."Order Cofins Credit")
                {
                    ApplicationArea = All;
                    ToolTip = 'Order Cofins Credit';
                }
                field("Order DIRF ret"; rec."Order DIRF ret")
                {
                    ApplicationArea = All;
                    ToolTip = 'Order Dirf Ret';
                }

                field(Status; rec.Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Status';
                }
                field("Posting Message"; rec."Posting Message")
                {
                    ApplicationArea = All;
                    ToolTip = 'Posting Message';
                }
                field("Error Order"; rec."Error Order")
                {
                    ApplicationArea = All;
                    ToolTip = 'Error Order';
                }

                field("Errors Import Excel"; rec."Errors Import Excel")
                {
                    ApplicationArea = All;
                    ToolTip = 'Error Import Excel';
                }
                field("Excel File Name"; rec."Excel File Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Excel File Name';
                }
            }
        }
        area(Factboxes)
        {

        }
    }

    actions
    {
        area(Processing)
        {
            action(ImportExcel)
            {
                ApplicationArea = All;
                Caption = 'Import Excel Purchase Credit Memo';
                Image = CreateDocument;
                ToolTip = 'Import Excel Purchase Return Order';

                trigger OnAction();
                var
                    ImportExcelBuffer: codeunit "Import Excel Buffer";

                begin
                    ImportExcelBuffer.ImportExcelPurchaseReturn();

                    CurrPage.SaveRecord();
                    CurrPage.Update();
                    Message('Import Excel Purchase Credit Memo');
                end;
            }
            action(CreateReturnOrder)
            {
                ApplicationArea = All;
                Caption = 'Create Purchase Credit Memo';
                Image = CreateDocument;
                ToolTip = 'Create Return Purchase Order';

                trigger OnAction();
                var
                    IntPurchRet: Record "Integration Purchase Return";
                begin
                    CurrPage.SetSelectionFilter(IntPurchRet);
                    IntPurchRet.CopyFilters(Rec);
                    IntegrationPurchaseReturn.CreatePurchaseReturn(IntPurchRet);
                    CurrPage.SaveRecord();
                    CurrPage.Update();
                    Message('Create Purchase Credit Memo');
                end;
            }
            action(PostOrder)
            {
                ApplicationArea = All;
                Caption = 'Post Credit Memo';
                Image = PostDocument;
                ToolTip = 'Post Return Order';

                trigger OnAction();
                var
                    IntPurchRet: Record "Integration Purchase Return";
                begin
                    CurrPage.SetSelectionFilter(IntPurchRet);
                    IntPurchRet.CopyFilters(Rec);
                    IntegrationPurchaseReturn.PostPurchaseReturn(IntPurchRet);
                    CurrPage.Update();
                    Message('Post Credit Memo');
                end;
            }
            action(PurchaseOrder)
            {
                ApplicationArea = All;
                Caption = 'Purchase Credit Memo Card';
                Image = Document;
                ToolTip = 'Purchase Return Order Card';

                trigger OnAction();
                var
                    PurchaseHeader: Record "Purchase Header";
                begin
                    if PurchaseHeader.get(PurchaseHeader."Document Type"::"Return Order", rec."document No.") then
                        PAGE.Run(PAGE::"Purchase Return Order", PurchaseHeader);
                end;
            }
            action(Vendor)
            {
                ApplicationArea = All;
                Caption = 'Vendor Card';
                Image = Vendor;
                ToolTip = 'Vendor Card';

                trigger OnAction();
                var
                    Vendor: Record Vendor;
                begin
                    Vendor."No." := rec."Buy-from Vendor No.";
                    PAGE.Run(PAGE::"Vendor Card", Vendor);
                end;
            }
            action(Iten)
            {
                ApplicationArea = All;
                Caption = 'Item Card';
                Image = Item;
                ToolTip = 'Item Card';

                trigger OnAction();
                var
                    Item: Record Item;
                begin
                    Item."No." := rec."Item No.";
                    PAGE.Run(PAGE::"Item Card", Item);
                end;
            }


        }
    }
    var
        IntegrationPurchaseReturn: codeunit "Integration Purchase Return";

}