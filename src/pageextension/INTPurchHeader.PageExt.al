pageextension 50013 "INTPurchHeader" extends "Purchase Order"
{
    layout
    {
        // Add changes to page layout here
        addbefore(Status)
        {
            field("IRRF Ret"; rec."IRRF Ret")
            {
                ApplicationArea = All;
                ToolTip = 'IRRF Ret';
                Editable = not CheckStatus;
            }

            field("CSRF Ret"; rec."CSRF Ret")
            {
                ApplicationArea = All;
                ToolTip = 'CSRF Ret';
                Editable = not CheckStatus;
            }

            field("INSS Ret"; rec."INSS Ret")
            {
                ApplicationArea = All;
                ToolTip = 'INSS Ret';
                Editable = not CheckStatus;
            }
            field("ISS Ret"; rec."ISS Ret")
            {
                ApplicationArea = All;
                ToolTip = 'ISS Ret';
                Editable = not CheckStatus;
            }

            field("PIS Credit"; rec."PIS Credit")
            {
                ApplicationArea = All;
                ToolTip = 'PIS Credit';
                Editable = not CheckStatus;
            }

            field("Cofins Credit"; rec."Cofins Credit")
            {
                ApplicationArea = All;
                ToolTip = 'Cofins Credit';
                Editable = not CheckStatus;
            }
            field(DIRF; rec.DIRF)
            {
                ApplicationArea = All;
                ToolTip = 'Dirf';
                Editable = not CheckStatus;
            }
            field("PO Total"; rec."PO Total")
            {
                ApplicationArea = All;
                ToolTip = 'PO Total';
                Editable = not CheckStatus;
            }
            field("Posting Message"; rec."Posting Message")
            {
                ApplicationArea = All;
                ToolTip = 'Posting Message';
                Editable = not CheckStatus;
            }
        }

        modify("Area")
        {
            Editable = not CheckStatus;
        }
        modify("Assigned User ID")
        {
            Editable = not CheckStatus;
        }
        modify("Buy-from Address")
        {
            Editable = not CheckStatus;
        }
        modify("Buy-from Address 2")
        {
            Editable = not CheckStatus;
        }
        modify("Buy-from City")
        {
            Editable = not CheckStatus;
        }
        modify("Buy-from Contact")
        {
            Editable = not CheckStatus;
        }
        modify("Buy-from Contact No.")
        {
            Editable = not CheckStatus;
        }
        modify("Buy-from Country/Region Code")
        {
            Editable = not CheckStatus;
        }
        modify("Buy-from County")
        {
            Editable = not CheckStatus;
        }
        modify("Buy-from Post Code")
        {
            Editable = not CheckStatus;
        }
        modify("Buy-from Vendor Name")
        {
            Editable = not CheckStatus;
        }

        modify("Buy-from Vendor No.")
        {
            Editable = not CheckStatus;
        }
        modify("CADBR Access Key")
        {
            Editable = not CheckStatus;
        }
        modify("CADBR Additional Description")
        {
            Editable = not CheckStatus;
        }

        modify("CADBR Automatic NF-e")
        {
            Editable = not CheckStatus;
        }
        modify("CADBR Beneficiary CPFCNPJ")
        {
            Editable = not CheckStatus;
        }

        modify("CADBR Branch Code")
        {
            Editable = not CheckStatus;
        }
        modify("CADBR Buy-from District")
        {
            Editable = not CheckStatus;
        }
        modify("CADBR Buy-from Number")
        {
            Editable = not CheckStatus;
        }
        modify("CADBR Buy-from Territory Code")
        {
            Editable = not CheckStatus;
        }
        modify("CADBR Buyer Presence")
        {
            Editable = not CheckStatus;
        }

        modify("CADBR CFOP Code")
        {
            Editable = not CheckStatus;
        }

        modify("CADBR Complementary Invoice Type")
        {
            Editable = not CheckStatus;
        }
        modify("CADBR DI Invoice No.")
        {
            Editable = not CheckStatus;
        }
        modify("CADBR DI No.")
        {
            Editable = not CheckStatus;
        }
        modify("CADBR DI Posting Date")
        {
            Editable = not CheckStatus;
        }
        modify("CADBR Destination CTRC Post Code")
        {
            Editable = not CheckStatus;
        }
        modify("CADBR Direct Import")
        {
            Editable = not CheckStatus;
        }
        modify("CADBR Disengagement Date")
        {
            Editable = not CheckStatus;
        }
        modify("CADBR Disengagement Location")
        {
            Editable = not CheckStatus;
        }
        modify("CADBR Disengagement Territory Code")
        {
            Editable = not CheckStatus;
        }


        modify("CADBR End User")
        {
            Editable = not CheckStatus;
        }
        modify("CADBR Exporter Code")
        {
            Editable = not CheckStatus;
        }
        modify("CADBR Extemporaneous Doc. Date")
        {
            Editable = not CheckStatus;
        }
        modify("CADBR Fiscal Book Remarks")
        {
            Editable = not CheckStatus;
        }
        modify("CADBR Fiscal Document Type")
        {
            Editable = not CheckStatus;
        }

        modify("CADBR Foreign Manufacturer Code")
        {
            Editable = not CheckStatus;
        }
        modify("CADBR Freight Billed To")
        {
            Editable = not CheckStatus;
        }
        modify("CADBR Gross Weight")
        {
            Editable = not CheckStatus;
        }

        modify("CADBR Ind Intermediary/MarketPlace")
        {
            Editable = not CheckStatus;
        }
        modify("CADBR Intermediate Type")
        {
            Editable = not CheckStatus;
        }

        modify("CADBR Invoice to Complement")
        {
            Editable = not CheckStatus;
        }
        modify("CADBR Invoicing Type")
        {
            Editable = not CheckStatus;
        }
        modify("CADBR License Plate")
        {
            Editable = not CheckStatus;
        }

        modify("CADBR Marks")
        {
            Editable = not CheckStatus;
        }

        modify("CADBR NFe Environment")
        {
            Editable = not CheckStatus;
        }

        modify("CADBR NFe Process No.")
        {
            Editable = not CheckStatus;
        }
        modify("CADBR NFe Protocol")
        {
            Editable = not CheckStatus;
        }

        modify("CADBR NFe Result")
        {
            Editable = not CheckStatus;
        }

        modify("CADBR NFe Shipment Date")
        {
            Editable = not CheckStatus;
        }
        modify("CADBR NFe Status")
        {
            Editable = not CheckStatus;
        }
        modify("CADBR Net Weight")
        {
            Editable = not CheckStatus;
        }
        modify("CADBR Operation Nature")
        {
            Editable = not CheckStatus;
        }
        modify("CADBR Operation Type")
        {
            Editable = not CheckStatus;
        }

        modify("CADBR Other Vendor No.")
        {
            Editable = not CheckStatus;
        }
        modify("CADBR Pay-to District")
        {
            Editable = not CheckStatus;
        }
        modify("CADBR Pay-to Number")
        {
            Editable = not CheckStatus;
        }
        modify("CADBR Print Serie")
        {
            Editable = not CheckStatus;
        }
        modify("CADBR Print Sub Serie")
        {
            Editable = not CheckStatus;
        }
        modify("CADBR RPA")
        {
            Editable = not CheckStatus;
        }
        modify("CADBR Release Date")
        {
            Editable = not CheckStatus;
        }

        modify("CADBR Service Delivery City")
        {
            Editable = not CheckStatus;
        }
        modify("CADBR Ship-to Number")
        {
            Editable = not CheckStatus;
        }
        modify("CADBR Ship-to Territory Code")
        {
            Editable = not CheckStatus;
        }
        modify("CADBR Shipping Agent Code")
        {
            Editable = not CheckStatus;
        }
        modify("CADBR Source CTRC Post Code")
        {
            Editable = not CheckStatus;
        }
        modify("CADBR Species")
        {
            Editable = not CheckStatus;
        }
        modify("CADBR Taxes Matrix Code")
        {
            Editable = not CheckStatus;
        }
        modify("CADBR Transaction Intermediator")
        {
            Editable = not CheckStatus;
        }
        modify("CADBR Transport Number")
        {
            Editable = not CheckStatus;
        }
        modify("CADBR Transported Quantity")
        {
            Editable = not CheckStatus;
        }
        modify("CADBR UF Vehicle")
        {
            Editable = not CheckStatus;
        }
        modify("Compress Prepayment")
        {
            Editable = not CheckStatus;
        }
        modify("Creditor No.")
        {
            Editable = not CheckStatus;
        }
        modify("Currency Code")
        {
            Editable = not CheckStatus;
        }
        modify("Document Date")
        {
            Editable = not CheckStatus;
        }

        modify("Due Date")
        {
            Editable = not CheckStatus;
        }
        modify("Entry Point")
        {
            Editable = not CheckStatus;
        }
        modify("Expected Receipt Date")
        {
            Editable = not CheckStatus;
        }
        modify("Format Region")
        {
            Editable = not CheckStatus;
        }
        modify("Inbound Whse. Handling Time")
        {
            Editable = not CheckStatus;
        }

        modify("Invoice Received Date")
        {
            Editable = not CheckStatus;
        }
        modify("Job Queue Status")
        {
            Editable = not CheckStatus;
        }
        modify("Journal Templ. Name")
        {
            Editable = not CheckStatus;
        }
        modify("Language Code")
        {
            Editable = not CheckStatus;
        }
        modify("Lead Time Calculation")
        {
            Editable = not CheckStatus;
        }
        modify("Location Code")
        {
            Editable = not CheckStatus;
        }
        modify("No.")
        {
            Editable = not CheckStatus;
        }
        modify("No. of Archived Versions")
        {
            Editable = not CheckStatus;
        }
        modify("On Hold")
        {
            Editable = not CheckStatus;
        }
        modify("Order Address Code")
        {
            Editable = not CheckStatus;
        }
        modify("Order Date")
        {
            Editable = not CheckStatus;
        }
        modify("Pay-to Address")
        {
            Editable = not CheckStatus;
        }
        modify("Pay-to Address 2")
        {
            Editable = not CheckStatus;
        }
        modify("Pay-to City")
        {
            Editable = not CheckStatus;
        }
        modify("Pay-to Contact")
        {
            Editable = not CheckStatus;
        }
        modify("Pay-to Contact No.")
        {
            Editable = not CheckStatus;
        }
        modify("Pay-to Country/Region Code")
        {
            Editable = not CheckStatus;
        }
        modify("Pay-to County")
        {
            Editable = not CheckStatus;
        }
        modify("Pay-to Name")
        {
            Editable = not CheckStatus;
        }
        modify("Pay-to Post Code")
        {
            Editable = not CheckStatus;
        }
        modify("Payment Discount %")
        {
            Editable = not CheckStatus;
        }
        modify("Payment Method Code")
        {
            Editable = not CheckStatus;
        }
        modify("Payment Reference")
        {
            Editable = not CheckStatus;
        }
        modify("Payment Terms Code")
        {
            Editable = not CheckStatus;
        }
        modify("Pmt. Discount Date")
        {
            Editable = not CheckStatus;
        }
        modify("Posting Date")
        {
            Editable = not CheckStatus;
        }
        modify("Posting Description")
        {
            Editable = not CheckStatus;
        }
        modify("Prepayment %")
        {
            Editable = not CheckStatus;
        }
        modify("Prepayment Due Date")
        {
            Editable = not CheckStatus;
        }
        modify("Prepmt. Payment Discount %")
        {
            Editable = not CheckStatus;
        }
        modify("Prepmt. Payment Terms Code")
        {
            Editable = not CheckStatus;
        }
        modify("Prepmt. Pmt. Discount Date")
        {
            Editable = not CheckStatus;
        }
        modify("Prices Including VAT")
        {
            Editable = not CheckStatus;
        }
        modify("Promised Receipt Date")
        {
            Editable = not CheckStatus;
        }
        modify("Purchaser Code")
        {
            Editable = not CheckStatus;
        }
        modify("Quote No.")
        {
            Editable = not CheckStatus;
        }
        modify("Remit-to Code")
        {
            Editable = not CheckStatus;
        }
        modify("Requested Receipt Date")
        {
            Editable = not CheckStatus;
        }
        modify("Responsibility Center")
        {
            Editable = not CheckStatus;
        }
        modify("Sell-to Customer No.")
        {
            Editable = not CheckStatus;
        }
        modify("Ship-to Address")
        {
            Editable = not CheckStatus;
        }
        modify("Ship-to Address 2")
        {
            Editable = not CheckStatus;
        }
        modify("Ship-to City")
        {
            Editable = not CheckStatus;
        }
        modify("Ship-to Code")
        {
            Editable = not CheckStatus;
        }
        modify("Ship-to Contact")
        {
            Editable = not CheckStatus;
        }
        modify("Ship-to Country/Region Code")
        {
            Editable = not CheckStatus;
        }
        modify("Ship-to County")
        {
            Editable = not CheckStatus;
        }
        modify("Ship-to Name")
        {
            Editable = not CheckStatus;
        }
        modify("Ship-to Post Code")
        {
            Editable = not CheckStatus;
        }
        modify("Shipment Method Code")
        {
            Editable = not CheckStatus;
        }
        modify("Shortcut Dimension 1 Code")
        {
            Editable = not CheckStatus;
        }
        modify("Shortcut Dimension 2 Code")
        {
            Editable = not CheckStatus;
        }
        modify(Status)
        {
            Editable = not CheckStatus;
        }
        modify("Tax Area Code")
        {
            Editable = not CheckStatus;

        }
        modify("Tax Liable")
        {
            Editable = not CheckStatus;
        }
        modify("Transaction Specification")
        {
            Editable = not CheckStatus;
        }
        modify("Transaction Type")
        {
            Editable = not CheckStatus;
        }
        modify("Transport Method")
        {
            Editable = not CheckStatus;
        }
        modify("VAT Bus. Posting Group")
        {
            Editable = not CheckStatus;
        }
        modify("VAT Reporting Date")
        {
            Editable = not CheckStatus;
        }
        modify("Vendor Cr. Memo No.")
        {
            Editable = not CheckStatus;
        }
        modify("Vendor Invoice No.")
        {
            Editable = not CheckStatus;
        }
        modify("Vendor Order No.")
        {
            Editable = not CheckStatus;
        }
        modify("Vendor Posting Group")
        {
            Editable = not CheckStatus;
        }
        modify("Vendor Shipment No.")
        {
            Editable = not CheckStatus;
        }
        modify("Your Reference")
        {
            Editable = not CheckStatus;
        }
        modify("CADBR Tax Area Code.")
        {
            Editable = not CheckStatus;
        }
        modify(ShippingOptionWithLocation)
        {
            Editable = not CheckStatus;
        }
        modify(PayToOptions)
        {
            Editable = not CheckStatus;
        }



    }

    actions
    {
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
                    Label50020: Label 'Under Analysis';
                begin
                    IntPurchase.Reset();
                    IntPurchase.SetRange("Document No.", rec."No.");
                    IntegrationPurchase.UnderAnalysis(IntPurchase);

                    CurrPage.SaveRecord();
                    CurrPage.Update();
                    Message(Label50020);

                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin

        if rec.Status = rec.Status::Open then
            CheckStatus := false
        else
            CheckStatus := true;

    end;

    var
        CheckStatus: Boolean;

}