page 50015 "Integration Landlord"
{
    Caption = 'Integration Landlord';
    PageType = List;
    ApplicationArea = All;
    RefreshOnActivate = true;
    SourceTable = "Integration Landlord";
    SourceTableView = where(Status = filter(<> Posted));
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Entry No."; rec."Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Entry No.';
                    Editable = false;
                }
                field(Status; rec.Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Status';
                }
                field("Status PO"; rec."Status PO")
                {
                    ApplicationArea = All;
                    ToolTip = 'Status PO';
                }

                field("Document No."; rec."Document No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Document No.';
                }

                field("document Date"; rec."Document Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Document Date';
                }

                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Posting Date';
                }
                field("Paid Date"; Rec."Paid Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Paid Date';
                }
                field("Buy-from Vendor No."; rec."Buy-from Vendor No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Buy-from Vendor No.';
                }
                field("Number Vendor No."; rec."Number Vendor No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Number Vendor No.';
                }

                field(Amount; rec.Amount)
                {
                    ApplicationArea = All;
                    ToolTip = 'Amount';
                }
                field("IRRF Ret"; rec."IRRF Ret")
                {
                    ApplicationArea = All;
                    ToolTip = 'IRRF Ret';
                }
                field("Line No."; rec."Line No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Line No.';
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
                field("Gen. Prod. Posting Group"; Rec."Gen. Prod. Posting Group")
                {
                    ToolTip = 'Specifies the value of the Gen. Prod. Posting Group field.';
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
                field("Tax Area Code"; rec."Tax Area Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Tax Area Code';
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
                field("Not Dif. Impostos"; rec."Not Dif. Impostos")
                {
                    ApplicationArea = All;
                    ToolTip = 'Not Dif. Impostos';
                }

                field("Post Code"; Rec."Post Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Post Code';
                }

                field("Fiscal Document Type"; Rec."Fiscal Document Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Fiscal Document Type';
                }
                field("Service Code"; Rec."Service Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Service Code';
                }
                field("Entity Category"; Rec."Entity Category")
                {
                    ApplicationArea = All;
                    ToolTip = 'Entity Category';
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
                Caption = 'Import Excel Landlord';
                Image = CreateDocument;
                ToolTip = 'Import Excel Landlord';

                trigger OnAction();
                var
                    ImportExcelBuffer: codeunit "Import Excel Buffer";

                begin
                    ImportExcelBuffer.ImportExcelLandlord();

                    CurrPage.SaveRecord();
                    CurrPage.Update();
                    Message('Import Excel Landlord');
                end;
            }
            action(CreateOrder)
            {
                ApplicationArea = All;
                Caption = 'Create Purchase Order';
                Image = CreateDocument;
                ToolTip = 'Create Purchase Order';

                trigger OnAction();
                var
                    IntLandlord: Record "Integration Landlord";
                begin
                    CurrPage.SetSelectionFilter(IntLandlord);
                    IntLandlord.CopyFilters(Rec);
                    IntegrationLandlord.CreatePurchase(IntLandlord);
                    CurrPage.SaveRecord();
                    CurrPage.Update();
                    Message('Create Purchase Order Landlord');
                end;
            }
            action(CheckTaxes)
            {
                ApplicationArea = All;
                Caption = 'Check Taxes';
                Image = CreateDocument;
                ToolTip = 'Check Taxes';

                trigger OnAction();
                var
                    IntPurchase: Record "Integration Landlord";
                begin
                    CurrPage.SetSelectionFilter(IntPurchase);
                    IntPurchase.CopyFilters(Rec);

                    IntegrationLandlord.CheckTaxes(IntPurchase);

                    CurrPage.SaveRecord();
                    CurrPage.Update();
                    Message('Checked Taxes');
                end;
            }
            action(ReleaseOrder)
            {
                ApplicationArea = All;
                Caption = 'Release Order';
                Image = ReleaseDoc;
                ToolTip = 'Release Order';

                trigger OnAction();
                var
                    IntPurchase: Record "Integration Landlord";
                begin
                    CurrPage.SetSelectionFilter(IntPurchase);
                    IntPurchase.CopyFilters(Rec);

                    IntegrationLandlord.PurchRealse(IntPurchase);

                    CurrPage.SaveRecord();
                    CurrPage.Update();
                    Message('Release Order');
                end;
            }
            action(OpenOrder)
            {
                ApplicationArea = All;
                Caption = 'Open Order';
                Image = ReOpen;
                ToolTip = 'Open Order';

                trigger OnAction();
                var
                    IntPurchase: Record "Integration Landlord";
                begin
                    CurrPage.SetSelectionFilter(IntPurchase);
                    IntPurchase.CopyFilters(Rec);

                    IntegrationLandlord.PurchOpen(IntPurchase);

                    CurrPage.SaveRecord();
                    CurrPage.Update();
                    Message('Purchase Open');
                end;
            }
            action(PostOrder)
            {
                ApplicationArea = All;
                Caption = 'Post Order';
                Image = PostDocument;
                ToolTip = 'Post Order';

                trigger OnAction();
                var
                    IntPurchase: Record "Integration Landlord";
                begin
                    CurrPage.SetSelectionFilter(IntPurchase);
                    IntPurchase.CopyFilters(Rec);
                    IntegrationLandlord.PostPurchase(IntPurchase);
                    CurrPage.Update();
                    Message('Post Order');
                end;
            }

            action(PurchaseOrder)
            {
                ApplicationArea = All;
                Caption = 'Purchase Order Card';
                Image = Document;
                ToolTip = 'Purchase Order Card';

                trigger OnAction();
                var
                    PurchaseHeader: Record "Purchase Header";
                begin
                    if PurchaseHeader.get(PurchaseHeader."Document Type"::Invoice, rec."document No.") then
                        PAGE.Run(PAGE::"Purchase Invoice", PurchaseHeader);
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
            action(IntegrationPosted)
            {
                ApplicationArea = All;
                Caption = 'Integration Posted';
                Image = PostedOrder;
                ToolTip = 'Integration Posted';

                trigger OnAction();
                var

                begin

                    PAGE.Run(PAGE::"Integration Landlord Posted");
                end;
            }

            action(DeleteEntries)
            {
                ApplicationArea = All;
                Caption = 'Delete Entries';
                Image = PostDocument;
                ToolTip = 'Delete Entries';

                trigger OnAction();
                var
                    IntAc: Record "Integration Landlord";
                begin
                    CurrPage.SetSelectionFilter(IntAc);
                    IntAc.CopyFilters(Rec);
                    IntAc.DeleteAll();
                    CurrPage.Update();

                end;
            }
        }
    }
    var
        IntegrationLandlord: codeunit "Integration Landlord";
}