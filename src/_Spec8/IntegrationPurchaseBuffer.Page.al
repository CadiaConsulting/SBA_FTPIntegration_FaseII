page 50090 "IntegrationPurchaseBuffer"
{
    ApplicationArea = All;
    Caption = 'IntegrationPurchaseBuffer';
    PageType = List;
    SourceTable = IntegrationPurchaseBuffer;
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Excel File Name"; Rec."Excel File Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Excel File Name field.';
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Document No. field.';
                }
                field("Error Order"; Rec."Error Order")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Error Order field.';
                }
                field(Lines; Rec.Lines)
                {
                    ApplicationArea = all;
                }
            }
        }
    }
}
