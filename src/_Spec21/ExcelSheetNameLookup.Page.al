page 50078 "Excel Sheet Name Lookup"
{
    Caption = 'Excel Sheet Name Lookup';
    Editable = false;
    PageType = List;
    SourceTable = "Name/Value Buffer";

    layout
    {
        area(content)
        {
            repeater(Control1000)
            {
                ShowCaption = false;
                field("Excel Sheet Name"; Rec.Value)
                {
                    ApplicationArea = Basic, Suite, Invoicing;
                    ToolTip = 'Specifies the Excel Sheet Name.';
                }
            }
        }
    }
}

