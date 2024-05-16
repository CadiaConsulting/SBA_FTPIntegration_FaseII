page 50004 "Integration Vendor"
{
    ApplicationArea = All;
    Caption = 'Integration Vendor Master Data';
    PageType = List;
    SourceTable = "Integration Vendor";
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
                field("Payment Terms Code"; Rec."Payment Terms Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Payment Terms Code';
                }
                field("Payment Method Code"; Rec."Payment Method Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Payment Method Code';
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
                Caption = 'Import Excel Vendor';
                Image = CreateDocument;
                ToolTip = 'Import Excel Vendor';

                trigger OnAction();
                var
                    ImportExcelBuffer: codeunit "Import Excel Buffer";

                begin
                    ImportExcelBuffer.ImportExcelVendor();

                    CurrPage.SaveRecord();
                    CurrPage.Update();
                    Message('Import Excel Vendor');
                end;
            }
            action(CreateVendor)
            {
                ApplicationArea = All;
                Caption = 'Create Vendor';
                Image = CreateDocument;
                ToolTip = 'Create Vendor';

                trigger OnAction();
                begin
                    IntegrationVendor.CreateVendor();
                    CurrPage.SaveRecord();
                    CurrPage.Update();
                    Message('Create Vendor');
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
                    Vendor."No." := rec."No.";
                    PAGE.Run(PAGE::"Vendor Card", Vendor);
                end;
            }
        }
    }
    var
        IntegrationVendor: codeunit "Integration Vendor";
}
