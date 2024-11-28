
page 50082 "IntPurchVoidPaymentPosted"
{
    ApplicationArea = All;
    Caption = 'Integration Purchase Void Payment Posted';
    PageType = List;
    SourceTable = IntPurchVoidPayment;
    SourceTableView = where(Status = filter(Posted | Cancelled));
    UsageCategory = Lists;
    Editable = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {

                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Status  field.';
                }

                field("Journal Template Name"; Rec."Journal Template Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Journal Template Name field.';
                }
                field("Journal Batch Name"; Rec."Journal Batch Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Journal Batch Name field.';
                }
                field("Line No."; Rec."Line No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Line No. field.';
                }
                field("Journal Line No."; Rec."Journal Line No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Journal Line No. field.';
                }
                field("Account Type"; Rec."Account Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Account Type field.';
                }
                field("Account No."; Rec."Account No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Account No. field.';
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Posting Date field.';
                }
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Document Type field.';
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Document No. field.';
                }
                field("Applies-to Doc. No."; Rec."Applies-to Doc. No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Applies-to Doc. No. field.';
                }
                field("Payment Date"; Rec."Payment Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Posting Date field.';
                }
                field("Purchase Document No"; Rec."Purchase Document No")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Purchase Document No field.';
                }
                field("Tax Paid"; Rec."Tax Paid")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Tax Paid field.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field.';
                }
                field("Bal. Account Type"; Rec."Bal. Account Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Bal. Account Type field.';
                }
                field("Bal. Account No."; Rec."Bal. Account No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field.';
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Amount field.';
                }
                field("Tax Amount"; Rec."Tax Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Tax Amount field.';
                }
                field("Tax Account No."; Rec."Tax Account No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Tax Account No. field.';
                }
                field("Dimension 1"; Rec."Dimension 1")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Shortcut Dimension 1 Code field.';
                }
                field("Dimension 2"; Rec."Dimension 2")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Shortcut Dimension 2 Code field.';
                }
                field("Dimension 3"; Rec."Dimension 3")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Shortcut Dimension 3 Code field.';
                }
                field("Dimension 4"; Rec."Dimension 4")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Shortcut Dimension 4 Code field.';
                }
                field("Dimension 5"; Rec."Dimension 5")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Shortcut Dimension 5 Code field.';
                }
                field("Dimension 6"; Rec."Dimension 6")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Shortcut Dimension 6 Code field.';
                }
                field("Dimension 7"; Rec."Dimension 7")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Shortcut Dimension 7 Code field.';
                }
                field("Dimension 8"; Rec."Dimension 8")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Shortcut Dimension 8 Code field.';
                }
                field("Applies-to Doc. Type"; Rec."Applies-to Doc. Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Applies-to Doc. Type field.';
                }
                field("Posting Message"; Rec."Posting Message")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Posting Message field.';
                }
                field("Excel File Name"; Rec."Excel File Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Excel File Name field.';
                }
                field("Old Detail Transaction No."; Rec."Old Detail Transaction No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Old Detail Transaction No. field.';
                }
                field("Vendor Ledger Entry No."; Rec."Vendor Ledger Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Vendor Ledger Entry No. field.';
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {

            action(Bank)
            {
                ApplicationArea = All;
                Caption = 'Bank Card';
                Image = BankAccount;
                ToolTip = 'Bank Card';

                trigger OnAction();
                var
                    Bank: Record "Bank Account";
                begin
                    if rec."Bal. Account Type" = rec."Bal. Account Type"::"Bank Account" then begin
                        Bank."No." := rec."Bal. Account No.";
                        PAGE.Run(PAGE::"Bank Account Card", Bank);
                    end;
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
                    if Rec."Account No." <> '' then begin
                        Vendor."No." := Rec."Account No.";
                        PAGE.Run(PAGE::"Vendor Card", Vendor);
                    end;
                end;
            }
            action(VendorLedgerEntry)
            {
                ApplicationArea = All;
                Caption = 'Vendor Ledger Entry';
                Image = VendorLedger;
                ToolTip = 'Vendor Ledger Entry';

                trigger OnAction()
                var
                    VendorLedgerEntry: Record "Vendor Ledger Entry";
                begin
                    if Rec."Account No." <> '' then begin
                        VendorLedgerEntry.SetRange("Vendor No.", Rec."Account No.");
                        if not VendorLedgerEntry.IsEmpty then begin
                            PAGE.Run(PAGE::"Vendor Ledger Entries", VendorLedgerEntry);
                        end;
                    end;
                end;
            }
            action(GeneralJournal)
            {
                ApplicationArea = All;
                Caption = 'General Journal';
                Image = GeneralLedger;
                ToolTip = 'General Journal';

                trigger OnAction();
                var
                    GenJournalLine: Record "Gen. Journal Line";
                begin
                    GenJournalLine."Journal Template Name" := rec."Journal Template Name";
                    GenJournalLine."Journal Batch Name" := rec."Journal Batch Name";
                    PAGE.Run(PAGE::"General Journal", GenJournalLine);
                end;
            }
            action(DetailVendor)
            {
                ApplicationArea = All;
                Caption = 'Detail Vendor Ledger';
                Image = VendorLedger;
                ToolTip = 'Detail Vendor Ledger';

                trigger OnAction();
                var
                    TransVoid: Record IntPurchVoidPayTrans;
                begin
                    TransVoid.Reset();
                    TransVoid.SetRange("Journal Template Name", rec."Journal Template Name");
                    TransVoid.SetRange("Journal Batch Name", rec."Journal Batch Name");
                    TransVoid.SetRange("Line No.", rec."Line No.");
                    TransVoid.SetRange("Excel File Name", rec."Excel File Name");
                    if TransVoid.FindSet() then
                        PAGE.Run(PAGE::IntPurchVoidPayTrans, TransVoid);

                end;
            }

        }
    }
    var
        IntPurchVoidPayment: Codeunit IntPurchVoidPayment;
        ImportMessageLbl: Label 'The Excel file was imported';
        PostJornalLbl: Label 'The jornal was posted';
        CopyToJournalLbl: Label 'Lines were Copied to Journal';
        Unapply: Label 'Unapply';
}
