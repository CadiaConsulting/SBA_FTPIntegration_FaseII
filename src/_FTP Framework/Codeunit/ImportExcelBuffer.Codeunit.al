codeunit 50002 "Import Excel Buffer"
{
    var
        TempExcelBuffer: Record "Excel Buffer" temporary;
        TypeIntergationErrorLbl: Label 'This routine is not prepared for this type of %1.';
        SetLanguage: Codeunit Language;
        GlobalDateYes: Date;
        GlobalDecimalYes: Decimal;


    // > TEST
    procedure TestImportExcelSalesData()
    var
        TemporaryBuffer: Record "IntegrationSales";
        RowNo: Integer;
        ColNo: Integer;
        LineNo: Integer;
        MaxRowNo: Integer;
    begin
        RowNo := 0;
        ColNo := 0;
        MaxRowNo := 0;
        LineNo := 0;

        TemporaryBuffer.Reset();
        if TemporaryBuffer.FindLast() then
            LineNo := TemporaryBuffer."Line No.";

        TempExcelBuffer.Reset();
        if TempExcelBuffer.FindLast() then begin
            MaxRowNo := TempExcelBuffer."Row No.";
        end;

        for RowNo := 2 to MaxRowNo do begin
            LineNo := LineNo + 10000;

            TemporaryBuffer.Init();
            Evaluate(TemporaryBuffer."No.", GetValueAtCell(RowNo, 2));//novas linhas
            TemporaryBuffer."Line No." := LineNo;
            if TemporaryBuffer.Insert() then;

        end;

    end;
    // < TEST


    procedure ImportExcelSales()
    var
        IntegrationSales: Record "IntegrationSales";
        IntegrationErros: Record IntegrationErros;
        FTPIntSetup: Record "FTP Integration Setup";
        FTPDir: Record "FTP Directory";
        FTPCommunication: codeunit "FTP Communication";
        ret: Text;
        lines: List of [Text];
        line: Text;
        FileName: Text;
        EntryNo: BigInteger;
        RowNo: Integer;
        ColNo: Integer;
        LineNo: Integer;
        MaxRowNo: Integer;
        CRLF: Char;
        ErrorFile: Boolean;
        ExistLine: Boolean;
        MaxCollumn: Integer;
        Item: Record Item;


    begin
        RowNo := 0;
        ColNo := 0;
        MaxRowNo := 0;
        LineNo := 0;
        MaxCollumn := 0;
        ExistLine := false;

        //FTPIntSetup.Get(FTPIntSetup.Integration::Sales);
        FTPIntSetup.Reset();
        FTPIntSetup.SetRange(Integration, FTPIntSetup.Integration::Sales);
        FTPIntSetup.SetRange(Sequence, 0);
        FTPIntSetup.FindSet();

        CRLF := 10;

        ret := FTPCommunication.DoAction(Enum::"FTP Actions"::list, '', FTPIntSetup.Directory, '', '');
        lines := ret.Split(CRLF);

        FTPDir.Reset();
        FTPDir.DeleteAll();
        foreach line in lines do
            if line <> '' then begin
                FTPDir.Init();
                FTPDir.Filename := line;
                FTPDir.IsDirectory := (StrPos(line, '.') = 0);
                FTPDir.Insert();
            end;

        FTPDir.Reset();
        FTPDir.SetRange(IsDirectory, false);
        if FTPDir.Find('-') then
            repeat
                Clear(FTPCommunication);
                ErrorFile := false;

                FileName := FTPDir.Filename.Trim();

                if FTPIntSetup."Active Prefix File Name" then begin
                    FTPIntSetup.testfield("Prefix File Name");
                    if StrPos(FileName, FTPIntSetup."Prefix File Name") = 0 then
                        Error('File Name Not Valid');
                end;

                EntryNo := FTPCommunication.DoAction(Enum::"FTP Actions"::download, FileName, FTPIntSetup.Directory, '', '');
                ReadExcelSheet(EntryNo);

                IntegrationSales.Reset();
                if IntegrationSales.FindLast() then
                    LineNo := IntegrationSales."Line No.";

                TempExcelBuffer.Reset();
                if TempExcelBuffer.FindLast() then
                    MaxRowNo := TempExcelBuffer."Row No.";

                //Delete Errors
                IntegrationErros.Reset();
                IntegrationErros.Setrange("Document No.", IntegrationSales."No.");
                if IntegrationErros.FindSet() then
                    repeat
                        IntegrationErros.DeleteAll();
                    until IntegrationErros.Next() = 0;

                //Column START Error
                if TempExcelBuffer.FindLast() then
                    MaxCollumn := TempExcelBuffer."Column No.";

                if MaxCollumn <> 36 then begin
                    IntegrationSales.Init();
                    IntegrationSales."No." := format(Today) + format(Time);
                    IntegrationSales.Status := IntegrationSales.Status::"Layout Error";
                    IntegrationSales."Excel File Name" := copystr(Filename, 1, 200);
                    IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Sales Order",
                      IntegrationSales."No.", IntegrationSales."Line No.", CopyStr('', 1, 50),
                      'Layout Error', GetValueAtCell(RowNo, 2), IntegrationSales."Excel File Name");

                    if IntegrationSales.Insert() then
                        ErrorFile := true;
                end else
                    //Column END Error

                        for RowNo := 2 to MaxRowNo do begin
                        LineNo := LineNo + 10000;
                        ExistLine := false;

                        if (StrLen(GetValueAtCell(RowNo, 2)) <= 20) then begin

                            if (IntegrationSales.Get(GetValueAtCell(RowNo, 2), GetValueAtCell(RowNo, 20))) then begin
                                //Not Modify Posted Line
                                if IntegrationSales.Status = IntegrationSales.Status::Posted then begin
                                    ExistLine := false;
                                    IntegrationSales."Posting Message" := 'Duplicate ' + copystr(Filename, 1, 200);
                                    IntegrationSales.Modify();
                                    ErrorFile := true;
                                end else begin
                                    ExistLine := true;
                                    IntegrationSales.Status := IntegrationSales.Status::Imported;
                                end;
                            end else
                                IntegrationSales.Init();
                            IntegrationSales.Status := IntegrationSales.Status::Imported;
                            Evaluate(IntegrationSales."No.", GetValueAtCell(RowNo, 2));
                            Evaluate(IntegrationSales."Line No.", GetValueAtCell(RowNo, 20));
                            IntegrationSales."Excel File Name" := copystr(Filename, 1, 200);
                        end else begin
                            IntegrationSales.Init();
                            Evaluate(IntegrationSales."No.", 'Errors-' + format(RowNo));
                            Evaluate(IntegrationSales."Line No.", GetValueAtCell(RowNo, 20));
                            IntegrationSales.Status := IntegrationSales.Status::"Data Excel Error";
                            IntegrationSales."Excel File Name" := copystr(Filename, 1, 200);
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Sales Order",
                              IntegrationSales."No.", IntegrationSales."Line No.", CopyStr(IntegrationSales.FieldCaption("No."), 1, 50),
                              'Maximum 20 characters', GetValueAtCell(RowNo, 2), IntegrationSales."Excel File Name");
                        end;

                        if (StrLen(GetValueAtCell(RowNo, 3)) <= 20) then
                            Evaluate(IntegrationSales."Sell-to Customer No.", GetValueAtCell(RowNo, 3))
                        else begin
                            IntegrationSales.Status := IntegrationSales.Status::"Data Excel Error";
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Sales Order",
                              IntegrationSales."No.", IntegrationSales."Line No.", CopyStr(IntegrationSales.FieldCaption("Sell-to Customer No."), 1, 50),
                              'Maximum 20 characters', GetValueAtCell(RowNo, 3), IntegrationSales."Excel File Name");
                        end;

                        if (StrLen(GetValueAtCell(RowNo, 4)) <= 35) then
                            Evaluate(IntegrationSales."Your Reference", GetValueAtCell(RowNo, 4))
                        else begin
                            IntegrationSales.Status := IntegrationSales.Status::"Data Excel Error";
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Sales Order",
                              IntegrationSales."No.", IntegrationSales."Line No.", CopyStr(IntegrationSales.FieldCaption("Your Reference"), 1, 50),
                              'Maximum 35 characters', GetValueAtCell(RowNo, 4), IntegrationSales."Excel File Name");
                        end;

                        if ValidateDate(GetValueAtCell(RowNo, 5)) then
                            IntegrationSales."Order Date" := GlobalDateYes
                        else begin
                            IntegrationSales.Status := IntegrationSales.Status::"Data Excel Error";
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Sales Order",
                            IntegrationSales."No.", IntegrationSales."Line No.", CopyStr(IntegrationSales.FieldCaption("Order Date"), 1, 50),
                            CopyStr(GetLastErrorText(), 1, 250), GetValueAtCell(RowNo, 5), IntegrationSales."Excel File Name");

                        end;

                        if ValidateDate(GetValueAtCell(RowNo, 6)) then
                            IntegrationSales."Posting Date" := GlobalDateYes
                        else begin
                            IntegrationSales.Status := IntegrationSales.Status::"Data Excel Error";
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Sales Order",
                            IntegrationSales."No.", IntegrationSales."Line No.", CopyStr(IntegrationSales.FieldCaption("Posting Date"), 1, 50),
                            CopyStr(GetLastErrorText(), 1, 250), GetValueAtCell(RowNo, 6), IntegrationSales."Excel File Name");

                        end;

                        if (StrLen(GetValueAtCell(RowNo, 8)) <= 20) then
                            Evaluate(IntegrationSales."Customer Posting Group", GetValueAtCell(RowNo, 8))
                        else begin
                            IntegrationSales.Status := IntegrationSales.Status::"Data Excel Error";
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Sales Order",
                              IntegrationSales."No.", IntegrationSales."Line No.", CopyStr(IntegrationSales.FieldCaption("Customer Posting Group"), 1, 50),
                              'Maximum 20 characters', GetValueAtCell(RowNo, 8), IntegrationSales."Excel File Name");
                        end;

                        if ValidateDate(GetValueAtCell(RowNo, 9)) then
                            IntegrationSales."Document Date" := GlobalDateYes
                        else begin
                            IntegrationSales.Status := IntegrationSales.Status::"Data Excel Error";
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Sales Order",
                            IntegrationSales."No.", IntegrationSales."Line No.", CopyStr(IntegrationSales.FieldCaption("Document Date"), 1, 50),
                            CopyStr(GetLastErrorText(), 1, 250), GetValueAtCell(RowNo, 9), IntegrationSales."Excel File Name");

                        end;

                        if (StrLen(GetValueAtCell(RowNo, 10)) <= 35) then
                            Evaluate(IntegrationSales."External Document No.", GetValueAtCell(RowNo, 10))
                        else begin
                            IntegrationSales.Status := IntegrationSales.Status::"Data Excel Error";
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Sales Order",
                              IntegrationSales."No.", IntegrationSales."Line No.", CopyStr(IntegrationSales.FieldCaption("External Document No."), 1, 50),
                              'Maximum 35 characters', GetValueAtCell(RowNo, 10), IntegrationSales."Excel File Name");
                        end;

                        IntegrationSales."Freight Billed To" := IntegrationSales."Freight Billed To"::"Without Freight";

                        if (StrLen(GetValueAtCell(RowNo, 14)) <= 20) then
                            Evaluate(IntegrationSales."Shortcut Dimension 1 Code", GetValueAtCell(RowNo, 14))
                        else begin
                            IntegrationSales.Status := IntegrationSales.Status::"Data Excel Error";
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Purchase Return Order",
                              IntegrationSales."No.", IntegrationSales."Line No.", CopyStr(IntegrationSales.FieldCaption("Shortcut Dimension 1 Code"), 1, 50),
                              'Maximum 20 characters', GetValueAtCell(RowNo, 14), IntegrationSales."Excel File Name");
                        end;

                        if (StrLen(GetValueAtCell(RowNo, 15)) <= 20) then
                            Evaluate(IntegrationSales."Shortcut Dimension 2 Code", GetValueAtCell(RowNo, 15))
                        else begin
                            IntegrationSales.Status := IntegrationSales.Status::"Data Excel Error";
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Purchase Return Order",
                              IntegrationSales."No.", IntegrationSales."Line No.", CopyStr(IntegrationSales.FieldCaption("Shortcut Dimension 2 Code"), 1, 50),
                              'Maximum 20 characters', GetValueAtCell(RowNo, 15), IntegrationSales."Excel File Name");
                        end;

                        if (StrLen(GetValueAtCell(RowNo, 16)) <= 20) then
                            Evaluate(IntegrationSales."Shortcut Dimension 3 Code", GetValueAtCell(RowNo, 16))
                        else begin
                            IntegrationSales.Status := IntegrationSales.Status::"Data Excel Error";
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Purchase Return Order",
                              IntegrationSales."No.", IntegrationSales."Line No.", CopyStr(IntegrationSales.FieldCaption("Shortcut Dimension 3 Code"), 1, 50),
                              'Maximum 20 characters', GetValueAtCell(RowNo, 16), IntegrationSales."Excel File Name");
                        end;

                        if (StrLen(GetValueAtCell(RowNo, 17)) <= 20) then
                            Evaluate(IntegrationSales."Shortcut Dimension 4 Code", GetValueAtCell(RowNo, 17))
                        else begin
                            IntegrationSales.Status := IntegrationSales.Status::"Data Excel Error";
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Purchase Return Order",
                              IntegrationSales."No.", IntegrationSales."Line No.", CopyStr(IntegrationSales.FieldCaption("Shortcut Dimension 4 Code"), 1, 50),
                              'Maximum 20 characters', GetValueAtCell(RowNo, 17), IntegrationSales."Excel File Name");
                        end;

                        if (StrLen(GetValueAtCell(RowNo, 18)) <= 20) then
                            Evaluate(IntegrationSales."Shortcut Dimension 5 Code", GetValueAtCell(RowNo, 18))
                        else begin
                            IntegrationSales.Status := IntegrationSales.Status::"Data Excel Error";
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Purchase Return Order",
                              IntegrationSales."No.", IntegrationSales."Line No.", CopyStr(IntegrationSales.FieldCaption("Shortcut Dimension 5 Code"), 1, 50),
                              'Maximum 20 characters', GetValueAtCell(RowNo, 18), IntegrationSales."Excel File Name");
                        end;

                        if (StrLen(GetValueAtCell(RowNo, 19)) <= 20) then
                            Evaluate(IntegrationSales."Shortcut Dimension 6 Code", GetValueAtCell(RowNo, 19))
                        else begin
                            IntegrationSales.Status := IntegrationSales.Status::"Data Excel Error";
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Purchase Return Order",
                              IntegrationSales."No.", IntegrationSales."Line No.", CopyStr(IntegrationSales.FieldCaption("Shortcut Dimension 6 Code"), 1, 50),
                              'Maximum 20 characters', GetValueAtCell(RowNo, 19), IntegrationSales."Excel File Name");
                        end;

                        //Lines

                        IntegrationSales.Type := IntegrationSales.Type::Item;

                        if (StrLen(GetValueAtCell(RowNo, 22)) <= 20) and
                            item.get(GetValueAtCell(RowNo, 22)) then
                            Evaluate(IntegrationSales."Item No.", GetValueAtCell(RowNo, 22))
                        else
                            if item.get(GetValueAtCell(RowNo, 22)) then begin
                                Evaluate(IntegrationSales."Item No.", GetValueAtCell(RowNo, 22));
                                IntegrationSales.Status := IntegrationSales.Status::"Data Excel Error";
                                IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Sales Order",
                                  IntegrationSales."No.", IntegrationSales."Line No.", CopyStr(IntegrationSales.FieldCaption("Item No."), 1, 50),
                                  'Maximum 20 characters', GetValueAtCell(RowNo, 22), IntegrationSales."Excel File Name")
                            end else begin
                                Evaluate(IntegrationSales."Item No.", GetValueAtCell(RowNo, 22));
                                IntegrationSales.Status := IntegrationSales.Status::"Data Error";
                                IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Sales Order",
                                  IntegrationSales."No.", IntegrationSales."Line No.", CopyStr(IntegrationSales.FieldCaption("Item No."), 1, 50),
                                  'Error Item No.', GetValueAtCell(RowNo, 22), IntegrationSales."Excel File Name")
                            end;


                        if (StrLen(GetValueAtCell(RowNo, 25)) <= 100) then
                            Evaluate(IntegrationSales.Description, GetValueAtCell(RowNo, 25))
                        else begin
                            IntegrationSales.Status := IntegrationSales.Status::"Data Excel Error";
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Sales Order",
                              IntegrationSales."No.", IntegrationSales."Line No.", CopyStr(IntegrationSales.FieldCaption(Description), 1, 50),
                              'Maximum 100 characters', GetValueAtCell(RowNo, 25), IntegrationSales."Excel File Name");
                        end;

                        if ValidateDecimal(GetValueAtCell(RowNo, 26)) then
                            IntegrationSales.Quantity := GlobalDecimalYes
                        else begin
                            IntegrationSales.Status := IntegrationSales.Status::"Data Excel Error";
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Sales Order",
                            IntegrationSales."No.", IntegrationSales."Line No.", CopyStr(IntegrationSales.FieldCaption(Quantity), 1, 50),
                            CopyStr(GetLastErrorText(), 1, 250), GetValueAtCell(RowNo, 26), IntegrationSales."Excel File Name");

                        end;

                        if ValidateDecimal(GetValueAtCell(RowNo, 27)) then
                            IntegrationSales."Unit Price" := GlobalDecimalYes
                        else begin
                            IntegrationSales.Status := IntegrationSales.Status::"Data Excel Error";
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Sales Order",
                            IntegrationSales."No.", IntegrationSales."Line No.", CopyStr(IntegrationSales.FieldCaption("Unit Price"), 1, 50),
                            CopyStr(GetLastErrorText(), 1, 250), GetValueAtCell(RowNo, 27), IntegrationSales."Excel File Name");

                        end;

                        if (StrLen(GetValueAtCell(RowNo, 34)) <= 20) then
                            Evaluate(IntegrationSales."G/L Account", GetValueAtCell(RowNo, 34))
                        else begin
                            IntegrationSales.Status := IntegrationSales.Status::"Data Excel Error";
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Sales Order",
                              IntegrationSales."No.", IntegrationSales."Line No.", CopyStr(IntegrationSales.FieldCaption("G/L Account"), 1, 50),
                              'Maximum 20 characters', GetValueAtCell(RowNo, 34), IntegrationSales."Excel File Name");
                        end;

                        if ValidateDecimal(GetValueAtCell(RowNo, 35)) then
                            IntegrationSales."Tax From Billing APP (PIS)" := GlobalDecimalYes
                        else
                            if (GetValueAtCell(RowNo, 35) <> '') then begin
                                IntegrationSales.Status := IntegrationSales.Status::"Data Excel Error";
                                IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Sales Order",
                                IntegrationSales."No.", IntegrationSales."Line No.", CopyStr(IntegrationSales.FieldCaption("Tax From Billing APP (PIS)"), 1, 50),
                                CopyStr(GetLastErrorText(), 1, 250), GetValueAtCell(RowNo, 35), IntegrationSales."Excel File Name");

                            end;

                        if ValidateDecimal(GetValueAtCell(RowNo, 36)) then
                            IntegrationSales."Tax From Billing APP (COFINS)" := GlobalDecimalYes
                        else
                            if (GetValueAtCell(RowNo, 36) <> '') then begin
                                IntegrationSales.Status := IntegrationSales.Status::"Data Excel Error";
                                IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Sales Order",
                                IntegrationSales."No.", IntegrationSales."Line No.", CopyStr(IntegrationSales.FieldCaption("Tax From Billing APP (COFINS)"), 1, 50),
                                CopyStr(GetLastErrorText(), 1, 250), GetValueAtCell(RowNo, 36), IntegrationSales."Excel File Name");

                            end;

                        if ExistLine then
                            IntegrationSales.Modify()
                        else
                            if IntegrationSales.Insert() then;

                        if IntegrationSales.Status = IntegrationSales.Status::"Data Excel Error" then
                            ErrorFile := true;
                    end;


                if ErrorFile then
                    FTPCommunication.DoAction(Enum::"FTP Actions"::rename, FileName, FTPIntSetup.Directory, FTPIntSetup."Error Folder", '')
                else
                    FTPCommunication.DoAction(Enum::"FTP Actions"::rename, FileName, FTPIntSetup.Directory, FTPIntSetup."Imported Folder", '');

            until FTPDir.Next() = 0;
    end;

    procedure ImportExcelSalesReturn()
    var
        IntSalesCreditNote: Record IntSalesCreditNote;
        IntegrationErros: Record IntegrationErros;
        FTPIntSetup: Record "FTP Integration Setup";
        FTPDir: Record "FTP Directory";
        FTPCommunication: codeunit "FTP Communication";
        ret: Text;
        lines: List of [Text];
        line: Text;
        FileName: Text;
        EntryNo: BigInteger;
        RowNo: Integer;
        ColNo: Integer;
        LineNo: Integer;
        MaxRowNo: Integer;
        MaxCollumn: Integer;
        CRLF: Char;
        ErrorFile: Boolean;
        ExistLine: Boolean;
        Item: Record Item;

    begin
        RowNo := 0;
        ColNo := 0;
        MaxRowNo := 0;
        LineNo := 0;
        MaxCollumn := 0;
        ExistLine := false;

        //FTPIntSetup.Get(FTPIntSetup.Integration::"Sales Credit Note");
        FTPIntSetup.Reset();
        FTPIntSetup.SetRange(Integration, FTPIntSetup.Integration::"Sales Credit Note");
        FTPIntSetup.SetRange(Sequence, 0);
        FTPIntSetup.FindSet();

        CRLF := 10;

        ret := FTPCommunication.DoAction(Enum::"FTP Actions"::list, '', FTPIntSetup.Directory, '', '');
        lines := ret.Split(CRLF);

        FTPDir.Reset();
        FTPDir.DeleteAll();
        foreach line in lines do
            if line <> '' then begin
                FTPDir.Init();
                FTPDir.Filename := line;
                FTPDir.IsDirectory := (StrPos(line, '.') = 0);
                FTPDir.Insert();
            end;

        FTPDir.Reset();
        FTPDir.SetRange(IsDirectory, false);
        if FTPDir.Find('-') then
            repeat
                Clear(FTPCommunication);
                ErrorFile := false;

                FileName := FTPDir.Filename.Trim();

                if FTPIntSetup."Active Prefix File Name" then begin
                    FTPIntSetup.testfield("Prefix File Name");
                    if StrPos(FileName, FTPIntSetup."Prefix File Name") = 0 then
                        Error('File Name Not Valid');
                end;

                EntryNo := FTPCommunication.DoAction(Enum::"FTP Actions"::download, FileName, FTPIntSetup.Directory, '', '');
                ReadExcelSheet(EntryNo);

                IntSalesCreditNote.Reset();
                if IntSalesCreditNote.FindLast() then
                    LineNo := IntSalesCreditNote."Line No.";

                TempExcelBuffer.Reset();
                if TempExcelBuffer.FindLast() then
                    MaxRowNo := TempExcelBuffer."Row No.";

                //Column START Error
                if TempExcelBuffer.FindLast() then
                    MaxCollumn := TempExcelBuffer."Column No.";

                if MaxCollumn <> 36 then begin
                    IntSalesCreditNote.Init();
                    IntSalesCreditNote."No." := format(Today) + format(Time);
                    IntSalesCreditNote.Status := IntSalesCreditNote.Status::"Layout Error";
                    IntSalesCreditNote."Excel File Name" := copystr(Filename, 1, 200);
                    IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Sales Return Order",
                      IntSalesCreditNote."No.", IntSalesCreditNote."Line No.", CopyStr('', 1, 50),
                      'Layout Error', GetValueAtCell(RowNo, 2), IntSalesCreditNote."Excel File Name");

                    if IntSalesCreditNote.Insert() then
                        ErrorFile := true;

                end else
                    //Column END Error
                for RowNo := 2 to MaxRowNo do begin
                        LineNo := LineNo + 10000;
                        ExistLine := false;

                        if (StrLen(GetValueAtCell(RowNo, 2)) <= 20) then begin
                            if IntSalesCreditNote.Get(GetValueAtCell(RowNo, 2), GetValueAtCell(RowNo, 20)) then begin
                                //Not Modify Posted Line
                                if IntSalesCreditNote.Status = IntSalesCreditNote.Status::Posted then begin
                                    ExistLine := false;
                                    IntSalesCreditNote."Posting Message" := 'Duplicate ' + copystr(Filename, 1, 200);
                                    IntSalesCreditNote.Modify();
                                end else
                                    ExistLine := true;

                                //Delete Errors
                                IntegrationErros.Reset();
                                IntegrationErros.Setrange("Document No.", IntSalesCreditNote."No.");
                                if IntegrationErros.FindSet() then
                                    repeat
                                        IntegrationErros.DeleteAll();
                                    until IntegrationErros.Next() = 0
                            end else
                                IntSalesCreditNote.Init();

                            IntSalesCreditNote.Init();
                            IntSalesCreditNote.Status := IntSalesCreditNote.Status::Imported;
                            Evaluate(IntSalesCreditNote."No.", GetValueAtCell(RowNo, 2));
                            Evaluate(IntSalesCreditNote."Line No.", GetValueAtCell(RowNo, 20));
                            IntSalesCreditNote."Excel File Name" := copystr(FileName, 1, 200);
                        end else begin
                            IntSalesCreditNote.Init();
                            Evaluate(IntSalesCreditNote."No.", 'Errors-' + format(RowNo));
                            Evaluate(IntSalesCreditNote."Line No.", GetValueAtCell(RowNo, 20));
                            IntSalesCreditNote.Status := IntSalesCreditNote.Status::"Data Excel Error";
                            IntSalesCreditNote."Excel File Name" := copystr(FileName, 1, 200);

                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Sales Return Order",
                              IntSalesCreditNote."No.", IntSalesCreditNote."Line No.", CopyStr(IntSalesCreditNote.FieldCaption("No."), 1, 50),
                              'Maximum 20 characters', GetValueAtCell(RowNo, 2), IntSalesCreditNote."Excel File Name");
                        end;

                        if (StrLen(GetValueAtCell(RowNo, 3)) <= 20) then
                            Evaluate(IntSalesCreditNote."Sell-to Customer No.", GetValueAtCell(RowNo, 3))
                        else begin
                            IntSalesCreditNote.Status := IntSalesCreditNote.Status::"Data Excel Error";
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Sales Return Order",
                              IntSalesCreditNote."No.", IntSalesCreditNote."Line No.", CopyStr(IntSalesCreditNote.FieldCaption("Sell-to Customer No."), 1, 50),
                              'Maximum 20 characters', GetValueAtCell(RowNo, 3), IntSalesCreditNote."Excel File Name");
                        end;

                        if (StrLen(GetValueAtCell(RowNo, 4)) <= 35) then
                            Evaluate(IntSalesCreditNote."Your Reference", GetValueAtCell(RowNo, 4))
                        else begin
                            IntSalesCreditNote.Status := IntSalesCreditNote.Status::"Data Excel Error";
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Sales Return Order",
                              IntSalesCreditNote."No.", IntSalesCreditNote."Line No.", CopyStr(IntSalesCreditNote.FieldCaption("Your Reference"), 1, 50),
                              'Maximum 35 characters', GetValueAtCell(RowNo, 4), IntSalesCreditNote."Excel File Name");
                        end;

                        if ValidateDate(GetValueAtCell(RowNo, 5)) then
                            IntSalesCreditNote."Order Date" := GlobalDateYes
                        else begin
                            IntSalesCreditNote.Status := IntSalesCreditNote.Status::"Data Excel Error";
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Sales Return Order",
                            IntSalesCreditNote."No.", IntSalesCreditNote."Line No.", CopyStr(IntSalesCreditNote.FieldCaption("Order Date"), 1, 50),
                            CopyStr(GetLastErrorText(), 1, 250), GetValueAtCell(RowNo, 5), IntSalesCreditNote."Excel File Name");

                        end;

                        if ValidateDate(GetValueAtCell(RowNo, 6)) then
                            IntSalesCreditNote."Posting Date" := GlobalDateYes
                        else begin
                            IntSalesCreditNote.Status := IntSalesCreditNote.Status::"Data Excel Error";
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Sales Return Order",
                            IntSalesCreditNote."No.", IntSalesCreditNote."Line No.", CopyStr(IntSalesCreditNote.FieldCaption("Posting Date"), 1, 50),
                            CopyStr(GetLastErrorText(), 1, 250), GetValueAtCell(RowNo, 6), IntSalesCreditNote."Excel File Name");

                        end;

                        if (StrLen(GetValueAtCell(RowNo, 8)) <= 20) then
                            Evaluate(IntSalesCreditNote."Customer Posting Group", GetValueAtCell(RowNo, 8))
                        else begin
                            IntSalesCreditNote.Status := IntSalesCreditNote.Status::"Data Excel Error";
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Sales Return Order",
                              IntSalesCreditNote."No.", IntSalesCreditNote."Line No.", CopyStr(IntSalesCreditNote.FieldCaption("Customer Posting Group"), 1, 50),
                              'Maximum 20 characters', GetValueAtCell(RowNo, 8), IntSalesCreditNote."Excel File Name");
                        end;

                        if ValidateDate(GetValueAtCell(RowNo, 9)) then
                            IntSalesCreditNote."Document Date" := GlobalDateYes
                        else begin
                            IntSalesCreditNote.Status := IntSalesCreditNote.Status::"Data Excel Error";
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Sales Return Order",
                            IntSalesCreditNote."No.", IntSalesCreditNote."Line No.", CopyStr(IntSalesCreditNote.FieldCaption("Document Date"), 1, 50),
                            CopyStr(GetLastErrorText(), 1, 250), GetValueAtCell(RowNo, 9), IntSalesCreditNote."Excel File Name");

                        end;

                        if (StrLen(GetValueAtCell(RowNo, 10)) <= 35) then
                            Evaluate(IntSalesCreditNote."External Document No.", GetValueAtCell(RowNo, 10))
                        else begin
                            IntSalesCreditNote.Status := IntSalesCreditNote.Status::"Data Excel Error";
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Sales Return Order",
                              IntSalesCreditNote."No.", IntSalesCreditNote."Line No.", CopyStr(IntSalesCreditNote.FieldCaption("External Document No."), 1, 50),
                              'Maximum 35 characters', GetValueAtCell(RowNo, 10), IntSalesCreditNote."Excel File Name");
                        end;

                        IntSalesCreditNote."Freight Billed To" := IntSalesCreditNote."Freight Billed To"::"Without Freight";

                        if (StrLen(GetValueAtCell(RowNo, 14)) <= 20) then
                            Evaluate(IntSalesCreditNote."Shortcut Dimension 1 Code", GetValueAtCell(RowNo, 14))
                        else begin
                            IntSalesCreditNote.Status := IntSalesCreditNote.Status::"Data Excel Error";
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Purchase Return Order",
                              IntSalesCreditNote."No.", IntSalesCreditNote."Line No.", CopyStr(IntSalesCreditNote.FieldCaption("Shortcut Dimension 1 Code"), 1, 50),
                              'Maximum 20 characters', GetValueAtCell(RowNo, 14), IntSalesCreditNote."Excel File Name");
                        end;

                        if (StrLen(GetValueAtCell(RowNo, 15)) <= 20) then
                            Evaluate(IntSalesCreditNote."Shortcut Dimension 2 Code", GetValueAtCell(RowNo, 15))
                        else begin
                            IntSalesCreditNote.Status := IntSalesCreditNote.Status::"Data Excel Error";
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Purchase Return Order",
                              IntSalesCreditNote."No.", IntSalesCreditNote."Line No.", CopyStr(IntSalesCreditNote.FieldCaption("Shortcut Dimension 2 Code"), 1, 50),
                              'Maximum 20 characters', GetValueAtCell(RowNo, 15), IntSalesCreditNote."Excel File Name");
                        end;

                        if (StrLen(GetValueAtCell(RowNo, 16)) <= 20) then
                            Evaluate(IntSalesCreditNote."Shortcut Dimension 3 Code", GetValueAtCell(RowNo, 16))
                        else begin
                            IntSalesCreditNote.Status := IntSalesCreditNote.Status::"Data Excel Error";
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Purchase Return Order",
                              IntSalesCreditNote."No.", IntSalesCreditNote."Line No.", CopyStr(IntSalesCreditNote.FieldCaption("Shortcut Dimension 3 Code"), 1, 50),
                              'Maximum 20 characters', GetValueAtCell(RowNo, 16), IntSalesCreditNote."Excel File Name");
                        end;

                        if (StrLen(GetValueAtCell(RowNo, 17)) <= 20) then
                            Evaluate(IntSalesCreditNote."Shortcut Dimension 4 Code", GetValueAtCell(RowNo, 17))
                        else begin
                            IntSalesCreditNote.Status := IntSalesCreditNote.Status::"Data Excel Error";
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Purchase Return Order",
                              IntSalesCreditNote."No.", IntSalesCreditNote."Line No.", CopyStr(IntSalesCreditNote.FieldCaption("Shortcut Dimension 4 Code"), 1, 50),
                              'Maximum 20 characters', GetValueAtCell(RowNo, 17), IntSalesCreditNote."Excel File Name");
                        end;

                        if (StrLen(GetValueAtCell(RowNo, 18)) <= 20) then
                            Evaluate(IntSalesCreditNote."Shortcut Dimension 5 Code", GetValueAtCell(RowNo, 18))
                        else begin
                            IntSalesCreditNote.Status := IntSalesCreditNote.Status::"Data Excel Error";
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Purchase Return Order",
                              IntSalesCreditNote."No.", IntSalesCreditNote."Line No.", CopyStr(IntSalesCreditNote.FieldCaption("Shortcut Dimension 5 Code"), 1, 50),
                              'Maximum 20 characters', GetValueAtCell(RowNo, 18), IntSalesCreditNote."Excel File Name");
                        end;

                        if (StrLen(GetValueAtCell(RowNo, 19)) <= 20) then
                            Evaluate(IntSalesCreditNote."Shortcut Dimension 6 Code", GetValueAtCell(RowNo, 19))
                        else begin
                            IntSalesCreditNote.Status := IntSalesCreditNote.Status::"Data Excel Error";
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Purchase Return Order",
                              IntSalesCreditNote."No.", IntSalesCreditNote."Line No.", CopyStr(IntSalesCreditNote.FieldCaption("Shortcut Dimension 6 Code"), 1, 50),
                              'Maximum 20 characters', GetValueAtCell(RowNo, 19), IntSalesCreditNote."Excel File Name");
                        end;
                        //Lines

                        IntSalesCreditNote.Type := IntSalesCreditNote.Type::Item;

                        if (StrLen(GetValueAtCell(RowNo, 22)) <= 20) and
                            item.get(GetValueAtCell(RowNo, 22)) then
                            Evaluate(IntSalesCreditNote."Item No.", GetValueAtCell(RowNo, 22))
                        else
                            if item.get(GetValueAtCell(RowNo, 22)) then begin
                                IntSalesCreditNote.Status := IntSalesCreditNote.Status::"Data Excel Error";
                                IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Sales Return Order",
                                  IntSalesCreditNote."No.", IntSalesCreditNote."Line No.", CopyStr(IntSalesCreditNote.FieldCaption("Item No."), 1, 50),
                                  'Maximum 20 characters', GetValueAtCell(RowNo, 22), IntSalesCreditNote."Excel File Name");
                            end else begin
                                IntSalesCreditNote.Status := IntSalesCreditNote.Status::"Data Error";
                                IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Sales Order",
                                  IntSalesCreditNote."No.", IntSalesCreditNote."Line No.", CopyStr(IntSalesCreditNote.FieldCaption("Item No."), 1, 50),
                                  'Error Item No.', GetValueAtCell(RowNo, 22), IntSalesCreditNote."Excel File Name");
                            end;

                        if (StrLen(GetValueAtCell(RowNo, 25)) <= 100) then
                            Evaluate(IntSalesCreditNote.Description, GetValueAtCell(RowNo, 25))
                        else begin
                            IntSalesCreditNote.Status := IntSalesCreditNote.Status::"Data Excel Error";
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Sales Return Order",
                              IntSalesCreditNote."No.", IntSalesCreditNote."Line No.", CopyStr(IntSalesCreditNote.FieldCaption(Description), 1, 50),
                              'Maximum 100 characters', GetValueAtCell(RowNo, 25), IntSalesCreditNote."Excel File Name");
                        end;

                        if ValidateDecimal(GetValueAtCell(RowNo, 26)) then
                            IntSalesCreditNote.Quantity := GlobalDecimalYes
                        else begin
                            IntSalesCreditNote.Status := IntSalesCreditNote.Status::"Data Excel Error";
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Sales Return Order",
                            IntSalesCreditNote."No.", IntSalesCreditNote."Line No.", CopyStr(IntSalesCreditNote.FieldCaption(Quantity), 1, 50),
                            CopyStr(GetLastErrorText(), 1, 250), GetValueAtCell(RowNo, 26), IntSalesCreditNote."Excel File Name");

                        end;

                        if ValidateDecimal(GetValueAtCell(RowNo, 27)) then
                            IntSalesCreditNote."Unit Price" := GlobalDecimalYes
                        else begin
                            IntSalesCreditNote.Status := IntSalesCreditNote.Status::"Data Excel Error";
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Sales Return Order",
                            IntSalesCreditNote."No.", IntSalesCreditNote."Line No.", CopyStr(IntSalesCreditNote.FieldCaption("Unit Price"), 1, 50),
                            CopyStr(GetLastErrorText(), 1, 250), GetValueAtCell(RowNo, 27), IntSalesCreditNote."Excel File Name");

                        end;

                        if (StrLen(GetValueAtCell(RowNo, 34)) <= 20) then
                            Evaluate(IntSalesCreditNote."G/L Account", GetValueAtCell(RowNo, 34))
                        else begin
                            IntSalesCreditNote.Status := IntSalesCreditNote.Status::"Data Excel Error";
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Sales Return Order",
                              IntSalesCreditNote."No.", IntSalesCreditNote."Line No.", CopyStr(IntSalesCreditNote.FieldCaption("G/L Account"), 1, 50),
                              'Maximum 20 characters', GetValueAtCell(RowNo, 34), IntSalesCreditNote."Excel File Name");
                        end;

                        if ValidateDecimal(GetValueAtCell(RowNo, 35)) then
                            IntSalesCreditNote."Tax From Billing APP (PIS)" := GlobalDecimalYes
                        else
                            if (GetValueAtCell(RowNo, 35) <> '') then begin
                                IntSalesCreditNote.Status := IntSalesCreditNote.Status::"Data Excel Error";
                                IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Sales Return Order",
                                IntSalesCreditNote."No.", IntSalesCreditNote."Line No.", CopyStr(IntSalesCreditNote.FieldCaption("Tax From Billing APP (PIS)"), 1, 50),
                                CopyStr(GetLastErrorText(), 1, 250), GetValueAtCell(RowNo, 35), IntSalesCreditNote."Excel File Name");

                            end;

                        if ValidateDecimal(GetValueAtCell(RowNo, 36)) then
                            IntSalesCreditNote."Tax From Billing APP (COFINS)" := GlobalDecimalYes
                        else
                            if (GetValueAtCell(RowNo, 36) <> '') then begin
                                IntSalesCreditNote.Status := IntSalesCreditNote.Status::"Data Excel Error";
                                IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Sales Return Order",
                                IntSalesCreditNote."No.", IntSalesCreditNote."Line No.", CopyStr(IntSalesCreditNote.FieldCaption("Tax From Billing APP (COFINS)"), 1, 50),
                                CopyStr(GetLastErrorText(), 1, 250), GetValueAtCell(RowNo, 36), IntSalesCreditNote."Excel File Name");

                            end;
                        if ExistLine then
                            IntSalesCreditNote.Modify()
                        else
                            if IntSalesCreditNote.Insert() then;

                        if IntSalesCreditNote.Status = IntSalesCreditNote.Status::"Data Excel Error" then
                            ErrorFile := true;

                    end;

                if ErrorFile then
                    FTPCommunication.DoAction(Enum::"FTP Actions"::rename, FileName, FTPIntSetup.Directory, FTPIntSetup."Error Folder", '')
                else
                    FTPCommunication.DoAction(Enum::"FTP Actions"::rename, FileName, FTPIntSetup.Directory, FTPIntSetup."Imported Folder", '');


            until FTPDir.next() = 0;
    end;

    procedure ImportExcelPurchase()
    var
        IntegrationPurchase: Record "Integration Purchase";
        IntegrationErros: Record IntegrationErros;
        FTPIntSetup: Record "FTP Integration Setup";
        FTPDir: Record "FTP Directory";
        FTPCommunication: codeunit "FTP Communication";
        CADBRMunicipio: Record "CADBR Municipio";
        IntPurcOld: Record "Integration Purchase";
        ret: Text;
        lines: List of [Text];
        line: Text;
        FileName: Text;
        EntryNo: BigInteger;
        RowNo: Integer;
        ColNo: Integer;
        LineNo: Integer;
        MaxRowNo: Integer;
        CRLF: Char;
        ErrorFile: Boolean;
        ExistLine: Boolean;
        MaxCollumn: Integer;
        PostingDateEmptyErr: Label 'The Posting date cannot be empty.';
        Orderdate: Date;

    begin
        RowNo := 0;
        ColNo := 0;
        MaxRowNo := 0;
        LineNo := 0;
        MaxCollumn := 0;
        ExistLine := false;

        //FTPIntSetup.Get(FTPIntSetup.Integration::Purchase);
        FTPIntSetup.Reset();
        FTPIntSetup.SetRange(Integration, FTPIntSetup.Integration::Purchase);
        FTPIntSetup.SetRange(Sequence, 0);
        FTPIntSetup.FindSet();

        CRLF := 10;

        ret := FTPCommunication.DoAction(Enum::"FTP Actions"::list, '', FTPIntSetup.Directory, '', '');
        lines := ret.Split(CRLF);

        FTPDir.Reset();
        FTPDir.DeleteAll();
        foreach line in lines do
            if line <> '' then begin
                FTPDir.Init();
                FTPDir.Filename := line;
                FTPDir.IsDirectory := (StrPos(line, '.') = 0);
                FTPDir.Insert();
            end;

        FTPDir.Reset();
        FTPDir.SetRange(IsDirectory, false);
        if FTPDir.Find('-') then
            repeat
                Clear(FTPCommunication);
                ErrorFile := false;

                FileName := FTPDir.Filename.Trim();

                if FTPIntSetup."Active Prefix File Name" then begin
                    FTPIntSetup.testfield("Prefix File Name");
                    if StrPos(FileName, FTPIntSetup."Prefix File Name") = 0 then
                        Error('File Name Not Valid');
                end;

                EntryNo := FTPCommunication.DoAction(Enum::"FTP Actions"::download, FileName, FTPIntSetup.Directory, '', '');
                ReadExcelSheet(EntryNo);

                IntegrationPurchase.Reset();
                if IntegrationPurchase.FindLast() then
                    LineNo := IntegrationPurchase."Line No.";

                TempExcelBuffer.Reset();
                if TempExcelBuffer.FindLast() then
                    MaxRowNo := TempExcelBuffer."Row No.";
                //Column START Error
                if TempExcelBuffer.FindLast() then
                    MaxCollumn := TempExcelBuffer."Column No.";

                if MaxCollumn <> 38 then begin

                    IntegrationPurchase.Init();
                    IntegrationPurchase."Document No." := DelChr(Format((Today)) + format(Time), '=', ':/');
                    IntegrationPurchase.Status := IntegrationPurchase.Status::"Layout Error";
                    IntegrationPurchase."Excel File Name" := copystr(Filename, 1, 200);
                    IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Purchase Order",
                      IntegrationPurchase."Document No.", IntegrationPurchase."Line No.", CopyStr('', 1, 50),
                      'Layout Error', GetValueAtCell(RowNo, 2), IntegrationPurchase."Excel File Name");

                    if IntegrationPurchase.Insert() then
                        ErrorFile := true;
                end else
                    //Column END Error
                    for RowNo := 2 to MaxRowNo do begin
                        LineNo := LineNo + 10000;
                        ExistLine := false;

                        if (StrLen(GetValueAtCell(RowNo, 2)) <= 20) then begin

                            if IntegrationPurchase.Get(GetValueAtCell(RowNo, 2), GetValueAtCell(RowNo, 6), copystr(Filename, 1, 200)) then
                                ExistLine := true
                            else
                                IntegrationPurchase.Init();

                            IntegrationPurchase.Status := IntegrationPurchase.Status::Imported;
                            Evaluate(IntegrationPurchase."document No.", GetValueAtCell(RowNo, 2));
                            Evaluate(IntegrationPurchase."Line No.", GetValueAtCell(RowNo, 6));
                            IntegrationPurchase."Excel File Name" := copystr(Filename, 1, 200);
                        end else begin
                            IntegrationPurchase.Init();
                            Evaluate(IntegrationPurchase."document No.", 'Errors-' + format(RowNo));
                            Evaluate(IntegrationPurchase."Line No.", GetValueAtCell(RowNo, 6));
                            IntegrationPurchase.Status := IntegrationPurchase.Status::"Data Excel Error";
                            IntegrationPurchase."Excel File Name" := copystr(Filename, 1, 200);

                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Purchase Order",
                              IntegrationPurchase."document No.", IntegrationPurchase."Line No.", CopyStr(IntegrationPurchase.FieldCaption("Document No."), 1, 50),
                              'Maximum 20 characters', GetValueAtCell(RowNo, 2), IntegrationPurchase."Excel File Name");
                        end;

                        if ValidateDate(GetValueAtCell(RowNo, 3)) then
                            IntegrationPurchase."Order Date" := GlobalDateYes
                        else begin
                            IntegrationPurchase.Status := IntegrationPurchase.Status::"Data Excel Error";
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Purchase Order",
                            IntegrationPurchase."document No.", IntegrationPurchase."Line No.", CopyStr(IntegrationPurchase.FieldCaption("Order Date"), 1, 50),
                            CopyStr(GetLastErrorText(), 1, 250), GetValueAtCell(RowNo, 3), IntegrationPurchase."Excel File Name");

                        end;

                        if (StrLen(GetValueAtCell(RowNo, 4)) <= 100) then
                            Evaluate(IntegrationPurchase."Additional Description", GetValueAtCell(RowNo, 4))
                        else begin
                            IntegrationPurchase.Status := IntegrationPurchase.Status::"Data Excel Error";
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Purchase Order",
                              IntegrationPurchase."Document No.", IntegrationPurchase."Line No.", CopyStr(IntegrationPurchase.FieldCaption("Additional Description"), 1, 50),
                              'Maximum 100 characters', GetValueAtCell(RowNo, 4), IntegrationPurchase."Excel File Name");
                        end;

                        if (StrLen(GetValueAtCell(RowNo, 5)) <= 250) then
                            Evaluate(IntegrationPurchase."Doc. URL", GetValueAtCell(RowNo, 5))
                        else begin
                            IntegrationPurchase.Status := IntegrationPurchase.Status::"Data Excel Error";
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Purchase Order",
                              IntegrationPurchase."Document No.", IntegrationPurchase."Line No.", CopyStr(IntegrationPurchase.FieldCaption("Doc. URL"), 1, 50),
                              'Maximum 250 characters', GetValueAtCell(RowNo, 5), IntegrationPurchase."Excel File Name");
                        end;

                        if (StrLen(GetValueAtCell(RowNo, 7)) <= 20) then
                            Evaluate(IntegrationPurchase."Buy-from Vendor No.", GetValueAtCell(RowNo, 7))
                        else begin
                            IntegrationPurchase.Status := IntegrationPurchase.Status::"Data Excel Error";
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Purchase Order",
                              IntegrationPurchase."document No.", IntegrationPurchase."Line No.", CopyStr(IntegrationPurchase.FieldCaption("Buy-from Vendor No."), 1, 50),
                              'Maximum 20 characters', GetValueAtCell(RowNo, 7), IntegrationPurchase."Excel File Name");
                        end;

                        IntegrationPurchase.Type := IntegrationPurchase.Type::Item;

                        if (StrLen(GetValueAtCell(RowNo, 9)) <= 20) then
                            Evaluate(IntegrationPurchase."Item No.", GetValueAtCell(RowNo, 9))
                        else begin
                            IntegrationPurchase.Status := IntegrationPurchase.Status::"Data Excel Error";
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Purchase Order",
                              IntegrationPurchase."document No.", IntegrationPurchase."Line No.", CopyStr(IntegrationPurchase.FieldCaption("Item No."), 1, 50),
                              'Maximum 20 characters', GetValueAtCell(RowNo, 9), IntegrationPurchase."Excel File Name");
                        end;

                        if (StrLen(GetValueAtCell(RowNo, 12)) <= 100) then
                            Evaluate(IntegrationPurchase.Description, GetValueAtCell(RowNo, 12))
                        else begin
                            IntegrationPurchase.Status := IntegrationPurchase.Status::"Data Excel Error";
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Purchase Order",
                              IntegrationPurchase."Document No.", IntegrationPurchase."Line No.", CopyStr(IntegrationPurchase.FieldCaption(Description), 1, 50),
                              'Maximum 100 characters', GetValueAtCell(RowNo, 12), IntegrationPurchase."Excel File Name");
                        end;

                        if ValidateDecimal(GetValueAtCell(RowNo, 13)) then
                            IntegrationPurchase.Quantity := GlobalDecimalYes
                        else begin
                            IntegrationPurchase.Status := IntegrationPurchase.Status::"Data Excel Error";
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Purchase Order",
                            IntegrationPurchase."document No.", IntegrationPurchase."Line No.", CopyStr(IntegrationPurchase.FieldCaption(Quantity), 1, 50),
                            CopyStr(GetLastErrorText(), 1, 250), GetValueAtCell(RowNo, 13), IntegrationPurchase."Excel File Name");

                        end;

                        if ValidateDecimal(GetValueAtCell(RowNo, 14)) then begin

                            if GlobalDecimalYes <> 0 then
                                IntegrationPurchase."Direct Unit Cost Excl. Vat" := GlobalDecimalYes
                            else begin
                                IntegrationPurchase.Status := IntegrationPurchase.Status::"Data Excel Error";
                                IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Purchase Order",
                                IntegrationPurchase."Document No.", IntegrationPurchase."Line No.", CopyStr(IntegrationPurchase.FieldCaption("Direct Unit Cost Excl. Vat"), 1, 50),
                                CopyStr('Não pode Valor Zera', 1, 250), GetValueAtCell(RowNo, 14), IntegrationPurchase."Excel File Name");

                            end;

                        end else begin
                            IntegrationPurchase.Status := IntegrationPurchase.Status::"Data Excel Error";
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Purchase Order",
                            IntegrationPurchase."Document No.", IntegrationPurchase."Line No.", CopyStr(IntegrationPurchase.FieldCaption("Direct Unit Cost Excl. Vat"), 1, 50),
                            CopyStr(GetLastErrorText(), 1, 250), GetValueAtCell(RowNo, 14), IntegrationPurchase."Excel File Name");

                        end;
                        if (StrLen(GetValueAtCell(RowNo, 15)) <= 20) then
                            Evaluate(IntegrationPurchase."Shortcut Dimension 1 Code", GetValueAtCell(RowNo, 15))
                        else begin
                            IntegrationPurchase.Status := IntegrationPurchase.Status::"Data Excel Error";
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Purchase Order",
                              IntegrationPurchase."Document No.", IntegrationPurchase."Line No.", CopyStr(IntegrationPurchase.FieldCaption("Shortcut Dimension 1 Code"), 1, 50),
                              'Maximum 20 characters', GetValueAtCell(RowNo, 15), IntegrationPurchase."Excel File Name");
                        end;

                        if (StrLen(GetValueAtCell(RowNo, 16)) <= 20) then
                            Evaluate(IntegrationPurchase."Shortcut Dimension 2 Code", GetValueAtCell(RowNo, 16))
                        else begin
                            IntegrationPurchase.Status := IntegrationPurchase.Status::"Data Excel Error";
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Purchase Order",
                              IntegrationPurchase."Document No.", IntegrationPurchase."Line No.", CopyStr(IntegrationPurchase.FieldCaption("Shortcut Dimension 2 Code"), 1, 50),
                              'Maximum 20 characters', GetValueAtCell(RowNo, 16), IntegrationPurchase."Excel File Name");
                        end;

                        if (StrLen(GetValueAtCell(RowNo, 17)) <= 20) then
                            Evaluate(IntegrationPurchase."Shortcut Dimension 3 Code", GetValueAtCell(RowNo, 17))
                        else begin
                            IntegrationPurchase.Status := IntegrationPurchase.Status::"Data Excel Error";
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Purchase Order",
                              IntegrationPurchase."Document No.", IntegrationPurchase."Line No.", CopyStr(IntegrationPurchase.FieldCaption("Shortcut Dimension 3 Code"), 1, 50),
                              'Maximum 20 characters', GetValueAtCell(RowNo, 17), IntegrationPurchase."Excel File Name");
                        end;

                        if (StrLen(GetValueAtCell(RowNo, 18)) <= 20) then
                            Evaluate(IntegrationPurchase."Shortcut Dimension 4 Code", GetValueAtCell(RowNo, 18))
                        else begin
                            IntegrationPurchase.Status := IntegrationPurchase.Status::"Data Excel Error";
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Purchase Order",
                              IntegrationPurchase."Document No.", IntegrationPurchase."Line No.", CopyStr(IntegrationPurchase.FieldCaption("Shortcut Dimension 4 Code"), 1, 50),
                              'Maximum 20 characters', GetValueAtCell(RowNo, 18), IntegrationPurchase."Excel File Name");
                        end;

                        if (StrLen(GetValueAtCell(RowNo, 19)) <= 20) then
                            Evaluate(IntegrationPurchase."Shortcut Dimension 5 Code", GetValueAtCell(RowNo, 19))
                        else begin
                            IntegrationPurchase.Status := IntegrationPurchase.Status::"Data Excel Error";
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Purchase Order",
                              IntegrationPurchase."Document No.", IntegrationPurchase."Line No.", CopyStr(IntegrationPurchase.FieldCaption("Shortcut Dimension 5 Code"), 1, 50),
                              'Maximum 20 characters', GetValueAtCell(RowNo, 19), IntegrationPurchase."Excel File Name");
                        end;

                        if (StrLen(GetValueAtCell(RowNo, 20)) <= 20) then
                            Evaluate(IntegrationPurchase."Shortcut Dimension 6 Code", GetValueAtCell(RowNo, 20))
                        else begin
                            IntegrationPurchase.Status := IntegrationPurchase.Status::"Data Excel Error";
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Purchase Order",
                              IntegrationPurchase."Document No.", IntegrationPurchase."Line No.", CopyStr(IntegrationPurchase.FieldCaption("Shortcut Dimension 6 Code"), 1, 50),
                              'Maximum 20 characters', GetValueAtCell(RowNo, 20), IntegrationPurchase."Excel File Name");
                        end;

                        if (StrLen(GetValueAtCell(RowNo, 21)) <= 20) then
                            Evaluate(IntegrationPurchase."G/L Account", GetValueAtCell(RowNo, 21))
                        else begin
                            IntegrationPurchase.Status := IntegrationPurchase.Status::"Data Excel Error";
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Purchase Order",
                              IntegrationPurchase."document No.", IntegrationPurchase."Line No.", CopyStr(IntegrationPurchase.FieldCaption("G/L Account"), 1, 50),
                              'Maximum 20 characters', GetValueAtCell(RowNo, 21), IntegrationPurchase."Excel File Name");
                        end;

                        if (StrLen(GetValueAtCell(RowNo, 22)) <= 20) then
                            Evaluate(IntegrationPurchase."Tax Area Code", GetValueAtCell(RowNo, 22))
                        else begin
                            IntegrationPurchase.Status := IntegrationPurchase.Status::"Data Excel Error";
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Purchase Order",
                              IntegrationPurchase."document No.", IntegrationPurchase."Line No.", CopyStr(IntegrationPurchase.FieldCaption("Tax Area Code"), 1, 50),
                              'Maximum 20 characters', GetValueAtCell(RowNo, 22), IntegrationPurchase."Excel File Name");
                        end;

                        if (StrLen(GetValueAtCell(RowNo, 24)) <= 20) then
                            Evaluate(IntegrationPurchase."Vendor Invoice No.", GetValueAtCell(RowNo, 24))
                        else begin
                            IntegrationPurchase.Status := IntegrationPurchase.Status::"Data Excel Error";
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Purchase Order",
                              IntegrationPurchase."document No.", IntegrationPurchase."Line No.", CopyStr(IntegrationPurchase.FieldCaption("Vendor Invoice No."), 1, 50),
                              'Maximum 20 characters', GetValueAtCell(RowNo, 24), IntegrationPurchase."Excel File Name");
                        end;

                        //IRRF Ret
                        if ValidateDecimal(GetValueAtCell(RowNo, 25)) then
                            IntegrationPurchase."IRRF Ret" := GlobalDecimalYes
                        else
                            if (GetValueAtCell(RowNo, 25) <> '') then begin
                                IntegrationPurchase.Status := IntegrationPurchase.Status::"Data Excel Error";
                                IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Purchase Order",
                                IntegrationPurchase."Document No.", IntegrationPurchase."Line No.", CopyStr(IntegrationPurchase.FieldCaption("IRRF Ret"), 1, 50),
                                CopyStr(GetLastErrorText(), 1, 250), GetValueAtCell(RowNo, 25), IntegrationPurchase."Excel File Name");
                            end;

                        if ValidateDecimal(GetValueAtCell(RowNo, 26)) then
                            IntegrationPurchase."CSRF Ret" := GlobalDecimalYes
                        else
                            if (GetValueAtCell(RowNo, 26) <> '') then begin
                                IntegrationPurchase.Status := IntegrationPurchase.Status::"Data Excel Error";
                                IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Purchase Order",
                                IntegrationPurchase."Document No.", IntegrationPurchase."Line No.", CopyStr(IntegrationPurchase.FieldCaption("CSRF Ret"), 1, 50),
                                CopyStr(GetLastErrorText(), 1, 250), GetValueAtCell(RowNo, 26), IntegrationPurchase."Excel File Name");
                            end;

                        if ValidateDecimal(GetValueAtCell(RowNo, 27)) then
                            IntegrationPurchase."INSS Ret" := GlobalDecimalYes
                        else
                            if (GetValueAtCell(RowNo, 27) <> '') then begin
                                IntegrationPurchase.Status := IntegrationPurchase.Status::"Data Excel Error";
                                IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Purchase Order",
                                IntegrationPurchase."Document No.", IntegrationPurchase."Line No.", CopyStr(IntegrationPurchase.FieldCaption("INSS Ret"), 1, 50),
                                CopyStr(GetLastErrorText(), 1, 250), GetValueAtCell(RowNo, 27), IntegrationPurchase."Excel File Name");
                            end;

                        if ValidateDecimal(GetValueAtCell(RowNo, 28)) then
                            IntegrationPurchase."ISS Ret" := GlobalDecimalYes
                        else
                            if (GetValueAtCell(RowNo, 28) <> '') then begin
                                IntegrationPurchase.Status := IntegrationPurchase.Status::"Data Excel Error";
                                IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Purchase Order",
                                IntegrationPurchase."Document No.", IntegrationPurchase."Line No.", CopyStr(IntegrationPurchase.FieldCaption("ISS Ret"), 1, 50),
                                CopyStr(GetLastErrorText(), 1, 250), GetValueAtCell(RowNo, 28), IntegrationPurchase."Excel File Name");
                            end;

                        if ValidateDecimal(GetValueAtCell(RowNo, 29)) then
                            IntegrationPurchase."PIS Credit" := GlobalDecimalYes
                        else
                            if (GetValueAtCell(RowNo, 29) <> '') then begin
                                IntegrationPurchase.Status := IntegrationPurchase.Status::"Data Excel Error";
                                IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Purchase Order",
                                IntegrationPurchase."Document No.", IntegrationPurchase."Line No.", CopyStr(IntegrationPurchase.FieldCaption("PIS Credit"), 1, 50),
                                CopyStr(GetLastErrorText(), 1, 250), GetValueAtCell(RowNo, 29), IntegrationPurchase."Excel File Name");
                            end;

                        if ValidateDecimal(GetValueAtCell(RowNo, 30)) then
                            IntegrationPurchase."Cofins Credit" := GlobalDecimalYes
                        else
                            if (GetValueAtCell(RowNo, 30) <> '') then begin
                                IntegrationPurchase.Status := IntegrationPurchase.Status::"Data Excel Error";
                                IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Purchase Order",
                                IntegrationPurchase."Document No.", IntegrationPurchase."Line No.", CopyStr(IntegrationPurchase.FieldCaption("Cofins Credit"), 1, 50),
                                CopyStr(GetLastErrorText(), 1, 250), GetValueAtCell(RowNo, 30), IntegrationPurchase."Excel File Name");
                            end;

                        if ValidateDecimal(GetValueAtCell(RowNo, 31)) then
                            IntegrationPurchase.DIRF := GlobalDecimalYes
                        else
                            if (GetValueAtCell(RowNo, 31) <> '') then begin
                                IntegrationPurchase.Status := IntegrationPurchase.Status::"Data Excel Error";
                                IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Purchase Order",
                                IntegrationPurchase."Document No.", IntegrationPurchase."Line No.", CopyStr(IntegrationPurchase.FieldCaption(DIRF), 1, 50),
                                CopyStr(GetLastErrorText(), 1, 250), GetValueAtCell(RowNo, 31), IntegrationPurchase."Excel File Name");
                            end;

                        if ValidateDecimal(GetValueAtCell(RowNo, 32)) then
                            IntegrationPurchase."PO Total" := GlobalDecimalYes
                        else
                            if (GetValueAtCell(RowNo, 32) <> '') then begin
                                IntegrationPurchase.Status := IntegrationPurchase.Status::"Data Excel Error";
                                IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Purchase Order",
                                IntegrationPurchase."Document No.", IntegrationPurchase."Line No.", CopyStr(IntegrationPurchase.FieldCaption("PO Total"), 1, 50),
                                CopyStr(GetLastErrorText(), 1, 250), GetValueAtCell(RowNo, 32), IntegrationPurchase."Excel File Name");
                            end;

                        if (StrLen(GetValueAtCell(RowNo, 33)) <= MaxStrLen(CADBRMunicipio.City)) then
                            Evaluate(IntegrationPurchase."Local Service Provision", GetValueAtCell(RowNo, 33))
                        else begin
                            IntegrationPurchase.Status := IntegrationPurchase.Status::"Data Excel Error";
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Purchase Order",
                              IntegrationPurchase."document No.", IntegrationPurchase."Line No.", CopyStr(IntegrationPurchase.FieldCaption("Local Service Provision"), 1, 50),
                              'Maximum 20 characters', GetValueAtCell(RowNo, 33), IntegrationPurchase."Excel File Name");
                        end;

                        if (StrLen(GetValueAtCell(RowNo, 34)) <= 20) then
                            Evaluate(IntegrationPurchase."Post Code", GetValueAtCell(RowNo, 34))
                        else begin
                            IntegrationPurchase.Status := IntegrationPurchase.Status::"Data Excel Error";
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Purchase Order",
                              IntegrationPurchase."document No.", IntegrationPurchase."Line No.", CopyStr(IntegrationPurchase.FieldCaption("Post Code"), 1, 50),
                              'Maximum 20 characters', GetValueAtCell(RowNo, 34), IntegrationPurchase."Excel File Name");
                        end;

                        if (StrLen(GetValueAtCell(RowNo, 35)) <= 10) then
                            Evaluate(IntegrationPurchase."Fiscal Document Type", GetValueAtCell(RowNo, 35))
                        else begin
                            IntegrationPurchase.Status := IntegrationPurchase.Status::"Data Excel Error";
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Purchase Order",
                              IntegrationPurchase."document No.", IntegrationPurchase."Line No.", CopyStr(IntegrationPurchase.FieldCaption("Fiscal Document Type"), 1, 50),
                              'Maximum 10 characters', GetValueAtCell(RowNo, 35), IntegrationPurchase."Excel File Name");
                        end;

                        if (StrLen(GetValueAtCell(RowNo, 36)) <= 20) then
                            Evaluate(IntegrationPurchase."Service Code", GetValueAtCell(RowNo, 36))
                        else begin
                            IntegrationPurchase.Status := IntegrationPurchase.Status::"Data Excel Error";
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Purchase Order",
                              IntegrationPurchase."document No.", IntegrationPurchase."Line No.", CopyStr(IntegrationPurchase.FieldCaption("Service Code"), 1, 50),
                              'Maximum 20 characters', GetValueAtCell(RowNo, 36), IntegrationPurchase."Excel File Name");
                        end;

                        if ValidateDate(GetValueAtCell(RowNo, 37)) then begin
                            IntegrationPurchase."Posting Date" := GlobalDateYes;
                            if IntegrationPurchase."Posting Date" = 0D then begin
                                IntegrationPurchase.Status := IntegrationPurchase.Status::"Data Excel Error";
                                IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Purchase Order",
                                IntegrationPurchase."document No.", IntegrationPurchase."Line No.", CopyStr(IntegrationPurchase.FieldCaption("Posting Date"), 1, 50),
                                CopyStr(PostingDateEmptyErr, 1, 250), GetValueAtCell(RowNo, 37), IntegrationPurchase."Excel File Name");
                            end
                        end

                        else begin
                            IntegrationPurchase.Status := IntegrationPurchase.Status::"Data Excel Error";
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Purchase Order",
                            IntegrationPurchase."document No.", IntegrationPurchase."Line No.", CopyStr(IntegrationPurchase.FieldCaption("Posting Date"), 1, 50),
                            CopyStr(GetLastErrorText(), 1, 250), GetValueAtCell(RowNo, 3), IntegrationPurchase."Excel File Name");
                        end;

                        //aqui Validação
                        IntPurcOld.Reset();
                        IntPurcOld.SetCurrentKey("Document No.", "Order Date");
                        IntPurcOld.SetRange("Document No.", IntegrationPurchase."Document No.");
                        //IntPurcOld.SetFilter("Order Date", '<>%1', IntegrationPurchase."Order Date");
                        IntPurcOld.SetFilter("Excel File Name", '<>%1', IntegrationPurchase."Excel File Name");
                        if IntPurcOld.FindFirst() then begin

                            IntegrationPurchase.Status := IntegrationPurchase.Status::"Data Excel Error";
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Purchase Order",
                            IntegrationPurchase."document No.", IntegrationPurchase."Line No.", CopyStr(IntegrationPurchase.FieldCaption("Document No."), 1, 50),
                            CopyStr('Nº Documento deste registro está igual a um já existente no sistema', 1, 250), GetValueAtCell(RowNo, 3), IntegrationPurchase."Excel File Name");

                        end;

                        if ExistLine then
                            IntegrationPurchase.Modify()
                        else
                            if IntegrationPurchase.Insert() then;

                        if IntegrationPurchase.Status = IntegrationPurchase.Status::"Data Excel Error" then
                            ErrorFile := true;
                    end;


                if ErrorFile then
                    FTPCommunication.DoAction(Enum::"FTP Actions"::rename, FileName, FTPIntSetup.Directory, FTPIntSetup."Error Folder", '')
                else
                    FTPCommunication.DoAction(Enum::"FTP Actions"::rename, FileName, FTPIntSetup.Directory, FTPIntSetup."Imported Folder", '');

            until FTPDir.Next() = 0;

        Commit();

    end;

    procedure ExportExcelPurchaseTax()
    var
        IntPurchase: Record "Integration Purchase";
        FTPIntSetup: Record "FTP Integration Setup";
        OutStr: OutStream;
        InSTR: InStream;
        FTPCommunication: codeunit "FTP Communication";
        Base64: codeunit "Base64 Convert";
        TempBlob: codeunit "Temp Blob";
        FileBase64: Text;
        PathToFile: Text;
        Filename: Text;
        DocumentOld: Code[20];
    begin

        TempExcelBuffer.Reset();
        TempExcelBuffer.DeleteAll();

        IntPurchase.Reset();
        IntPurchase.SetFilter(Status, '%1', IntPurchase.Status::Created);
        IntPurchase.SetRange("Status PO", IntPurchase."Status PO"::Released);
        if IntPurchase.FindSet() then begin

            Filename := format(FTPIntSetup.Integration::"Purchase Tax Validation") + DelChr(Format(Today) + Format(Time), '=', '/:');

            TempExcelBuffer.NewRow();
            TempExcelBuffer.AddColumn('Document Type', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
            TempExcelBuffer.AddColumn(IntPurchase.FieldCaption("Document No."), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
            TempExcelBuffer.AddColumn('Vendor Id', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
            TempExcelBuffer.AddColumn(IntPurchase.FieldCaption("Order IRRF Ret"), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
            TempExcelBuffer.AddColumn(IntPurchase.FieldCaption("Order CSRF Ret"), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
            TempExcelBuffer.AddColumn(IntPurchase.FieldCaption("Order INSS Ret"), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
            TempExcelBuffer.AddColumn(IntPurchase.FieldCaption("Order ISS Ret"), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
            TempExcelBuffer.AddColumn(IntPurchase.FieldCaption("Order PIS Credit"), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
            TempExcelBuffer.AddColumn(IntPurchase.FieldCaption("Order Cofins Credit"), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
            TempExcelBuffer.AddColumn(IntPurchase.FieldCaption("Order DIRF Ret"), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
            TempExcelBuffer.AddColumn(IntPurchase.FieldCaption(Rejected), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
            TempExcelBuffer.AddColumn(IntPurchase.FieldCaption(Status), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
            TempExcelBuffer.AddColumn(IntPurchase.FieldCaption("Posting Message"), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
            TempExcelBuffer.AddColumn(IntPurchase.FieldCaption("Reason Code"), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
            DocumentOld := '999cvgt67vv';

            repeat

                if DocumentOld <> IntPurchase."Document No." then begin
                    TempExcelBuffer.NewRow();
                    TempExcelBuffer.AddColumn('Order', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                    TempExcelBuffer.AddColumn(IntPurchase."Document No.", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                    TempExcelBuffer.AddColumn(IntPurchase."Buy-from Vendor No.", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                    TempExcelBuffer.AddColumn(IntPurchase."Order IRRF Ret", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);
                    TempExcelBuffer.AddColumn(IntPurchase."Order CSRF Ret", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);
                    TempExcelBuffer.AddColumn(IntPurchase."Order INSS Ret", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);
                    TempExcelBuffer.AddColumn(IntPurchase."Order ISS Ret", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);
                    TempExcelBuffer.AddColumn(IntPurchase."Order PIS Credit", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);
                    TempExcelBuffer.AddColumn(IntPurchase."Order Cofins Credit", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);
                    TempExcelBuffer.AddColumn(IntPurchase."Order DIRF Ret", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);
                    TempExcelBuffer.AddColumn(IntPurchase.Rejected, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                    TempExcelBuffer.AddColumn(IntPurchase.Status, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                    TempExcelBuffer.AddColumn(IntPurchase."Posting Message", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                    TempExcelBuffer.AddColumn(IntPurchase."Reason Description", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                end;

                IntPurchase.Status := IntPurchase.Status::Exported;
                IntPurchase."Exported Excel Purch. Tax Name" := Filename;
                IntPurchase.Modify();

                DocumentOld := IntPurchase."Document No.";

            until IntPurchase.Next() = 0;

            TempExcelBuffer.CreateNewBook(IntPurchase.TableCaption);
            TempExcelBuffer.WriteSheet(IntPurchase.TableCaption, CompanyName, UserId);
            TempExcelBuffer.CloseBook();

            //TempExcelBuffer.SetFriendlyFilename(IntPurchase.TableCaption);
            //TempExcelBuffer.OpenExcel();

            TempBlob.CreateOutStream(OutStr);
            TempExcelBuffer.SaveToStream(OutStr, true);

            TempBlob.CreateInStream(InSTR);

            FileBase64 := Base64.ToBase64(InSTR);
            //FTPIntSetup.Get(FTPIntSetup.Integration::"Purchase Tax Validation");
            FTPIntSetup.Reset();
            FTPIntSetup.SetRange(Integration, FTPIntSetup.Integration::"Purchase Tax Validation");
            FTPIntSetup.SetRange(Sequence, 0);
            FTPIntSetup.FindSet();
            FTPCommunication.DoAction(Enum::"FTP Actions"::upload, IntPurchase."Exported Excel Purch. Tax Name" + '.xlsx', FTPIntSetup.Directory, '', FileBase64);
            Message('Uploaded');
        end;
    end;

    procedure ImportExcelPurchasePost()
    var
        IntegrationPurchase: Record "Integration Purchase";
        IPSaveRejected: Record "Integration Purchase";
        IntegrationErros: Record IntegrationErros;
        FTPIntSetup: Record "FTP Integration Setup";
        FTPDir: Record "FTP Directory";
        PurcHeader: Record "Purchase Header";
        OutStr: OutStream;
        InSTR: InStream;
        FTPCommunication: codeunit "FTP Communication";
        Base64: codeunit "Base64 Convert";
        TempBlob: codeunit "Temp Blob";
        FileBase64: Text;
        PathToFile: Text;
        ret: Text;
        lines: List of [Text];
        line: Text;
        FileName: Text;
        EntryNo: BigInteger;
        RowNo: Integer;
        ColNo: Integer;
        LineNo: Integer;
        MaxRowNo: Integer;
        CRLF: Char;
        ErrorFile: Boolean;
        ExistLine: Boolean;
        MaxCollumn: Integer;
        DocNoValue: Text;
        RejectValue: Boolean;
    begin

        RowNo := 0;
        ColNo := 0;
        MaxRowNo := 0;
        LineNo := 0;
        MaxCollumn := 0;
        ExistLine := false;

        //FTPIntSetup.Get(FTPIntSetup.Integration::"Purchase Posting");
        FTPIntSetup.Reset();
        FTPIntSetup.SetRange(Integration, FTPIntSetup.Integration::"Purchase Posting");
        FTPIntSetup.SetRange(Sequence, 0);
        FTPIntSetup.FindSet();

        CRLF := 10;

        ret := FTPCommunication.DoAction(Enum::"FTP Actions"::list, '', FTPIntSetup.Directory, '', '');
        lines := ret.Split(CRLF);

        FTPDir.Reset();
        FTPDir.DeleteAll();
        foreach line in lines do
            if line <> '' then begin
                FTPDir.Init();
                FTPDir.Filename := line;
                FTPDir.IsDirectory := (StrPos(line, '.') = 0);
                FTPDir.Insert();
            end;

        FTPDir.Reset();
        FTPDir.SetRange(IsDirectory, false);
        if FTPDir.Find('-') then
            repeat
                Clear(FTPCommunication);

                FileName := FTPDir.Filename.Trim();

                if FTPIntSetup."Active Prefix File Name" then begin
                    FTPIntSetup.testfield("Prefix File Name");
                    if StrPos(FileName, FTPIntSetup."Prefix File Name") = 0 then
                        Error('File Name Not Valid');
                end;

                EntryNo := FTPCommunication.DoAction(Enum::"FTP Actions"::download, FileName, FTPIntSetup.Directory, '', '');
                ReadExcelSheet(EntryNo);

                IntegrationPurchase.Reset();
                if IntegrationPurchase.FindLast() then
                    LineNo := IntegrationPurchase."Line No.";

                TempExcelBuffer.Reset();
                if TempExcelBuffer.FindLast() then
                    MaxRowNo := TempExcelBuffer."Row No.";
                //Column START Error
                if TempExcelBuffer.FindLast() then
                    MaxCollumn := TempExcelBuffer."Column No.";

                if MaxCollumn <> 3 then begin

                    IntegrationPurchase.Init();
                    IntegrationPurchase."Document No." := DelChr(Format((Today)) + format(Time), '=', ':/');
                    IntegrationPurchase.Status := IntegrationPurchase.Status::"Layout Error";
                    IntegrationPurchase."Purch Post Excel File Name" := copystr(Filename, 1, 200);
                    IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Purchase Order",
                      IntegrationPurchase."Document No.", IntegrationPurchase."Line No.", CopyStr('', 1, 50),
                      'Layout Error', GetValueAtCell(RowNo, 2), IntegrationPurchase."Excel File Name");

                    if IntegrationPurchase.Insert() then
                        ErrorFile := true;
                end else
                    //Column END Error
                for RowNo := 2 to MaxRowNo do begin
                        LineNo := LineNo + 10000;

                        DocNoValue := '';
                        DocNoValue := GetValueAtCell(RowNo, 1);
                        DocNoValue := DocNoValue.Trim();

                        if (StrLen(DocNoValue) <= 20) then begin

                            IPSaveRejected.Reset();
                            IPSaveRejected.SetRange("Document No.", DocNoValue);
                            if not IPSaveRejected.IsEmpty then begin
                                IPSaveRejected.FindSet();
                                repeat

                                    if GlobalLanguage = 1046 then
                                        Evaluate(IPSaveRejected.Rejected, GetValueAtCell(RowNo, 2))
                                    else
                                        if GetValueAtCell(RowNo, 2) = 'Não' then
                                            IPSaveRejected.Rejected := false
                                        else
                                            IPSaveRejected.Rejected := true;

                                    IPSaveRejected."Release to Post" := not IPSaveRejected.Rejected;
                                    IPSaveRejected."Purch Post Excel File Name" := copystr(Filename, 1, 200);

                                    if ValidateDate(GetValueAtCell(RowNo, 3)) then
                                        IPSaveRejected."Posting Date" := GlobalDateYes;

                                    IPSaveRejected.Modify();

                                    //Update Purchase
                                    PurcHeader.Reset();
                                    PurcHeader.SetRange("No.", IPSaveRejected."Document No.");
                                    if PurcHeader.Find('-') then
                                        repeat
                                            PurcHeader."Posting Date" := IPSaveRejected."Posting Date";
                                            PurcHeader.Modify();

                                        until PurcHeader.Next() = 0;


                                until IPSaveRejected.Next() = 0;
                            end;
                        end;
                    end;
                if ErrorFile then
                    FTPCommunication.DoAction(Enum::"FTP Actions"::rename, FileName, FTPIntSetup.Directory, FTPIntSetup."Error Folder", '')
                else
                    FTPCommunication.DoAction(Enum::"FTP Actions"::rename, FileName, FTPIntSetup.Directory, FTPIntSetup."Imported Folder", '');

            until FTPDir.Next() = 0;



    end;

    procedure ImportExcelPurchaseReturn()
    var
        IntPurchReturn: Record "Integration Purchase Return";
        IntegrationErros: Record IntegrationErros;
        FTPIntSetup: Record "FTP Integration Setup";
        FTPDir: Record "FTP Directory";
        FTPCommunication: codeunit "FTP Communication";
        ret: Text;
        lines: List of [Text];
        line: Text;
        FileName: Text;
        EntryNo: BigInteger;
        RowNo: Integer;
        ColNo: Integer;
        LineNo: Integer;
        MaxRowNo: Integer;
        CRLF: Char;
        ErrorFile: Boolean;
        ExistLine: Boolean;
        MaxCollumn: Integer;

    begin
        RowNo := 0;
        ColNo := 0;
        MaxRowNo := 0;
        LineNo := 0;

        //FTPIntSetup.Get(FTPIntSetup.Integration::"Purchase Credit Note");
        FTPIntSetup.Reset();
        FTPIntSetup.SetRange(Integration, FTPIntSetup.Integration::"Purchase Credit Note");
        FTPIntSetup.SetRange(Sequence, 0);
        FTPIntSetup.FindSet();

        CRLF := 10;

        ret := FTPCommunication.DoAction(Enum::"FTP Actions"::list, '', FTPIntSetup.Directory, '', '');
        lines := ret.Split(CRLF);

        FTPDir.Reset();
        FTPDir.DeleteAll();
        foreach line in lines do
            if line <> '' then begin
                FTPDir.Init();
                FTPDir.Filename := line;
                FTPDir.IsDirectory := (StrPos(line, '.') = 0);
                FTPDir.Insert();
            end;

        FTPDir.Reset();
        FTPDir.SetRange(IsDirectory, false);
        if FTPDir.Find('-') then
            repeat
                Clear(FTPCommunication);

                FileName := FTPDir.Filename.Trim();

                if FTPIntSetup."Active Prefix File Name" then begin
                    FTPIntSetup.testfield("Prefix File Name");
                    if StrPos(FileName, FTPIntSetup."Prefix File Name") = 0 then
                        Error('File Name Not Valid');
                end;

                EntryNo := FTPCommunication.DoAction(Enum::"FTP Actions"::download, FileName, FTPIntSetup.Directory, '', '');
                ReadExcelSheet(EntryNo);

                IntPurchReturn.Reset();
                if IntPurchReturn.FindLast() then
                    LineNo := IntPurchReturn."Line No.";

                TempExcelBuffer.Reset();
                if TempExcelBuffer.FindLast() then
                    MaxRowNo := TempExcelBuffer."Row No.";

                //Column START Error
                if TempExcelBuffer.FindLast() then
                    MaxCollumn := TempExcelBuffer."Column No.";

                if MaxCollumn <> 33 then begin
                    IntPurchReturn.Init();
                    IntPurchReturn."Document No." := format(Today) + format(Time);
                    IntPurchReturn.Status := IntPurchReturn.Status::"Layout Error";
                    IntPurchReturn."Excel File Name" := copystr(Filename, 1, 200);
                    IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Purchase Return Order",
                      IntPurchReturn."Document No.", IntPurchReturn."Line No.", CopyStr('', 1, 50),
                      'Layout Error', GetValueAtCell(RowNo, 2), IntPurchReturn."Excel File Name");

                    if IntPurchReturn.Insert() then
                        ErrorFile := true;
                end else
                    //Column END Error

                for RowNo := 2 to MaxRowNo do begin
                        LineNo := LineNo + 10000;
                        ExistLine := false;

                        if (StrLen(GetValueAtCell(RowNo, 2)) <= 20) and (GetValueAtCell(RowNo, 2) <> '') then begin

                            if GetValueAtCell(RowNo, 6) = '' then begin

                                IntPurchReturn.Init();
                                Evaluate(IntPurchReturn."document No.", 'LineNoErrors-' + format(RowNo));
                                //Evaluate(IntPurchReturn."Line No.", GetValueAtCell(RowNo, 6));
                                IntPurchReturn.Status := IntPurchReturn.Status::"Data Excel Error";
                                IntPurchReturn."Excel File Name" := copystr(Filename, 1, 200);

                                IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Purchase Return Order",
                                IntPurchReturn."document No.", IntPurchReturn."Line No.", CopyStr(IntPurchReturn.FieldCaption("Line No."), 1, 50),
                                CopyStr('N. Linha não pode ser 0', 1, 250), GetValueAtCell(RowNo, 6), IntPurchReturn."Excel File Name");

                            end else

                                if (IntPurchReturn.Get(GetValueAtCell(RowNo, 2), GetValueAtCell(RowNo, 6))) then begin
                                    //Not Modify Posted Line
                                    if IntPurchReturn.Status = IntPurchReturn.Status::Posted then begin
                                        ExistLine := false;
                                        IntPurchReturn."Posting Message" := 'Duplicate ' + copystr(Filename, 1, 180);
                                        IntPurchReturn.Modify();
                                    end else
                                        ExistLine := true;

                                    //Delete Errors
                                    IntegrationErros.Reset();
                                    IntegrationErros.Setrange("Document No.", IntPurchReturn."Document No.");
                                    if IntegrationErros.FindSet() then
                                        repeat
                                            IntegrationErros.DeleteAll();
                                        until IntegrationErros.Next() = 0;

                                end else begin
                                    IntPurchReturn.Init();
                                    IntPurchReturn.Status := IntPurchReturn.Status::Imported;
                                    Evaluate(IntPurchReturn."document No.", GetValueAtCell(RowNo, 2));
                                    Evaluate(IntPurchReturn."Line No.", GetValueAtCell(RowNo, 6));
                                    IntPurchReturn."Excel File Name" := copystr(Filename, 1, 200);
                                end;

                        end else begin

                            IntPurchReturn.Init();
                            Evaluate(IntPurchReturn."document No.", 'Errors-' + format(RowNo));
                            Evaluate(IntPurchReturn."Line No.", GetValueAtCell(RowNo, 6));
                            IntPurchReturn.Status := IntPurchReturn.Status::"Data Excel Error";
                            IntPurchReturn."Excel File Name" := copystr(Filename, 1, 200);

                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Purchase Return Order",
                            IntPurchReturn."document No.", IntPurchReturn."Line No.", CopyStr(IntPurchReturn.FieldCaption("Document No."), 1, 50),
                            'Maximum 20 characters', GetValueAtCell(RowNo, 2), IntPurchReturn."Excel File Name");
                        end;



                        if ValidateDate(GetValueAtCell(RowNo, 3)) and (GetValueAtCell(RowNo, 3) <> '') then
                            IntPurchReturn."Order Date" := GlobalDateYes
                        else begin
                            IntPurchReturn.Status := IntPurchReturn.Status::"Data Excel Error";
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Purchase Return Order",
                            IntPurchReturn."document No.", IntPurchReturn."Line No.", CopyStr(IntPurchReturn.FieldCaption("Order Date"), 1, 50),
                            CopyStr('Data Invalida', 1, 250), GetValueAtCell(RowNo, 3), IntPurchReturn."Excel File Name");

                        end;

                        if (StrLen(GetValueAtCell(RowNo, 4)) <= 100) then
                            Evaluate(IntPurchReturn."Additional Description", GetValueAtCell(RowNo, 4))
                        else begin
                            IntPurchReturn.Status := IntPurchReturn.Status::"Data Excel Error";
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Purchase Return Order",
                            IntPurchReturn."Document No.", IntPurchReturn."Line No.", CopyStr(IntPurchReturn.FieldCaption("Additional Description"), 1, 50),
                            'Maximum 100 characters', GetValueAtCell(RowNo, 4), IntPurchReturn."Excel File Name");
                        end;

                        if (StrLen(GetValueAtCell(RowNo, 5)) <= 250) then
                            Evaluate(IntPurchReturn."Doc. URL", GetValueAtCell(RowNo, 5))
                        else begin
                            IntPurchReturn.Status := IntPurchReturn.Status::"Data Excel Error";
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Purchase Return Order",
                            IntPurchReturn."Document No.", IntPurchReturn."Line No.", CopyStr(IntPurchReturn.FieldCaption("Doc. URL"), 1, 50),
                            'Maximum 250 characters', GetValueAtCell(RowNo, 5), IntPurchReturn."Excel File Name");
                        end;

                        if (StrLen(GetValueAtCell(RowNo, 7)) <= 20) and (GetValueAtCell(RowNo, 7) <> '') then
                            Evaluate(IntPurchReturn."Buy-from Vendor No.", GetValueAtCell(RowNo, 7))
                        else begin
                            IntPurchReturn.Status := IntPurchReturn.Status::"Data Excel Error";
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Purchase Return Order",
                            IntPurchReturn."document No.", IntPurchReturn."Line No.", CopyStr(IntPurchReturn.FieldCaption("Buy-from Vendor No."), 1, 50),
                            'Maximum 20 characters', GetValueAtCell(RowNo, 7), IntPurchReturn."Excel File Name");
                        end;

                        IntPurchReturn.Type := IntPurchReturn.Type::Item;

                        if (StrLen(GetValueAtCell(RowNo, 9)) <= 20) and (GetValueAtCell(RowNo, 9) <> '') then
                            Evaluate(IntPurchReturn."Item No.", GetValueAtCell(RowNo, 9))
                        else begin
                            IntPurchReturn.Status := IntPurchReturn.Status::"Data Excel Error";
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Purchase Return Order",
                            IntPurchReturn."document No.", IntPurchReturn."Line No.", CopyStr(IntPurchReturn.FieldCaption("Item No."), 1, 50),
                            'Maximum 20 characters', GetValueAtCell(RowNo, 9), IntPurchReturn."Excel File Name");
                        end;

                        if (StrLen(GetValueAtCell(RowNo, 12)) <= 100) then
                            Evaluate(IntPurchReturn.Description, GetValueAtCell(RowNo, 12))
                        else begin
                            IntPurchReturn.Status := IntPurchReturn.Status::"Data Excel Error";
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Purchase Return Order",
                            IntPurchReturn."Document No.", IntPurchReturn."Line No.", CopyStr(IntPurchReturn.FieldCaption(Description), 1, 50),
                            'Maximum 100 characters', GetValueAtCell(RowNo, 12), IntPurchReturn."Excel File Name");
                        end;

                        if ValidateDecimal(GetValueAtCell(RowNo, 13)) and (GetValueAtCell(RowNo, 13) <> '') then begin
                            IntPurchReturn.Quantity := GlobalDecimalYes;

                            if IntPurchReturn.Quantity = 0 then begin

                                IntPurchReturn.Status := IntPurchReturn.Status::"Data Excel Error";
                                IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Purchase Return Order",
                                IntPurchReturn."document No.", IntPurchReturn."Line No.", CopyStr(IntPurchReturn.FieldCaption(Quantity), 1, 50),
                                CopyStr('Quantidade deve ser maior que 0', 1, 250), GetValueAtCell(RowNo, 13), IntPurchReturn."Excel File Name");

                            end;

                        end else begin
                            IntPurchReturn.Status := IntPurchReturn.Status::"Data Excel Error";
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Purchase Return Order",
                            IntPurchReturn."document No.", IntPurchReturn."Line No.", CopyStr(IntPurchReturn.FieldCaption(Quantity), 1, 50),
                            CopyStr('Quantidade Invalida', 1, 250), GetValueAtCell(RowNo, 13), IntPurchReturn."Excel File Name");

                        end;

                        if ValidateDecimal(GetValueAtCell(RowNo, 14)) and (GetValueAtCell(RowNo, 14) <> '') then begin
                            IntPurchReturn."Direct Unit Cost Excl. Vat" := GlobalDecimalYes;

                            if IntPurchReturn."Direct Unit Cost Excl. Vat" = 0 then begin

                                IntPurchReturn.Status := IntPurchReturn.Status::"Data Excel Error";
                                IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Purchase Return Order",
                                IntPurchReturn."Document No.", IntPurchReturn."Line No.", CopyStr(IntPurchReturn.FieldCaption("Direct Unit Cost Excl. Vat"), 1, 50),
                                CopyStr('Valor de ser maior que 0', 1, 250), GetValueAtCell(RowNo, 14), IntPurchReturn."Excel File Name");

                            end;

                        end else begin
                            IntPurchReturn.Status := IntPurchReturn.Status::"Data Excel Error";
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Purchase Return Order",
                            IntPurchReturn."Document No.", IntPurchReturn."Line No.", CopyStr(IntPurchReturn.FieldCaption("Direct Unit Cost Excl. Vat"), 1, 50),
                            CopyStr('Valor Invalido', 1, 250), GetValueAtCell(RowNo, 14), IntPurchReturn."Excel File Name");

                        end;

                        if (StrLen(GetValueAtCell(RowNo, 15)) <= 20) then
                            Evaluate(IntPurchReturn."Shortcut Dimension 1 Code", GetValueAtCell(RowNo, 15))
                        else begin
                            IntPurchReturn.Status := IntPurchReturn.Status::"Data Excel Error";
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Purchase Return Order",
                            IntPurchReturn."Document No.", IntPurchReturn."Line No.", CopyStr(IntPurchReturn.FieldCaption("Shortcut Dimension 1 Code"), 1, 50),
                            'Maximum 20 characters', GetValueAtCell(RowNo, 15), IntPurchReturn."Excel File Name");
                        end;

                        if (StrLen(GetValueAtCell(RowNo, 16)) <= 20) then
                            Evaluate(IntPurchReturn."Shortcut Dimension 2 Code", GetValueAtCell(RowNo, 16))
                        else begin
                            IntPurchReturn.Status := IntPurchReturn.Status::"Data Excel Error";
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Purchase Return Order",
                            IntPurchReturn."Document No.", IntPurchReturn."Line No.", CopyStr(IntPurchReturn.FieldCaption("Shortcut Dimension 2 Code"), 1, 50),
                            'Maximum 20 characters', GetValueAtCell(RowNo, 16), IntPurchReturn."Excel File Name");
                        end;

                        if (StrLen(GetValueAtCell(RowNo, 17)) <= 20) then
                            Evaluate(IntPurchReturn."Shortcut Dimension 3 Code", GetValueAtCell(RowNo, 17))
                        else begin
                            IntPurchReturn.Status := IntPurchReturn.Status::"Data Excel Error";
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Purchase Return Order",
                            IntPurchReturn."Document No.", IntPurchReturn."Line No.", CopyStr(IntPurchReturn.FieldCaption("Shortcut Dimension 3 Code"), 1, 50),
                            'Maximum 20 characters', GetValueAtCell(RowNo, 17), IntPurchReturn."Excel File Name");
                        end;

                        if (StrLen(GetValueAtCell(RowNo, 18)) <= 20) then
                            Evaluate(IntPurchReturn."Shortcut Dimension 4 Code", GetValueAtCell(RowNo, 18))
                        else begin
                            IntPurchReturn.Status := IntPurchReturn.Status::"Data Excel Error";
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Purchase Return Order",
                            IntPurchReturn."Document No.", IntPurchReturn."Line No.", CopyStr(IntPurchReturn.FieldCaption("Shortcut Dimension 4 Code"), 1, 50),
                            'Maximum 20 characters', GetValueAtCell(RowNo, 18), IntPurchReturn."Excel File Name");
                        end;

                        if (StrLen(GetValueAtCell(RowNo, 19)) <= 20) then
                            Evaluate(IntPurchReturn."Shortcut Dimension 5 Code", GetValueAtCell(RowNo, 19))
                        else begin
                            IntPurchReturn.Status := IntPurchReturn.Status::"Data Excel Error";
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Purchase Return Order",
                            IntPurchReturn."Document No.", IntPurchReturn."Line No.", CopyStr(IntPurchReturn.FieldCaption("Shortcut Dimension 5 Code"), 1, 50),
                            'Maximum 20 characters', GetValueAtCell(RowNo, 19), IntPurchReturn."Excel File Name");
                        end;

                        if (StrLen(GetValueAtCell(RowNo, 20)) <= 20) and (GetValueAtCell(RowNo, 20) <> '') then
                            Evaluate(IntPurchReturn."Shortcut Dimension 6 Code", GetValueAtCell(RowNo, 20))
                        else begin
                            IntPurchReturn.Status := IntPurchReturn.Status::"Data Excel Error";
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Purchase Return Order",
                            IntPurchReturn."Document No.", IntPurchReturn."Line No.", CopyStr(IntPurchReturn.FieldCaption("Shortcut Dimension 6 Code"), 1, 50),
                            'Maximum 20 characters', GetValueAtCell(RowNo, 20), IntPurchReturn."Excel File Name");
                        end;

                        if (StrLen(GetValueAtCell(RowNo, 21)) <= 20) then
                            Evaluate(IntPurchReturn."G/L Account", GetValueAtCell(RowNo, 21))
                        else begin
                            IntPurchReturn.Status := IntPurchReturn.Status::"Data Excel Error";
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Purchase Return Order",
                            IntPurchReturn."document No.", IntPurchReturn."Line No.", CopyStr(IntPurchReturn.FieldCaption("G/L Account"), 1, 50),
                            'Maximum 20 characters', GetValueAtCell(RowNo, 21), IntPurchReturn."Excel File Name");
                        end;

                        if (StrLen(GetValueAtCell(RowNo, 24)) <= 20) and (GetValueAtCell(RowNo, 24) <> '') then
                            Evaluate(IntPurchReturn."Vendor Invoice No.", GetValueAtCell(RowNo, 24))
                        else begin
                            IntPurchReturn.Status := IntPurchReturn.Status::"Data Excel Error";
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Purchase Return Order",
                            IntPurchReturn."document No.", IntPurchReturn."Line No.", CopyStr(IntPurchReturn.FieldCaption("Vendor Invoice No."), 1, 50),
                            'Maximum 20 characters', GetValueAtCell(RowNo, 24), IntPurchReturn."Excel File Name");
                        end;

                        //IRRF Ret
                        if ValidateDecimal(GetValueAtCell(RowNo, 25)) then
                            IntPurchReturn."IRRF Ret" := GlobalDecimalYes
                        else
                            if (GetValueAtCell(RowNo, 25) <> '') then begin
                                IntPurchReturn.Status := IntPurchReturn.Status::"Data Excel Error";
                                IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Purchase Return Order",
                                IntPurchReturn."Document No.", IntPurchReturn."Line No.", CopyStr(IntPurchReturn.FieldCaption("IRRF Ret"), 1, 50),
                                CopyStr(GetLastErrorText(), 1, 250), GetValueAtCell(RowNo, 25), IntPurchReturn."Excel File Name");
                            end;

                        if ValidateDecimal(GetValueAtCell(RowNo, 26)) then
                            IntPurchReturn."CSRF Ret" := GlobalDecimalYes
                        else
                            if (GetValueAtCell(RowNo, 26) <> '') then begin
                                IntPurchReturn.Status := IntPurchReturn.Status::"Data Excel Error";
                                IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Purchase Return Order",
                                IntPurchReturn."Document No.", IntPurchReturn."Line No.", CopyStr(IntPurchReturn.FieldCaption("CSRF Ret"), 1, 50),
                                CopyStr(GetLastErrorText(), 1, 250), GetValueAtCell(RowNo, 26), IntPurchReturn."Excel File Name");
                            end;

                        if ValidateDecimal(GetValueAtCell(RowNo, 27)) then
                            IntPurchReturn."INSS Ret" := GlobalDecimalYes
                        else
                            if (GetValueAtCell(RowNo, 27) <> '') then begin
                                IntPurchReturn.Status := IntPurchReturn.Status::"Data Excel Error";
                                IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Purchase Return Order",
                                IntPurchReturn."Document No.", IntPurchReturn."Line No.", CopyStr(IntPurchReturn.FieldCaption("INSS Ret"), 1, 50),
                                CopyStr(GetLastErrorText(), 1, 250), GetValueAtCell(RowNo, 27), IntPurchReturn."Excel File Name");
                            end;

                        if ValidateDecimal(GetValueAtCell(RowNo, 28)) then
                            IntPurchReturn."ISS Ret" := GlobalDecimalYes
                        else
                            if (GetValueAtCell(RowNo, 28) <> '') then begin
                                IntPurchReturn.Status := IntPurchReturn.Status::"Data Excel Error";
                                IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Purchase Return Order",
                                IntPurchReturn."Document No.", IntPurchReturn."Line No.", CopyStr(IntPurchReturn.FieldCaption("ISS Ret"), 1, 50),
                                CopyStr(GetLastErrorText(), 1, 250), GetValueAtCell(RowNo, 28), IntPurchReturn."Excel File Name");
                            end;

                        if ValidateDecimal(GetValueAtCell(RowNo, 29)) then
                            IntPurchReturn."PIS Credit" := GlobalDecimalYes
                        else
                            if (GetValueAtCell(RowNo, 29) <> '') then begin
                                IntPurchReturn.Status := IntPurchReturn.Status::"Data Excel Error";
                                IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Purchase Return Order",
                                IntPurchReturn."Document No.", IntPurchReturn."Line No.", CopyStr(IntPurchReturn.FieldCaption("PIS Credit"), 1, 50),
                                CopyStr(GetLastErrorText(), 1, 250), GetValueAtCell(RowNo, 29), IntPurchReturn."Excel File Name");
                            end;

                        if ValidateDecimal(GetValueAtCell(RowNo, 30)) then
                            IntPurchReturn."Cofins Credit" := GlobalDecimalYes
                        else
                            if (GetValueAtCell(RowNo, 30) <> '') then begin
                                IntPurchReturn.Status := IntPurchReturn.Status::"Data Excel Error";
                                IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Purchase Return Order",
                                IntPurchReturn."Document No.", IntPurchReturn."Line No.", CopyStr(IntPurchReturn.FieldCaption("Cofins Credit"), 1, 50),
                                CopyStr(GetLastErrorText(), 1, 250), GetValueAtCell(RowNo, 30), IntPurchReturn."Excel File Name");
                            end;

                        if ValidateDecimal(GetValueAtCell(RowNo, 31)) then
                            IntPurchReturn.DIRF := GlobalDecimalYes
                        else
                            if (GetValueAtCell(RowNo, 31) <> '') then begin
                                IntPurchReturn.Status := IntPurchReturn.Status::"Data Excel Error";
                                IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Purchase Return Order",
                                IntPurchReturn."Document No.", IntPurchReturn."Line No.", CopyStr(IntPurchReturn.FieldCaption(DIRF), 1, 50),
                                CopyStr(GetLastErrorText(), 1, 250), GetValueAtCell(RowNo, 31), IntPurchReturn."Excel File Name");
                            end;

                        if ValidateDecimal(GetValueAtCell(RowNo, 32)) then
                            IntPurchReturn."PO Total" := GlobalDecimalYes
                        else
                            if (GetValueAtCell(RowNo, 32) <> '') then begin
                                IntPurchReturn.Status := IntPurchReturn.Status::"Data Excel Error";
                                IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Purchase Return Order",
                                IntPurchReturn."Document No.", IntPurchReturn."Line No.", CopyStr(IntPurchReturn.FieldCaption("PO Total"), 1, 50),
                                CopyStr(GetLastErrorText(), 1, 250), GetValueAtCell(RowNo, 32), IntPurchReturn."Excel File Name");
                            end;

                        if ExistLine then
                            IntPurchReturn.Modify()
                        else
                            if IntPurchReturn.Insert() then;

                        if IntPurchReturn.Status = IntPurchReturn.Status::"Data Excel Error" then
                            ErrorFile := true;


                    end;

                if ErrorFile then
                    FTPCommunication.DoAction(Enum::"FTP Actions"::rename, FileName, FTPIntSetup.Directory, FTPIntSetup."Error Folder", '')
                else
                    FTPCommunication.DoAction(Enum::"FTP Actions"::rename, FileName, FTPIntSetup.Directory, FTPIntSetup."Imported Folder", '');

            until FTPDir.Next() = 0;
    end;

    procedure ImportExcelLandlord()
    var
        IntegrationLandlord: Record "Integration Landlord";
        IntegrationErros: Record IntegrationErros;
        FTPIntSetup: Record "FTP Integration Setup";
        FTPDir: Record "FTP Directory";
        PurPaySetup: Record "Purchases & Payables Setup";
        Item: Record Item;
        Vendor: Record Vendor;
        FTPCommunication: codeunit "FTP Communication";
        ret: Text;
        NumberVendorNo: Text;
        lines: List of [Text];
        line: Text;
        FileName: Text;
        EntryNo: BigInteger;
        RowNo: Integer;
        ColNo: Integer;
        LineNo: Integer;
        MaxRowNo: Integer;
        CRLF: Char;
        ErrorFile: Boolean;
        ExistLine: Boolean;
        MaxCollumn: Integer;
        PostingDateEmptyErr: Label 'The Posting date cannot be empty.';

    begin
        RowNo := 0;
        ColNo := 0;
        MaxRowNo := 0;
        LineNo := 0;
        MaxCollumn := 0;
        ExistLine := false;

        //FTPIntSetup.Get(FTPIntSetup.Integration::Landlord);
        FTPIntSetup.Reset();
        FTPIntSetup.SetRange(Integration, FTPIntSetup.Integration::Landlord);
        FTPIntSetup.SetRange(Sequence, 0);
        FTPIntSetup.FindSet();

        PurPaySetup.Get();
        PurPaySetup.TestField("Item Serv. Landlord");

        CRLF := 10;

        ret := FTPCommunication.DoAction(Enum::"FTP Actions"::list, '', FTPIntSetup.Directory, '', '');
        lines := ret.Split(CRLF);

        FTPDir.Reset();
        FTPDir.DeleteAll();
        foreach line in lines do
            if line <> '' then begin
                FTPDir.Init();
                FTPDir.Filename := line;
                FTPDir.IsDirectory := (StrPos(line, '.') = 0);
                FTPDir.Insert();
            end;

        FTPDir.Reset();
        FTPDir.SetRange(IsDirectory, false);
        if FTPDir.Find('-') then
            repeat
                Clear(FTPCommunication);
                ErrorFile := false;

                FileName := FTPDir.Filename.Trim();

                if FTPIntSetup."Active Prefix File Name" then begin
                    FTPIntSetup.testfield("Prefix File Name");
                    if StrPos(FileName, FTPIntSetup."Prefix File Name") = 0 then
                        Error('File Name Not Valid');
                end;

                EntryNo := FTPCommunication.DoAction(Enum::"FTP Actions"::download, FileName, FTPIntSetup.Directory, '', '');
                ReadExcelSheet(EntryNo);

                Clear(EntryNo);
                IntegrationLandlord.Reset();
                if IntegrationLandlord.FindLast() then
                    EntryNo := IntegrationLandlord."Entry No.";

                TempExcelBuffer.Reset();
                if TempExcelBuffer.FindLast() then
                    MaxRowNo := TempExcelBuffer."Row No.";
                //Column START Error
                if TempExcelBuffer.FindLast() then
                    MaxCollumn := TempExcelBuffer."Column No.";

                for RowNo := 2 to MaxRowNo do begin
                    LineNo := LineNo + 10000;
                    EntryNo += 1;
                    ExistLine := false;

                    IntegrationLandlord.Init();
                    IntegrationLandlord."Entry No." := EntryNo;
                    IntegrationErros."Document No." := Format(IntegrationLandlord."Entry No.");

                    IntegrationLandlord.Status := IntegrationLandlord.Status::Imported;
                    IntegrationLandlord."Excel File Name" := copystr(Filename, 1, 200);

                    //Month Start Date 5
                    if ValidateDate(GetValueAtCell(RowNo, 5)) then
                        IntegrationLandlord."Document Date" := GlobalDateYes
                    else begin
                        IntegrationLandlord.Status := IntegrationLandlord.Status::"Data Excel Error";
                        IntegrationErros.InsertErros(IntegrationErros."Integration Type"::Landlord,
                        IntegrationLandlord."document No.", IntegrationLandlord."Line No.", CopyStr(IntegrationLandlord.FieldCaption("Document Date"), 1, 50),
                        CopyStr(GetLastErrorText(), 1, 250), GetValueAtCell(RowNo, 3), IntegrationLandlord."Excel File Name");
                    end;

                    //Tax Num 9
                    if (StrLen(GetValueAtCell(RowNo, 9)) <= 20) then
                        Evaluate(IntegrationLandlord."Number Vendor No.", GetValueAtCell(RowNo, 9))
                    else begin
                        IntegrationLandlord.Status := IntegrationLandlord.Status::"Data Excel Error";
                        IntegrationErros.InsertErros(IntegrationErros."Integration Type"::Landlord,
                          IntegrationLandlord."document No.", IntegrationLandlord."Line No.", CopyStr(IntegrationLandlord.FieldCaption("Number Vendor No."), 1, 50),
                          'Maximum 20 characters', GetValueAtCell(RowNo, 9), IntegrationLandlord."Excel File Name");
                    end;

                    //Vendor ID 14
                    if (StrLen(GetValueAtCell(RowNo, 14)) <= 20) then
                        Evaluate(IntegrationLandlord."Buy-from Vendor No.", GetValueAtCell(RowNo, 14))
                    else begin
                        IntegrationLandlord.Status := IntegrationLandlord.Status::"Data Excel Error";
                        IntegrationErros.InsertErros(IntegrationErros."Integration Type"::Landlord,
                          IntegrationLandlord."document No.", IntegrationLandlord."Line No.", CopyStr(IntegrationLandlord.FieldCaption("Buy-from Vendor No."), 1, 50),
                          'Maximum 20 characters', GetValueAtCell(RowNo, 14), IntegrationLandlord."Excel File Name");
                    end;

                    if IntegrationLandlord."Buy-from Vendor No." = '' then begin
                        IntegrationLandlord.Status := IntegrationLandlord.Status::"Data Excel Error";
                        IntegrationErros.InsertErros(IntegrationErros."Integration Type"::Landlord,
                          IntegrationLandlord."document No.", IntegrationLandlord."Line No.", CopyStr(IntegrationLandlord.FieldCaption("Buy-from Vendor No."), 1, 50),
                          'Maximum 20 characters', GetValueAtCell(RowNo, 9), IntegrationLandlord."Excel File Name");
                    end;

                    //Entity Category 11
                    if (StrLen(GetValueAtCell(RowNo, 11)) <= 100) then
                        Evaluate(IntegrationLandlord."Entity Category", GetValueAtCell(RowNo, 11));

                    //Filial 3
                    if (StrLen(GetValueAtCell(RowNo, 3)) <= 20) then begin
                        Evaluate(IntegrationLandlord."Shortcut Dimension 1 Code", GetValueAtCell(RowNo, 3));
                        if IntegrationLandlord."Shortcut Dimension 1 Code" = '' then
                            IntegrationLandlord."Shortcut Dimension 1 Code" := 'BRTOW';

                    end else begin
                        IntegrationLandlord.Status := IntegrationLandlord.Status::"Data Excel Error";
                        IntegrationErros.InsertErros(IntegrationErros."Integration Type"::Landlord,
                          IntegrationLandlord."Document No.", IntegrationLandlord."Line No.", CopyStr(IntegrationLandlord.FieldCaption("Shortcut Dimension 1 Code"), 1, 50),
                          'Maximum 20 characters', GetValueAtCell(RowNo, 3), IntegrationLandlord."Excel File Name");
                    end;
                    //SBALease Num 6 
                    if (StrLen(GetValueAtCell(RowNo, 6)) <= 20) then
                        Evaluate(IntegrationLandlord."Shortcut Dimension 3 Code", GetValueAtCell(RowNo, 6))
                    else begin
                        IntegrationLandlord.Status := IntegrationLandlord.Status::"Data Excel Error";
                        IntegrationErros.InsertErros(IntegrationErros."Integration Type"::Landlord,
                          IntegrationLandlord."Document No.", IntegrationLandlord."Line No.", CopyStr(IntegrationLandlord.FieldCaption("Shortcut Dimension 3 Code"), 1, 50),
                          'Maximum 20 characters', GetValueAtCell(RowNo, 6), IntegrationLandlord."Excel File Name");
                    end;
                    if IntegrationLandlord."Shortcut Dimension 6 Code" = '' then
                        IntegrationLandlord."Shortcut Dimension 6 Code" := IntegrationLandlord."Shortcut Dimension 1 Code";

                    //Paid Date 21
                    if ValidateDate(GetValueAtCell(RowNo, 21)) then
                        IntegrationLandlord."Paid Date" := GlobalDateYes
                    else begin
                        IntegrationLandlord.Status := IntegrationLandlord.Status::"Data Excel Error";
                        IntegrationErros.InsertErros(IntegrationErros."Integration Type"::Landlord,
                        IntegrationLandlord."document No.", IntegrationLandlord."Line No.", CopyStr(IntegrationLandlord.FieldCaption("Paid Date"), 1, 50),
                        CopyStr(GetLastErrorText(), 1, 250), GetValueAtCell(RowNo, 21), IntegrationLandlord."Excel File Name");
                    end;

                    //Gross AP Tax Amount Withheld (Great Plains) 23
                    if GetValueAtCell(RowNo, 23) <> '' then
                        Evaluate(IntegrationLandlord.Amount, GetValueAtCell(RowNo, 23));

                    // GrossTax Amount Withheld (Great Plains 25
                    if GetValueAtCell(RowNo, 25) <> '' then
                        Evaluate(IntegrationLandlord."IRRF Ret", GetValueAtCell(RowNo, 25));

                    IntegrationLandlord.Quantity := 1;
                    IntegrationLandlord."Item No." := PurPaySetup."Item Serv. Landlord";
                    Item.Get(PurPaySetup."Item Serv. Landlord");
                    IntegrationLandlord.Description := Item.Description;

                    if (IntegrationLandlord.Amount <> 0) and (IntegrationLandlord."Entity Category" = 'Individual') then begin
                        if ExistLine then
                            IntegrationLandlord.Modify()
                        else
                            if IntegrationLandlord.Insert() then;

                        if IntegrationLandlord.Status = IntegrationLandlord.Status::"Data Excel Error" then
                            ErrorFile := true;
                    end;

                end;


                if ErrorFile then
                    FTPCommunication.DoAction(Enum::"FTP Actions"::rename, FileName, FTPIntSetup.Directory, FTPIntSetup."Error Folder", '')
                else
                    FTPCommunication.DoAction(Enum::"FTP Actions"::rename, FileName, FTPIntSetup.Directory, FTPIntSetup."Imported Folder", '');

            until FTPDir.Next() = 0;

    end;

    procedure ImportExcelReceiptJournal()
    var
        TemporaryBuffer: Record "Integration Receipt Journal";
        IntegrationErros: Record IntegrationErros;
        Customer: Record Customer;
        Bank: Record "Bank Account";
        RowNo: Integer;
        ColNo: Integer;
        LineNo: Integer;
        MaxRowNo: Integer;
        FTPIntSetup: Record "FTP Integration Setup";
        FTPDir: Record "FTP Directory" temporary;
        FTPCommunication: codeunit "FTP Communication";
        ret: Text;
        lines: List of [Text];
        line: Text;
        FileName: Text;
        EntryNo: BigInteger;
        CRLF: Char;
        fm29: Page 29;
        ErrorFile: Boolean;
        DateValue: Date;
        MaxCollumn: Integer;
        IntReceiptJ: Record "Integration Receipt Journal";
        ExistLine: Boolean;
        ExistLineNo: Integer;
        IntegrationEmail: Codeunit "Integration Email";

    begin

        RowNo := 0;
        ColNo := 0;
        MaxRowNo := 0;
        LineNo := 0;

        //FTPIntSetup.Get(FTPIntSetup.Integration::"Sales Payment");
        FTPIntSetup.Reset();
        FTPIntSetup.SetRange(Integration, FTPIntSetup.Integration::"Sales Payment");
        FTPIntSetup.SetRange(Sequence, 0);
        FTPIntSetup.FindSet();

        CRLF := 10;

        ret := FTPCommunication.DoAction(Enum::"FTP Actions"::list, '', FTPIntSetup.Directory, '', '');
        lines := ret.Split(CRLF);

        FTPDir.Reset();
        FTPDir.DeleteAll();
        foreach line in lines do
            if line <> '' then begin
                FTPDir.Init();
                FTPDir.Filename := line;
                FTPDir.IsDirectory := (StrPos(line, '.') = 0);
                FTPDir.Insert();
            end;

        FTPDir.Reset();
        FTPDir.SetRange(IsDirectory, false);
        if FTPDir.Find('-') then
            repeat
                Clear(FTPCommunication);

                FileName := FTPDir.Filename.Trim();

                if FTPIntSetup."Active Prefix File Name" then begin
                    FTPIntSetup.testfield("Prefix File Name");
                    if StrPos(FileName, FTPIntSetup."Prefix File Name") = 0 then
                        Error('File Name Not Valid');
                end;

                EntryNo := FTPCommunication.DoAction(Enum::"FTP Actions"::download, FileName, FTPIntSetup.Directory, '', '');
                ReadExcelSheet(EntryNo);

                TemporaryBuffer.Reset();
                if TemporaryBuffer.FindLast() then
                    LineNo := TemporaryBuffer."Line No.";

                TempExcelBuffer.Reset();
                if TempExcelBuffer.FindLast() then
                    MaxRowNo := TempExcelBuffer."Row No.";

                //Column START Error
                if TempExcelBuffer.FindLast() then
                    MaxCollumn := TempExcelBuffer."Column No.";

                if MaxCollumn <> 23 then begin
                    TemporaryBuffer.Init();
                    TemporaryBuffer."Journal Template Name" := format(Today);
                    TemporaryBuffer."Journal Batch Name" := format(Time);
                    TemporaryBuffer."Line No." := LineNo;
                    TemporaryBuffer."Document No." := format(Today) + format(Time);
                    TemporaryBuffer.Status := TemporaryBuffer.Status::"Layout Error";
                    TemporaryBuffer."Excel File Name" := copystr(Filename, 1, 200);
                    IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Sales Receipt",
                      TemporaryBuffer."document No.", TemporaryBuffer."Line No.", CopyStr('', 1, 50),
                      'Layout Error', GetValueAtCell(RowNo, 2), TemporaryBuffer."Excel File Name");

                    if TemporaryBuffer.Insert() then
                        ErrorFile := true;

                end else
                    //Column END Error

                for RowNo := 2 to MaxRowNo do begin

                        LineNo := LineNo + 10000;

                        IntReceiptJ.reset;
                        IntReceiptJ.SetRange("Journal Template Name", (GetValueAtCell(RowNo, 1)));
                        IntReceiptJ.SetRange("Journal Batch Name", (GetValueAtCell(RowNo, 2)));
                        IntReceiptJ.SetRange("Document No.", (GetValueAtCell(RowNo, 8)));
                        Evaluate(LineNo, GetValueAtCell(RowNo, 3));
                        IntReceiptJ.SetRange("Line No.", LineNo); //Aug
                        clear(ExistLineNo);
                        clear(ExistLine);
                        if IntReceiptJ.Find('-') then
                            repeat
                                ExistLineNo := IntReceiptJ."Line No.";
                                ExistLine := true;
                            until IntReceiptJ.Next = 0;

                        if (StrLen(GetValueAtCell(RowNo, 1)) <= 10) then begin
                            if TemporaryBuffer.get(GetValueAtCell(RowNo, 1), GetValueAtCell(RowNo, 2), ExistLineNo) then begin
                                //Not Modify Posted Line
                                if TemporaryBuffer.Status = TemporaryBuffer.Status::Posted then begin
                                    ExistLine := false;
                                    TemporaryBuffer."Posting Message" := 'Duplicate ' + copystr(Filename, 1, 200);
                                    TemporaryBuffer.Modify();
                                    ErrorFile := true;
                                end else begin
                                    ExistLine := true;
                                    TemporaryBuffer.Status := TemporaryBuffer.Status::Imported;
                                end;
                            end else begin
                                ExistLine := false;
                                //<ExistLine
                                TemporaryBuffer.Init();
                                Evaluate(TemporaryBuffer."Journal Template Name", GetValueAtCell(RowNo, 1));
                                Evaluate(TemporaryBuffer."Journal Batch Name", GetValueAtCell(RowNo, 2));
                                TemporaryBuffer."Line No." := LineNo;
                                TemporaryBuffer.Status := TemporaryBuffer.Status::Imported;
                            end;

                            //Delete Errors
                            IntegrationErros.Reset();
                            IntegrationErros.Setrange("Document No.", TemporaryBuffer."Document No.");
                            IntegrationErros.SetRange("Excel File Name", TemporaryBuffer."Excel File Name");
                            IntegrationErros.SetRange("Integration Type", IntegrationErros."Integration Type"::"Sales Receipt");
                            if IntegrationErros.FindSet() then
                                repeat
                                    IntegrationErros.DeleteAll();
                                until IntegrationErros.Next() = 0;

                        end else begin
                            TemporaryBuffer.Init();
                            Evaluate(TemporaryBuffer."Journal Template Name", 'Errors-' + format(RowNo));
                            Evaluate(TemporaryBuffer."Line No.", GetValueAtCell(RowNo, 3));
                            TemporaryBuffer.Status := TemporaryBuffer.Status::"Data Excel Error";
                            TemporaryBuffer."Excel File Name" := copystr(Filename, 1, 200);
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Sales Receipt",
                              TemporaryBuffer."Document No.", TemporaryBuffer."Line No.", CopyStr(TemporaryBuffer.FieldCaption("Journal Template Name"), 1, 10),
                              'Maximum 10 characters', GetValueAtCell(RowNo, 1), TemporaryBuffer."Excel File Name");
                        end;

                        if (StrLen(GetValueAtCell(RowNo, 2)) <= 10) then
                            Evaluate(TemporaryBuffer."Journal Batch Name", GetValueAtCell(RowNo, 2))
                        else begin
                            TemporaryBuffer.Status := TemporaryBuffer.Status::"Data Excel Error";
                            TemporaryBuffer."Excel File Name" := copystr(Filename, 1, 200);
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Sales Receipt",
                              TemporaryBuffer."Document No.", TemporaryBuffer."Line No.", CopyStr(TemporaryBuffer.FieldCaption("Journal Batch Name"), 1, 10),
                              'Maximum 10 characters', GetValueAtCell(RowNo, 2), TemporaryBuffer."Excel File Name");
                        end;

                        //Evaluate(TemporaryBuffer."Line No.", GetValueAtCell(RowNo, 3));

                        //Evaluate(TemporaryBuffer."Account Type", GetValueAtCell(RowNo, 4));
                        // if GetValueAtCell(RowNo, 4) <> 'Customer' then begin
                        //     TemporaryBuffer.Status := TemporaryBuffer.Status::"Data Excel Error";
                        //     IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Sales Receipt",
                        //           format(TemporaryBuffer."Document No."), TemporaryBuffer."Line No.", CopyStr(TemporaryBuffer.FieldCaption("Account Type"), 1, 10),
                        //           'Type <> Customer', GetValueAtCell(RowNo, 4), TemporaryBuffer."Excel File Name")
                        // end else
                        TemporaryBuffer."Account Type" := TemporaryBuffer."Account Type"::Customer;


                        if Customer.get(GetValueAtCell(RowNo, 5)) then
                            Evaluate(TemporaryBuffer."Account No.", GetValueAtCell(RowNo, 5))
                        else begin
                            TemporaryBuffer.Status := TemporaryBuffer.Status::"Data Excel Error";
                            TemporaryBuffer."Excel File Name" := copystr(Filename, 1, 200);
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Sales Receipt",
                                  TemporaryBuffer."Document No.", TemporaryBuffer."Line No.", CopyStr(TemporaryBuffer.FieldCaption("Account No."), 1, 10),
                                  'Customer Not Found', GetValueAtCell(RowNo, 5), TemporaryBuffer."Excel File Name")
                        end;


                        if ValidateDate(GetValueAtCell(RowNo, 6)) then
                            TemporaryBuffer."Posting Date" := GlobalDateYes
                        else begin
                            TemporaryBuffer.Status := TemporaryBuffer.Status::"Data Excel Error";
                            TemporaryBuffer."Excel File Name" := copystr(Filename, 1, 200);
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Sales Receipt",
                            TemporaryBuffer."document No.", TemporaryBuffer."Line No.", CopyStr(TemporaryBuffer.FieldCaption("Posting Date"), 1, 50),
                            CopyStr(GetLastErrorText(), 1, 250), GetValueAtCell(RowNo, 6), TemporaryBuffer."Excel File Name");
                        end;

                        Evaluate(TemporaryBuffer."Document Type", GetValueAtCell(RowNo, 7));
                        // if GetValueAtCell(RowNo, 7) <> 'Payment' then begin
                        //     TemporaryBuffer.Status := TemporaryBuffer.Status::"Data Excel Error";
                        //     IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Sales Receipt",
                        //           format(TemporaryBuffer."Document No."), TemporaryBuffer."Line No.", CopyStr(TemporaryBuffer.FieldCaption("Document Type"), 1, 10),
                        //           'Type <> Payment', GetValueAtCell(RowNo, 7), TemporaryBuffer."Excel File Name")
                        // end else
                        //     TemporaryBuffer."Document Type" := TemporaryBuffer."Document Type"::Payment;

                        if (StrLen(GetValueAtCell(RowNo, 8)) <= 20) then
                            Evaluate(TemporaryBuffer."Document No.", GetValueAtCell(RowNo, 8))
                        else begin
                            TemporaryBuffer.Status := TemporaryBuffer.Status::"Data Excel Error";
                            TemporaryBuffer."Excel File Name" := copystr(Filename, 1, 200);
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Sales Receipt",
                              TemporaryBuffer."Document No.", TemporaryBuffer."Line No.", CopyStr(TemporaryBuffer.FieldCaption("Document No."), 1, 20),
                              'Maximum 20 characters', GetValueAtCell(RowNo, 8), TemporaryBuffer."Excel File Name");
                        end;

                        if (StrLen(GetValueAtCell(RowNo, 9)) <= 100) then
                            Evaluate(TemporaryBuffer.Description, GetValueAtCell(RowNo, 9))
                        else begin
                            TemporaryBuffer.Status := TemporaryBuffer.Status::"Data Excel Error";
                            TemporaryBuffer."Excel File Name" := copystr(Filename, 1, 200);
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Sales Receipt",
                              TemporaryBuffer."Document No.", TemporaryBuffer."Line No.", CopyStr(TemporaryBuffer.FieldCaption(Description), 1, 100),
                              'Maximum 100 characters', GetValueAtCell(RowNo, 9), TemporaryBuffer."Excel File Name");
                        end;

                        Evaluate(TemporaryBuffer."Bal. Account Type", GetValueAtCell(RowNo, 10));
                        // if GetValueAtCell(RowNo, 10) <> 'Bank Account' then begin
                        //     TemporaryBuffer.Status := TemporaryBuffer.Status::"Data Excel Error";
                        //     IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Sales Receipt",
                        //           format(TemporaryBuffer."Document No."), TemporaryBuffer."Line No.", CopyStr(TemporaryBuffer.FieldCaption("Bal. Account Type"), 1, 10),
                        //           'Type <> Bank Account', GetValueAtCell(RowNo, 10), TemporaryBuffer."Excel File Name")
                        // end else
                        //     TemporaryBuffer."Bal. Account Type" := TemporaryBuffer."Bal. Account Type"::"Bank Account";


                        if Bank.get(GetValueAtCell(RowNo, 11)) then
                            Evaluate(TemporaryBuffer."Bal. Account No.", GetValueAtCell(RowNo, 11))
                        else begin
                            TemporaryBuffer.Status := TemporaryBuffer.Status::"Data Excel Error";
                            TemporaryBuffer."Excel File Name" := copystr(Filename, 1, 200);
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Sales Receipt",
                                  TemporaryBuffer."Document No.", TemporaryBuffer."Line No.", CopyStr(TemporaryBuffer.FieldCaption("Bal. Account No."), 1, 10),
                                  'Bank Not Found', GetValueAtCell(RowNo, 11), TemporaryBuffer."Excel File Name")
                        end;

                        if GetValueAtCell(RowNo, 14) <> '' then
                            Evaluate(TemporaryBuffer.Amount, GetValueAtCell(RowNo, 14));
                        if TemporaryBuffer.Amount = 0 then begin
                            TemporaryBuffer.Status := TemporaryBuffer.Status::"Data Excel Error";
                            TemporaryBuffer."Excel File Name" := copystr(Filename, 1, 200);
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Sales Receipt",
                                  TemporaryBuffer."Document No.", TemporaryBuffer."Line No.", CopyStr(TemporaryBuffer.FieldCaption(Amount), 1, 10),
                                  'Amount Not Found', GetValueAtCell(RowNo, 14), TemporaryBuffer."Excel File Name")
                        end;

                        Evaluate(TemporaryBuffer."dimension 1", GetValueAtCell(RowNo, 15));
                        Evaluate(TemporaryBuffer."dimension 2", GetValueAtCell(RowNo, 16));
                        Evaluate(TemporaryBuffer."dimension 3", GetValueAtCell(RowNo, 17));
                        Evaluate(TemporaryBuffer."dimension 4", GetValueAtCell(RowNo, 18));
                        Evaluate(TemporaryBuffer."dimension 5", GetValueAtCell(RowNo, 19));
                        Evaluate(TemporaryBuffer."dimension 6", GetValueAtCell(RowNo, 20));

                        Evaluate(TemporaryBuffer."Applies-to Doc. Type", GetValueAtCell(RowNo, 21));

                        if (StrLen(GetValueAtCell(RowNo, 22)) <= 20) then
                            Evaluate(TemporaryBuffer."Applies-to Doc. No.", GetValueAtCell(RowNo, 22))
                        else begin
                            TemporaryBuffer.Status := TemporaryBuffer.Status::"Data Excel Error";
                            TemporaryBuffer."Excel File Name" := copystr(Filename, 1, 200);
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Sales Receipt",
                              TemporaryBuffer."Document No.", TemporaryBuffer."Line No.", CopyStr(TemporaryBuffer.FieldCaption("Applies-to Doc. No."), 1, 20),
                              'Maximum 20 characters', GetValueAtCell(RowNo, 22), TemporaryBuffer."Excel File Name");
                        end;

                        if (StrLen(GetValueAtCell(RowNo, 23)) <= 20) then
                            Evaluate(TemporaryBuffer."External Document No.", GetValueAtCell(RowNo, 23))
                        else begin
                            TemporaryBuffer.Status := TemporaryBuffer.Status::"Data Excel Error";
                            TemporaryBuffer."Excel File Name" := copystr(Filename, 1, 200);
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Sales Receipt",
                              TemporaryBuffer."Document No.", TemporaryBuffer."Line No.", CopyStr(TemporaryBuffer.FieldCaption("External Document No."), 1, 20),
                              'Maximum 20 characters', GetValueAtCell(RowNo, 23), TemporaryBuffer."Excel File Name");
                        end;

                        //TemporaryBuffer."Line No." := LineNo;
                        TemporaryBuffer."Excel File Name" := copystr(Filename, 1, 200);

                        if ExistLine then
                            TemporaryBuffer.Modify()
                        else
                            if TemporaryBuffer.Insert() then;

                        if TemporaryBuffer.Status = TemporaryBuffer.Status::"Data Excel Error" then
                            ErrorFile := true;

                    end;

                if ErrorFile then begin

                    FTPCommunication.DoAction(Enum::"FTP Actions"::rename, FileName, FTPIntSetup.Directory, FTPIntSetup."Error Folder", '');
                    //FTPIntSetup.Get(FTPIntSetup.Integration::"Sales Payment");
                    FTPIntSetup.Reset();
                    FTPIntSetup.SetRange(Integration, FTPIntSetup.Integration::"Sales Payment");
                    FTPIntSetup.SetRange(Sequence, 0);
                    FTPIntSetup.FindSet();
                    if FTPIntSetup."Send Email" then
                        IntegrationEmail.SendMail(FTPIntSetup."E-mail Rejected Data", False, '', TemporaryBuffer."Excel File Name");

                end else
                    FTPCommunication.DoAction(Enum::"FTP Actions"::rename, FileName, FTPIntSetup.Directory, FTPIntSetup."Imported Folder", '');


            until FTPDir.Next() = 0;

    end;

    procedure ImportExcelRcptJournalApply()
    var
        TemporaryBuffer: Record "Integration Rcpt Jnl Apply";
        IntegrationErros: Record IntegrationErros;
        Customer: Record Customer;
        Bank: Record "Bank Account";
        RowNo: Integer;
        ColNo: Integer;
        LineNo: Integer;
        MaxRowNo: Integer;
        FTPIntSetup: Record "FTP Integration Setup";
        FTPDir: Record "FTP Directory" temporary;
        FTPCommunication: codeunit "FTP Communication";
        ret: Text;
        lines: List of [Text];
        line: Text;
        FileName: Text;
        EntryNo: BigInteger;
        CRLF: Char;
        fm29: Page 29;
        ErrorFile: Boolean;
        ExistLine: Boolean;
        MaxCollumn: Integer;
        IntReceiptJApply: Record "Integration Rcpt Jnl Apply";
        ExistLineNo: Integer;
        CustLedgEntry: Record "Cust. Ledger Entry";
    begin

        RowNo := 0;
        ColNo := 0;
        MaxRowNo := 0;
        LineNo := 0;

        //FTPIntSetup.Get(FTPIntSetup.Integration::"Sale Apply");
        FTPIntSetup.Reset();
        FTPIntSetup.SetRange(Integration, FTPIntSetup.Integration::"Sale Apply");
        FTPIntSetup.SetRange(Sequence, 0);
        FTPIntSetup.FindSet();

        CRLF := 10;

        ret := FTPCommunication.DoAction(Enum::"FTP Actions"::list, '', FTPIntSetup.Directory, '', '');
        lines := ret.Split(CRLF);

        FTPDir.Reset();
        FTPDir.DeleteAll();
        foreach line in lines do
            if line <> '' then begin
                FTPDir.Init();
                FTPDir.Filename := line;
                FTPDir.IsDirectory := (StrPos(line, '.') = 0);
                FTPDir.Insert();
            end;

        FTPDir.Reset();
        FTPDir.SetRange(IsDirectory, false);
        if FTPDir.Find('-') then
            repeat
                Clear(FTPCommunication);

                FileName := FTPDir.Filename.Trim();

                if FTPIntSetup."Active Prefix File Name" then begin
                    FTPIntSetup.testfield("Prefix File Name");
                    if StrPos(FileName, FTPIntSetup."Prefix File Name") = 0 then
                        Error('File Name Not Valid');
                end;

                EntryNo := FTPCommunication.DoAction(Enum::"FTP Actions"::download, FileName, FTPIntSetup.Directory, '', '');
                ReadExcelSheet(EntryNo);

                TemporaryBuffer.Reset();
                if TemporaryBuffer.FindLast() then
                    LineNo := TemporaryBuffer."Line No.";

                TempExcelBuffer.Reset();
                if TempExcelBuffer.FindLast() then
                    MaxRowNo := TempExcelBuffer."Row No.";

                //Column START Error
                if TempExcelBuffer.FindLast() then
                    MaxCollumn := TempExcelBuffer."Column No.";

                if MaxCollumn <> 23 then begin
                    TemporaryBuffer.Init();
                    TemporaryBuffer."Journal Template Name" := format(Today);
                    TemporaryBuffer."Journal Batch Name" := format(Time);
                    TemporaryBuffer."Line No." := LineNo;
                    TemporaryBuffer."Document No." := format(Today) + format(Time);
                    TemporaryBuffer.Status := TemporaryBuffer.Status::"Layout Error";
                    TemporaryBuffer."Excel File Name" := copystr(Filename, 1, 200);
                    IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Sales Apply",
                      TemporaryBuffer."document No.", TemporaryBuffer."Line No.", CopyStr('', 1, 50),
                      'Layout Error', GetValueAtCell(RowNo, 2), TemporaryBuffer."Excel File Name");

                    if TemporaryBuffer.Insert() then
                        ErrorFile := true;

                end else
                    //Column END Error

                for RowNo := 2 to MaxRowNo do begin

                        LineNo := LineNo + 10000;

                        IntReceiptJApply.reset;
                        IntReceiptJApply.SetRange("Journal Template Name", (GetValueAtCell(RowNo, 1)));
                        IntReceiptJApply.SetRange("Journal Batch Name", (GetValueAtCell(RowNo, 2)));
                        IntReceiptJApply.SetRange("Document No.", (GetValueAtCell(RowNo, 8)));
                        Evaluate(LineNo, GetValueAtCell(RowNo, 3));
                        IntReceiptJApply.SetRange("Line No.", LineNo); //Aug
                        clear(ExistLineNo);
                        clear(ExistLine);
                        if IntReceiptJApply.Find('-') then
                            repeat
                                ExistLineNo := IntReceiptJApply."Line No.";
                                ExistLine := true;
                            until IntReceiptJApply.Next = 0;

                        if (StrLen(GetValueAtCell(RowNo, 1)) <= 10) then begin
                            if TemporaryBuffer.get(GetValueAtCell(RowNo, 1), GetValueAtCell(RowNo, 2), ExistLineNo) then begin
                                //Not Modify Posted Line
                                if TemporaryBuffer.Status = TemporaryBuffer.Status::Posted then begin
                                    ExistLine := false;
                                    TemporaryBuffer."Posting Message" := 'Duplicate ' + copystr(Filename, 1, 200);
                                    TemporaryBuffer.Modify();
                                    ErrorFile := true;
                                end else begin
                                    ExistLine := true;
                                    TemporaryBuffer.Status := TemporaryBuffer.Status::Imported;
                                end;
                            end else begin
                                ExistLine := false;
                                //<ExistLine
                                TemporaryBuffer.Init();
                                Evaluate(TemporaryBuffer."Journal Template Name", GetValueAtCell(RowNo, 1));
                                Evaluate(TemporaryBuffer."Journal Batch Name", GetValueAtCell(RowNo, 2));
                                TemporaryBuffer."Line No." := LineNo;
                                TemporaryBuffer.Status := TemporaryBuffer.Status::Imported;
                            end;

                            //Delete Errors
                            IntegrationErros.Reset();
                            IntegrationErros.Setrange("Document No.", TemporaryBuffer."Document No.");
                            IntegrationErros.SetRange("Excel File Name", TemporaryBuffer."Excel File Name");
                            IntegrationErros.SetRange("Integration Type", IntegrationErros."Integration Type"::"Sales Apply");
                            if IntegrationErros.FindSet() then
                                repeat
                                    IntegrationErros.DeleteAll();
                                until IntegrationErros.Next() = 0;

                        end else begin
                            TemporaryBuffer.Init();
                            Evaluate(TemporaryBuffer."Journal Template Name", 'Errors-' + format(RowNo));
                            Evaluate(TemporaryBuffer."Line No.", GetValueAtCell(RowNo, 1));
                            TemporaryBuffer.Status := TemporaryBuffer.Status::"Data Excel Error";
                            TemporaryBuffer."Excel File Name" := copystr(Filename, 1, 200);
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Sales Apply",
                              TemporaryBuffer."Document No.", TemporaryBuffer."Line No.", CopyStr(TemporaryBuffer.FieldCaption("Journal Template Name"), 1, 10),
                              'Maximum 10 characters', GetValueAtCell(RowNo, 1), TemporaryBuffer."Excel File Name");
                        end;


                        if (StrLen(GetValueAtCell(RowNo, 2)) <= 10) then
                            Evaluate(TemporaryBuffer."Journal Batch Name", GetValueAtCell(RowNo, 2))
                        else begin
                            TemporaryBuffer.Status := TemporaryBuffer.Status::"Data Excel Error";
                            TemporaryBuffer."Excel File Name" := copystr(Filename, 1, 200);
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Sales Apply",
                              TemporaryBuffer."Document No.", TemporaryBuffer."Line No.", CopyStr(TemporaryBuffer.FieldCaption("Journal Batch Name"), 1, 10),
                              'Maximum 10 characters', GetValueAtCell(RowNo, 2), TemporaryBuffer."Excel File Name");
                        end;

                        //Evaluate(TemporaryBuffer."Line No.", GetValueAtCell(RowNo, 3));

                        //Evaluate(TemporaryBuffer."Account Type", GetValueAtCell(RowNo, 4));
                        // if GetValueAtCell(RowNo, 4) <> 'Customer' then begin
                        //     TemporaryBuffer.Status := TemporaryBuffer.Status::"Data Excel Error";
                        //     IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Sales Apply",
                        //           format(TemporaryBuffer."Document No."), TemporaryBuffer."Line No.", CopyStr(TemporaryBuffer.FieldCaption("Account Type"), 1, 10),
                        //           'Type <> Customer', GetValueAtCell(RowNo, 4), TemporaryBuffer."Excel File Name")
                        // end else
                        TemporaryBuffer."Account Type" := TemporaryBuffer."Account Type"::Customer;


                        if Customer.get(GetValueAtCell(RowNo, 5)) then
                            Evaluate(TemporaryBuffer."Account No.", GetValueAtCell(RowNo, 5))
                        else begin
                            TemporaryBuffer.Status := TemporaryBuffer.Status::"Data Excel Error";
                            TemporaryBuffer."Excel File Name" := copystr(Filename, 1, 200);
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Sales Apply",
                                  TemporaryBuffer."Document No.", TemporaryBuffer."Line No.", CopyStr(TemporaryBuffer.FieldCaption("Account No."), 1, 10),
                                  'Customer Not Found', GetValueAtCell(RowNo, 5), TemporaryBuffer."Excel File Name")
                        end;

                        if ValidateDate(GetValueAtCell(RowNo, 6)) then
                            TemporaryBuffer."Posting Date" := GlobalDateYes
                        else begin
                            TemporaryBuffer.Status := TemporaryBuffer.Status::"Data Excel Error";
                            TemporaryBuffer."Excel File Name" := copystr(Filename, 1, 200);
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Sales Apply",
                            TemporaryBuffer."document No.", TemporaryBuffer."Line No.", CopyStr(TemporaryBuffer.FieldCaption("Posting Date"), 1, 50),
                            CopyStr(GetLastErrorText(), 1, 250), GetValueAtCell(RowNo, 6), TemporaryBuffer."Excel File Name");
                        end;

                        Evaluate(TemporaryBuffer."Document Type", GetValueAtCell(RowNo, 7));
                        //  //   if GetValueAtCell(RowNo, 7) <> 'Payment' then begin
                        //         TemporaryBuffer.Status := TemporaryBuffer.Status::"Data Excel Error";
                        //         IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Sales Apply",
                        //               format(TemporaryBuffer."Document No."), TemporaryBuffer."Line No.", CopyStr(TemporaryBuffer.FieldCaption("Document Type"), 1, 10),
                        //               'Type <> Payment', GetValueAtCell(RowNo, 7), TemporaryBuffer."Excel File Name")
                        //  end else
                        //      TemporaryBuffer."document Type" := TemporaryBuffer."Document Type"::Payment;

                        if (StrLen(GetValueAtCell(RowNo, 8)) <= 20) then begin
                            Evaluate(TemporaryBuffer."Document No.", GetValueAtCell(RowNo, 8));
                            CustLedgEntry.Reset();
                            CustLedgEntry.SetRange("Customer No.", GetValueAtCell(RowNo, 5));
                            //CustLedgEntry.SetRange("Document Type", TemporaryBuffer."Document Type");
                            // CustLedgEntry.SetFilter("Document No.", '%1|%2', GetValueAtCell(RowNo, 8), GetValueAtCell(RowNo, 22));
                            CustLedgEntry.SetRange("Document No.", GetValueAtCell(RowNo, 8));
                            if not CustLedgEntry.FindFirst() then begin
                                TemporaryBuffer.Status := TemporaryBuffer.Status::"Data Error";
                                TemporaryBuffer."Excel File Name" := copystr(Filename, 1, 200);
                                IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Sales Apply",
                                  TemporaryBuffer."Document No.", TemporaryBuffer."Line No.", CopyStr(TemporaryBuffer.FieldCaption("Document No."), 1, 20),
                                  'Apply Not Found', GetValueAtCell(RowNo, 8), TemporaryBuffer."Excel File Name");
                            end;
                        end
                        else begin
                            TemporaryBuffer.Status := TemporaryBuffer.Status::"Data Excel Error";
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Sales Apply",
                              TemporaryBuffer."Document No.", TemporaryBuffer."Line No.", CopyStr(TemporaryBuffer.FieldCaption("Document No."), 1, 20),
                              'Maximum 20 characters', GetValueAtCell(RowNo, 8), TemporaryBuffer."Excel File Name");
                        end;

                        if (StrLen(GetValueAtCell(RowNo, 9)) <= 100) then
                            Evaluate(TemporaryBuffer.Description, GetValueAtCell(RowNo, 9))
                        else begin
                            TemporaryBuffer.Status := TemporaryBuffer.Status::"Data Excel Error";
                            TemporaryBuffer."Excel File Name" := copystr(Filename, 1, 200);
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Sales Apply",
                              TemporaryBuffer."Document No.", TemporaryBuffer."Line No.", CopyStr(TemporaryBuffer.FieldCaption(Description), 1, 100),
                              'Maximum 100 characters', GetValueAtCell(RowNo, 9), TemporaryBuffer."Excel File Name");
                        end;

                        Evaluate(TemporaryBuffer."Bal. Account Type", GetValueAtCell(RowNo, 10));
                        // if GetValueAtCell(RowNo, 10) <> 'Bank Account' then begin
                        //     TemporaryBuffer.Status := TemporaryBuffer.Status::"Data Excel Error";
                        //     IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Sales Apply",
                        //           format(TemporaryBuffer."Document No."), TemporaryBuffer."Line No.", CopyStr(TemporaryBuffer.FieldCaption("Bal. Account Type"), 1, 10),
                        //           'Type <> Bank Account', GetValueAtCell(RowNo, 10), TemporaryBuffer."Excel File Name")
                        // end else
                        //     TemporaryBuffer."Bal. Account Type" := TemporaryBuffer."Bal. Account Type"::"Bank Account";


                        Evaluate(TemporaryBuffer."Bal. Account No.", copystr(GetValueAtCell(RowNo, 11), 1, MaxStrLen(TemporaryBuffer."Bal. Account No.")));

                        // if Bank.get(GetValueAtCell(RowNo, 11)) then
                        //     Evaluate(TemporaryBuffer."Bal. Account No.", GetValueAtCell(RowNo, 11))
                        // else begin
                        //     TemporaryBuffer.Status := TemporaryBuffer.Status::"Data Excel Error";
                        //     TemporaryBuffer."Excel File Name" := copystr(Filename, 1, 200);
                        //     IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Sales Apply",
                        //           TemporaryBuffer."Document No.", TemporaryBuffer."Line No.", CopyStr(TemporaryBuffer.FieldCaption("Bal. Account No."), 1, 10),
                        //           'Bank Not Found', GetValueAtCell(RowNo, 11), TemporaryBuffer."Excel File Name")
                        // end;

                        if GetValueAtCell(RowNo, 13) <> '' then
                            Evaluate(TemporaryBuffer.Amount, GetValueAtCell(RowNo, 13));
                        if TemporaryBuffer.Amount = 0 then begin
                            TemporaryBuffer.Status := TemporaryBuffer.Status::"Data Excel Error";
                            TemporaryBuffer."Excel File Name" := copystr(Filename, 1, 200);
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Sales Apply",
                                  TemporaryBuffer."Document No.", TemporaryBuffer."Line No.", CopyStr(TemporaryBuffer.FieldCaption(Amount), 1, 10),
                                  'Amount Not Found', GetValueAtCell(RowNo, 13), TemporaryBuffer."Excel File Name")
                        end;

                        Evaluate(TemporaryBuffer."dimension 1", GetValueAtCell(RowNo, 15));
                        Evaluate(TemporaryBuffer."dimension 2", GetValueAtCell(RowNo, 16));
                        Evaluate(TemporaryBuffer."dimension 3", GetValueAtCell(RowNo, 17));
                        Evaluate(TemporaryBuffer."dimension 4", GetValueAtCell(RowNo, 18));
                        Evaluate(TemporaryBuffer."dimension 5", GetValueAtCell(RowNo, 19));
                        Evaluate(TemporaryBuffer."dimension 6", GetValueAtCell(RowNo, 20));

                        Evaluate(TemporaryBuffer."Applies-to Doc. Type", GetValueAtCell(RowNo, 21));

                        if (StrLen(GetValueAtCell(RowNo, 22)) <= 20) then
                            Evaluate(TemporaryBuffer."Applies-to Doc. No.", GetValueAtCell(RowNo, 22))
                        else begin
                            TemporaryBuffer.Status := TemporaryBuffer.Status::"Data Excel Error";
                            TemporaryBuffer."Excel File Name" := copystr(Filename, 1, 200);
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Sales Apply",
                              TemporaryBuffer."Document No.", TemporaryBuffer."Line No.", CopyStr(TemporaryBuffer.FieldCaption("Applies-to Doc. No."), 1, 20),
                              'Maximum 20 characters', GetValueAtCell(RowNo, 22), TemporaryBuffer."Excel File Name");
                        end;

                        if (StrLen(GetValueAtCell(RowNo, 23)) <= 20) then
                            Evaluate(TemporaryBuffer."External Document No.", GetValueAtCell(RowNo, 23))
                        else begin
                            TemporaryBuffer.Status := TemporaryBuffer.Status::"Data Excel Error";
                            TemporaryBuffer."Excel File Name" := copystr(Filename, 1, 200);
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Sales Apply",
                              TemporaryBuffer."Document No.", TemporaryBuffer."Line No.", CopyStr(TemporaryBuffer.FieldCaption("External Document No."), 1, 20),
                              'Maximum 20 characters', GetValueAtCell(RowNo, 23), TemporaryBuffer."Excel File Name");
                        end;

                        //TemporaryBuffer."Line No." := LineNo;

                        TemporaryBuffer."Excel File Name" := copystr(Filename, 1, 200);

                        if ExistLine then
                            TemporaryBuffer.Modify()
                        else
                            if TemporaryBuffer.Insert() then;

                        if TemporaryBuffer.Status = TemporaryBuffer.Status::"Data Excel Error" then
                            ErrorFile := true;

                    end;

                if ErrorFile then
                    FTPCommunication.DoAction(Enum::"FTP Actions"::rename, FileName, FTPIntSetup.Directory, FTPIntSetup."Error Folder", '')
                else
                    FTPCommunication.DoAction(Enum::"FTP Actions"::rename, FileName, FTPIntSetup.Directory, FTPIntSetup."Imported Folder", '');


            until FTPDir.Next() = 0;

    end;

    procedure ImportExcelRcptJournalUnApply()
    var
        TemporaryBuffer: Record "Integration Rcpt Jnl UnApply";
        IntegrationErros: Record IntegrationErros;
        Customer: Record Customer;
        Bank: Record "Bank Account";
        RowNo: Integer;
        ColNo: Integer;
        LineNo: Integer;
        MaxRowNo: Integer;
        FTPIntSetup: Record "FTP Integration Setup";
        FTPDir: Record "FTP Directory" temporary;
        FTPCommunication: codeunit "FTP Communication";
        ret: Text;
        lines: List of [Text];
        line: Text;
        FileName: Text;
        EntryNo: BigInteger;
        CRLF: Char;
        fm29: Page 29;
        ErrorFile: Boolean;
        ExistLine: Boolean;
        MaxCollumn: Integer;
        IntReceiptUnApply: Record "Integration Rcpt Jnl UnApply";
        ExistLineNo: Integer;

    begin

        RowNo := 0;
        ColNo := 0;
        MaxRowNo := 0;
        LineNo := 0;

        //FTPIntSetup.Get(FTPIntSetup.Integration::"Sales Unapply");
        FTPIntSetup.Reset();
        FTPIntSetup.SetRange(Integration, FTPIntSetup.Integration::"Sales Unapply");
        FTPIntSetup.SetRange(Sequence, 0);
        FTPIntSetup.FindSet();

        CRLF := 10;

        ret := FTPCommunication.DoAction(Enum::"FTP Actions"::list, '', FTPIntSetup.Directory, '', '');
        lines := ret.Split(CRLF);

        FTPDir.Reset();
        FTPDir.DeleteAll();
        foreach line in lines do
            if line <> '' then begin
                FTPDir.Init();
                FTPDir.Filename := line;
                FTPDir.IsDirectory := (StrPos(line, '.') = 0);
                FTPDir.Insert();
            end;

        FTPDir.Reset();
        FTPDir.SetRange(IsDirectory, false);
        if FTPDir.Find('-') then
            repeat
                Clear(FTPCommunication);

                FileName := FTPDir.Filename.Trim();

                if FTPIntSetup."Active Prefix File Name" then begin
                    FTPIntSetup.testfield("Prefix File Name");
                    if StrPos(FileName, FTPIntSetup."Prefix File Name") = 0 then
                        Error('File Name Not Valid');
                end;

                EntryNo := FTPCommunication.DoAction(Enum::"FTP Actions"::download, FileName, FTPIntSetup.Directory, '', '');
                ReadExcelSheet(EntryNo);

                TemporaryBuffer.Reset();
                if TemporaryBuffer.FindLast() then
                    LineNo := TemporaryBuffer."Line No.";

                TempExcelBuffer.Reset();
                if TempExcelBuffer.FindLast() then
                    MaxRowNo := TempExcelBuffer."Row No.";

                //Column START Error
                if TempExcelBuffer.FindLast() then
                    MaxCollumn := TempExcelBuffer."Column No.";

                if MaxCollumn <> 23 then begin
                    TemporaryBuffer.Init();
                    TemporaryBuffer."Journal Template Name" := format(Today);
                    TemporaryBuffer."Journal Batch Name" := format(Time);
                    TemporaryBuffer."Line No." := LineNo;
                    TemporaryBuffer."Document No." := format(Today) + format(Time);
                    TemporaryBuffer.Status := TemporaryBuffer.Status::"Layout Error";
                    TemporaryBuffer."Excel File Name" := copystr(Filename, 1, 200);
                    IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Sales Unapply",
                      TemporaryBuffer."document No.", TemporaryBuffer."Line No.", CopyStr('', 1, 50),
                      'Layout Error', GetValueAtCell(RowNo, 2), TemporaryBuffer."Excel File Name");

                    if TemporaryBuffer.Insert() then
                        ErrorFile := true;

                end else
                    //Column END Error

                for RowNo := 2 to MaxRowNo do begin

                        LineNo := LineNo + 10000;

                        IntReceiptUnApply.reset;
                        IntReceiptUnApply.SetRange("Journal Template Name", (GetValueAtCell(RowNo, 1)));
                        IntReceiptUnApply.SetRange("Journal Batch Name", (GetValueAtCell(RowNo, 2)));
                        IntReceiptUnApply.SetRange("Document No.", (GetValueAtCell(RowNo, 8)));
                        Evaluate(LineNo, GetValueAtCell(RowNo, 3));
                        IntReceiptUnApply.SetRange("Line No.", LineNo); //Aug
                        clear(ExistLineNo);
                        clear(ExistLine);
                        if IntReceiptUnApply.Find('-') then
                            repeat
                                ExistLineNo := IntReceiptUnApply."Line No.";
                                ExistLine := true;
                            until IntReceiptUnApply.Next = 0;

                        if (StrLen(GetValueAtCell(RowNo, 1)) <= 10) then begin
                            if TemporaryBuffer.get(GetValueAtCell(RowNo, 1), GetValueAtCell(RowNo, 2), ExistLineNo) then begin
                                //Not Modify Posted Line
                                if TemporaryBuffer.Status = TemporaryBuffer.Status::Posted then begin
                                    ExistLine := false;
                                    TemporaryBuffer."Posting Message" := 'Duplicate ' + copystr(Filename, 1, 200);
                                    TemporaryBuffer.Modify();
                                    ErrorFile := true;
                                end else begin
                                    ExistLine := true;
                                    TemporaryBuffer.Status := TemporaryBuffer.Status::Imported;
                                end;
                            end else begin
                                ExistLine := false;
                                //<ExistLine
                                TemporaryBuffer.Init();
                                Evaluate(TemporaryBuffer."Journal Template Name", GetValueAtCell(RowNo, 1));
                                TemporaryBuffer.Status := TemporaryBuffer.Status::Imported;
                                Evaluate(TemporaryBuffer."Journal Batch Name", GetValueAtCell(RowNo, 2));
                                TemporaryBuffer."Line No." := LineNo
                            end;

                            //Delete Errors
                            IntegrationErros.Reset();
                            IntegrationErros.Setrange("Document No.", TemporaryBuffer."Document No.");
                            IntegrationErros.SetRange("Excel File Name", TemporaryBuffer."Excel File Name");
                            IntegrationErros.SetRange("Integration Type", IntegrationErros."Integration Type"::"Sales Unapply");
                            if IntegrationErros.FindSet() then
                                repeat
                                    IntegrationErros.DeleteAll();
                                until IntegrationErros.Next() = 0;

                        end else begin
                            TemporaryBuffer.Init();
                            Evaluate(TemporaryBuffer."Journal Template Name", 'Errors-' + format(RowNo));
                            Evaluate(TemporaryBuffer."Line No.", GetValueAtCell(RowNo, 1));
                            TemporaryBuffer.Status := TemporaryBuffer.Status::"Data Excel Error";
                            TemporaryBuffer."Excel File Name" := copystr(Filename, 1, 200);
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Sales UnApply",
                              TemporaryBuffer."Document No.", TemporaryBuffer."Line No.", CopyStr(TemporaryBuffer.FieldCaption("Journal Template Name"), 1, 10),
                              'Maximum 10 characters', GetValueAtCell(RowNo, 1), TemporaryBuffer."Excel File Name");
                        end;

                        if (StrLen(GetValueAtCell(RowNo, 2)) <= 10) then
                            Evaluate(TemporaryBuffer."Journal Batch Name", GetValueAtCell(RowNo, 2))
                        else begin
                            TemporaryBuffer.Status := TemporaryBuffer.Status::"Data Excel Error";
                            TemporaryBuffer."Excel File Name" := copystr(Filename, 1, 200);
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Sales UnApply",
                              TemporaryBuffer."Document No.", TemporaryBuffer."Line No.", CopyStr(TemporaryBuffer.FieldCaption("Journal Batch Name"), 1, 10),
                              'Maximum 10 characters', GetValueAtCell(RowNo, 2), TemporaryBuffer."Excel File Name");
                        end;

                        //Evaluate(TemporaryBuffer."Line No.", GetValueAtCell(RowNo, 3));

                        //Evaluate(TemporaryBuffer."Account Type", GetValueAtCell(RowNo, 4));
                        // if GetValueAtCell(RowNo, 4) <> 'Customer' then begin
                        //     TemporaryBuffer.Status := TemporaryBuffer.Status::"Data Excel Error";
                        //     IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Sales UnApply",
                        //           format(TemporaryBuffer."Document No."), TemporaryBuffer."Line No.", CopyStr(TemporaryBuffer.FieldCaption("Account Type"), 1, 10),
                        //           'Type <> Customer', GetValueAtCell(RowNo, 4), TemporaryBuffer."Excel File Name")
                        // end else
                        TemporaryBuffer."Account Type" := TemporaryBuffer."Account Type"::Customer;


                        if Customer.get(GetValueAtCell(RowNo, 5)) then
                            Evaluate(TemporaryBuffer."Account No.", GetValueAtCell(RowNo, 5))
                        else begin
                            TemporaryBuffer.Status := TemporaryBuffer.Status::"Data Excel Error";
                            TemporaryBuffer."Excel File Name" := copystr(Filename, 1, 200);
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Sales UnApply",
                                  TemporaryBuffer."Document No.", TemporaryBuffer."Line No.", CopyStr(TemporaryBuffer.FieldCaption("Account No."), 1, 10),
                                  'Customer Not Found', GetValueAtCell(RowNo, 5), TemporaryBuffer."Excel File Name")
                        end;


                        if ValidateDate(GetValueAtCell(RowNo, 6)) then
                            TemporaryBuffer."Posting Date" := GlobalDateYes
                        else begin
                            TemporaryBuffer.Status := TemporaryBuffer.Status::"Data Excel Error";
                            TemporaryBuffer."Excel File Name" := copystr(Filename, 1, 200);
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Sales UnApply",
                            TemporaryBuffer."document No.", TemporaryBuffer."Line No.", CopyStr(TemporaryBuffer.FieldCaption("Posting Date"), 1, 50),
                            CopyStr(GetLastErrorText(), 1, 250), GetValueAtCell(RowNo, 6), TemporaryBuffer."Excel File Name");
                        end;

                        Evaluate(TemporaryBuffer."Document Type", GetValueAtCell(RowNo, 7));
                        // if GetValueAtCell(RowNo, 7) <> 'Payment' then begin
                        //     TemporaryBuffer.Status := TemporaryBuffer.Status::"Data Excel Error";
                        //     IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Sales UnApply",
                        //           format(TemporaryBuffer."Document No."), TemporaryBuffer."Line No.", CopyStr(TemporaryBuffer.FieldCaption("Document Type"), 1, 10),
                        //           'Type <> Payment', GetValueAtCell(RowNo, 7), TemporaryBuffer."Excel File Name")
                        // end else
                        //     TemporaryBuffer."document Type" := TemporaryBuffer."Document Type"::Payment;

                        if (StrLen(GetValueAtCell(RowNo, 8)) <= 20) then
                            Evaluate(TemporaryBuffer."Document No.", GetValueAtCell(RowNo, 8))
                        else begin
                            TemporaryBuffer.Status := TemporaryBuffer.Status::"Data Excel Error";
                            TemporaryBuffer."Excel File Name" := copystr(Filename, 1, 200);
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Sales UnApply",
                              TemporaryBuffer."Document No.", TemporaryBuffer."Line No.", CopyStr(TemporaryBuffer.FieldCaption("Document No."), 1, 20),
                              'Maximum 20 characters', GetValueAtCell(RowNo, 8), TemporaryBuffer."Excel File Name");
                        end;

                        if (StrLen(GetValueAtCell(RowNo, 9)) <= 100) then
                            Evaluate(TemporaryBuffer.Description, GetValueAtCell(RowNo, 9))
                        else begin
                            TemporaryBuffer.Status := TemporaryBuffer.Status::"Data Excel Error";
                            TemporaryBuffer."Excel File Name" := copystr(Filename, 1, 200);
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Sales UnApply",
                              TemporaryBuffer."Document No.", TemporaryBuffer."Line No.", CopyStr(TemporaryBuffer.FieldCaption(Description), 1, 100),
                              'Maximum 100 characters', GetValueAtCell(RowNo, 9), TemporaryBuffer."Excel File Name");
                        end;

                        Evaluate(TemporaryBuffer."Bal. Account Type", GetValueAtCell(RowNo, 10));
                        // if GetValueAtCell(RowNo, 10) <> 'Bank Account' then begin
                        //     TemporaryBuffer.Status := TemporaryBuffer.Status::"Data Excel Error";
                        //     IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Sales UnApply",
                        //           format(TemporaryBuffer."Document No."), TemporaryBuffer."Line No.", CopyStr(TemporaryBuffer.FieldCaption("Bal. Account Type"), 1, 10),
                        //           'Type <> Bank Account', GetValueAtCell(RowNo, 10), TemporaryBuffer."Excel File Name")
                        // end else
                        //     TemporaryBuffer."Bal. Account Type" := TemporaryBuffer."Bal. Account Type"::"Bank Account";


                        if Bank.get(GetValueAtCell(RowNo, 11)) then
                            Evaluate(TemporaryBuffer."Bal. Account No.", GetValueAtCell(RowNo, 11))
                        else begin
                            TemporaryBuffer."Excel File Name" := copystr(Filename, 1, 200);
                            TemporaryBuffer.Status := TemporaryBuffer.Status::"Data Excel Error";
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Sales UnApply",
                                  TemporaryBuffer."Document No.", TemporaryBuffer."Line No.", CopyStr(TemporaryBuffer.FieldCaption("Bal. Account No."), 1, 10),
                                  'Bank Not Found', GetValueAtCell(RowNo, 11), TemporaryBuffer."Excel File Name")
                        end;

                        if GetValueAtCell(RowNo, 13) <> '' then
                            Evaluate(TemporaryBuffer.Amount, GetValueAtCell(RowNo, 13));
                        if TemporaryBuffer.Amount = 0 then begin
                            TemporaryBuffer.Status := TemporaryBuffer.Status::"Data Excel Error";
                            TemporaryBuffer."Excel File Name" := copystr(Filename, 1, 200);
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Sales UNApply",
                                  TemporaryBuffer."Document No.", TemporaryBuffer."Line No.", CopyStr(TemporaryBuffer.FieldCaption(Amount), 1, 10),
                                  'Amount Not Found', GetValueAtCell(RowNo, 13), TemporaryBuffer."Excel File Name");
                        end;

                        Evaluate(TemporaryBuffer."dimension 1", GetValueAtCell(RowNo, 15));
                        Evaluate(TemporaryBuffer."dimension 2", GetValueAtCell(RowNo, 16));
                        Evaluate(TemporaryBuffer."dimension 3", GetValueAtCell(RowNo, 17));
                        Evaluate(TemporaryBuffer."dimension 4", GetValueAtCell(RowNo, 18));
                        Evaluate(TemporaryBuffer."dimension 5", GetValueAtCell(RowNo, 19));
                        Evaluate(TemporaryBuffer."dimension 6", GetValueAtCell(RowNo, 20));

                        Evaluate(TemporaryBuffer."Applies-to Doc. Type", GetValueAtCell(RowNo, 21));

                        if (StrLen(GetValueAtCell(RowNo, 22)) <= 20) then
                            Evaluate(TemporaryBuffer."Applies-to Doc. No.", GetValueAtCell(RowNo, 22))
                        else begin
                            TemporaryBuffer.Status := TemporaryBuffer.Status::"Data Excel Error";
                            TemporaryBuffer."Excel File Name" := copystr(Filename, 1, 200);
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Sales UnApply",
                              TemporaryBuffer."Document No.", TemporaryBuffer."Line No.", CopyStr(TemporaryBuffer.FieldCaption("Applies-to Doc. No."), 1, 20),
                              'Maximum 20 characters', GetValueAtCell(RowNo, 22), TemporaryBuffer."Excel File Name");
                        end;

                        if (StrLen(GetValueAtCell(RowNo, 23)) <= 20) then
                            Evaluate(TemporaryBuffer."External Document No.", GetValueAtCell(RowNo, 23))
                        else begin
                            TemporaryBuffer.Status := TemporaryBuffer.Status::"Data Excel Error";
                            TemporaryBuffer."Excel File Name" := copystr(Filename, 1, 200);
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Sales UnApply",
                              TemporaryBuffer."Document No.", TemporaryBuffer."Line No.", CopyStr(TemporaryBuffer.FieldCaption("External Document No."), 1, 20),
                              'Maximum 20 characters', GetValueAtCell(RowNo, 23), TemporaryBuffer."Excel File Name");
                        end;

                        //TemporaryBuffer."Line No." := LineNo;

                        TemporaryBuffer."Excel File Name" := copystr(Filename, 1, 200);

                        if ExistLine then
                            TemporaryBuffer.Modify()
                        else
                            if TemporaryBuffer.Insert() then;

                        if TemporaryBuffer.Status = TemporaryBuffer.Status::"Data Excel Error" then
                            ErrorFile := true;

                    end;

                if ErrorFile then
                    FTPCommunication.DoAction(Enum::"FTP Actions"::rename, FileName, FTPIntSetup.Directory, FTPIntSetup."Error Folder", '')
                else
                    FTPCommunication.DoAction(Enum::"FTP Actions"::rename, FileName, FTPIntSetup.Directory, FTPIntSetup."Imported Folder", '');


            until FTPDir.Next() = 0;

    end;

    procedure ReadExcelSheet(EntryNo: BigInteger)
    var
        FileMgt: Codeunit "File Management";
        SheetName: Text[250];
        FTPLog: Record "FTP Log";
        ExcelInStream: InStream;
        RequestMessage: Text;
    begin

        FTPLog.Reset();
        FTPLog.Get(EntryNo);
        FTPLog.CalcFields(Response);

        FTPLog.CalcFields(Response);
        FTPLog.Response.CreateInStream(ExcelInStream);

        SheetName := TempExcelBuffer.SelectSheetsNameStream(ExcelInStream);

        TempExcelBuffer.Reset();
        TempExcelBuffer.DeleteAll();
        TempExcelBuffer.OpenBookStream(ExcelInStream, SheetName);
        TempExcelBuffer.SetReadDateTimeInUtcDate(true);
        TempExcelBuffer.ReadSheet();

    end;

    local procedure GetValueAtCell(RowNo: Integer; ColNo: Integer): Text
    begin

        TempExcelBuffer.Reset();
        if TempExcelBuffer.Get(RowNo, ColNo) then
            exit(TempExcelBuffer."Cell Value as Text")
        else
            exit('');
    end;

    [TryFunction]
    local procedure ValidateDate(VDate: Text)
    var
        DateYes: Date;
    begin
        Clear(GlobalDateYes);

        if GlobalLanguage <> 1046 then begin
            if StrLen(VDate) = 8 then
                VDate := '20' + CopyStr(VDate, 7, 4) + '-' + CopyStr(VDate, 1, 2) + '-' + CopyStr(VDate, 4, 2)
            else
                VDate := CopyStr(VDate, 7, 4) + '-' + CopyStr(VDate, 4, 2) + '-' + CopyStr(VDate, 1, 2);

            evaluate(DateYes, VDate);
        end else
            evaluate(DateYes, VDate);

        GlobalDateYes := DateYes;

    end;

    [TryFunction]
    local procedure ValidateDecimal(VDecimal: Text)
    var
        DecimalYes: Decimal;
    begin
        Clear(GlobalDecimalYes);

        if GlobalLanguage <> 1046 then begin

            VDecimal := ConvertStr(VDecimal, ',', '.');
            evaluate(DecimalYes, VDecimal);
        end else
            evaluate(DecimalYes, VDecimal);

        GlobalDecimalYes := DecimalYes;

    end;

    procedure ImportExcelCustomer()
    var
        IntegrationCustomer: Record "Integration Customer";
        IntegrationErros: Record IntegrationErros;
        FTPCommunication: codeunit "FTP Communication";
        EntryNo: BigInteger;
        RowNo: Integer;
        ColNo: Integer;
        LineNo: Integer;
        MaxRowNo: Integer;
        PostCode: Record "Post Code";
        ErrorFile: Boolean;
        FileName: Text;
        FTPIntSetup: Record "FTP Integration Setup";
        FTPDir: Record "FTP Directory";
        ret: Text;
        lines: List of [Text];
        line: Text;
        CRLF: Char;
        MaxCollumn: Integer;

    begin
        RowNo := 0;
        ColNo := 0;
        MaxRowNo := 0;
        LineNo := 0;
        MaxCollumn := 0;

        //FTPIntSetup.Get(FTPIntSetup.Integration::Customer);
        FTPIntSetup.Reset();
        FTPIntSetup.SetRange(Integration, FTPIntSetup.Integration::Customer);
        FTPIntSetup.SetRange(Sequence, 0);
        FTPIntSetup.FindSet();

        CRLF := 10;

        ret := FTPCommunication.DoAction(Enum::"FTP Actions"::list, '', FTPIntSetup.Directory, '', '');
        lines := ret.Split(CRLF);

        FTPDir.Reset();
        FTPDir.DeleteAll();
        foreach line in lines do
            if line <> '' then begin
                FTPDir.Init();
                FTPDir.Filename := line;
                FTPDir.IsDirectory := (StrPos(line, '.') = 0);
                FTPDir.Insert();
            end;

        FTPDir.Reset();
        FTPDir.SetRange(IsDirectory, false);
        if FTPDir.Find('-') then
            repeat
                Clear(FTPCommunication);

                FileName := FTPDir.Filename.Trim();

                if FTPIntSetup."Active Prefix File Name" then begin
                    FTPIntSetup.testfield("Prefix File Name");
                    if StrPos(FileName, FTPIntSetup."Prefix File Name") = 0 then
                        Error('File Name Not Valid');
                end;

                EntryNo := FTPCommunication.DoAction(Enum::"FTP Actions"::download, FileName, FTPIntSetup.Directory, '', '');
                ReadExcelSheet(EntryNo);


                IntegrationCustomer.Reset();
                TempExcelBuffer.Reset();
                if TempExcelBuffer.FindLast() then
                    MaxRowNo := TempExcelBuffer."Row No.";

                //Column START Error
                if TempExcelBuffer.FindLast() then
                    MaxCollumn := TempExcelBuffer."Column No.";

                if MaxCollumn <> 15 then begin
                    IntegrationCustomer.Init();
                    Evaluate(IntegrationCustomer."No.", copystr(Filename, 1, 20));
                    IntegrationCustomer.Status := IntegrationCustomer.Status::"Layout Error";
                    IntegrationCustomer."Excel File Name" := copystr(Filename, 1, 200);
                    IntegrationErros.InsertErros(IntegrationErros."Integration Type"::Customer,
                      IntegrationCustomer."No.", 1, CopyStr('', 1, 50),
                      'Layout Error', GetValueAtCell(RowNo, 2), IntegrationCustomer."Excel File Name");

                    if IntegrationCustomer.Insert() then
                        ErrorFile := true;

                end else
                    //Column END Error

                for RowNo := 2 to MaxRowNo do begin
                        LineNo := LineNo + 10000;

                        if (StrLen(GetValueAtCell(RowNo, 1)) <= 20) then begin
                            IntegrationCustomer.Init();
                            IntegrationCustomer.Status := IntegrationCustomer.Status::Imported;
                            Evaluate(IntegrationCustomer."No.", GetValueAtCell(RowNo, 1));
                            IntegrationCustomer."Excel File Name" := copystr(Filename, 1, 200);

                        end else begin
                            IntegrationCustomer.Init();
                            Evaluate(IntegrationCustomer."No.", 'Errors-' + format(RowNo));
                            IntegrationCustomer.Status := IntegrationCustomer.Status::"Data Excel Error";
                            IntegrationCustomer."Excel File Name" := copystr(Filename, 1, 200);
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::Customer,
                             IntegrationCustomer."No.", 1, CopyStr(IntegrationCustomer.FieldCaption("No."), 1, 50),
                              'Maximum 20 characters', GetValueAtCell(RowNo, 1), IntegrationCustomer."Excel File Name");
                        end;

                        if ((getValueAtCell(RowNo, 2)) <> '') then
                            Evaluate(IntegrationCustomer.Name, Copystr(GetValueAtCell(RowNo, 2), 1, 100));

                        if ((GetValueAtCell(RowNo, 3)) <> '') then
                            Evaluate(IntegrationCustomer."Search Name", Copystr(GetValueAtCell(RowNo, 3), 1, 50));

                        if ((GetValueAtCell(RowNo, 5)) <> '') then
                            Evaluate(IntegrationCustomer."Post Code", Copystr(GetValueAtCell(RowNo, 5), 1, 20));

                        if ((GetValueAtCell(RowNo, 6)) <> '') then
                            Evaluate(IntegrationCustomer.Country, Copystr(GetValueAtCell(RowNo, 6), 1, 30));

                        if ((GetValueAtCell(RowNo, 7)) <> '') then
                            Evaluate(IntegrationCustomer."Territory Code", Copystr(GetValueAtCell(RowNo, 7), 1, 10));

                        if ((GetValueAtCell(RowNo, 8)) <> '') then
                            Evaluate(IntegrationCustomer.City, CopyStr(GetValueAtCell(RowNo, 8), 1, 30));

                        if ((GetValueAtCell(RowNo, 9)) <> '') then
                            Evaluate(IntegrationCustomer.Address, Copystr(GetValueAtCell(RowNo, 9), 1, 100));

                        if ((GetValueAtCell(RowNo, 10)) <> '') then
                            Evaluate(IntegrationCustomer."Address 2", Copystr(GetValueAtCell(RowNo, 10), 1, 50));

                        if ((GetValueAtCell(RowNo, 11)) <> '') then
                            Evaluate(IntegrationCustomer.Number, CopyStr(GetValueAtCell(RowNo, 11), 1, 12));

                        if ((GetValueAtCell(RowNo, 12)) <> '') then
                            Evaluate(IntegrationCustomer."Phone No.", CopyStr(GetValueAtCell(RowNo, 12), 1, 30));

                        if ((GetValueAtCell(RowNo, 13)) <> '') then
                            Evaluate(IntegrationCustomer."Phone No. 2", CopyStr(GetValueAtCell(RowNo, 13), 1, 30));

                        if ((GetValueAtCell(RowNo, 14)) <> '') then
                            Evaluate(IntegrationCustomer."E-Mail", CopyStr(GetValueAtCell(RowNo, 14), 1, 80));

                        if ((GetValueAtCell(RowNo, 15)) <> '') then
                            Evaluate(IntegrationCustomer."C.N.P.J./C.P.F.", CopyStr(GetValueAtCell(RowNo, 15), 1, 20))
                        else begin
                            IntegrationCustomer.Init();
                            Evaluate(IntegrationCustomer."No.", 'Errors-' + format(RowNo));
                            IntegrationCustomer.Status := IntegrationCustomer.Status::"Data Excel Error";
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::Customer,
                             IntegrationCustomer."No.", 1, CopyStr(IntegrationCustomer.FieldCaption("C.N.P.J./C.P.F."), 1, 20),
                              'CNPJ/CPF Not Found', GetValueAtCell(RowNo, 15), IntegrationCustomer."Excel File Name");
                        end;

                        IntegrationCustomer."Excel File Name" := copystr(Filename, 1, 200);
                        if IntegrationCustomer.Insert() then;

                        if IntegrationCustomer.Status = IntegrationCustomer.Status::"Data Excel Error" then
                            ErrorFile := true;
                    end;

                if ErrorFile then
                    FTPCommunication.DoAction(Enum::"FTP Actions"::rename, FileName, FTPIntSetup.Directory, FTPIntSetup."Error Folder", '')
                else
                    FTPCommunication.DoAction(Enum::"FTP Actions"::rename, FileName, FTPIntSetup.Directory, FTPIntSetup."Imported Folder", '');

            until FTPDir.Next() = 0;
    end;

    procedure ImportExcelVendor()
    var
        IntegrationVendor: Record "Integration Vendor";
        IntegrationErros: Record IntegrationErros;
        FTPCommunication: codeunit "FTP Communication";
        EntryNo: BigInteger;
        RowNo: Integer;
        ColNo: Integer;
        LineNo: Integer;
        MaxRowNo: Integer;
        PostCode: Record "Post Code";
        PaymentTerms: Record "Payment Terms";
        PaymentMetho: Record "Payment Method";
        ErrorFile: Boolean;
        FileName: Text;
        FTPIntSetup: Record "FTP Integration Setup";
        FTPDir: Record "FTP Directory";
        ret: Text;
        lines: List of [Text];
        line: Text;
        CRLF: Char;
        MaxCollumn: Integer;
    begin
        RowNo := 0;
        ColNo := 0;
        MaxRowNo := 0;
        LineNo := 0;
        MaxCollumn := 0;

        //FTPIntSetup.Get(FTPIntSetup.Integration::Vendor);
        FTPIntSetup.Reset();
        FTPIntSetup.SetRange(Integration, FTPIntSetup.Integration::Vendor);
        FTPIntSetup.SetRange(Sequence, 0);
        FTPIntSetup.FindSet();

        CRLF := 10;

        ret := FTPCommunication.DoAction(Enum::"FTP Actions"::list, '', FTPIntSetup.Directory, '', '');
        lines := ret.Split(CRLF);

        FTPDir.Reset();
        FTPDir.DeleteAll();
        foreach line in lines do
            if line <> '' then begin
                FTPDir.Init();
                FTPDir.Filename := line;
                FTPDir.IsDirectory := (StrPos(line, '.') = 0);
                FTPDir.Insert();
            end;

        FTPDir.Reset();
        FTPDir.SetRange(IsDirectory, false);
        if FTPDir.Find('-') then
            repeat
                Clear(FTPCommunication);

                FileName := FTPDir.Filename.Trim();

                if FTPIntSetup."Active Prefix File Name" then begin
                    FTPIntSetup.testfield("Prefix File Name");
                    if StrPos(FileName, FTPIntSetup."Prefix File Name") = 0 then
                        Error('File Name Not Valid');
                end;

                EntryNo := FTPCommunication.DoAction(Enum::"FTP Actions"::download, FileName, FTPIntSetup.Directory, '', '');
                ReadExcelSheet(EntryNo);

                IntegrationVendor.Reset();
                TempExcelBuffer.Reset();
                if TempExcelBuffer.FindLast() then
                    MaxRowNo := TempExcelBuffer."Row No.";

                //Column START Error
                if TempExcelBuffer.FindLast() then
                    MaxCollumn := TempExcelBuffer."Column No.";

                if MaxCollumn <> 16 then begin
                    IntegrationVendor.Init();
                    Evaluate(IntegrationVendor."No.", copystr(Filename, 1, 20));
                    IntegrationVendor.Status := IntegrationVendor.Status::"Layout Error";
                    IntegrationVendor."Excel File Name" := copystr(Filename, 1, 200);
                    IntegrationErros.InsertErros(IntegrationErros."Integration Type"::Vendor,
                      IntegrationVendor."No.", 1, CopyStr('', 1, 50),
                      'Layout Error', GetValueAtCell(RowNo, 2), IntegrationVendor."Excel File Name");

                    if IntegrationVendor.Insert() then
                        ErrorFile := true;

                end else
                    //Column END Error

                    for RowNo := 2 to MaxRowNo do begin
                        LineNo := LineNo + 10000;

                        if (StrLen(GetValueAtCell(RowNo, 1)) <= 20) then begin
                            IntegrationVendor.Init();
                            IntegrationVendor.Status := IntegrationVendor.Status::Imported;
                            Evaluate(IntegrationVendor."No.", GetValueAtCell(RowNo, 1));
                            IntegrationVendor."Excel File Name" := copystr(Filename, 1, 200);
                            ;
                        end else begin
                            IntegrationVendor.Init();
                            Evaluate(IntegrationVendor."No.", 'Errors-' + format(RowNo));
                            IntegrationVendor.Status := IntegrationVendor.Status::"Data Excel Error";
                            IntegrationVendor."Excel File Name" := copystr(Filename, 1, 200);
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::Vendor,
                             IntegrationVendor."No.", 1, CopyStr(IntegrationVendor.FieldCaption("No."), 1, 50),
                              'Maximum 20 characters', GetValueAtCell(RowNo, 1), IntegrationVendor."Excel File Name");
                        end;

                        if ((GetValueAtCell(RowNo, 2)) <> '') then
                            Evaluate(IntegrationVendor.Name, Copystr(GetValueAtCell(RowNo, 2), 1, 100));

                        if ((GetValueAtCell(RowNo, 3)) <> '') then
                            Evaluate(IntegrationVendor."Search Name", Copystr(GetValueAtCell(RowNo, 3), 1, 50));

                        if ((GetValueAtCell(RowNo, 4)) <> '') then
                            Evaluate(IntegrationVendor."Post Code", Copystr(GetValueAtCell(RowNo, 4), 1, 20));

                        if ((GetValueAtCell(RowNo, 5)) <> '') then
                            Evaluate(integrationvendor.Country, Copystr(GetValueAtCell(RowNo, 5), 1, 30));

                        if ((GetValueAtCell(RowNo, 6)) <> '') then
                            Evaluate(IntegrationVendor."Territory Code", Copystr(GetValueAtCell(RowNo, 6), 1, 10));

                        if ((GetValueAtCell(RowNo, 7)) <> '') then
                            Evaluate(IntegrationVendor.Address, Copystr(GetValueAtCell(RowNo, 7), 1, 100));

                        if ((GetValueAtCell(RowNo, 8)) <> '') then
                            Evaluate(IntegrationVendor."Address 2", Copystr(GetValueAtCell(RowNo, 8), 1, 50));

                        //         if ((GetValueAtCell(RowNo, 9)) <> '') then
                        //             Evaluate(IntegrationVendor."Address 3", Copystr(GetValueAtCell(RowNo, 9), 1, 50));

                        if ((GetValueAtCell(RowNo, 9)) <> '') then
                            Evaluate(IntegrationVendor.Number, CopyStr(GetValueAtCell(RowNo, 9), 1, 12));

                        if ((GetValueAtCell(RowNo, 10)) <> '') then
                            Evaluate(IntegrationVendor.City, CopyStr(GetValueAtCell(RowNo, 10), 1, 30));

                        if ((GetValueAtCell(RowNo, 11)) <> '') then
                            Evaluate(IntegrationVendor."Phone No.", CopyStr(GetValueAtCell(RowNo, 11), 1, 30));

                        //  if ((GetValueAtCell(RowNo, 13)) <> '') then
                        //      Evaluate(IntegrationVendor."Phone No. 2", CopyStr(GetValueAtCell(RowNo, 13), 1, 30));

                        if ((GetValueAtCell(RowNo, 12)) <> '') then
                            Evaluate(IntegrationVendor."Payment Terms Code", CopyStr(GetValueAtCell(RowNo, 12), 1, 10));

                        if ((GetValueAtCell(RowNo, 13)) <> '') then
                            Evaluate(IntegrationVendor."Payment Method Code", CopyStr(GetValueAtCell(RowNo, 13), 1, 10));

                        if ((GetValueAtCell(RowNo, 15)) <> '') then
                            Evaluate(IntegrationVendor."E-Mail", CopyStr(GetValueAtCell(RowNo, 15), 1, 80));

                        if ((GetValueAtCell(RowNo, 16)) <> '') then
                            Evaluate(IntegrationVendor."C.N.P.J./C.P.F.", CopyStr(GetValueAtCell(RowNo, 16), 1, 20))
                        else begin
                            IntegrationVendor.Init();
                            Evaluate(IntegrationVendor."No.", 'Errors-' + format(RowNo));
                            IntegrationVendor.Status := IntegrationVendor.Status::"Data Excel Error";
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::Vendor,
                             IntegrationVendor."No.", 1, CopyStr(IntegrationVendor.FieldCaption("C.N.P.J./C.P.F."), 1, 20),
                              'CNPJ/CPF Not Found', GetValueAtCell(RowNo, 16), IntegrationVendor."Excel File Name");
                        end;

                        IntegrationVendor."Excel File Name" := copystr(Filename, 1, 200);
                        ;
                        if IntegrationVendor.Insert() then;

                        if IntegrationVendor.Status = IntegrationVendor.Status::"Data Excel Error" then
                            ErrorFile := true;
                    end;

                if ErrorFile then
                    FTPCommunication.DoAction(Enum::"FTP Actions"::rename, FileName, FTPIntSetup.Directory, FTPIntSetup."Error Folder", '')
                else
                    FTPCommunication.DoAction(Enum::"FTP Actions"::rename, FileName, FTPIntSetup.Directory, FTPIntSetup."Imported Folder", '');

            until FTPDir.Next() = 0;

    end;

    procedure ImportExcelPaymentPurchaseJournal(Integration: Enum "FTP Integration Type")
    var
        IntegrationImportStatus: enum "Integration Import Status";
        CompareIntImportStatus: enum "Integration Import Status";
        IntegrationRef: Recordref;
        IntegrationFieldRef: FieldRef;
        SearchRef: Recordref;
        SearchFieldRef: FieldRef;
        IntegrationErrosType: Enum IntegrationErrosType;
        IntegrationErros: Record IntegrationErros;
        FTPIntSetup: Record "FTP Integration Setup";
        FTPDir: Record "FTP Directory";
        intPurc: Record "Integration Purchase";
        VLE: Record "Vendor Ledger Entry";
        VatEntry: Record "VAT Entry";
        FTPCommunication: codeunit "FTP Communication";
        IntPurcPay: Record IntPurchPayment;
        ret: Text;
        lines: List of [Text];
        line: Text;
        FileName: Text;
        EntryNo: BigInteger;
        RowNo: Integer;
        ColNo: Integer;
        LineNo: Integer;
        MaxRowNo: Integer;
        MaxCollNo: integer;
        CRLF: Char;
        TextValue: Text;
        DecimalValue: Decimal;
        IntegerValue: Integer;
        DateValue: Date;
        ErrorFile: Boolean;
        ExistingLineNo: Integer;
        ExistLine: Boolean;
        ReplicationKeyIndex: Integer;
        MissingKeyReplicationCounterErr: Label 'Secondary Key for table ''%1'' on field ''%2'' is missing. This is a programming error.';
        IntegrationEmail: Codeunit "Integration Email";
        DocNo: Text;
        TotDirectUnit: Decimal;
        DecimalValueTot: Decimal;

    begin
        RowNo := 0;
        ColNo := 0;
        MaxRowNo := 0;
        LineNo := 0;

        //FTPIntSetup.Get(Integration);
        FTPIntSetup.Reset();
        FTPIntSetup.SetRange(Integration, Integration);
        FTPIntSetup.SetRange(Sequence, 0);
        FTPIntSetup.FindSet();

        case Integration of
            Integration::"Purchase Payment":
                begin
                    IntegrationRef.Open(Database::IntPurchPayment);
                    SearchRef.Open(Database::IntPurchPayment);
                    IntegrationErrosType := IntegrationErrosType::"Purchase Payment";
                end;
            Integration::"Purchase Apply":
                begin
                    IntegrationRef.Open(Database::IntPurchPaymentApply);
                    SearchRef.Open(Database::IntPurchPaymentApply);
                    IntegrationErrosType := IntegrationErrosType::"Purchase Apply";
                end;
            Integration::"Purchase Unapply":
                begin
                    IntegrationRef.Open(Database::IntPurchPaymentUnapply);
                    SearchRef.Open(Database::IntPurchPaymentUnapply);
                    IntegrationErrosType := IntegrationErrosType::"Purchase Unapply";
                end;
            else
                Error(TypeIntergationErrorLbl, FTPIntSetup.FieldCaption(Integration));
        end;

        CRLF := 10;

        ret := FTPCommunication.DoAction(Enum::"FTP Actions"::list, '', FTPIntSetup.Directory, '', '');
        lines := ret.Split(CRLF);

        FTPDir.Reset();
        FTPDir.DeleteAll();
        foreach line in lines do
            if line <> '' then begin
                FTPDir.Init();
                FTPDir.Filename := line;
                FTPDir.IsDirectory := (StrPos(line, '.') = 0);
                FTPDir.Insert();
            end;

        FTPDir.Reset();
        FTPDir.SetRange(IsDirectory, false);
        if FTPDir.Find('-') then
            repeat
                Clear(FTPCommunication);
                ErrorFile := false;
                FileName := FTPDir.Filename.Trim();

                if FTPIntSetup."Active Prefix File Name" then begin
                    FTPIntSetup.testfield("Prefix File Name");
                    if StrPos(FileName, FTPIntSetup."Prefix File Name") = 0 then
                        Error('File Name Not Valid');
                end;

                EntryNo := FTPCommunication.DoAction(Enum::"FTP Actions"::download, FileName, FTPIntSetup.Directory, '', '');
                ReadExcelSheet(EntryNo);

                TempExcelBuffer.Reset();
                if TempExcelBuffer.FindLast() then begin
                    MaxRowNo := TempExcelBuffer."Row No.";
                    MaxCollNo := TempExcelBuffer."Column No.";
                end;

                if MaxCollNo <> 22 then begin
                    ErrorFile := true;

                    IntegrationRef.Init();
                    IntegrationFieldRef := IntegrationRef.Field(1);
                    IntegrationFieldRef.Value := copystr(format(Today) + ' ' + format(Time), 1, IntegrationFieldRef.Length);

                    IntegrationFieldRef := IntegrationRef.Field(2);
                    IntegrationFieldRef.Value := copystr(format(Today) + ' ' + format(Time), 1, IntegrationFieldRef.Length);

                    IntegrationFieldRef := IntegrationRef.Field(3);
                    IntegrationFieldRef.Value := 10000;
                    IntegrationFieldRef := IntegrationRef.Field(98);
                    IntegrationFieldRef.Value := IntegrationImportStatus::"Layout Error";
                    IntegrationFieldRef := IntegrationRef.Field(115);
                    IntegrationFieldRef.value := CopyStr(FileName, 1, IntegrationFieldRef.Length);
                    IntegrationErros.InsertErros(IntegrationErrosType, '', LineNo, '', 'Layout Error', '', FileName);
                    IntegrationRef.Insert();
                end
                else
                    for RowNo := 2 to MaxRowNo do begin

                        Clear(LineNo);
                        clear(ExistingLineNo);
                        clear(ExistLine);
                        Clear(DocNo);

                        Evaluate(LineNo, GetValueAtCell(RowNo, 3));
                        DocNo := GetValueAtCell(RowNo, 8);
                        SearchRef.CurrentKeyIndex(2);

                        SearchFieldRef := SearchRef.Field(1);
                        SearchFieldRef.SetRange(GetValueAtCell(RowNo, 1));
                        SearchFieldRef := SearchRef.Field(2);
                        SearchFieldRef.SetRange(GetValueAtCell(RowNo, 2));
                        SearchFieldRef := SearchRef.Field(3);
                        SearchFieldRef.SetRange(LineNo);
                        SearchFieldRef := SearchRef.Field(8);
                        SearchFieldRef.SetRange(GetValueAtCell(RowNo, 8));
                        if SearchRef.FindFirst() then begin
                            SearchFieldRef := SearchRef.Field(3);
                            ExistingLineNo := SearchFieldRef.Value;
                            ExistLine := true;
                        end;

                        //"Journal Template Name"
                        ColNo := 1;
                        Clear(TextValue);
                        TextValue := GetValueAtCell(RowNo, ColNo);
                        TextValue := TextValue.Trim();

                        if StrLen(TextValue) <= 10 then begin

                            if ExistLine then begin
                                IntegrationRef.Get(SearchRef.RecordId);

                                //Status
                                IntegrationFieldRef := IntegrationRef.Field(98);
                                CompareIntImportStatus := IntegrationFieldRef.Value;
                                if CompareIntImportStatus = IntegrationImportStatus::Posted then begin
                                    ExistLine := false;
                                    //posting Message
                                    IntegrationFieldRef := IntegrationRef.Field(99);
                                    IntegrationFieldRef.Value := 'Duplicate ' + copystr(Filename, 1, 200);
                                    IntegrationRef.Modify();

                                end
                                else begin
                                    ExistLine := true;
                                    //Status
                                    IntegrationFieldRef := IntegrationRef.Field(98);
                                    IntegrationFieldRef.Value := IntegrationImportStatus::Imported;
                                    IntegrationFieldRef := IntegrationRef.Field(115);
                                    IntegrationFieldRef.value := CopyStr(FileName, 1, IntegrationFieldRef.Length);
                                end;

                            end
                            else begin
                                ExistLine := false;

                                IntegrationRef.Init();

                                //"Journal Template Name"
                                IntegrationFieldRef := IntegrationRef.Field(ColNo);
                                IntegrationFieldRef.Value := TextValue;

                                //Line No.
                                IntegrationFieldRef := IntegrationRef.Field(3);
                                IntegrationFieldRef.Value := LineNo;

                                //Status
                                IntegrationFieldRef := IntegrationRef.Field(98);
                                IntegrationFieldRef.Value := IntegrationImportStatus::Imported;

                                //"Excel File Name"
                                IntegrationFieldRef := IntegrationRef.Field(115);
                                IntegrationFieldRef.value := CopyStr(FileName, 1, IntegrationFieldRef.Length);
                            end;

                        end else begin
                            IntegrationRef.Init();

                            //Line No.
                            IntegrationFieldRef := IntegrationRef.Field(3);
                            IntegrationFieldRef.Value := LineNo;

                            //Status
                            IntegrationFieldRef := IntegrationRef.Field(98);
                            IntegrationFieldRef.Value := IntegrationImportStatus::"Data Excel Error";

                            //"Excel File Name"
                            IntegrationFieldRef := IntegrationRef.Field(115);
                            IntegrationFieldRef.value := CopyStr(FileName, 1, IntegrationFieldRef.Length);

                            //"Journal Template Name"
                            IntegrationFieldRef := IntegrationRef.Field(ColNo);
                            IntegrationFieldRef.Value := 'Errors-' + format(RowNo);

                            IntegrationErros.InsertErros(IntegrationErrosType, DocNo, LineNo, CopyStr(IntegrationFieldRef.Caption, 1, 50), 'Maximum 10 characters', TextValue, FileName);
                            ErrorFile := true;
                        end;

                        if not (CompareIntImportStatus = IntegrationImportStatus::Posted) then begin
                            //"Journal Batch Name"
                            ColNo := 2;
                            Clear(TextValue);
                            TextValue := GetValueAtCell(RowNo, ColNo);
                            TextValue := TextValue.Trim();

                            if (StrLen(TextValue) <= 10) then begin
                                //"Journal Batch Name"
                                IntegrationFieldRef := IntegrationRef.Field(ColNo);
                                IntegrationFieldRef.Value := TextValue;

                            end else begin
                                //Status
                                IntegrationFieldRef := IntegrationRef.Field(98);
                                IntegrationFieldRef.Value := IntegrationImportStatus::"Data Excel Error";

                                //"Journal Batch Name"
                                IntegrationFieldRef := IntegrationRef.Field(ColNo);
                                IntegrationFieldRef.Value := 'Errors-' + format(RowNo);

                                IntegrationErros.InsertErros(IntegrationErrosType, DocNo, LineNo, CopyStr(IntegrationFieldRef.Caption, 1, 50), 'Maximum 10 characters', TextValue, FileName);
                                ErrorFile := true;
                            end;

                            //"Account No."
                            ColNo := 5;
                            Clear(TextValue);
                            TextValue := GetValueAtCell(RowNo, ColNo);
                            TextValue := TextValue.Trim();

                            if (StrLen(TextValue) <= 20) then begin
                                //"Account No."
                                IntegrationFieldRef := IntegrationRef.Field(ColNo);
                                IntegrationFieldRef.Value := TextValue;

                            end else begin
                                //Status
                                IntegrationFieldRef := IntegrationRef.Field(98);
                                IntegrationFieldRef.Value := IntegrationImportStatus::"Data Excel Error";

                                //"Account No."
                                IntegrationFieldRef := IntegrationRef.Field(ColNo);
                                IntegrationFieldRef.Value := 'Errors-' + format(RowNo);

                                IntegrationErros.InsertErros(IntegrationErrosType, DocNo, LineNo, CopyStr(IntegrationFieldRef.Caption, 1, 50), 'Maximum 20 characters', TextValue, FileName);
                                ErrorFile := true;
                            end;

                            //"Posting Date"
                            ColNo := 6;
                            Clear(DateValue);
                            if Evaluate(DateValue, GetValueAtCell(RowNo, ColNo)) then begin
                                //"Posting Date"
                                IntegrationFieldRef := IntegrationRef.Field(ColNo);
                                IntegrationFieldRef.Value := DateValue;
                            end
                            else begin
                                //Status
                                IntegrationFieldRef := IntegrationRef.Field(98);
                                IntegrationFieldRef.Value := IntegrationImportStatus::"Data Excel Error";

                                //"Posting Date"
                                IntegrationFieldRef := IntegrationRef.Field(ColNo);
                                //IntegrationFieldRef.Value := 'Errors-' + format(RowNo);

                                IntegrationErros.InsertErros(IntegrationErrosType, DocNo, LineNo, CopyStr(IntegrationFieldRef.Caption, 1, 50), CopyStr(GetLastErrorText(), 1, 250), GetValueAtCell(RowNo, ColNo), FileName);
                                ErrorFile := true;
                            end;

                            //Document Type
                            ColNo := 7;
                            Clear(TextValue);
                            TextValue := GetValueAtCell(RowNo, ColNo);
                            TextValue := TextValue.Trim();

                            IntegrationFieldRef := IntegrationRef.Field(ColNo);
                            if not evaluate(IntegrationFieldRef, TextValue) then begin
                                //Status
                                IntegrationFieldRef := IntegrationRef.Field(98);
                                IntegrationFieldRef.Value := IntegrationImportStatus::"Data Excel Error";

                                //Document Type
                                IntegrationFieldRef := IntegrationRef.Field(ColNo);

                                IntegrationErros.InsertErros(IntegrationErrosType, DocNo, LineNo, CopyStr(IntegrationFieldRef.Caption, 1, 50), 'Maximum 20 characters', TextValue, FileName);
                                ErrorFile := true;
                            end;


                            //"Document No."
                            ColNo := 8;
                            Clear(TextValue);
                            TextValue := GetValueAtCell(RowNo, ColNo);
                            TextValue := TextValue.Trim();

                            if (StrLen(TextValue) <= 20) then begin
                                //"Document No."
                                IntegrationFieldRef := IntegrationRef.Field(ColNo);
                                IntegrationFieldRef.Value := TextValue;

                            end else begin
                                //Status
                                IntegrationFieldRef := IntegrationRef.Field(98);
                                IntegrationFieldRef.Value := IntegrationImportStatus::"Data Excel Error";

                                //"Document No."
                                IntegrationFieldRef := IntegrationRef.Field(ColNo);
                                IntegrationFieldRef.Value := 'Errors-' + format(RowNo);

                                IntegrationErros.InsertErros(IntegrationErrosType, DocNo, LineNo, CopyStr(IntegrationFieldRef.Caption, 1, 50), 'Maximum 20 characters', TextValue, FileName);
                                ErrorFile := true;
                            end;

                            //Description
                            ColNo := 9;
                            Clear(TextValue);
                            TextValue := GetValueAtCell(RowNo, ColNo);
                            TextValue := TextValue.Trim();

                            if (StrLen(TextValue) <= 100) then begin

                                //Description
                                IntegrationFieldRef := IntegrationRef.Field(ColNo);
                                IntegrationFieldRef.Value := TextValue;

                            end else begin
                                //Status
                                IntegrationFieldRef := IntegrationRef.Field(98);
                                IntegrationFieldRef.Value := IntegrationImportStatus::"Data Excel Error";

                                //Description
                                IntegrationFieldRef := IntegrationRef.Field(ColNo);
                                IntegrationFieldRef.Value := 'Errors-' + format(RowNo);

                                IntegrationErros.InsertErros(IntegrationErrosType, DocNo, LineNo, CopyStr(IntegrationFieldRef.Caption, 1, 50), 'Maximum 100 characters', TextValue, FileName);
                                ErrorFile := true;
                            end;

                            //Bal. Account Type
                            ColNo := 10;
                            Clear(TextValue);
                            TextValue := GetValueAtCell(RowNo, ColNo);
                            TextValue := TextValue.Trim();

                            if TextValue <> 'Banco' then
                                TextValue := 'Banco';

                            IntegrationFieldRef := IntegrationRef.Field(ColNo);
                            if not evaluate(IntegrationFieldRef, TextValue) then begin
                                //Status
                                IntegrationFieldRef := IntegrationRef.Field(98);
                                IntegrationFieldRef.Value := IntegrationImportStatus::"Data Excel Error";

                                //Bal. Account Type
                                IntegrationFieldRef := IntegrationRef.Field(ColNo);

                                IntegrationErros.InsertErros(IntegrationErrosType, DocNo, LineNo, CopyStr(IntegrationFieldRef.Caption, 1, 50), 'Bal. Account Type Error', TextValue, FileName);
                                ErrorFile := true;
                            end;

                            //"Bal. Account No."
                            ColNo := 11;
                            Clear(TextValue);
                            TextValue := GetValueAtCell(RowNo, ColNo);
                            TextValue := TextValue.Trim();

                            if (StrLen(TextValue) <= 20) then begin

                                //"Bal. Account No."
                                IntegrationFieldRef := IntegrationRef.Field(ColNo);
                                IntegrationFieldRef.Value := TextValue;

                            end else begin
                                //Status
                                IntegrationFieldRef := IntegrationRef.Field(98);
                                IntegrationFieldRef.Value := IntegrationImportStatus::"Data Excel Error";

                                //"Bal. Account No."
                                IntegrationFieldRef := IntegrationRef.Field(ColNo);
                                IntegrationFieldRef.Value := 'Errors-' + format(RowNo);

                                IntegrationErros.InsertErros(IntegrationErrosType, DocNo, LineNo, CopyStr(IntegrationFieldRef.Caption, 1, 50), 'Maximum 20 characters', TextValue, FileName);
                                ErrorFile := true;
                            end;

                            //Amount
                            ColNo := 12;
                            Clear(DecimalValue);
                            if Evaluate(DecimalValue, GetValueAtCell(RowNo, ColNo)) then begin
                                //Amount
                                IntegrationFieldRef := IntegrationRef.Field(ColNo);
                                IntegrationFieldRef.Value := DecimalValue;
                            end
                            else begin
                                //Status
                                IntegrationFieldRef := IntegrationRef.Field(98);
                                IntegrationFieldRef.Value := IntegrationImportStatus::"Data Excel Error";
                                //Amount
                                IntegrationFieldRef := IntegrationRef.Field(ColNo);

                                IntegrationErros.InsertErros(IntegrationErrosType, DocNo, LineNo, CopyStr(IntegrationFieldRef.Caption, 1, 50), CopyStr(GetLastErrorText(), 1, 250), GetValueAtCell(RowNo, ColNo), FileName);
                                ErrorFile := true;
                            end;

                            //Shortcut Dimension 1 Code
                            ColNo := 14;
                            Clear(TextValue);
                            TextValue := GetValueAtCell(RowNo, ColNo);
                            TextValue := TextValue.Trim();

                            if (StrLen(TextValue) <= 20) then begin

                                //Shortcut Dimension 1 Code
                                IntegrationFieldRef := IntegrationRef.Field(ColNo);
                                IntegrationFieldRef.Value := TextValue;

                            end else begin
                                //Status
                                IntegrationFieldRef := IntegrationRef.Field(98);
                                IntegrationFieldRef.Value := IntegrationImportStatus::"Data Excel Error";

                                //Shortcut Dimension 1 Code
                                IntegrationFieldRef := IntegrationRef.Field(ColNo);
                                IntegrationFieldRef.Value := 'Errors-' + format(RowNo);

                                IntegrationErros.InsertErros(IntegrationErrosType, DocNo, LineNo, CopyStr(IntegrationFieldRef.Caption, 1, 50), 'Maximum 20 characters', TextValue, FileName);
                                ErrorFile := true;
                            end;

                            //Shortcut Dimension 2 Code
                            ColNo := 15;
                            Clear(TextValue);
                            TextValue := GetValueAtCell(RowNo, ColNo);
                            TextValue := TextValue.Trim();

                            if (StrLen(TextValue) <= 20) then begin

                                //Shortcut Dimension 2 Code
                                IntegrationFieldRef := IntegrationRef.Field(ColNo);
                                IntegrationFieldRef.Value := TextValue;

                            end else begin
                                //Status
                                IntegrationFieldRef := IntegrationRef.Field(98);
                                IntegrationFieldRef.Value := IntegrationImportStatus::"Data Excel Error";

                                //Shortcut Dimension 2 Code
                                IntegrationFieldRef := IntegrationRef.Field(ColNo);
                                IntegrationFieldRef.Value := 'Errors-' + format(RowNo);

                                IntegrationErros.InsertErros(IntegrationErrosType, DocNo, LineNo, CopyStr(IntegrationFieldRef.Caption, 1, 50), 'Maximum 20 characters', TextValue, FileName);
                                ErrorFile := true;
                            end;

                            //Shortcut Dimension 3 Code
                            ColNo := 16;
                            Clear(TextValue);
                            TextValue := GetValueAtCell(RowNo, ColNo);
                            TextValue := TextValue.Trim();

                            if (StrLen(TextValue) <= 20) then begin

                                //Shortcut Dimension 3 Code
                                IntegrationFieldRef := IntegrationRef.Field(ColNo);
                                IntegrationFieldRef.Value := TextValue;

                            end else begin
                                //Status
                                IntegrationFieldRef := IntegrationRef.Field(98);
                                IntegrationFieldRef.Value := IntegrationImportStatus::"Data Excel Error";

                                //Shortcut Dimension 3 Code
                                IntegrationFieldRef := IntegrationRef.Field(ColNo);
                                IntegrationFieldRef.Value := 'Errors-' + format(RowNo);

                                IntegrationErros.InsertErros(IntegrationErrosType, DocNo, LineNo, CopyStr(IntegrationFieldRef.Caption, 1, 50), 'Maximum 20 characters', TextValue, FileName);
                                ErrorFile := true;
                            end;

                            //Shortcut Dimension 4 Code
                            ColNo := 17;
                            Clear(TextValue);
                            TextValue := GetValueAtCell(RowNo, ColNo);
                            TextValue := TextValue.Trim();

                            if (StrLen(TextValue) <= 20) then begin

                                //Shortcut Dimension 4 Code
                                IntegrationFieldRef := IntegrationRef.Field(ColNo);
                                IntegrationFieldRef.Value := TextValue;

                            end else begin
                                //Status
                                IntegrationFieldRef := IntegrationRef.Field(98);
                                IntegrationFieldRef.Value := IntegrationImportStatus::"Data Excel Error";

                                //Shortcut Dimension 4 Code
                                IntegrationFieldRef := IntegrationRef.Field(ColNo);
                                IntegrationFieldRef.Value := 'Errors-' + format(RowNo);

                                IntegrationErros.InsertErros(IntegrationErrosType, DocNo, LineNo, CopyStr(IntegrationFieldRef.Caption, 1, 50), 'Maximum 20 characters', TextValue, FileName);
                                ErrorFile := true;
                            end;

                            //Shortcut Dimension 5 Code
                            ColNo := 18;
                            Clear(TextValue);
                            TextValue := GetValueAtCell(RowNo, ColNo);
                            TextValue := TextValue.Trim();

                            if (StrLen(TextValue) <= 20) then begin

                                //Shortcut Dimension 5 Code
                                IntegrationFieldRef := IntegrationRef.Field(ColNo);
                                IntegrationFieldRef.Value := TextValue;

                            end else begin
                                //Status
                                IntegrationFieldRef := IntegrationRef.Field(98);
                                IntegrationFieldRef.Value := IntegrationImportStatus::"Data Excel Error";

                                //Shortcut Dimension 5 Code
                                IntegrationFieldRef := IntegrationRef.Field(ColNo);
                                IntegrationFieldRef.Value := 'Errors-' + format(RowNo);

                                IntegrationErros.InsertErros(IntegrationErrosType, DocNo, LineNo, CopyStr(IntegrationFieldRef.Caption, 1, 50), 'Maximum 20 characters', TextValue, FileName);
                                ErrorFile := true;
                            end;

                            //Shortcut Dimension 6 Code
                            ColNo := 19;
                            Clear(TextValue);
                            TextValue := GetValueAtCell(RowNo, ColNo);
                            TextValue := TextValue.Trim();

                            if (StrLen(TextValue) <= 20) then begin

                                //Shortcut Dimension 6 Code
                                IntegrationFieldRef := IntegrationRef.Field(ColNo);
                                IntegrationFieldRef.Value := TextValue;

                            end else begin
                                //Status
                                IntegrationFieldRef := IntegrationRef.Field(98);
                                IntegrationFieldRef.Value := IntegrationImportStatus::"Data Excel Error";

                                //Shortcut Dimension 6 Code
                                IntegrationFieldRef := IntegrationRef.Field(ColNo);
                                IntegrationFieldRef.Value := 'Errors-' + format(RowNo);

                                IntegrationErros.InsertErros(IntegrationErrosType, DocNo, LineNo, CopyStr(IntegrationFieldRef.Caption, 1, 50), 'Maximum 20 characters', TextValue, FileName);
                                ErrorFile := true;
                            end;

                            // if Integration <> Integration::"Purchase Payment" then begin

                            //Applies-to Doc. Type
                            ColNo := 20;
                            Clear(TextValue);
                            TextValue := GetValueAtCell(RowNo, ColNo);
                            TextValue := TextValue.Trim();

                            TextValue := 'Invoice';

                            //Applies-to Doc. Type
                            IntegrationFieldRef := IntegrationRef.Field(ColNo + 2);
                            if not evaluate(IntegrationFieldRef, TextValue) then begin
                                //Status
                                IntegrationFieldRef := IntegrationRef.Field(98);
                                IntegrationFieldRef.Value := IntegrationImportStatus::"Data Excel Error";

                                //Applies-to Doc. Type
                                IntegrationFieldRef := IntegrationRef.Field(ColNo + 2);

                                IntegrationErros.InsertErros(IntegrationErrosType, DocNo, LineNo, CopyStr(IntegrationFieldRef.Caption, 1, 50), 'Maximum 20 characters', TextValue, FileName);
                                ErrorFile := true;
                            end;


                            //Applies-to Doc. No.
                            ColNo := 21;
                            Clear(TextValue);
                            TextValue := GetValueAtCell(RowNo, ColNo);
                            TextValue := TextValue.Trim();

                            if (StrLen(TextValue) <= 20) then begin
                                //Applies-to Doc. No.
                                IntegrationFieldRef := IntegrationRef.Field(ColNo + 2);
                                IntegrationFieldRef.Value := TextValue;
                            end else begin
                                //Status
                                IntegrationFieldRef := IntegrationRef.Field(98);
                                IntegrationFieldRef.Value := IntegrationImportStatus::"Data Excel Error";

                                //Applies-to Doc. No.
                                IntegrationFieldRef := IntegrationRef.Field(ColNo + 2);
                                IntegrationFieldRef.Value := 'Errors-' + format(RowNo);

                                IntegrationErros.InsertErros(IntegrationErrosType, DocNo, LineNo, CopyStr(IntegrationFieldRef.Caption, 1, 50), 'Maximum 20 characters', TextValue, FileName);
                                ErrorFile := true;
                            end;
                            // end;

                            //External Document No.
                            ColNo := 22;
                            Clear(TextValue);
                            TextValue := GetValueAtCell(RowNo, ColNo);
                            TextValue := TextValue.Trim();

                            if (StrLen(TextValue) <= 20) then begin
                                //External Document No.
                                IntegrationFieldRef := IntegrationRef.Field(ColNo + 2);
                                IntegrationFieldRef.Value := TextValue;
                            end else begin
                                //Status
                                IntegrationFieldRef := IntegrationRef.Field(98);
                                IntegrationFieldRef.Value := IntegrationImportStatus::"Data Excel Error";

                                //External Document No.
                                IntegrationFieldRef := IntegrationRef.Field(ColNo + 2);
                                IntegrationFieldRef.Value := 'Errors-' + format(RowNo);

                                IntegrationErros.InsertErros(IntegrationErrosType, DocNo, LineNo, CopyStr(IntegrationFieldRef.Caption, 1, 50), 'Maximum 20 characters', TextValue, FileName);
                                ErrorFile := true;
                            end;

                            //Check empty values ++++++++
                            Clear(TextValue);
                            IntegrationFieldRef := IntegrationRef.Field(1);
                            TextValue := IntegrationFieldRef.Value;
                            if TextValue = '' then begin
                                IntegrationErros.InsertErros(IntegrationErrosType, DocNo, LineNo, CopyStr(IntegrationFieldRef.Caption, 1, 50), 'It cannot be empty.', TextValue, FileName);
                                IntegrationFieldRef := IntegrationRef.Field(98);
                                IntegrationFieldRef.Value := IntegrationImportStatus::"Data Excel Error";
                            end;

                            Clear(TextValue);
                            IntegrationFieldRef := IntegrationRef.Field(2);
                            TextValue := IntegrationFieldRef.Value;
                            if TextValue = '' then begin
                                IntegrationErros.InsertErros(IntegrationErrosType, DocNo, LineNo, CopyStr(IntegrationFieldRef.Caption, 1, 50), 'It cannot be empty.', TextValue, FileName);
                                IntegrationFieldRef := IntegrationRef.Field(98);
                                IntegrationFieldRef.Value := IntegrationImportStatus::"Data Excel Error";
                            end;

                            Clear(IntegerValue);
                            IntegrationFieldRef := IntegrationRef.Field(3);
                            IntegerValue := IntegrationFieldRef.Value;
                            if IntegerValue = 0 then begin
                                IntegrationErros.InsertErros(IntegrationErrosType, DocNo, LineNo, CopyStr(IntegrationFieldRef.Caption, 1, 50), 'It cannot be zero.', TextValue, FileName);
                                IntegrationFieldRef := IntegrationRef.Field(98);
                                IntegrationFieldRef.Value := IntegrationImportStatus::"Data Excel Error";
                            end;

                            Clear(TextValue);
                            IntegrationFieldRef := IntegrationRef.Field(5);
                            TextValue := IntegrationFieldRef.Value;
                            if TextValue = '' then begin
                                IntegrationErros.InsertErros(IntegrationErrosType, DocNo, LineNo, CopyStr(IntegrationFieldRef.Caption, 1, 50), 'It cannot be empty.', TextValue, FileName);
                                IntegrationFieldRef := IntegrationRef.Field(98);
                                IntegrationFieldRef.Value := IntegrationImportStatus::"Data Excel Error";
                            end;

                            Clear(DateValue);
                            IntegrationFieldRef := IntegrationRef.Field(6);
                            DateValue := IntegrationFieldRef.Value;
                            if DateValue = 0D then begin
                                IntegrationErros.InsertErros(IntegrationErrosType, DocNo, LineNo, CopyStr(IntegrationFieldRef.Caption, 1, 50), 'It cannot be empty.', TextValue, FileName);
                                IntegrationFieldRef := IntegrationRef.Field(98);
                                IntegrationFieldRef.Value := IntegrationImportStatus::"Data Excel Error";
                            end;

                            Clear(TextValue);
                            IntegrationFieldRef := IntegrationRef.Field(8);
                            TextValue := IntegrationFieldRef.Value;
                            if TextValue = '' then begin
                                IntegrationErros.InsertErros(IntegrationErrosType, DocNo, LineNo, CopyStr(IntegrationFieldRef.Caption, 1, 50), 'It cannot be empty.', TextValue, FileName);
                                IntegrationFieldRef := IntegrationRef.Field(98);
                                IntegrationFieldRef.Value := IntegrationImportStatus::"Data Excel Error";
                            end;

                            Clear(TextValue);
                            IntegrationFieldRef := IntegrationRef.Field(11);
                            TextValue := IntegrationFieldRef.Value;
                            if TextValue = '' then begin
                                IntegrationErros.InsertErros(IntegrationErrosType, DocNo, LineNo, CopyStr(IntegrationFieldRef.Caption, 1, 50), 'It cannot be empty.', TextValue, FileName);
                                IntegrationFieldRef := IntegrationRef.Field(98);
                                IntegrationFieldRef.Value := IntegrationImportStatus::"Data Excel Error";
                            end;
                            //Check empty values ------------~

                            if Integration = Integration::"Purchase Payment" then begin

                                IntegrationFieldRef := IntegrationRef.Field(23);

                                TotDirectUnit := 0;
                                intPurc.reset();
                                intPurc.SetRange("Document No.", IntegrationFieldRef.Value);
                                if intPurc.FindSet() then begin
                                    repeat
                                        TotDirectUnit += intPurc."Direct Unit Cost Excl. Vat" * intPurc.Quantity;
                                    until intPurc.Next() = 0;

                                end;

                                intPurc.reset();
                                intPurc.SetRange("Document No.", IntegrationFieldRef.Value);
                                if intPurc.FindFirst() then begin

                                    IntegrationFieldRef := IntegrationRef.Field(150);
                                    IntegrationFieldRef.Value := intPurc."Order IRRF Ret";
                                    if intPurc."Order IRRF Ret" <> 0 then begin

                                        VatEntry.Reset();
                                        VatEntry.Setrange("Document No.", intPurc."Document No.");
                                        VatEntry.SETRANGE("CADBR Tax Identification", VatEntry."CADBR Tax Identification"::IRRF);
                                        if VatEntry.FindFirst() then
                                            if VatEntry.Base <> 0 then
                                                IntegrationFieldRef.Value := 0;
                                    end;

                                    IntegrationFieldRef := IntegrationRef.Field(151);
                                    IntegrationFieldRef.Value := intPurc."Order CSRF Ret";

                                    if intPurc."Order CSRF Ret" <> 0 then begin

                                        VatEntry.Reset();
                                        VatEntry.Setrange("Document No.", intPurc."Document No.");
                                        VatEntry.SETRANGE("CADBR Tax Identification", VatEntry."CADBR Tax Identification"::PCC);
                                        if VatEntry.FindFirst() then
                                            if VatEntry.Base <> 0 then
                                                IntegrationFieldRef.Value := 0;

                                        IntPurcPay.Reset();
                                        IntPurcPay.SetCurrentKey("Excel File Name", "Journal Template Name", "Journal Batch Name", Status);
                                        IntegrationFieldRef := IntegrationRef.Field(115);
                                        IntPurcPay.setrange("Excel File Name", IntegrationFieldRef.Value);
                                        IntegrationFieldRef := IntegrationRef.Field(23);
                                        IntPurcPay.SetRange("Applies-to Doc. No.", IntegrationFieldRef.Value);
                                        if IntPurcPay.FindFirst() then begin
                                            IntegrationFieldRef := IntegrationRef.Field(151);
                                            IntegrationFieldRef.Value := 0;
                                        end;

                                    end;

                                    IntegrationFieldRef := IntegrationRef.Field(152);
                                    IntegrationFieldRef.Value := intPurc."Order INSS Ret";
                                    if intPurc."Order inss Ret" <> 0 then begin

                                        VatEntry.Reset();
                                        VatEntry.Setrange("Document No.", intPurc."Document No.");
                                        VatEntry.SETRANGE("CADBR Tax Identification", VatEntry."CADBR Tax Identification"::"INSS Ret.");
                                        if VatEntry.FindFirst() then
                                            if VatEntry.Base <> 0 then
                                                IntegrationFieldRef.Value := 0;

                                    end;

                                    IntegrationFieldRef := IntegrationRef.Field(153);
                                    IntegrationFieldRef.Value := intPurc."Order ISS Ret";
                                    if intPurc."Order iss Ret" <> 0 then begin

                                        VatEntry.Reset();
                                        VatEntry.Setrange("Document No.", intPurc."Document No.");
                                        VatEntry.SETRANGE("CADBR Tax Identification", VatEntry."CADBR Tax Identification"::"ISS Ret.");
                                        if VatEntry.FindFirst() then
                                            if VatEntry.Base <> 0 then
                                                IntegrationFieldRef.Value := 0;

                                    end;

                                    IntegrationFieldRef := IntegrationRef.Field(156);
                                    IntegrationFieldRef.Value := intPurc."Order DIRF Ret";
                                    if intPurc."Order DIRF Ret" <> 0 then begin

                                        VatEntry.Reset();
                                        VatEntry.Setrange("Document No.", intPurc."Document No.");
                                        VatEntry.SETRANGE("CADBR Tax Identification", VatEntry."CADBR Tax Identification"::IRRF);
                                        if VatEntry.FindFirst() then
                                            if VatEntry.Base <> 0 then
                                                IntegrationFieldRef.Value := 0;

                                    end;

                                    IntegrationFieldRef := IntegrationRef.Field(157);
                                    IntegrationFieldRef.Value := TotDirectUnit;

                                    IntegrationFieldRef := IntegrationRef.Field(250);
                                    IntegrationFieldRef.Value := intPurc."Tax % Order IRRF Ret";

                                    IntegrationFieldRef := IntegrationRef.Field(251);
                                    IntegrationFieldRef.Value := intPurc."Tax % Order CSRF Ret";

                                    IntegrationFieldRef := IntegrationRef.Field(252);
                                    IntegrationFieldRef.Value := intPurc."Tax % Order INSS Ret";

                                    IntegrationFieldRef := IntegrationRef.Field(253);
                                    IntegrationFieldRef.Value := intPurc."Tax % Order ISS Ret";

                                    IntegrationFieldRef := IntegrationRef.Field(256);
                                    IntegrationFieldRef.Value := intPurc."Tax % Order DIRF Ret";

                                end;

                                //VendorValue
                                IntegrationFieldRef := IntegrationRef.Field(23);
                                VLE.Reset();
                                VLE.SetRange("Document No.", IntegrationFieldRef.Value);
                                if VLE.FindFirst() then begin

                                    Clear(DecimalValue);
                                    Clear(DecimalValueTot);

                                    IntegrationFieldRef := IntegrationRef.Field(12);
                                    DecimalValue := IntegrationFieldRef.Value;
                                    DecimalValueTot := DecimalValue;

                                    IntegrationFieldRef := IntegrationRef.Field(150);
                                    DecimalValue := IntegrationFieldRef.Value;
                                    DecimalValueTot += DecimalValue;

                                    IntegrationFieldRef := IntegrationRef.Field(151);
                                    DecimalValue := IntegrationFieldRef.Value;
                                    DecimalValueTot += DecimalValue;

                                    VLE.calcfields("Remaining Amount");
                                    if abs(VLE."Remaining Amount") < DecimalValueTot then begin
                                        IntegrationFieldRef := IntegrationRef.Field(27);
                                        IntegrationFieldRef.Value := true;
                                    end;

                                    IntegrationFieldRef := IntegrationRef.Field(26);
                                    IntegrationFieldRef.Value := ABS(VLE."Remaining Amount");

                                end;

                                IntPurcPay.Reset();
                                IntPurcPay.SetCurrentKey("Excel File Name", "Journal Template Name", "Journal Batch Name", Status);
                                IntegrationFieldRef := IntegrationRef.Field(115);
                                IntPurcPay.setrange("Excel File Name", IntegrationFieldRef.Value);
                                IntegrationFieldRef := IntegrationRef.Field(23);
                                IntPurcPay.SetRange("Applies-to Doc. No.", IntegrationFieldRef.Value);
                                IntegrationFieldRef := IntegrationRef.Field(3);
                                IntPurcPay.SetFilter("Line No.", '<>%1', IntegrationFieldRef.Value);
                                if IntPurcPay.FindFirst() then begin
                                    repeat
                                        DecimalValueTot += IntPurcPay.Amount + IntPurcPay."Order CSRF Ret" + IntPurcPay."Order IRRF Ret";
                                    until IntPurcPay.Next() = 0;

                                    IntegrationFieldRef := IntegrationRef.Field(26);
                                    DecimalValue := IntegrationFieldRef.Value;

                                    if DecimalValue < DecimalValueTot then begin
                                        IntegrationFieldRef := IntegrationRef.Field(27);
                                        IntegrationFieldRef.Value := true;

                                        TextValue := '';
                                        if TextValue = '' then begin
                                            IntegrationErros.InsertErros(IntegrationErrosType, DocNo, LineNo, CopyStr(IntegrationFieldRef.Caption, 1, 50), 'Existe mais de 1 linha com o mesmo documento Aplicado que ultrapassa o Valor pendente', TextValue, FileName);
                                            IntegrationFieldRef := IntegrationRef.Field(98);
                                            IntegrationFieldRef.Value := IntegrationImportStatus::"Data Error";

                                            IntegrationFieldRef := IntegrationRef.Field(99);
                                            IntegrationFieldRef.Value := 'Existe mais de 1 linha com o mesmo documento Aplicado que ultrapassa o Valor pendente';

                                        end;
                                    end;

                                end;

                            end;


                            if ExistLine then
                                IntegrationRef.Modify()
                            else
                                IntegrationRef.Insert();

                        end;
                    end;

                if ErrorFile then begin
                    FTPCommunication.DoAction(Enum::"FTP Actions"::rename, FileName, FTPIntSetup.Directory, FTPIntSetup."Error Folder", '');
                    if FTPIntSetup."Send Email" then
                        IntegrationEmail.SendMail(FTPIntSetup."E-mail Rejected Data", False, '', FileName);
                end
                else
                    FTPCommunication.DoAction(Enum::"FTP Actions"::rename, FileName, FTPIntSetup.Directory, FTPIntSetup."Imported Folder", '');
                LineNo := 0;

            until FTPDir.Next() = 0;
    end;

    procedure ImportExcelIntAccountingEntries(Integration: Enum "FTP Integration Type")
    var
        IntegrationErros: Record IntegrationErros;
        IntAccEntries: Record IntAccountingEntries;
        FTPIntSetup: Record "FTP Integration Setup";
        FTPDir: Record "FTP Directory";
        FTPCommunication: codeunit "FTP Communication";
        ret: Text;
        lines: List of [Text];
        line: Text;
        FileName: Text;
        EntryNo: BigInteger;
        RowNo: Integer;
        ColNo: Integer;
        LineNo: Integer;
        MaxRowNo: Integer;
        MaxCollNo: integer;
        CRLF: Char;
        TextValue: Text;
        DecimalValue: Decimal;
        DateValue: Date;
        ErrorFile: Boolean;
        MaxCharErrorLbl: Label 'Maximum %1 characters';
        IntegrationEmail: Codeunit "Integration Email";

    begin
        RowNo := 0;
        ColNo := 0;
        MaxRowNo := 0;
        LineNo := 0;

        if IntAccEntries.FindLast() then
            LineNo := IntAccEntries."Line No.";

        //FTPIntSetup.Get(Integration::"Accounting Entries");
        FTPIntSetup.Reset();
        FTPIntSetup.SetRange(Integration, FTPIntSetup.Integration::"Accounting Entries");
        FTPIntSetup.SetRange(Sequence, 0);
        FTPIntSetup.FindSet();

        CRLF := 10;

        ret := FTPCommunication.DoAction(Enum::"FTP Actions"::list, '', FTPIntSetup.Directory, '', '');
        lines := ret.Split(CRLF);

        FTPDir.Reset();
        FTPDir.DeleteAll();
        foreach line in lines do
            if line <> '' then begin
                FTPDir.Init();
                FTPDir.Filename := line;
                FTPDir.IsDirectory := (StrPos(line, '.') = 0);
                FTPDir.Insert();
            end;

        FTPDir.Reset();
        FTPDir.SetRange(IsDirectory, false);
        if FTPDir.Find('-') then
            repeat
                Clear(FTPCommunication);
                ErrorFile := false;
                FileName := FTPDir.Filename.Trim();

                if FTPIntSetup."Active Prefix File Name" then begin
                    FTPIntSetup.testfield("Prefix File Name");
                    if StrPos(FileName, FTPIntSetup."Prefix File Name") = 0 then
                        Error('File Name Not Valid');
                end;

                EntryNo := FTPCommunication.DoAction(Enum::"FTP Actions"::download, FileName, FTPIntSetup.Directory, '', '');
                ReadExcelSheet(EntryNo);

                TempExcelBuffer.Reset();
                if TempExcelBuffer.FindLast() then begin
                    MaxRowNo := TempExcelBuffer."Row No.";
                    MaxCollNo := TempExcelBuffer."Column No.";
                end;

                if MaxCollNo <> 21 then begin
                    ErrorFile := true;

                    IntAccEntries.Init();
                    IntAccEntries.Description := '';
                    IntAccEntries.Status := IntAccEntries.Status::"Layout Error";
                    IntAccEntries."Excel File Name" := FileName;
                    LineNo += 1;
                    IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Accounting Entries", '', LineNo, '', 'Layout Error', '', FileName);
                    IntAccEntries.Insert();
                end
                else begin

                    for RowNo := 2 to MaxRowNo do begin
                        LineNo += 1;

                        //"Journal Template Name"
                        ColNo := 1;
                        Clear(TextValue);
                        TextValue := GetValueAtCell(RowNo, ColNo);
                        TextValue := TextValue.Trim();
                        if StrLen(TextValue) <= MaxStrLen(IntAccEntries."Journal Template Name") then begin

                            IntAccEntries.Init();
                            IntAccEntries."Journal Template Name" := TextValue;
                            IntAccEntries.Status := IntAccEntries.Status::Imported;
                            IntAccEntries."Excel File Name" := CopyStr(FileName, 1, MaxStrLen(IntAccEntries."Excel File Name"));
                            IntAccEntries."Line No." := LineNo;

                        end else begin
                            IntAccEntries.Init();
                            IntAccEntries."Journal Template Name" := 'Errors-' + format(RowNo);
                            IntAccEntries.Status := IntAccEntries.Status::"Data Excel Error";
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Accounting Entries",
                                                         TextValue, LineNo,
                                                         CopyStr(IntAccEntries.FieldCaption("Journal Template Name"), 1, 50),
                                                         CopyStr(StrSubstNo(MaxCharErrorLbl, MaxStrLen(IntAccEntries."Account No.")), 1, 250),
                                                         TextValue,
                                                         FileName);
                            IntAccEntries."Line No." := LineNo;
                            IntAccEntries."Excel File Name" := CopyStr(FileName, 1, MaxStrLen(IntAccEntries."Excel File Name"));
                        end;

                        //"Journal Batch Name"
                        ColNo := 2;
                        Clear(TextValue);
                        TextValue := GetValueAtCell(RowNo, ColNo);
                        TextValue := TextValue.Trim();
                        if StrLen(TextValue) <= MaxStrLen(IntAccEntries."Journal Batch Name") then begin
                            IntAccEntries."Journal Batch Name" := TextValue;
                        end else begin
                            IntAccEntries.Status := IntAccEntries.Status::"Data Excel Error";
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Accounting Entries",
                                                         TextValue, LineNo,
                                                         CopyStr(IntAccEntries.FieldCaption("Journal Batch Name"), 1, 50),
                                                         CopyStr(StrSubstNo(MaxCharErrorLbl, MaxStrLen(IntAccEntries."Account No.")), 1, 250),
                                                         TextValue,
                                                         FileName);
                        end;

                        //"Posting Date"
                        ColNo := 3;
                        Clear(DateValue);
                        Clear(TextValue);
                        TextValue := GetValueAtCell(RowNo, ColNo);
                        if Evaluate(DateValue, TextValue) then begin
                            IntAccEntries."Posting Date" := DateValue;
                        end else begin
                            IntAccEntries.Status := IntAccEntries.Status::"Data Excel Error";
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Accounting Entries",
                                                         TextValue, LineNo,
                                                         CopyStr(IntAccEntries.FieldCaption("Posting Date"), 1, 50),
                                                         CopyStr(GetLastErrorText(), 1, 250),
                                                         TextValue,
                                                         FileName);
                        end;

                        //"Document Type"
                        ColNo := 4;
                        Clear(TextValue);
                        TextValue := GetValueAtCell(RowNo, ColNo);
                        TextValue := TextValue.Trim();
                        if not Evaluate(IntAccEntries."Document Type", TextValue) then begin
                            IntAccEntries.Status := IntAccEntries.Status::"Data Excel Error";
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Accounting Entries",
                                                         TextValue, LineNo,
                                                         CopyStr(IntAccEntries.FieldCaption("Document Type"), 1, 50),
                                                         CopyStr(GetLastErrorText(), 1, 250),
                                                         TextValue,
                                                         FileName);
                        end;

                        //"Account Type"
                        ColNo := 5;
                        Clear(TextValue);
                        TextValue := GetValueAtCell(RowNo, ColNo);
                        TextValue := TextValue.Trim();
                        if not Evaluate(IntAccEntries."Account Type", TextValue) then begin
                            IntAccEntries.Status := IntAccEntries.Status::"Data Excel Error";
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Accounting Entries",
                                                         TextValue, LineNo,
                                                         CopyStr(IntAccEntries.FieldCaption("Account Type"), 1, 50),
                                                         CopyStr(GetLastErrorText(), 1, 250),
                                                         TextValue,
                                                         FileName);
                        end;

                        //"Account No."
                        ColNo := 6;
                        Clear(TextValue);
                        TextValue := GetValueAtCell(RowNo, ColNo);
                        TextValue := TextValue.Trim();
                        if StrLen(TextValue) <= MaxStrLen(IntAccEntries."Account No.") then begin
                            IntAccEntries."Account No." := TextValue;
                        end else begin
                            IntAccEntries.Status := IntAccEntries.Status::"Data Excel Error";
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Accounting Entries",
                                                         TextValue, LineNo,
                                                         CopyStr(IntAccEntries.FieldCaption("Account No."), 1, 50),
                                                         CopyStr(StrSubstNo(MaxCharErrorLbl, MaxStrLen(IntAccEntries."Account No.")), 1, 250),
                                                         TextValue,
                                                         FileName);
                        end;

                        //Description
                        ColNo := 7;
                        Clear(TextValue);
                        TextValue := GetValueAtCell(RowNo, ColNo);
                        TextValue := TextValue.Trim();
                        if StrLen(TextValue) <= MaxStrLen(IntAccEntries.Description) then begin
                            IntAccEntries.Description := TextValue;
                        end else begin
                            IntAccEntries.Status := IntAccEntries.Status::"Data Excel Error";
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Accounting Entries",
                                                         TextValue, LineNo,
                                                         CopyStr(IntAccEntries.FieldCaption(Description), 1, 50),
                                                         CopyStr(StrSubstNo(MaxCharErrorLbl, MaxStrLen(IntAccEntries.Description)), 1, 250),
                                                         TextValue,
                                                         FileName);
                        end;

                        //"Bal. Account Type"
                        ColNo := 8;
                        Clear(TextValue);
                        TextValue := GetValueAtCell(RowNo, ColNo);
                        TextValue := TextValue.Trim();
                        if not Evaluate(IntAccEntries."Bal. Account Type", TextValue) then begin
                            IntAccEntries.Status := IntAccEntries.Status::"Data Excel Error";
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Accounting Entries",
                                                         TextValue, LineNo,
                                                         CopyStr(IntAccEntries.FieldCaption("Bal. Account Type"), 1, 50),
                                                         CopyStr(GetLastErrorText(), 1, 250),
                                                         TextValue,
                                                         FileName);
                        end;

                        //"Bal. Account No."
                        ColNo := 9;
                        Clear(TextValue);
                        TextValue := GetValueAtCell(RowNo, ColNo);
                        TextValue := TextValue.Trim();
                        if StrLen(TextValue) <= MaxStrLen(IntAccEntries."Bal. Account No.") then begin
                            IntAccEntries."Bal. Account No." := TextValue;
                        end else begin
                            IntAccEntries.Status := IntAccEntries.Status::"Data Excel Error";
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Accounting Entries",
                                                         TextValue, LineNo,
                                                         CopyStr(IntAccEntries.FieldCaption("Bal. Account No."), 1, 50),
                                                         CopyStr(StrSubstNo(MaxCharErrorLbl, MaxStrLen(IntAccEntries."Bal. Account No.")), 1, 250),
                                                         TextValue,
                                                         FileName);
                        end;

                        //Amount
                        ColNo := 10;
                        Clear(TextValue);
                        Clear(DecimalValue);
                        TextValue := GetValueAtCell(RowNo, ColNo);
                        TextValue := TextValue.Trim();
                        if not Evaluate(DecimalValue, TextValue) then begin
                            IntAccEntries.Status := IntAccEntries.Status::"Data Excel Error";
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Accounting Entries",
                                                         TextValue, LineNo,
                                                         CopyStr(IntAccEntries.FieldCaption(Amount), 1, 50),
                                                         CopyStr(GetLastErrorText(), 1, 250),
                                                         TextValue,
                                                         FileName);
                        end else
                            IntAccEntries.Amount := Round(DecimalValue, 0.01, '=');

                        //"Dimension 1"
                        ColNo := 11;
                        Clear(TextValue);
                        TextValue := GetValueAtCell(RowNo, ColNo);
                        TextValue := TextValue.Trim();
                        if StrLen(TextValue) <= MaxStrLen(IntAccEntries."Dimension 1") then begin
                            IntAccEntries."Dimension 1" := TextValue;
                        end else begin
                            IntAccEntries.Status := IntAccEntries.Status::"Data Excel Error";
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Accounting Entries",
                                                         TextValue, LineNo,
                                                         CopyStr(IntAccEntries.FieldCaption("Dimension 1"), 1, 50),
                                                         CopyStr(StrSubstNo(MaxCharErrorLbl, MaxStrLen(IntAccEntries."Dimension 1")), 1, 250),
                                                         TextValue,
                                                         FileName);
                        end;

                        //"Dimension 2"
                        ColNo := 12;
                        Clear(TextValue);
                        TextValue := GetValueAtCell(RowNo, ColNo);
                        TextValue := TextValue.Trim();
                        if StrLen(TextValue) <= MaxStrLen(IntAccEntries."Dimension 2") then begin
                            IntAccEntries."Dimension 2" := TextValue;
                        end else begin
                            IntAccEntries.Status := IntAccEntries.Status::"Data Excel Error";
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Accounting Entries",
                                                         TextValue, LineNo,
                                                         CopyStr(IntAccEntries.FieldCaption("Dimension 2"), 1, 50),
                                                         CopyStr(StrSubstNo(MaxCharErrorLbl, MaxStrLen(IntAccEntries."Dimension 2")), 1, 250),
                                                         TextValue,
                                                         FileName);
                        end;

                        //"Dimension 3"
                        ColNo := 13;
                        Clear(TextValue);
                        TextValue := GetValueAtCell(RowNo, ColNo);
                        TextValue := TextValue.Trim();
                        if StrLen(TextValue) <= MaxStrLen(IntAccEntries."Dimension 3") then begin
                            IntAccEntries."Dimension 3" := TextValue;
                        end else begin
                            IntAccEntries.Status := IntAccEntries.Status::"Data Excel Error";
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Accounting Entries",
                                                         TextValue, LineNo,
                                                         CopyStr(IntAccEntries.FieldCaption("Dimension 3"), 1, 50),
                                                         CopyStr(StrSubstNo(MaxCharErrorLbl, MaxStrLen(IntAccEntries."Dimension 3")), 1, 250),
                                                         TextValue,
                                                         FileName);
                        end;

                        //"Dimension 4"
                        ColNo := 14;
                        Clear(TextValue);
                        TextValue := GetValueAtCell(RowNo, ColNo);
                        TextValue := TextValue.Trim();
                        if StrLen(TextValue) <= MaxStrLen(IntAccEntries."Dimension 4") then begin
                            IntAccEntries."Dimension 4" := TextValue;
                        end else begin
                            IntAccEntries.Status := IntAccEntries.Status::"Data Excel Error";
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Accounting Entries",
                                                         TextValue, LineNo,
                                                         CopyStr(IntAccEntries.FieldCaption("Dimension 4"), 1, 50),
                                                         CopyStr(StrSubstNo(MaxCharErrorLbl, MaxStrLen(IntAccEntries."Dimension 4")), 1, 250),
                                                         TextValue,
                                                         FileName);
                        end;

                        //"Dimension 5"
                        ColNo := 15;
                        Clear(TextValue);
                        TextValue := GetValueAtCell(RowNo, ColNo);
                        TextValue := TextValue.Trim();
                        if StrLen(TextValue) <= MaxStrLen(IntAccEntries."Dimension 5") then begin
                            IntAccEntries."Dimension 5" := TextValue;
                        end else begin
                            IntAccEntries.Status := IntAccEntries.Status::"Data Excel Error";
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Accounting Entries",
                                                         TextValue, LineNo,
                                                         CopyStr(IntAccEntries.FieldCaption("Dimension 5"), 1, 50),
                                                         CopyStr(StrSubstNo(MaxCharErrorLbl, MaxStrLen(IntAccEntries."Dimension 5")), 1, 250),
                                                         TextValue,
                                                         FileName);
                        end;

                        //"Dimension 6"
                        ColNo := 16;
                        Clear(TextValue);
                        TextValue := GetValueAtCell(RowNo, ColNo);
                        TextValue := TextValue.Trim();
                        if StrLen(TextValue) <= MaxStrLen(IntAccEntries."Dimension 6") then begin
                            IntAccEntries."Dimension 6" := TextValue;
                        end else begin
                            IntAccEntries.Status := IntAccEntries.Status::"Data Excel Error";
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Accounting Entries",
                                                         TextValue, LineNo,
                                                         CopyStr(IntAccEntries.FieldCaption("Dimension 5"), 1, 50),
                                                         CopyStr(StrSubstNo(MaxCharErrorLbl, MaxStrLen(IntAccEntries."Dimension 6")), 1, 250),
                                                         TextValue,
                                                         FileName);
                        end;

                        //"Dimension 7"
                        ColNo := 17;
                        Clear(TextValue);
                        TextValue := GetValueAtCell(RowNo, ColNo);
                        TextValue := TextValue.Trim();
                        if StrLen(TextValue) <= MaxStrLen(IntAccEntries."Dimension 7") then begin
                            IntAccEntries."Dimension 7" := TextValue;
                        end else begin
                            IntAccEntries.Status := IntAccEntries.Status::"Data Excel Error";
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Accounting Entries",
                                                         TextValue, LineNo,
                                                         CopyStr(IntAccEntries.FieldCaption("Dimension 7"), 1, 50),
                                                         CopyStr(StrSubstNo(MaxCharErrorLbl, MaxStrLen(IntAccEntries."Dimension 7")), 1, 250),
                                                         TextValue,
                                                         FileName);
                        end;

                        //"Dimension 8"
                        ColNo := 18;
                        Clear(TextValue);
                        TextValue := GetValueAtCell(RowNo, ColNo);
                        TextValue := TextValue.Trim();
                        if StrLen(TextValue) <= MaxStrLen(IntAccEntries."Dimension 8") then begin
                            IntAccEntries."Dimension 8" := TextValue;
                        end else begin
                            IntAccEntries.Status := IntAccEntries.Status::"Data Excel Error";
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Accounting Entries",
                                                         TextValue, LineNo,
                                                         CopyStr(IntAccEntries.FieldCaption("Dimension 8"), 1, 50),
                                                         CopyStr(StrSubstNo(MaxCharErrorLbl, MaxStrLen(IntAccEntries."Dimension 8")), 1, 250),
                                                         TextValue,
                                                         FileName);
                        end;

                        //"Document No."
                        ColNo := 19;
                        Clear(TextValue);
                        TextValue := GetValueAtCell(RowNo, ColNo);
                        TextValue := TextValue.Trim();
                        if StrLen(TextValue) <= MaxStrLen(IntAccEntries."Document No.") then begin
                            IntAccEntries."Document No." := TextValue;
                        end else begin
                            IntAccEntries.Status := IntAccEntries.Status::"Data Excel Error";
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Accounting Entries",
                                                         TextValue, LineNo,
                                                         CopyStr(IntAccEntries.FieldCaption("Document No."), 1, 50),
                                                         CopyStr(StrSubstNo(MaxCharErrorLbl, MaxStrLen(IntAccEntries."Document No.")), 1, 250),
                                                         TextValue,
                                                         FileName);
                        end;

                        //"Additional Description"
                        ColNo := 20;
                        Clear(TextValue);
                        TextValue := GetValueAtCell(RowNo, ColNo);
                        TextValue := TextValue.Trim();
                        if StrLen(TextValue) <= MaxStrLen(IntAccEntries."Additional Description") then begin
                            IntAccEntries."Additional Description" := TextValue;
                        end else begin
                            IntAccEntries.Status := IntAccEntries.Status::"Data Excel Error";
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Accounting Entries",
                                                         TextValue, LineNo,
                                                         CopyStr(IntAccEntries.FieldCaption("Additional Description"), 1, 50),
                                                         CopyStr(StrSubstNo(MaxCharErrorLbl, MaxStrLen(IntAccEntries."Additional Description")), 1, 250),
                                                         TextValue,
                                                         FileName);
                        end;

                        //"Branch Code"
                        ColNo := 21;
                        Clear(TextValue);
                        TextValue := GetValueAtCell(RowNo, ColNo);
                        TextValue := TextValue.Trim();
                        if StrLen(TextValue) <= MaxStrLen(IntAccEntries."Branch Code") then begin
                            IntAccEntries."Branch Code" := TextValue;
                        end else begin
                            IntAccEntries.Status := IntAccEntries.Status::"Data Excel Error";
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Accounting Entries",
                                                         TextValue, LineNo,
                                                         CopyStr(IntAccEntries.FieldCaption("Branch Code"), 1, 50),
                                                         CopyStr(StrSubstNo(MaxCharErrorLbl, MaxStrLen(IntAccEntries."Branch Code")), 1, 250),
                                                         TextValue,
                                                         FileName);
                        end;

                        //Check empty values ++++++++
                        if IntAccEntries."Journal Template Name" = '' then begin
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Accounting Entries",
                                                        IntAccEntries."Document No.",
                                                        LineNo,
                                                        CopyStr(IntAccEntries.FieldCaption("Journal Template Name"), 1, 50), 'It cannot be empty.', '', FileName);
                            IntAccEntries.Status := IntAccEntries.Status::"Data Excel Error";
                        end;

                        if IntAccEntries."Journal Batch Name" = '' then begin
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Accounting Entries",
                                                        IntAccEntries."Document No.",
                                                        LineNo,
                                                        CopyStr(IntAccEntries.FieldCaption("Journal Batch Name"), 1, 50), 'It cannot be empty.', '', FileName);
                            IntAccEntries.Status := IntAccEntries.Status::"Data Excel Error";
                        end;

                        if IntAccEntries."Line No." = 0 then begin
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Accounting Entries",
                                                        IntAccEntries."Document No.",
                                                        LineNo,
                                                        CopyStr(IntAccEntries.FieldCaption("Line No."), 1, 50), 'It cannot be zero.', '', FileName);
                            IntAccEntries.Status := IntAccEntries.Status::"Data Excel Error";
                        end;

                        if IntAccEntries."Posting Date" = 0D then begin
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Accounting Entries",
                                                        IntAccEntries."Document No.",
                                                        LineNo,
                                                        CopyStr(IntAccEntries.FieldCaption("Posting Date"), 1, 50), 'It cannot be empty.', '', FileName);
                            IntAccEntries.Status := IntAccEntries.Status::"Data Excel Error";
                        end;

                        if IntAccEntries."Account No." = '' then begin
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Accounting Entries",
                                                        IntAccEntries."Document No.",
                                                        LineNo,
                                                        CopyStr(IntAccEntries.FieldCaption("Account No."), 1, 50), 'It cannot be empty.', '', FileName);
                            IntAccEntries.Status := IntAccEntries.Status::"Data Excel Error";
                        end;

                        /*if IntAccEntries."Bal. Account No." = '' then begin
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Accounting Entries",
                                                        IntAccEntries."Document No.",
                                                        LineNo,
                                                        CopyStr(IntAccEntries.FieldCaption("Bal. Account No."), 1, 50), 'It cannot be empty.', '', FileName);
                            IntAccEntries.Status := IntAccEntries.Status::"Data Excel Error";
                        end;*/

                        if IntAccEntries.Amount = 0 then begin
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Accounting Entries",
                                                        IntAccEntries."Document No.",
                                                        LineNo,
                                                        CopyStr(IntAccEntries.FieldCaption(Amount), 1, 50), 'It cannot be zero.', '', FileName);
                            IntAccEntries.Status := IntAccEntries.Status::"Data Excel Error";
                        end;

                        if IntAccEntries."Branch Code" = '' then begin
                            IntegrationErros.InsertErros(IntegrationErros."Integration Type"::"Accounting Entries",
                                                        IntAccEntries."Document No.",
                                                        LineNo,
                                                        CopyStr(IntAccEntries.FieldCaption("Branch Code"), 1, 50), 'It cannot be zero.', '', FileName);
                            IntAccEntries.Status := IntAccEntries.Status::"Data Excel Error";
                        end;
                        //Check empty values ------------~

                        IntAccEntries.Insert();
                        ErrorFile := IntAccEntries.Status = IntAccEntries.Status::"Data Excel Error";




                    end;
                end;
                if ErrorFile then begin
                    FTPCommunication.DoAction(Enum::"FTP Actions"::rename, FileName, FTPIntSetup.Directory, FTPIntSetup."Error Folder", '');
                    if FTPIntSetup."Send Email" then
                        IntegrationEmail.SendMail(FTPIntSetup."E-mail Rejected Data", False, '', FileName);
                end
                else
                    FTPCommunication.DoAction(Enum::"FTP Actions"::rename, FileName, FTPIntSetup.Directory, FTPIntSetup."Imported Folder", '');


            until FTPDir.Next() = 0;

    end;
}
