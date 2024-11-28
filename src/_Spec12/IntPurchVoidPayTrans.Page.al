page 50080 IntPurchVoidPayTrans
{
    ApplicationArea = All;
    Caption = 'IntPurchVoidPayTrans';
    PageType = List;
    SourceTable = IntPurchVoidPayTrans;
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Account No."; Rec."Account No.")
                {
                    ToolTip = 'Specifies the value of the Account No. field.', Comment = '%';
                }
                field("Account Type"; Rec."Account Type")
                {
                    ToolTip = 'Specifies the value of the Account Type field.', Comment = '%';
                }
                field(Amount; Rec.Amount)
                {
                    ToolTip = 'Specifies the value of the Amount field.', Comment = '%';
                }
                field("Applies-to Doc. No."; Rec."Applies-to Doc. No.")
                {
                    ToolTip = 'Specifies the value of the Applies-to Doc. No. field.', Comment = '%';
                }
                field("Applies-to Doc. Type"; Rec."Applies-to Doc. Type")
                {
                    ToolTip = 'Specifies the value of the Applies-to Doc. Type field.', Comment = '%';
                }
                field("Bal. Account No."; Rec."Bal. Account No.")
                {
                    ToolTip = 'Specifies the value of the Description field.', Comment = '%';
                }
                field("Bal. Account Type"; Rec."Bal. Account Type")
                {
                    ToolTip = 'Specifies the value of the Bal. Account Type field.', Comment = '%';
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the value of the Description field.', Comment = '%';
                }
                field("Dimension 1"; Rec."Dimension 1")
                {
                    ToolTip = 'Specifies the value of the Dimension 1 field.', Comment = '%';
                }
                field("Dimension 2"; Rec."Dimension 2")
                {
                    ToolTip = 'Specifies the value of the Dimension 2 field.', Comment = '%';
                }
                field("Dimension 3"; Rec."Dimension 3")
                {
                    ToolTip = 'Specifies the value of the Dimension 3 field.', Comment = '%';
                }
                field("Dimension 4"; Rec."Dimension 4")
                {
                    ToolTip = 'Specifies the value of the Dimension 4 field.', Comment = '%';
                }
                field("Dimension 5"; Rec."Dimension 5")
                {
                    ToolTip = 'Specifies the value of the Dimension 5 field.', Comment = '%';
                }
                field("Dimension 6"; Rec."Dimension 6")
                {
                    ToolTip = 'Specifies the value of the Dimension 6 field.', Comment = '%';
                }
                field("Dimension 7"; Rec."Dimension 7")
                {
                    ToolTip = 'Specifies the value of the Dimension 7 field.', Comment = '%';
                }
                field("Dimension 8"; Rec."Dimension 8")
                {
                    ToolTip = 'Specifies the value of the Dimension 8 field.', Comment = '%';
                }
                field("Document No."; Rec."Document No.")
                {
                    ToolTip = 'Specifies the value of the Document No. field.', Comment = '%';
                }
                field("Document Type"; Rec."Document Type")
                {
                    ToolTip = 'Specifies the value of the Document Type field.', Comment = '%';
                }
                field("Errors Import Excel"; Rec."Errors Import Excel")
                {
                    ToolTip = 'Specifies the value of the Errors Import Excel field.', Comment = '%';
                }
                field("Excel File Name"; Rec."Excel File Name")
                {
                    ToolTip = 'Specifies the value of the Excel File Name field.', Comment = '%';
                }
                field("Purchase Document No"; Rec."Purchase Document No")
                {
                    ToolTip = 'Specifies the value of the Purchase Document No field.', Comment = '%';
                }
                field("Journal Batch Name"; Rec."Journal Batch Name")
                {
                    ToolTip = 'Specifies the value of the Journal Batch Name field.', Comment = '%';
                }
                field("Journal Line No."; Rec."Journal Line No.")
                {
                    ToolTip = 'Specifies the value of the Journal Line No. field.', Comment = '%';
                }
                field("Journal Template Name"; Rec."Journal Template Name")
                {
                    ToolTip = 'Specifies the value of the Journal Template Name field.', Comment = '%';
                }
                field("Line Errors"; Rec."Line Errors")
                {
                    ToolTip = 'Specifies the value of the Line Errors field.', Comment = '%';
                }
                field("Line No."; Rec."Line No.")
                {
                    ToolTip = 'Specifies the value of the Line No. field.', Comment = '%';
                }
                field("Old Detail Transaction No."; Rec."Old Detail Transaction No.")
                {
                    ToolTip = 'Specifies the value of the Old Detail Transaction No. field.', Comment = '%';
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ToolTip = 'Specifies the value of the Posting Date field.', Comment = '%';
                }
                field("Posting Message"; Rec."Posting Message")
                {
                    ToolTip = 'Specifies the value of the Posting Message field.', Comment = '%';
                }
                field(Status; Rec.Status)
                {
                    ToolTip = 'Specifies the value of the Status field.', Comment = '%';
                }
                field(SystemCreatedAt; Rec.SystemCreatedAt)
                {
                    ToolTip = 'Specifies the value of the SystemCreatedAt field.', Comment = '%';
                }
                field(SystemCreatedBy; Rec.SystemCreatedBy)
                {
                    ToolTip = 'Specifies the value of the SystemCreatedBy field.', Comment = '%';
                }
                field(SystemId; Rec.SystemId)
                {
                    ToolTip = 'Specifies the value of the SystemId field.', Comment = '%';
                }
                field(SystemModifiedAt; Rec.SystemModifiedAt)
                {
                    ToolTip = 'Specifies the value of the SystemModifiedAt field.', Comment = '%';
                }
                field(SystemModifiedBy; Rec.SystemModifiedBy)
                {
                    ToolTip = 'Specifies the value of the SystemModifiedBy field.', Comment = '%';
                }
                field("Tax Account No."; Rec."Tax Account No.")
                {
                    ToolTip = 'Specifies the value of the Tax Account No. field.', Comment = '%';
                }
                field("Tax Amount"; Rec."Tax Amount")
                {
                    ToolTip = 'Specifies the value of the Tax Amount field.', Comment = '%';
                }
                field("Tax Paid"; Rec."Tax Paid")
                {
                    ToolTip = 'Specifies the value of the Tax Paid field.', Comment = '%';
                }
                field("Trans Line No."; Rec."Trans Line No.")
                {
                    ToolTip = 'Specifies the value of the Trans Line No. field.', Comment = '%';
                }
                field("Trans Vendor Ledger Entry No."; Rec."Trans Vendor Ledger Entry No.")
                {
                    ToolTip = 'Specifies the value of the Trans Vendor Ledger Entry No. field.', Comment = '%';
                }
                field("Trans. Document No."; Rec."Trans. Document No.")
                {
                    ToolTip = 'Specifies the value of the Trans. Document No. field.', Comment = '%';
                }
                field("Vendor Ledger Entry No."; Rec."Vendor Ledger Entry No.")
                {
                    ToolTip = 'Specifies the value of the Vendor Ledger Entry No. field.', Comment = '%';
                }
            }
        }
    }
}
