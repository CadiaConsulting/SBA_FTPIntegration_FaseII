page 50100 "FTP Log Card"
{
    PageType = Card;
    SourceTable = "FTP Log";
    Caption = 'FTP Log';
    Editable = false;

    layout
    {
        area(content)
        {
            Group(General)
            {
                field(RequestMethod; Rec.RequestMethod)
                {
                    Tooltip = 'Specifies the RequestMethod';
                    ApplicationArea = All;
                }
                field(RequestUrl; Rec.RequestUrl)
                {
                    Tooltip = 'Specifies the RequestUrl';
                    ApplicationArea = All;
                }
                field(ContentType; Rec.ContentType)
                {
                    Tooltip = 'Specifies the ContentType';
                    ApplicationArea = All;
                }
                field(DateTimeCreated; Rec.DateTimeCreated)
                {
                    Tooltip = 'Specifies the DateTimeCreated';
                    ApplicationArea = All;
                }
                field(Duration; Rec.Duraction)
                {
                    Tooltip = 'Specifies the Duration';
                    ApplicationArea = All;
                }
                field(User; Rec.User)
                {
                    Tooltip = 'Specifies the User';
                    ApplicationArea = All;
                }
            }
            Group(Request)
            {
                field(RequestBodySize; Rec.RequestBodySize)
                {
                    Tooltip = 'Specifies the RequestBodySize';
                    ApplicationArea = All;
                }
                field(RequestHeaders; Rec.RequestHeaders)
                {
                    Tooltip = 'Specifies the RequestHeaders';
                    ApplicationArea = All;
                }
            }
            group(Response)
            {
                field(ResponseHttpStatusCode; Rec.ResponseHttpStatusCode)
                {
                    Tooltip = 'Specifies the ResponseHttpStatusCode';
                    ApplicationArea = All;
                }
                field(ResponseSize; Rec.ResponseSize)
                {
                    Tooltip = 'Specifies the ResponseSize';
                    ApplicationArea = All;
                }
            }
        }
    }

}