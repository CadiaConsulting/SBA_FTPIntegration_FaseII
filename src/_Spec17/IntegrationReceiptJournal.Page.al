page 50002 "Integration Receipt Journal"
{
    Caption = 'Integration Receipt Journal';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Integration Receipt Journal";

    layout
    {
        area(content)
        {
            repeater(General)
            {

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
                    ToolTip = 'Specifies the value of the Bal. Account No. field.';
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Amount field.';
                }
                field("dimension 1"; Rec."dimension 1")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the dimension 1 field.';
                }
                field("dimension 2"; Rec."dimension 2")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the dimension 2 field.';
                }
                field("dimension 3"; Rec."dimension 3")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the dimension 3 field.';
                }
                field("dimension 4"; Rec."dimension 4")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the dimension 4 field.';
                }
                field("dimension 5"; Rec."dimension 5")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the dimension 5 field.';
                }
                field("dimension 6"; Rec."dimension 6")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the dimension 6 field.';
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
    }
    actions
    {
        area(Processing)
        {
            action(ImportExcel)
            {
                ApplicationArea = All;
                Caption = 'Import Excel Receipt Journal';
                Image = CreateDocument;
                ToolTip = 'Import Excel Receipt Journal';

                trigger OnAction();
                var
                    ImportExcelBuffer: codeunit "Import Excel Buffer";

                begin
                    ImportExcelBuffer.ImportExcelReceiptJournal();

                    CurrPage.SaveRecord();
                    CurrPage.Update();
                    Message('Import Excel Receipt Journal');
                end;
            }
            action(CreateJornal)
            {
                ApplicationArea = All;
                Caption = 'Create / Post Receipt Journal';
                Image = PostDocument;
                ToolTip = 'Create / Post Receipt Journal';

                trigger OnAction();
                var
                    IntReceiptJournal: Record "Integration Receipt Journal";
                begin
                    CurrPage.SetSelectionFilter(IntReceiptJournal);
                    IntReceiptJournal.CopyFilters(Rec);
                    IntegrationReceiptJournal.CreateJournal(IntReceiptJournal);
                    CurrPage.SaveRecord();
                    CurrPage.Update();
                    Message('Create / Pos Receipt Journal');
                end;
            }
            // action(PostReceiptJournal)
            // {
            //     ApplicationArea = All;
            //     Caption = 'Post Receipt Journal';
            //     Image = PostDocument;
            //     ToolTip = 'Post Receipt Journal';

            //     trigger OnAction();
            //     begin
            //         IntegrationReceiptJournal.PostReceiptJournal();
            //         CurrPage.Update();
            //         Message('Post Receipt Journal');
            //     end;
            // }
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
            action(Customer)
            {
                ApplicationArea = All;
                Caption = 'Customer Card';
                Image = Customer;
                ToolTip = 'Customer Card';

                trigger OnAction();
                var
                    Customer: Record Customer;
                begin
                    if rec."Account Type" = rec."Account Type"::Customer then begin
                        Customer."No." := rec."Account No.";
                        PAGE.Run(PAGE::"Customer Card", Customer);
                    end;
                end;
            }
            action("Cash Receipt Journals")
            {
                ApplicationArea = All;
                Caption = 'Cash Receipt Journals';
                Image = CashReceiptJournal;
                ToolTip = 'Cash Receipt Journals';

                trigger OnAction();
                var
                    GenJournalLine: Record "Gen. Journal Line";
                begin
                    GenJournalLine."Journal Template Name" := rec."Journal Template Name";
                    GenJournalLine."Journal Batch Name" := rec."Journal Batch Name";
                    GenJournalLine."Document No." := rec."Document No.";
                    PAGE.Run(PAGE::"Cash Receipt Journal", GenJournalLine);
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
                    IntAc: Record "Integration Receipt Journal";
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
        IntegrationReceiptJournal: codeunit "Integration Receipt Journal";
}
