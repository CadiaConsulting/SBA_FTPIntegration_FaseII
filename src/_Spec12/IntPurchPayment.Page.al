/// <summary>
/// Page "IntegrationPurchasePayment" (ID 50070).
/// NGS
/// </summary>
page 50070 "IntPurchPayment"
{
    ApplicationArea = All;
    Caption = 'Integration Purchase Payment';
    PageType = List;
    SourceTable = IntPurchPayment;
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                FreezeColumn = "Errors Import Excel";

                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Status  field.';
                }
                field("Line Errors"; Rec."Line Errors")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Error Order field.';
                }
                field("Errors Import Excel"; Rec."Errors Import Excel")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Errors Import Excel field.';
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
                field(WiteOffAmount; Rec.WiteOffAmount)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the WiteOffAmount field.';
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
                field("Applies-to Doc. No."; Rec."Applies-to Doc. No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Applies-to Doc. No. field.';
                }
                field("External Document No."; Rec."External Document No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the External Document No. field.';
                }
                field("Order CSRF Ret"; rec."Order CSRF Ret")
                {
                    ApplicationArea = all;
                    ToolTip = 'Order CSRF Ret';
                }
                field("Order DIRF Ret"; rec."Order DIRF Ret")
                {
                    ApplicationArea = ALL;
                    ToolTip = 'Order DIRF Ret';
                }
                field("Order INSS Ret"; rec."Order INSS Ret")
                {
                    ApplicationArea = all;
                    ToolTip = 'Order INSS Ret';
                }
                field("Order IRRF Ret"; rec."Order IRRF Ret")
                {
                    ApplicationArea = all;
                    ToolTip = 'Order IRRF Ret';
                }
                field("Order ISS Ret"; rec."Order ISS Ret")
                {
                    ApplicationArea = all;
                    ToolTip = 'Order ISS Ret';
                }
                field("Order PO Total"; rec."Order PO Total")
                {
                    ApplicationArea = all;
                    ToolTip = 'Order PO Total';
                    Visible = false;
                }
                field("Amount Entry"; rec."Amount Entry")
                {
                    ApplicationArea = all;
                    ToolTip = 'Amount Entry';
                }
                field("Permitir Dif. Aplicação"; rec."Permitir Dif. Aplicação")
                {
                    ApplicationArea = all;
                    ToolTip = 'Permitir Dif. Aplicação';
                }
                field("Different Amount"; rec."Different Amount")
                {
                    ApplicationArea = all;
                    ToolTip = 'Different Amount';
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
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(ImportExcel)
            {
                ApplicationArea = All;
                Caption = 'Import Excel Purchase Payment';
                Image = CreateDocument;
                ToolTip = 'Import Excel Purchase Payment';

                trigger OnAction();
                var
                    ImportExcelBuffer: codeunit "Import Excel Buffer";
                    FTPIntegrationType: Enum "FTP Integration Type";
                begin
                    ImportExcelBuffer.ImportExcelPaymentPurchaseJournal(FTPIntegrationType::"Purchase Payment");

                    CurrPage.SaveRecord();
                    CurrPage.Update();
                    Message(ImportMessageLbl);
                end;
            }

            action(CopyToJournal)
            {
                ApplicationArea = All;
                Caption = 'Copy To Journal';
                Image = PostDocument;
                ToolTip = 'Copy lines to Jornal';

                trigger OnAction();
                var
                    IntPurchPay: Record IntPurchPayment;
                begin
                    CurrPage.SetSelectionFilter(IntPurchPay);
                    IntPurchPay.CopyFilters(Rec);
                    IntPurchPayment.CheckData(IntPurchPay);
                    CurrPage.Update();
                    Message(CopyToJournalLbl);
                end;
            }

            action(PostJournal)
            {
                ApplicationArea = All;
                Caption = 'Post Journal';
                Image = PostDocument;
                ToolTip = 'Post Jornal';

                trigger OnAction();
                begin
                    IntPurchPayment.PostPaymentJournal(Rec);
                    CurrPage.Update();
                    Message(PostJornalLbl);
                end;
            }
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
            action(PaymentJournal)
            {
                ApplicationArea = All;
                Caption = 'Payment Journal';
                Image = PaymentJournal;
                ToolTip = 'Payment Journal';

                trigger OnAction();
                var
                    GenJournalLine: Record "Gen. Journal Line";
                begin
                    GenJournalLine."Journal Template Name" := rec."Journal Template Name";
                    GenJournalLine."Journal Batch Name" := rec."Journal Batch Name";
                    PAGE.Run(PAGE::"Payment Journal", GenJournalLine);
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
                    IntAc: Record IntPurchPayment;
                begin
                    CurrPage.SetSelectionFilter(IntAc);
                    IntAc.CopyFilters(Rec);
                    IntAc.DeleteAll();
                    CurrPage.Update();

                end;
            }

            action(ClearErrorMessage)
            {
                ApplicationArea = All;
                Caption = 'Clear Error Message';
                Image = ClearLog;
                ToolTip = 'Clear Error Message';

                trigger OnAction();
                var
                    IntAc: Record IntPurchPayment;
                begin
                    CurrPage.SetSelectionFilter(IntAc);
                    IntAc.CopyFilters(Rec);
                    IntAc.SetRange(Status, IntAc.Status::"Data Error");
                    IntAc.ModifyAll("Posting Message", '');
                    IntAc.ModifyAll(Status, IntAc.Status::Imported);

                    CurrPage.Update();

                end;
            }
        }
    }
    var
        IntPurchPayment: codeunit IntPurchPayment;
        ImportMessageLbl: Label 'The Excel file was imported';
        PostJornalLbl: Label 'The joranl was posted';
        CopyToJournalLbl: Label 'Lines were Copied to Journal';
}
