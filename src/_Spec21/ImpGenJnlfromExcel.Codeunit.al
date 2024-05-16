Codeunit 50076 "Imp. GenJnl From Excel"
{
    TableNo = "Gen. Journal Line";

    trigger OnRun()
    begin
        ImportFile(Rec);
    end;

    var
        Text001: label 'Open Excel file';

    local procedure ImportFile(var GenJnlLine: Record "Gen. Journal Line")
    var
        ExcelBuffer: Record "Excel Buffer" temporary;
        Fromfile: Text;
        InS: InStream;
        FileName: Text;
        FileMngt: Codeunit "File Management";
        NameValueBuffer: Record "Name/Value Buffer" temporary;
        ExcelSheetNameLookup: Page "Excel Sheet Name Lookup";
        NameValueLookup: Page "Name/Value Lookup";
        SheetName: Text;
        MaxRowNo: Integer;
        RowNo: Integer;
        ColNo: Integer;
        LineNo: Integer;
        GJLine: Record "Gen. Journal Line";
        LastGJLine: Record "Gen. Journal Line";
        ImportExcelFileLbl: Label 'Choose the Excel file to Import';
        ExcelFileNotfoundLbl: Label 'Excel file not found';
        DateValue: Date;
        DecimalValue: Decimal;
        DimValue: array[8] of Code[20];
        AccType: Enum "Gen. Journal Account Type";
        DocType: Enum "Gen. Journal Document Type";
        BRAccountLbl: Label 'The File is made with the BR Account?';
        BRAcc: Boolean;
        BalAccNo: code[20];

    begin

        ExcelBuffer.Reset();
        ExcelBuffer.DeleteAll();
        Commit();

        BRAcc := Confirm(BRAccountLbl, true);
        UploadIntoStream(ImportExcelFileLbl, '', '', Fromfile, InS);
        if Fromfile <> '' then begin
            FileName := FileMngt.GetFileName(Fromfile);
            ExcelBuffer.GetSheetsNameListFromStream(InS, NameValueBuffer);
        end else
            Error(ExcelFileNotfoundLbl);




        NameValueBuffer.Reset();
        if NameValueBuffer.FindSet() then begin
            if NameValueBuffer.Count = 1 then
                SheetName := NameValueBuffer.Value
            else begin
                if page.RunModal(page::"Excel Sheet Name Lookup", NameValueBuffer) = Action::LookupOK then
                    SheetName := NameValueBuffer.Value;
            end;
        end;

        if SheetName <> '' then begin
            ExcelBuffer.OpenBookStream(InS, SheetName);
            ExcelBuffer.ReadSheet();

            if not ExcelBuffer.IsEmpty then begin
                ExcelBuffer.FindLast();
                MaxRowNo := ExcelBuffer."Row No.";


                LastGJLine.SETRANGE("Journal Template Name", GenJnlLine."Journal Template Name");
                LastGJLine.SETRANGE("Journal Batch Name", GenJnlLine."Journal Batch Name");
                IF LastGJLine.FINDLAST THEN
                    LineNo := LastGJLine."Line No.";

                for RowNo := 2 to MaxRowNo do begin

                    LastGJLine.SETRANGE("Journal Template Name", GenJnlLine."Journal Template Name");
                    LastGJLine.SETRANGE("Journal Batch Name", GenJnlLine."Journal Batch Name");
                    IF LastGJLine.FINDLAST THEN
                        LineNo := LastGJLine."Line No.";

                    LineNo += 10000;

                    GJLine.Reset();
                    GJLine.Init();
                    GJLine."Journal Template Name" := GenJnlLine."Journal Template Name";
                    GJLine."Journal Batch Name" := GenJnlLine."Journal Batch Name";
                    GJLine."Line No." := LineNo;
                    GJLine.SetUpNewLine(LastGJLine, 0, false);

                    GJLine.Validate("Posting Date", GetDate(ExcelBuffer, 1, RowNo));
                    GJLine.Validate("Document No.", GetText(ExcelBuffer, 17, RowNo));

                    Clear(DocType);
                    Evaluate(DocType, GetText(ExcelBuffer, 2, RowNo));
                    GJLine.Validate("Document Type", DocType);

                    GetValidateDimValues(ExcelBuffer, RowNo, DimValue);

                    Clear(AccType);
                    Evaluate(AccType, GetText(ExcelBuffer, 3, RowNo));
                    GJLine.Validate("Account Type", AccType);

                    if GJLine."Account Type" <> GJLine."Account Type"::"G/L Account" then
                        GJLine.Validate("Account No.", GetText(ExcelBuffer, 4, RowNo))
                    else
                        GJLine.Validate("Account No.", GetGLAcc(GetText(ExcelBuffer, 4, RowNo), DimValue, BRAcc));

                    GJLine.Validate(Description, GetText(ExcelBuffer, 5, RowNo));

                    Clear(AccType);
                    Evaluate(AccType, GetText(ExcelBuffer, 6, RowNo));
                    GJLine.Validate("Bal. Account Type", AccType);

                    Clear(BalAccNo);
                    BalAccNo := GetText(ExcelBuffer, 7, RowNo);
                    if BalAccNo <> '' then begin
                        if GJLine."Bal. Account Type" <> GJLine."Bal. Account Type"::"G/L Account" then
                            GJLine.Validate("Bal. Account No.", BalAccNo)
                        else
                            GJLine.Validate("Bal. Account No.", GetGLAcc(BalAccNo, DimValue, BRAcc));
                    end;
                    GJLine.Validate(Amount, GetDecimal(ExcelBuffer, 8, RowNo));

                    if DimValue[1] <> '' then
                        GJLine.Validate("Shortcut Dimension 1 Code", DimValue[1]);
                    if DimValue[2] <> '' then
                        GJLine.Validate("Shortcut Dimension 2 Code", DimValue[2]);
                    if DimValue[3] <> '' then
                        GJLine.ValidateShortcutDimCode(3, DimValue[3]);
                    if DimValue[4] <> '' then
                        GJLine.ValidateShortcutDimCode(4, DimValue[4]);
                    if DimValue[5] <> '' then
                        GJLine.ValidateShortcutDimCode(5, DimValue[5]);
                    if DimValue[6] <> '' then
                        GJLine.ValidateShortcutDimCode(6, DimValue[6]);
                    if DimValue[7] <> '' then
                        GJLine.ValidateShortcutDimCode(7, DimValue[7]);
                    if DimValue[8] <> '' then
                        GJLine.ValidateShortcutDimCode(7, DimValue[8]);

                    GJLine.Validate("CADBR Additional Description", GetText(ExcelBuffer, 18, RowNo));
                    GJLine.Validate("CADBR Branch Code", GetText(ExcelBuffer, 19, RowNo));
                    GJLine.Insert(true);

                end;

            end;

        end;
    end;


    local procedure GetText(var Buffer: Record "Excel Buffer" temporary; Col: Integer; Row: Integer): Text
    begin
        if Buffer.Get(Row, col) then
            exit(Buffer."Cell Value as Text");
    end;

    local procedure GetDate(var Buffer: Record "Excel Buffer" temporary; Col: Integer; Row: Integer): Date
    var
        d: Date;
    begin
        if Buffer.Get(Row, col) then begin
            Evaluate(D, Buffer."Cell Value as Text");
            exit(D);
        end;
        // if ExcelBuffer.Get(Row, col) then begin
        //     Evaluate(D, ExcelBuffer."Cell Value as Text");
        //     exit(D);
        // end;
    end;

    Local procedure GetDecimal(var Buffer: Record "Excel Buffer" temporary; Col: Integer; Row: Integer): Decimal
    var
        d: Decimal;
    begin
        if Buffer.Get(Row, col) then begin
            Evaluate(d, Buffer."Cell Value as Text");
            exit(d);
        end;

    end;

    local procedure GetValidateDimValues(var ExcelBuffer: Record "Excel Buffer" temporary; var RowNo: Integer; var DimValue: array[8] of Code[20])
    var
        i: Integer;
        IntPurchPayment: Codeunit IntPurchPayment;
    begin
        for i := 1 to ArrayLen(DimValue) do begin
            DimValue[i] := GetText(ExcelBuffer, i + 8, RowNo);
            if DimValue[i] <> '' then
                IntPurchPayment.ValidateDim(i, DimValue[i]);
        end;
    end;


    local procedure GetGLAcc(Acc: Code[20]; DimValue: array[8] of Code[20]; BrAcc: Boolean): Code[20]
    var
        GLAcc: Record "G/L Account";
        FromToUSGAAP: Record "From/To US GAAP";
    begin
        if BrAcc then
            exit(Acc);

        GLAcc.SetRange("No. 2", Acc);
        if GLAcc.FindFirst() then begin
            exit(GLAcc."No.")
        end else
            FromToUSGAAP.SetRange("US GAAP", Acc);
        DimFilterFromToUSGAAP(DimValue, FromToUSGAAP);
        FromToUSGAAP.FindFirst();
        exit(FromToUSGAAP."BR GAAP");

    end;

    local procedure DimFilterFromToUSGAAP(DimValue: array[8] of Code[20]; var FromToUSGAAP: Record "From/To US GAAP")
    begin
        FromToUSGAAP.SetRange("Dimension 1", DimValue[1]);
        FromToUSGAAP.SetRange("Dimension 2", DimValue[2]);
        FromToUSGAAP.SetRange("Dimension 3", DimValue[3]);
        FromToUSGAAP.SetRange("Dimension 4", DimValue[4]);
        FromToUSGAAP.SetRange("Dimension 5", DimValue[5]);
        FromToUSGAAP.SetRange("Dimension 6", DimValue[6]);
        FromToUSGAAP.SetRange("Dimension 7", DimValue[7]);
        FromToUSGAAP.SetRange("Dimension 8", DimValue[8]);
    end;
}
