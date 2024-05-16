page 50074 "IntAccountingEntries"
{
    ApplicationArea = All;
    Caption = 'Integration Accounting Entries';
    PageType = List;
    SourceTable = IntAccountingEntries;
    SourceTableView = where(Status = filter(<> Posted));
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
                    ToolTip = 'Specifies the value of the Line Errors field.';
                }
                field("Errors Import Excel"; Rec."Errors Import Excel")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Errors Import Excel field.';
                }
                field("Journal Batch Name"; Rec."Journal Batch Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Journal Batch Name field.';
                }
                field("Journal Template Name"; Rec."Journal Template Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Journal Template Name field.';
                }
                field("Line No."; Rec."Line No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Line No. field.';
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
                field("BR Account No."; Rec."BR Account No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the BR Account No. field.';
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
                field("BR Bal. Account No."; Rec."BR Bal. Account No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the BR Bal. Account No. field.';
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Amount field.';
                }
                field("Dimension 1"; Rec."Dimension 1")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Dimension 1 field.';
                }
                field("Dimension 2"; Rec."Dimension 2")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Dimension 2 field.';
                }
                field("Dimension 3"; Rec."Dimension 3")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Dimension 3 field.';
                }
                field("Dimension 4"; Rec."Dimension 4")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Dimension 4 field.';
                }
                field("Dimension 5"; Rec."Dimension 5")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Dimension 5 field.';
                }
                field("Dimension 6"; Rec."Dimension 6")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Dimension 6 field.';
                }
                field("Dimension 7"; Rec."Dimension 7")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Dimension 7 field.';
                }
                field("Dimension 8"; Rec."Dimension 8")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Dimension 8 field.';
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Document No. field.';
                }
                field("Additional Description"; Rec."Additional Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Additional Description field.';
                }
                field("Branch Code"; Rec."Branch Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Branch Code field.';
                }
                field("Bal. Amount"; Rec."Bal. Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Bal. Amount field.';
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
                Caption = 'Import Excel Accounting Entries';
                Image = CreateDocument;
                ToolTip = 'Import Excel Accounting Entries';

                trigger OnAction();
                var
                    ImportExcelBuffer: codeunit "Import Excel Buffer";
                    FTPIntegrationType: Enum "FTP Integration Type";
                begin

                    ImportExcelBuffer.ImportExcelIntAccountingEntries(FTPIntegrationType::"Accounting Entries");

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
                begin
                    IntAccountingEntries.CheckData(Rec);
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
                    IntAccountingEntries.PostPaymentJournal(Rec);
                    CurrPage.Update();
                    Message(PostJornalLbl);
                end;
            }
            action(OpenJournal)
            {
                ApplicationArea = All;
                Caption = 'Open Journal';
                Image = Vendor;
                ToolTip = 'Open Journal';

                trigger OnAction();
                var
                    GenJournalLine: Record "Gen. Journal Line";
                begin
                    GenJournalLine.SetRange("Journal Template Name", Rec."Journal Template Name");
                    GenJournalLine.SetRange("Journal Batch Name", Rec."Journal Batch Name");
                    if GenJournalLine.FindSet() then
                        Page.Run(pAGE::"General Journal", GenJournalLine);
                end;
            }
            action("&Navigate")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Find entries...';
                Image = Navigate;
                Promoted = true;
                PromotedCategory = Process;
                ShortCutKey = 'Ctrl+Alt+Q';
                ToolTip = 'Find entries and documents that exist for the document number and posting date on the selected document. (Formerly this action was named Navigate.)';

                trigger OnAction()
                var
                    Navigate: Page Navigate;
                begin
                    if Rec.Status = Rec.Status::Posted then begin
                        Navigate.SetDoc(Rec."Posting Date", Rec."Document No.");
                        Navigate.Run();
                    end;
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

                    PAGE.Run(PAGE::IntAccountingEntriesPosted);
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
                    IntAc: Record IntAccountingEntries;
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
        ImportMessageLbl: Label 'The Excel file was imported';
        CopyToJournalLbl: Label 'Copied to Journal';
        PostJornalLbl: Label 'Posted Journal';
        IntAccountingEntries: Codeunit IntAccountingEntries;

}
