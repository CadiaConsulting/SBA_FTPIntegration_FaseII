page 50014 "Integration Purchase Posted"
{
    Caption = 'Integration Purchase Order Posted';
    PageType = List;
    Editable = false;
    ApplicationArea = All;
    RefreshOnActivate = true;
    SourceTable = "Integration Purchase";
    SourceTableView = where(Status = filter(Posted));
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Status';
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Document No.';
                }

                field("Order Date"; Rec."Order Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Order Date';
                }

                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Posting Date';
                }

                field("Additional Description"; Rec."Additional Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Additional Description';
                }

                field("Doc. URL"; Rec."Doc. URL")
                {
                    ApplicationArea = All;
                    ToolTip = 'Doc. URL';
                }

                field("Line No."; Rec."Line No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Line No.';
                }
                field("Buy-from Vendor No."; Rec."Buy-from Vendor No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Buy-from Vendor No.';
                }

                field(Type; Rec."Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Type';
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Item No.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Description';
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                    ToolTip = 'Quantity';
                }
                field("Direct Unit Cost Excl. Vat"; Rec."Direct Unit Cost Excl. Vat")
                {
                    ApplicationArea = All;
                    ToolTip = 'Direct Unit Cost Excl. Vat';
                }
                field("Tax Area Code"; Rec."Tax Area Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Tax Area Code';
                }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Shortcut Dimension 1 Code';
                }
                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Shortcut Dimension 2 Code';
                }
                field("Shortcut Dimension 3 Code"; Rec."Shortcut Dimension 3 Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Shortcut Dimension 3 Code';
                }
                field("Shortcut Dimension 4 Code"; Rec."Shortcut Dimension 4 Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Shortcut Dimension 4 Code';
                }
                field("Shortcut Dimension 5 Code"; Rec."Shortcut Dimension 5 Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Shortcut Dimension 5 Code';
                }
                field("Shortcut Dimension 6 Code"; Rec."Shortcut Dimension 6 Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Shortcut Dimension 6 Code';
                }

                field("Vendor Invoice No."; Rec."Vendor Invoice No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Vendor Invoice No.';
                }
                field("IRRF Ret"; Rec."IRRF Ret")
                {
                    ApplicationArea = All;
                    ToolTip = 'IRRF Ret';
                }

                field("CSRF Ret"; Rec."CSRF Ret")
                {
                    ApplicationArea = All;
                    ToolTip = 'CSRF Ret';
                }

                field("INSS Ret"; Rec."INSS Ret")
                {
                    ApplicationArea = All;
                    ToolTip = 'INSS Ret';
                }
                field("ISS Ret"; Rec."ISS Ret")
                {
                    ApplicationArea = All;
                    ToolTip = 'ISS Ret';
                }

                field("PIS Credit"; Rec."PIS Credit")
                {
                    ApplicationArea = All;
                    ToolTip = 'PIS Credit';
                }

                field("Cofins Credit"; Rec."Cofins Credit")
                {
                    ApplicationArea = All;
                    ToolTip = 'Cofins Credit';
                }
                field(DIRF; Rec.DIRF)
                {
                    ApplicationArea = All;
                    ToolTip = 'Dirf';
                }
                field("PO Total"; Rec."PO Total")
                {
                    ApplicationArea = All;
                    ToolTip = 'PO Total';
                }
                field("Order IRRF Ret"; Rec."Order IRRF Ret")
                {
                    ApplicationArea = All;
                    ToolTip = 'Order IRRF Ret';
                }

                field("Order CSRF Ret"; Rec."Order CSRF Ret")
                {
                    ApplicationArea = All;
                    ToolTip = 'Order CSRF Ret';
                }

                field("Order INSS Ret"; Rec."Order INSS Ret")
                {
                    ApplicationArea = All;
                    ToolTip = 'Order INSS Ret';
                }
                field("Order ISS Ret"; Rec."Order ISS Ret")
                {
                    ApplicationArea = All;
                    ToolTip = 'Order ISS Ret';
                }

                field("Order PIS Credit"; Rec."Order PIS Credit")
                {
                    ApplicationArea = All;
                    ToolTip = 'Order PIS Credit';
                }

                field("Order Cofins Credit"; Rec."Order Cofins Credit")
                {
                    ApplicationArea = All;
                    ToolTip = 'Order Cofins Credit';
                }
                field("Order DIRF ret"; Rec."Order DIRF ret")
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

                field(Rejected; Rec.Rejected)
                {
                    ApplicationArea = All;
                    ToolTip = 'Rejected';
                }
                field("Posting Message"; Rec."Posting Message")
                {
                    ApplicationArea = All;
                    ToolTip = 'Posting Message';
                }
                field("Error Order"; Rec."Error Order")
                {
                    ApplicationArea = All;
                    ToolTip = 'Error Order';
                }

                field("Errors Import Excel"; Rec."Errors Import Excel")
                {
                    ApplicationArea = All;
                    ToolTip = 'Error Import Excel';
                }
                field("Excel File Name"; Rec."Excel File Name")
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
                    if PurchaseHeader.get(PurchaseHeader."Document Type"::Order, Rec."document No.") then
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
                    Vendor."No." := Rec."Buy-from Vendor No.";
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
                    Item."No." := Rec."Item No.";
                    PAGE.Run(PAGE::"Item Card", Item);
                end;
            }


        }
    }
    var
        IntegrationPurchase: codeunit "Integration Purchase";

}