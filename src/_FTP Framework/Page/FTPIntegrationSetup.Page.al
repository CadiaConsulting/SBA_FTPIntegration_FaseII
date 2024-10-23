page 50000 "FTP Integration Setup"
{

    PageType = List;
    Caption = 'FTP Integration Setup';
    ApplicationArea = ALL;
    UsageCategory = Documents;
    SourceTable = "FTP Integration Setup";
    Permissions = tabledata "Sales Cr.Memo Header" = RIMD,
                tabledata "Sales Cr.Memo Line" = RIMD;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(Integration; Rec.Integration)
                {
                    ApplicationArea = ALL;
                    ToolTip = 'Specifies the value of the Integration field.';
                }
                field("Integration Relation"; Rec."Integration Relation")
                {
                    ApplicationArea = ALL;
                    ToolTip = 'Specifies the value of the Integration Relation field.';
                }
                field(Sequence; Rec.Sequence)
                {
                    ApplicationArea = ALL;
                    ToolTip = 'Specifies the value of the Sequence field.';
                }
                field("URL Azure"; Rec."URL Azure")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the URL Azure field.';
                }
                field("URL Address FTP"; Rec."URL Address FTP")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the URL Address FTP field.';
                }
                field("FTP User"; Rec."FTP User")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the FTP User field.';
                }
                field("FTP Password"; Rec."FTP Password")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the FTP Password field.';
                }
                field("Send Email"; Rec."Send Email")
                {
                    ApplicationArea = ALL;
                    ToolTip = 'Specifies the value of the Send Email field.';
                }
                field("E-mail Rejected File"; Rec."E-mail Rejected File")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the E-mail Rejected File field.';
                }
                field("E-mail Rejected data"; Rec."E-mail Rejected Data")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the E-mail Rejected data field.';
                }
                field(Directory; Rec.Directory)
                {
                    ApplicationArea = ALL;
                    ToolTip = 'Specifies the value of the Directory field.';
                }
                field("Error Folder"; Rec."Error Folder")
                {
                    ApplicationArea = ALL;
                    ToolTip = 'Specifies the value of the Error Folder field.';
                }
                field("Imported Folder"; Rec."Imported Folder")
                {
                    ApplicationArea = ALL;
                    ToolTip = 'Specifies the value of the Imported Folder field.';
                }
                field("Manage by file"; Rec."Manage by file")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Manage by file field.';
                }

                field("Prefix File Name"; Rec."Prefix File Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Prefix File Name';
                }
                field("Active Prefix File Name"; Rec."Active Prefix File Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Active Prefix File Name';
                }
                field("Import Excel"; Rec."Import Excel")
                {
                    ApplicationArea = All;
                    Caption = 'Import Excel';
                }
                field("Create Order"; Rec."Create Order")
                {
                    ApplicationArea = All;
                    Caption = 'Create Order';
                }
                field("Post Order"; Rec."Post Order\Journal")
                {
                    ApplicationArea = All;
                    Caption = 'Post Order\Journal';
                }
                field("Export Excel"; Rec."Export Excel")
                {
                    ApplicationArea = All;
                    Caption = 'Export Excel';
                }
                field("Import Purch Post"; Rec."Import Purch Post")
                {
                    ApplicationArea = All;
                    Caption = 'Import Purch Post';
                }
                field("Suggest Vendor Payments"; Rec."Suggest Vendor Payments")
                {
                    ApplicationArea = All;
                    Caption = 'Suggest Vendor Payments';
                }
                field("Copy to Journal"; Rec."Copy to Journal")
                {
                    ApplicationArea = All;
                    Caption = 'Copy to Journal';
                }
                field(Unapply; Rec.Unapply)
                {
                    ApplicationArea = All;
                    Caption = 'Unapply';
                }

            }


            group("FTP Test")
            {

                field("FileName"; FileName)
                {
                    ApplicationArea = All;
                }

                field("Destination"; Destination)
                {
                    ApplicationArea = All;
                }

            }


            group("FTP Dir")
            {
                part(FTPDirectory; "FTP Directory")
                {
                    Caption = 'FTP Directory';
                    ApplicationArea = All;
                }
            }


        }

    }


    actions
    {
        area(Processing)
        {

            action(ListFTP)
            {
                ApplicationArea = All;
                Image = Process;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    StreamInTest: Instream;
                    FTPComm: Codeunit "FTP Communication";
                    ret: Text;
                    lines: List of [Text];
                    line: Text;
                    txtBuilder: TextBuilder;
                    CRLF: Char;
                    FTPDir: Record "FTP Directory";
                begin

                    CRLF := 10;

                    ret := FTPComm.DoAction(Enum::"FTP Actions"::list, FileName, Rec.Directory, Destination, '');
                    lines := ret.Split(CRLF);

                    FTPDir.Reset();
                    FTPDir.DeleteAll();
                    foreach line in lines do begin
                        if line <> '' then begin
                            FTPDir.Init();
                            FTPDir.Filename := line;
                            FTPDir.IsDirectory := (StrPos(line, '.') = 0);
                            FTPDir.Insert();
                        end;
                    end;
                    CurrPage.FTPDirectory.Page.Update();

                end;
            }

            action(DownloadFTP)
            {
                ApplicationArea = All;
                ToolTip = 'Download FTP';
                Image = Process;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    ImportExcelBuffer: codeunit "Import Excel Buffer";
                    FTPComm: codeunit "FTP Communication";
                    EntryNo: BigInteger;
                begin

                    EntryNo := FTPComm.DoAction(Enum::"FTP Actions"::download, FileName, Rec.Directory, Destination, '');
                    ImportExcelBuffer.ReadExcelSheet(EntryNo);
                    ImportExcelBuffer.TestImportExcelSalesData();

                    ImportExcelBuffer.Run();
                    ImportExcelBuffer.ReadExcelSheet(EntryNo);

                    Message('Imported');
                    page.Run(Page::"IntegrationSales");

                end;
            }

            action(MoveFTP)
            {
                ApplicationArea = All;
                ToolTip = 'Move FTP';
                Image = Process;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    FTPComm: codeunit "FTP Communication";
                begin
                    FTPComm.DoAction(Enum::"FTP Actions"::rename, FileName, Rec.Directory, Destination, '');
                    Message('Renamed');
                end;

            }
            action(UploadFTP)
            {
                ApplicationArea = All;
                ToolTip = 'Upload FTP';
                Image = Process;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    FTPComm: Codeunit "FTP Communication";
                    Base64: Codeunit "Base64 Convert";
                    PathToFile: Text;
                    InStr: InStream;
                    FileBase64: Text;
                begin

                    UploadIntoStream('File', '', '', PathToFile, InStr);
                    If PathToFile = '' Then
                        Exit;

                    FileBase64 := Base64.ToBase64(InStr);

                    FTPComm.DoAction(Enum::"FTP Actions"::upload, FileName, Rec.Directory, Destination, FileBase64);
                    Message('Uploaded');
                end;

            }
            action(TestErrorEmail)
            {
                ApplicationArea = All;
                ToolTip = 'Test Error Email';
                Image = Process;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    IntegrationEmail: codeunit "Integration Email";
                begin
                    if Rec."Send Email" then begin
                        IntegrationEmail.SendMail(Rec."E-mail Rejected Data", True, 'Erro teste', 'excel_test.xls');
                        IntegrationEmail.SendMail(Rec."E-mail Rejected Data", False, 'Erro teste', 'excel_test.xls');
                        Message('OK');
                    end;
                end;

            }
            action(DeleteSalesCred)
            {
                ApplicationArea = All;
                Caption = 'Delete Sales Credit';
                ToolTip = 'Delete Sales Credit';
                Image = Delete;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    SalesCreH: Record "Sales Cr.Memo Header";
                    SalesCredLine: Record "Sales Cr.Memo Line";

                begin
                    SalesCreH.Reset();
                    SalesCreH.SetFilter(Amount, '=%1', 0);
                    if SalesCreH.FindSet() then
                        repeat
                            SalesCredLine.Reset();
                            SalesCredLine.SetRange("Document No.", SalesCreH."No.");
                            if SalesCredLine.FindSet() then
                                repeat
                                    SalesCredLine.Delete()
                                until SalesCredLine.Next() = 0;

                            SalesCreH.Delete();

                        until SalesCreH.Next() = 0;


                end;

            }

        }

    }

    var
        FileName: Text[250];
        Destination: Text[250];

}