page 50013 "Integration Purchase"
{
    Caption = 'Integration Purchase Order';
    PageType = List;
    //Editable = false;
    ApplicationArea = All;
    RefreshOnActivate = true;
    SourceTable = "Integration Purchase";
    SourceTableView = where(Status = filter(Imported | Created | "Data Error" | Reviewed | "On Hold" | "Data Excel Error" | "Layout Error" | "Exported" | "Under Analysis"));
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
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
                field("Release to Post"; Rec."Release to Post")
                {
                    ApplicationArea = All;
                    ToolTip = 'Release to Post';
                }
                field(Rejected; rec.Rejected)
                {
                    ApplicationArea = All;
                    ToolTip = 'Rejected';
                }
                field("Reason Code"; rec."Reason Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Reason Code';
                }
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

                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Posting Date';
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
                field("tax % Order IRRF Ret"; rec."tax % Order IRRF Ret")
                {
                    ApplicationArea = All;
                    ToolTip = 'Tax % Order IRRF Ret';
                }

                field("tax % Order CSRF Ret"; rec."tax % Order CSRF Ret")
                {
                    ApplicationArea = All;
                    ToolTip = 'Tax % Order CSRF Ret';
                }

                field("tax % Order INSS Ret"; rec."tax % Order INSS Ret")
                {
                    ApplicationArea = All;
                    ToolTip = 'Tax % Order INSS Ret';
                }
                field("tax % Order ISS Ret"; rec."tax % Order ISS Ret")
                {
                    ApplicationArea = All;
                    ToolTip = 'Tax % Order ISS Ret';
                }
                field("tax % Order DIRF ret"; rec."tax % Order DIRF ret")
                {
                    ApplicationArea = All;
                    ToolTip = 'Tax % Order Dirf Ret';
                }

                field("Local Service Provision"; Rec."Local Service Provision")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Local Service Provision field.';
                }

                field("Municipio Code"; Rec."Municipio Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Municipio Code field.';
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
                field("Purch Post Excel File Name"; rec."Purch Post Excel File Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Purch Post Excel File Name';
                }
                field("Exported Excel Purch. Tax Name"; rec."Exported Excel Purch. Tax Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Exported Excel Purch. Tax Name';
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
                Caption = 'Import Excel Purchase Order';
                Image = CreateDocument;
                ToolTip = 'Import Excel Purchase Order';

                trigger OnAction();
                var
                    ImportExcelBuffer: codeunit "Import Excel Buffer";

                begin
                    ImportExcelBuffer.ImportExcelPurchase();

                    CurrPage.SaveRecord();
                    CurrPage.Update();
                    Message('Import Excel Purchase Order');
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
                    IntPurchase: Record "Integration Purchase";
                begin
                    CurrPage.SetSelectionFilter(IntPurchase);
                    IntPurchase.CopyFilters(Rec);
                    IntegrationPurchase.CreatePurchase(IntPurchase);
                    CurrPage.SaveRecord();
                    CurrPage.Update();
                    Message('Create Purchase Order');
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
                    IntPurchase: Record "Integration Purchase";
                begin
                    CurrPage.SetSelectionFilter(IntPurchase);
                    IntPurchase.CopyFilters(Rec);

                    IntegrationPurchase.PurchRealse(IntPurchase);

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
                    IntPurchase: Record "Integration Purchase";
                begin
                    CurrPage.SetSelectionFilter(IntPurchase);
                    IntPurchase.CopyFilters(Rec);

                    IntegrationPurchase.PurchOpen(IntPurchase);

                    CurrPage.SaveRecord();
                    CurrPage.Update();
                    Message('Purchase Open');
                end;
            }
            action(UnderAnalysis)
            {
                ApplicationArea = All;
                Caption = 'Under Analysis';
                Image = Undo;
                ToolTip = 'Under Analysis';

                trigger OnAction();
                var
                    IntPurchase: Record "Integration Purchase";
                begin
                    CurrPage.SetSelectionFilter(IntPurchase);
                    IntPurchase.CopyFilters(Rec);

                    IntegrationPurchase.UnderAnalysis(IntPurchase);

                    CurrPage.SaveRecord();
                    CurrPage.Update();
                    Message('Under Analysis');
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
                    IntPurchase: Record "Integration Purchase";
                begin
                    CurrPage.SetSelectionFilter(IntPurchase);
                    IntPurchase.CopyFilters(Rec);
                    IntegrationPurchase.PostPurchase(IntPurchase);
                    CurrPage.Update();
                    Message('Post Order');
                end;
            }
            action(ExportTax)
            {
                ApplicationArea = All;
                Caption = 'Export Excel Purchase Tax';
                Image = CreateDocument;
                ToolTip = 'Export Excel Purchase Tax';

                trigger OnAction();
                var
                    ImportExcelBuffer: codeunit "Import Excel Buffer";

                begin
                    ImportExcelBuffer.ExportExcelPurchaseTax();

                    CurrPage.SaveRecord();
                    CurrPage.Update();
                    Message('Export Excel Purchase Tax');
                end;
            }

            action(ImportPosting)
            {
                ApplicationArea = All;
                Caption = 'Import Excel Purchase Posting';
                Image = CreateDocument;
                ToolTip = 'Import Excel Purchase Posting';

                trigger OnAction();
                var
                    ImportExcelBuffer: codeunit "Import Excel Buffer";

                begin
                    ImportExcelBuffer.ImportExcelPurchasePost();

                    CurrPage.SaveRecord();
                    CurrPage.Update();
                    Message('Import Excel Purchase Post');
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
                    if PurchaseHeader.get(PurchaseHeader."Document Type"::Order, rec."document No.") then
                        PAGE.Run(PAGE::"Purchase Order", PurchaseHeader);
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

                    PAGE.Run(PAGE::"Integration Purchase Posted");
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
                    IntAc: Record "Integration Purchase";
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
        IntegrationPurchase: codeunit "Integration Purchase";
}