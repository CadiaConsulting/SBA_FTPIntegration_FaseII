page 50012 IntegrationErros
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = IntegrationErros;
    Caption = 'Integration Errors';

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Entry No."; rec."Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'No.';
                }
                field("Integration Type"; rec."Integration Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Integration Type';
                }
                field(Errors; rec.Errors)
                {
                    ApplicationArea = All;
                    ToolTip = 'Errors';
                }
                field("Field Error"; rec."Field Error")
                {
                    ApplicationArea = All;
                    ToolTip = 'Field Error';
                }
                field("Value Error"; rec."Value Error")
                {
                    ApplicationArea = All;
                    ToolTip = 'Value Error';
                }

                field("Posting Date"; rec."Posting Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Posting Date';
                }
                field("Document No."; rec."Document No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Document No.';
                }
                field("Line No."; rec."Line No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Line No.';
                }
                field("Excel File Name"; rec."Excel File Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Line No.';
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

        }
    }
    var


}