page 50003 "Integration Customer"
{
    ApplicationArea = All;
    Caption = 'Integration Customer Master Data';
    PageType = List;
    SourceTable = "Integration Customer";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'No.';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Name';
                }
                field("Search Name"; Rec."Search Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Search Name';
                }
                field("Post Code"; Rec."Post Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Post Code';
                }
                field(Country; Rec.Country)
                {
                    ApplicationArea = All;
                    ToolTip = 'Country Code';
                }
                field("Territory Code"; Rec."Territory Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Territory Code';
                }
                field(City; Rec.City)
                {
                    ApplicationArea = All;
                    ToolTip = 'City';
                }
                field(Address; Rec.Address)
                {
                    ApplicationArea = All;
                    ToolTip = 'Address';
                }
                field("Address 2"; Rec."Address 2")
                {
                    ApplicationArea = All;
                    ToolTip = 'Address';
                }
                field(Number; Rec.Number)
                {
                    ApplicationArea = All;
                    ToolTip = 'Number';
                }
                field("Phone No."; Rec."Phone No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Phone No.';
                }
                field("Phone No. 2"; Rec."Phone No. 2")
                {
                    ApplicationArea = All;
                    ToolTip = 'Mobile No.';
                }
                field("E-Mail"; Rec."E-Mail")
                {
                    ApplicationArea = All;
                    ToolTip = 'E-mail';
                }
                field("C.N.P.J./C.P.F."; Rec."C.N.P.J./C.P.F.")
                {
                    ApplicationArea = All;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                }
                field("Posting Message"; Rec."Posting Message")
                {
                    ApplicationArea = All;
                    ToolTip = 'Posting Message';
                }
                field("Errors Import Excel"; Rec."Errors Import Excel")
                {
                    ApplicationArea = All;
                    ToolTip = 'Errors Import';
                }
                field("Excel File Name"; Rec."Excel File Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Excel File Name';
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
            action(ImportExcel)
            {
                ApplicationArea = All;
                Caption = 'Import Excel Customer';
                Image = CreateDocument;
                ToolTip = 'Import Excel Customer';

                trigger OnAction();
                var
                    ImportExcelBuffer: codeunit "Import Excel Buffer";

                begin
                    ImportExcelBuffer.ImportExcelCustomer();

                    CurrPage.SaveRecord();
                    CurrPage.Update();
                    Message('Import Excel Customer');
                end;
            }
            action(CreateOrder)
            {
                ApplicationArea = All;
                Caption = 'Create Customer';
                Image = CreateDocument;
                ToolTip = 'Create Customer';

                trigger OnAction();
                begin
                    IntegrationCustomer.CreateCustomer();
                    CurrPage.SaveRecord();
                    CurrPage.Update();
                    Message('Create Customer');
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
                    Customer."No." := rec."No.";
                    PAGE.Run(PAGE::"Customer Card", Customer);
                end;
            }
        }
    }
    var
        IntegrationCustomer: codeunit "Integration Customer";
}
