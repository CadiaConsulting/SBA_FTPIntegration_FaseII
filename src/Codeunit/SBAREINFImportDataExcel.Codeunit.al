codeunit 50019 "SBA REINF Import Data Excel"
{
    TableNo = "CADBR REINFSet-R4000_10_80";

    trigger OnRun()
    begin
        REINFSetR4000 := Rec;
        SetupReinf.get();

        Clear(ExistValue);
        ImportExcelFile();
    end;

    var
        Window: Dialog;
        RecNo: Integer;
        TotalRecNo: Integer;
        NextLine: Integer;
        Ok: Boolean;
        TempExcelBuffer: Record "Excel Buffer" temporary;
        SetupReinf: Record "CADBR REINF Setup";
        REINFSetR4000: Record "CADBR REINFSet-R4000_10_80";
        "4010Detail": Record "CADBR REINF4010 Details";
        "4010Detail2": Record "CADBR REINF4010 Details";
        "4010Document": Record "CADBR REINF4000 Det Document";
        BranchInformation: Record "CADBR Branch Information";
        ExistValue: Boolean;
        Text001: label 'Analyzing Data...\\';
        Text002: label 'No Default Table selected.';
        Text003: label 'Process Done!';
        VendorCNPJ: Text[20];
        CNPJ: Text[20];
        DescricaoRRA: Text[50];
        RRA: Boolean;
        QtdeMeses: Text[4];

    procedure ImportExcelFile()
    var
        FileManagement: Codeunit "File Management";
        TempBlob: Codeunit "Temp Blob";

        SheetName, ErrorMessage : Text;
        FileInStream: InStream;
        ImportFileLbl: Label 'Import file';
    begin
        // Select file and import the file to tempBlob
        FileManagement.BLOBImportWithFilter(TempBlob, ImportFileLbl, '', FileManagement.GetToFilterText('', '.xlsx'), 'xlsx');

        // Select sheet from the excel file
        TempBlob.CreateInStream(FileInStream);
        SheetName := TempExcelBuffer.SelectSheetsNameStream(FileInStream);

        // Open selected sheet
        TempBlob.CreateInStream(FileInStream);
        ErrorMessage := TempExcelBuffer.OpenBookStream(FileInStream, SheetName);
        if ErrorMessage <> '' then
            Error(ErrorMessage);

        TempExcelBuffer.ReadSheet();
        case SheetName of
            'Planilha1':
                Import(1);
        end;
    end;

    procedure Import(TabSeq: Integer)
    begin

        TempExcelBuffer.Reset;
        TempExcelBuffer.SetFilter(TempExcelBuffer."Row No.", '<>%1', 1);

        AnalyzeData(TabSeq);

        if not ExistValue then
            Message(Text002)
        else
            Message(Text003);

        TempExcelBuffer.Reset;
        TempExcelBuffer.DeleteAll;
    end;

    procedure AnalyzeData(TabSeq: Integer)
    begin
        Window.Open(
          Text001 +
          '@1@@@@@@@@@@@@@@@@@@@@@@@@@\');
        Window.Update(1, 0);
        TotalRecNo := TempExcelBuffer.Count;

        clear(RecNo);
        clear(Ok);

        if TempExcelBuffer.Find('-') then begin
            ExistValue := true;

            repeat
                RecNo := RecNo + 1;
                Window.Update(1, ROUND(RecNo / TotalRecNo * 10000, 1));

                if (TempExcelBuffer.xlColID = 'N') and (TempExcelBuffer."Cell Value as Text" <> '') then begin
                    ok := true;
                    InputTable(TabSeq);
                end;
                if Ok then begin
                    if (TempExcelBuffer.xlColID = 'O') and (TempExcelBuffer."Cell Value as Text" <> '') then
                        InputTable(TabSeq);
                    if (TempExcelBuffer.xlColID = 'P') and (TempExcelBuffer."Cell Value as Text" <> '') then
                        InputTable(TabSeq);
                    if (TempExcelBuffer.xlColID = 'Q') and (TempExcelBuffer."Cell Value as Text" <> '') then
                        InputTable(TabSeq);
                    if (TempExcelBuffer.xlColID = 'R') and (TempExcelBuffer."Cell Value as Text" <> '') then
                        InputTable(TabSeq);
                    if (TempExcelBuffer.xlColID = 'S') and (TempExcelBuffer."Cell Value as Text" <> '') then
                        InputTable(TabSeq);
                    if (TempExcelBuffer.xlColID = 'T') and (TempExcelBuffer."Cell Value as Text" <> '') then
                        InputTable(TabSeq);
                    if (TempExcelBuffer.xlColID = 'U') and (TempExcelBuffer."Cell Value as Text" <> '') then
                        InputTable(TabSeq);
                    if (TempExcelBuffer.xlColID = 'V') and (TempExcelBuffer."Cell Value as Text" <> '') then
                        InputTable(TabSeq);
                    if (TempExcelBuffer.xlColID = 'W') and (TempExcelBuffer."Cell Value as Text" <> '') then
                        InputTable(TabSeq);
                    if (TempExcelBuffer.xlColID = 'X') and (TempExcelBuffer."Cell Value as Text" <> '') then
                        InputTable(TabSeq);
                    if (TempExcelBuffer.xlColID = 'Y') and (TempExcelBuffer."Cell Value as Text" <> '') then
                        InputTable(TabSeq);
                    if (TempExcelBuffer.xlColID = 'Z') and (TempExcelBuffer."Cell Value as Text" <> '') then
                        InputTable(TabSeq);
                    if (TempExcelBuffer.xlColID = 'AA') and (TempExcelBuffer."Cell Value as Text" <> '') then
                        InputTable(TabSeq);
                    if (TempExcelBuffer.xlColID = 'AB') and (TempExcelBuffer."Cell Value as Text" <> '') then
                        InputTable(TabSeq);
                    if (TempExcelBuffer.xlColID = 'AC') and (TempExcelBuffer."Cell Value as Text" <> '') then
                        InputTable(TabSeq);
                    if (TempExcelBuffer.xlColID = 'AD') and (TempExcelBuffer."Cell Value as Text" <> '') then
                        InputTable(TabSeq);
                end;
            until TempExcelBuffer.Next = 0;
        end;

        Window.Close;
    end;

    procedure InputTable(TabSeq: Integer)
    begin
        case TabSeq of
            1:
                "4010Doc";
        end;
    end;

    procedure "4010Doc"()
    var
        natRend: Code[5];
        Vendor: Record Vendor;
        RowNo: Integer;
        AmountRendBruto: Text;
        AmounRendTribIR: Text;
        AmountRetencaoIR: Text;
        DateFG: Date;
    begin
        TempExcelBuffer.Reset();
        if (TempExcelBuffer.xlColID = 'W') then begin
            AmountRendBruto := TempExcelBuffer."Cell Value as Text";
        end;

        if (TempExcelBuffer.xlColID = 'X') and (TempExcelBuffer."Cell Value as Text" <> '') then
            AmounRendTribIR := TempExcelBuffer."Cell Value as Text";

        if (TempExcelBuffer.xlColID = 'Y') and (TempExcelBuffer."Cell Value as Text" <> '') then
            AmountRetencaoIR := TempExcelBuffer."Cell Value as Text";

        if (TempExcelBuffer.xlColID = 'N') and (TempExcelBuffer."Cell Value as Text" <> '') then begin
            "4010Document".Init;
            "4010Document".TypeRegister := "4010Document".Typeregister::R4010;
            "4010Document"."No." := REINFSetR4000."No.";
            Evaluate("4010Document"."Vendor No.", TempExcelBuffer."Cell Value as Text");
            "4010Document".Validate("Vendor No.");
            cnpj := "4010Document"."cnpj/cpfPrestador";
        end;

        if (TempExcelBuffer.xlColID = 'U') then
            Evaluate("4010Document".dtFG, TempExcelBuffer."Cell Value as Text");

        if (TempExcelBuffer.xlColID = 'Z') and (TempExcelBuffer."Cell Value as Text" <> '') then begin
            Evaluate("4010Document".DocumentoNavBC, TempExcelBuffer."Cell Value as Text");
        end;

        if (TempExcelBuffer.xlColID = 'AA') then begin
            "4010Document".natRend := TempExcelBuffer."Cell Value as Text";
            "4010Document".Insert;
        end;

        if AmountRendBruto <> '' then
            Evaluate("4010Document".vlrRendBruto, AmountRendBruto);

        if AmounRendTribIR <> '' then
            Evaluate("4010Document".vlrRendTribIR, AmounRendTribIR);

        if AmountRetencaoIR <> '' then
            Evaluate("4010Document".vlrRetencaoIR, AmountRetencaoIR);

        if (TempExcelBuffer.xlColID = 'N') or (TempExcelBuffer.xlColID = 'Z') then
            "4010Det"();

        if (TempExcelBuffer.xlColID = 'AB') and (TempExcelBuffer."Cell Value as Text" <> '') then begin
            Evaluate("4010Document".indRRA, TempExcelBuffer."Cell Value as Text");
            "4010Document".Modify;
            RRA := true
        end;

        if (TempExcelBuffer.xlColID = 'AC') and (TempExcelBuffer."Cell Value as Text" <> '0') then
            QtdeMeses := TempExcelBuffer."Cell Value as Text";

        if RRA and (QtdeMeses <> '') then
            ProcessJud();
    end;

    procedure "4010Det"()
    begin
        SetupReinf.Get();
        if REINFSetR4000."Branch Code" <> '' then
            BranchInformation.get(REINFSetR4000."Branch Code");

        TempExcelBuffer.Reset;

        if (TempExcelBuffer.xlColID = 'N') and (TempExcelBuffer."Cell Value as Text" <> '') then begin
            "4010Detail".Init;
            "4010Detail"."No." := REINFSetR4000."No.";
            "4010Detail"."File Type" := REINFSetR4000."File Type";
            "4010Detail".verProc := FORMAT(SetupReinf."Version Event Issue Process");
            Evaluate("4010Detail"."Vendor No.", TempExcelBuffer."Cell Value as Text");
            VendorCNPJ := '';
            "4010Detail".Validate("Vendor No.");
            VendorCNPJ := "4010Detail".cnpjBenef;
        end;

        if (TempExcelBuffer.xlColID = 'Z') then begin
            "4010Detail".perApur := DataFormatAnoMes(REINFSetR4000."Start Date");
            "4010Detail".tpInsc := '1';
            "4010Detail".nrInsc := DelChr(BranchInformation."C.N.P.J.", '=', './-');
            "4010Detail".tpInscEstab := '1';
            "4010Detail".nrInscEstab := DelChr(BranchInformation."C.N.P.J.", '=', './-');
            Evaluate("4010Detail"."Document No.", TempExcelBuffer."Cell Value as Text");

            case SetupReinf.Ambient of
                SetupReinf.Ambient::"1.Production":
                    "4010Detail".tpAmb := '1';
                SetupReinf.Ambient::"2.Production Restricted - Real Data":
                    "4010Detail".tpAmb := '2';
                SetupReinf.Ambient::"3.Production Restricted - Fictional Data":
                    "4010Detail".tpAmb := '2';
            end;

            case SetupReinf."Event Issue Process" of
                SetupReinf."event issue process"::"1.Emission with taxpayer application":
                    "4010Detail".procEmi := '1';
                SetupReinf."event issue process"::"2.Emission with government application":
                    "4010Detail".procEmi := '2';
            end;

            "4010Detail2".RESET;
            "4010Detail2".SETCURRENTKEY("No.", cnpjBenef, "Vendor No.", Version);
            "4010Detail2".SETRANGE("No.", REINFSetR4000."No.");
            "4010Detail2".setrange(cnpjBenef, "4010Detail".cnpjBenef);
            "4010Detail2".SETRANGE(Version, 0);
            IF not "4010Detail2".FINDFIRST THEN
                "4010Detail".Insert;
        end;
    end;

    procedure ProcessJud()
    var
        ProcJudAdmin: Record "CADBR Process Jud Admin REINF";
        ProcJudRRA: Record "CADBR Process Jud - Info RRA";
        Vendor: Record Vendor;
    begin
        TempExcelBuffer.reset;
        if (TempExcelBuffer.xlColID = 'AD') then begin
            ProcJudAdmin.reset;
            ProcJudAdmin.SetRange("Process Type", ProcJudAdmin."Process Type"::"1.ADM");
            ProcJudAdmin.setrange("No. Process", '');
            ProcJudAdmin.setrange("Branch Code", REINFSetR4000."Branch Code");
            if ProcJudAdmin.FindFirst() then
                ProcJudAdmin.Modify()
            else begin
                ProcJudAdmin."Process Type" := ProcJudAdmin."Process Type"::"1.ADM";
                ProcJudAdmin."No. Process" := '';
                ProcJudAdmin."Branch Code" := REINFSetR4000."Branch Code";
                ProcJudAdmin.insert;
            end;
            ProcJudRRA.Init();
            ProcJudRRA."Process Type" := ProcJudRRA."Process Type"::"1.ADM";
            ProcJudRRA."No. Process" := '';
            ProcJudRRA.cnpjOrigRecurso := VendorCNPJ;
            ProcJudRRA."cnpj/cpfPrestador" := VendorCNPJ;
            ProcJudRRA.qtdMesesRRA := QtdeMeses;
            ProcJudRRA.descRRA := TempExcelBuffer."Cell Value as Text";
            ProcJudRRA."Tax Settlement No." := REINFSetR4000."No.";
            ProcJudRRA.dtFG := "4010Document".dtFG;
            ProcJudRRA.natRend := "4010Document".natRend;
            ProcJudRRA.DocumentoNavBC := "4010Document".DocumentoNavBC;
            ProcJudRRA.Insert();
            RRA := False;
        end;
    end;

    procedure GetValueAtCell(RowNo: Integer; ColNo: Integer): Text[30]
    begin
        TempExcelBuffer.Reset();
        TempExcelBuffer.SetFilter(TempExcelBuffer."Row No.", '<>%1', 1);
        if TempExcelBuffer.Get(RowNo, ColNo) then
            exit(TempExcelBuffer."Cell Value as Text")
        else
            exit('');
    end;

    procedure DataFormatAnoMes(DataConv: Date) DtConvertida: Text[7]
    begin
        DtConvertida := Format(Date2dmy(DataConv, 2));
        if StrLen(DtConvertida) = 1 then
            DtConvertida := '0' + DtConvertida;
        DtConvertida := Format(Date2dmy(DataConv, 3)) + '-' + DtConvertida;
    end;
}
