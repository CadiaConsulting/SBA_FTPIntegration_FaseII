pageextension 50026 INTPurchaseOrderSubForm extends "Purchase Order Subform"
{
    layout
    {
        // Add changes to page layout here
        addbefore("Bin Code")
        {
            field("Status SBA"; rec."Status SBA")
            {
                ApplicationArea = All;
                ToolTip = 'Status SBA';
            }
        }

        modify("CADBR Service Code")
        {
            Visible = true;
            Enabled = not CheckStatus;
        }
        modify(Type)
        {
            Enabled = not CheckStatus;
        }
        modify("No.")
        {
            Enabled = not CheckStatus;
        }
        modify("Item Reference No.")
        {
            Enabled = not CheckStatus;
        }
        modify("IC Partner Code")
        {
            Enabled = not CheckStatus;
        }
        modify("IC Partner Ref. Type")
        {
            Enabled = not CheckStatus;
        }
        modify("IC Partner Reference")
        {
            Enabled = not CheckStatus;
        }
        modify("Variant Code")
        {
            Enabled = not CheckStatus;
        }
        modify(Nonstock)
        {
            Enabled = not CheckStatus;
        }
        modify("Gen. Bus. Posting Group")
        {
            Enabled = not CheckStatus;
        }
        modify("Gen. Prod. Posting Group")
        {
            Enabled = not CheckStatus;
        }
        modify("VAT Bus. Posting Group")
        {
            Enabled = not CheckStatus;
        }
        modify("VAT Prod. Posting Group")
        {
            Enabled = not CheckStatus;
        }
        modify(Description)
        {
            Enabled = not CheckStatus;
        }
        modify("Description 2")
        {
            Visible = false;
        }
        modify("Drop Shipment")
        {
            Enabled = not CheckStatus;
        }
        modify("Return Reason Code")
        {
            Enabled = not CheckStatus;
        }
        modify("Location Code")
        {
            Enabled = not CheckStatus;
        }
        modify("Bin Code")
        {
            Enabled = not CheckStatus;
        }
        modify(Quantity)
        {
            Enabled = not CheckStatus;
        }
        modify("Reserved Quantity")
        {
            Enabled = not CheckStatus;
        }
        modify("Job Remaining Qty.")
        {
            Enabled = not CheckStatus;
        }
        modify("Unit of Measure Code")
        {
            Enabled = not CheckStatus;
        }
        modify("Unit of Measure")
        {
            Enabled = not CheckStatus;
        }
        modify("Direct Unit Cost")
        {
            Enabled = not CheckStatus;
        }
        modify("Indirect Cost %")
        {
            Enabled = not CheckStatus;
        }
        modify("Unit Cost (LCY)")
        {
            Enabled = not CheckStatus;
        }
        modify("Unit Price (LCY)")
        {
            Enabled = not CheckStatus;
        }
        modify("Tax Liable")
        {
            Enabled = not CheckStatus;
        }
        modify("Tax Area Code")
        {
            Enabled = not CheckStatus;
        }
        modify("Tax Group Code")
        {
            Enabled = not CheckStatus;
        }
        modify("Use Tax")
        {
            Enabled = not CheckStatus;
        }
        modify("Line Discount %")
        {
            Enabled = not CheckStatus;
        }
        modify("Line Amount")
        {
            Enabled = not CheckStatus;
        }
        modify("Line Discount Amount")
        {
            Enabled = not CheckStatus;
        }
        modify(NonDeductibleVATBase)
        {
            Enabled = not CheckStatus;
        }
        modify(NonDeductibleVATAmount)
        {
            Enabled = not CheckStatus;
        }
        modify("Prepayment %")
        {
            Enabled = not CheckStatus;
        }
        modify("Prepmt. Line Amount")
        {
            Enabled = not CheckStatus;
        }
        modify("Prepmt. Amt. Inv.")
        {
            Enabled = not CheckStatus;
        }
        modify("Allow Invoice Disc.")
        {
            Enabled = not CheckStatus;
        }
        modify("Inv. Discount Amount")
        {
            Enabled = not CheckStatus;
        }
        modify("Inv. Disc. Amount to Invoice")
        {
            Enabled = not CheckStatus;
        }
        modify("Qty. to Receive")
        {
            Enabled = not CheckStatus;
        }
        modify("Quantity Received")
        {
            Enabled = not CheckStatus;
        }
        modify("Qty. to Invoice")
        {
            Enabled = not CheckStatus;
        }
        modify("Quantity Invoiced")
        {
            Enabled = not CheckStatus;
        }
        modify("Prepmt Amt to Deduct")
        {
            Enabled = not CheckStatus;
        }
        modify("Prepmt Amt Deducted")
        {
            Enabled = not CheckStatus;
        }
        modify("Allow Item Charge Assignment")
        {
            Enabled = not CheckStatus;
        }
        modify("Qty. to Assign")
        {
            Enabled = not CheckStatus;
        }
        modify("Item Charge Qty. to Handle")
        {
            Enabled = not CheckStatus;
        }
        modify("Qty. Assigned")
        {
            Enabled = not CheckStatus;
        }
        modify("Allocation Account No.")
        {
            Enabled = not CheckStatus;
        }
        modify("Job No.")
        {
            Enabled = not CheckStatus;
        }
        modify("Job Task No.")
        {
            Enabled = not CheckStatus;
        }
        modify("Job Planning Line No.")
        {
            Enabled = not CheckStatus;
        }
        modify("Job Line Type")
        {
            Enabled = not CheckStatus;
        }
        modify("Job Unit Price")
        {
            Enabled = not CheckStatus;
        }
        modify("Job Line Amount")
        {
            Enabled = not CheckStatus;
        }
        modify("Job Line Discount Amount")
        {
            Enabled = not CheckStatus;
        }
        modify("Job Line Discount %")
        {
            Enabled = not CheckStatus;
        }
        modify("Job Total Price")
        {
            Enabled = not CheckStatus;
        }
        modify("Job Unit Price (LCY)")
        {
            Enabled = not CheckStatus;
        }
        modify("Job Total Price (LCY)")
        {
            Enabled = not CheckStatus;
        }
        modify("Job Line Amount (LCY)")
        {
            Enabled = not CheckStatus;
        }
        modify("Job Line Disc. Amount (LCY)")
        {
            Enabled = not CheckStatus;
        }
        modify("Requested Receipt Date")
        {
            Enabled = not CheckStatus;
        }
        modify("Promised Receipt Date")
        {
            Enabled = not CheckStatus;
        }
        modify("Planned Receipt Date")
        {
            Enabled = not CheckStatus;
        }
        modify("Expected Receipt Date")
        {
            Enabled = not CheckStatus;
        }
        modify("Order Date")
        {
            Enabled = not CheckStatus;
        }
        modify("Lead Time Calculation")
        {
            Enabled = not CheckStatus;
        }
        modify("Planning Flexibility")
        {
            Enabled = not CheckStatus;
        }
        modify("Prod. Order No.")
        {
            Enabled = not CheckStatus;
        }
        modify("Prod. Order Line No.")
        {
            Enabled = not CheckStatus;
        }
        modify("Operation No.")
        {
            Enabled = not CheckStatus;
        }
        modify("Work Center No.")
        {
            Enabled = not CheckStatus;
        }
        modify(Finished)
        {
            Enabled = not CheckStatus;
        }
        modify("Whse. Outstanding Qty. (Base)")
        {
            Enabled = not CheckStatus;
        }
        modify("Inbound Whse. Handling Time")
        {
            Enabled = not CheckStatus;
        }
        modify("Blanket Order No.")
        {
            Enabled = not CheckStatus;
        }
        modify("Blanket Order Line No.")
        {
            Enabled = not CheckStatus;
        }
        modify("Appl.-to Item Entry")
        {
            Enabled = not CheckStatus;
        }
        modify("Deferral Code")
        {
            Enabled = not CheckStatus;
        }
        modify("Shortcut Dimension 1 Code")
        {
            Enabled = not CheckStatus;
        }
        modify("Shortcut Dimension 2 Code")
        {
            Enabled = not CheckStatus;
        }
        modify(ShortcutDimCode3)
        {
            Enabled = not CheckStatus;
        }
        modify(ShortcutDimCode4)
        {
            Enabled = not CheckStatus;
        }
        modify(ShortcutDimCode5)
        {
            Enabled = not CheckStatus;
        }
        modify(ShortcutDimCode6)
        {
            Enabled = not CheckStatus;
        }
        modify(ShortcutDimCode7)
        {
            Enabled = not CheckStatus;
        }
        modify(ShortcutDimCode8)
        {
            Enabled = not CheckStatus;
        }
        modify("Document No.")
        {
            Enabled = not CheckStatus;
        }
        modify("Line No.")
        {
            Enabled = not CheckStatus;
        }
        modify("Over-Receipt Quantity")
        {
            Enabled = not CheckStatus;
        }
        modify("Over-Receipt Code")
        {
            Enabled = not CheckStatus;
        }
        modify("Gross Weight")
        {
            Enabled = not CheckStatus;
        }
        modify("Net Weight")
        {
            Enabled = not CheckStatus;
        }
        modify("Unit Volume")
        {
            Enabled = not CheckStatus;
        }
        modify("Units per Parcel")
        {
            Enabled = not CheckStatus;
        }
        modify("FA Posting Date")
        {
            Enabled = not CheckStatus;
        }
        modify("Attached to Line No.")
        {
            Enabled = not CheckStatus;
        }
        modify("Attached Lines Count")
        {
            Enabled = not CheckStatus;
        }
        modify(AmountBeforeDiscount)
        {
            Enabled = not CheckStatus;
        }
        modify("Invoice Discount Amount")
        {
            Enabled = not CheckStatus;
        }
        modify("Invoice Disc. Pct.")
        {
            Enabled = not CheckStatus;
        }
        modify("Total Amount Excl. VAT")
        {
            Enabled = not CheckStatus;
        }
        modify("Total VAT Amount")
        {
            Enabled = not CheckStatus;
        }
        modify("Total Amount Incl. VAT")
        {
            Enabled = not CheckStatus;
        }

        modify("CADBR Charge Item No.")
        {
            Visible = false;
        }
        modify("CADBR Description 2")
        {
            Visible = false;
        }
        modify("CADBR CFOP Code")
        {
            Enabled = not CheckStatus;
        }
        modify("CADBR NCM Code")
        {
            Enabled = not CheckStatus;
        }
        modify("CADBR NCM Exception Code")
        {
            Enabled = not CheckStatus;
        }
        modify("CADBR Tax Exception Code")
        {
            Enabled = not CheckStatus;
        }
        modify("CADBR End User")
        {
            Enabled = not CheckStatus;
        }
        modify("CADBR Origin Code")
        {
            Enabled = not CheckStatus;
        }
        modify("CADBR ICMS CST Code")
        {
            Enabled = not CheckStatus;
        }
        modify("CADBR PIS CST Code")
        {
            Enabled = not CheckStatus;
        }
        modify("CADBR COFINS CST Code")
        {
            Enabled = not CheckStatus;
        }
        modify("CADBR IPI CST Code")
        {
            Enabled = not CheckStatus;
        }
        modify("CADBR Base Calculation Credit Code")
        {
            Enabled = not CheckStatus;
        }
        modify("CADBR DI No.")
        {
            Enabled = not CheckStatus;
        }
        modify("CADBR DI Posting Date")
        {
            Enabled = not CheckStatus;
        }
        modify("CADBR Addition Number")
        {
            Enabled = not CheckStatus;
        }
        modify("CADBR Addition Sequential Number")
        {
            Enabled = not CheckStatus;
        }
        modify("CADBR Drawback Act No.")
        {
            Enabled = not CheckStatus;
        }
        modify("CADBR Service Type REINF")
        {
            Enabled = not CheckStatus;
        }
        modify("CADBR Nature of Income")
        {
            Enabled = not CheckStatus;
        }
        modify("CADBR Tax Area Code.")
        {
            Enabled = not CheckStatus;
        }
        modify("CADBR Status")
        {
            Visible = false;
        }
        modify("CADBR Gen. Prod. Posting Group")
        {
            Enabled = not CheckStatus;
        }
        modify("CADBR Net Weight")
        {
            Enabled = not CheckStatus;
        }
        modify("CADBR Gross Weight")
        {
            Enabled = not CheckStatus;
        }

    }

    trigger OnAfterGetRecord()
    var
        PurcHeader: Record "Purchase Header";

    begin
        if PurcHeader.get(Rec."Document Type", rec."Document No.") then
            if PurcHeader.Status = PurcHeader.Status::Open then
                CheckStatus := false

            else
                CheckStatus := true;

    end;

    var
        CheckStatus: Boolean;


}