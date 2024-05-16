codeunit 50700 "Export NFTS"
{
    trigger OnRun()
    begin

    end;

    procedure RunNewFile(BranchCode: Code[20]; StartDate: Date; EndDate: Date)
    var
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchInvLine: record "Purch. Inv. Line";
        FiscalType: Record "CADBR Fiscal Document Type";
        CADBRNFeSetup: Record "CADBR NF-e Setup";
        BranchInf: Record "CADBR Branch Information";
        ServiceCode: Record "CADBR NFS Service Code";
        VatEntry: Record "VAT Entry";
        GLEntry: Record "G/L Entry";
        Vendor: Record Vendor;
        TempBlob: Codeunit "Temp Blob";
        TotalLines: Integer;
        TotalService: Decimal;
        TotalDedu: Decimal;
        InStr: InStream;
        OutStr: OutStream;
        varWriteText: Text;
        FileName: Text;
        CRLF: Text[2];
        DeductionAmount: Decimal;

    begin
        CRLF[1] := 13;
        CRLF[2] := 10;
        CADBRNFeSetup.get();
        CADBRNFeSetup.TestField("Versao do Layout NFST em Lote");
        CADBRNFeSetup.TestField("CADBR Service Delivery City");

        BranchInf.Get(BranchCode);


        FileName := 'NFTS' + format(Today) + '.txt';

        //Inicia arquivo
        TempBlob.CreateOutStream(OutStr, TextEncoding::Windows);

        //Busca as Linhas sem parentes
        varWriteText := '1';
        varWriteText += CADBRNFeSetup."Versao do Layout NFST em Lote";
        varWriteText += FormatValue(BranchInf."C.C.M.", 8, 0);
        varWriteText += format(StartDate, 0, '<Year4><Month,2><Day,2>');
        varWriteText += format(EndDate, 0, '<Year4><Month,2><Day,2>');
        varWriteText += CRLF;
        OutStr.WriteText(varWriteText);

        PurchInvHeader.Reset();
        PurchInvHeader.SetRange("Posting Date", StartDate, EndDate);
        PurchInvHeader.SetRange("Document Date", StartDate, EndDate);
        PurchInvHeader.SetRange("CADBR Credit Memos", false);
        PurchInvHeader.SetRange("CADBR Return Invoices", false);
        PurchInvHeader.SetFilter("Buy-from City", '<>%1', 'São Paulo');
        // PurchInvHeader.SetRange("CADBR Service Delivery City", CADBRNFeSetup."CADBR Service Delivery City");
        PurchInvHeader.SetFilter(Amount, '<>%1', 0);
        if BranchCode <> '' then
            PurchInvHeader.SetRange("CADBR Branch Code", BranchCode);
        if PurchInvHeader.Find('-') then
            repeat

                GLEntry.Reset();
                GLEntry.SetRange("Document No.", PurchInvHeader."No.");
                GLEntry.SetRange("Posting Date", PurchInvHeader."Posting Date");
                if GLEntry.FindFirst() then
                    if FiscalType.get(PurchInvHeader."CADBR Fiscal Document Type") and
                        FiscalType.Service then begin

                        Vendor.Get(PurchInvHeader."Buy-from Vendor No.");

                        PurchInvHeader.CalcFields(Amount);
                        TotalLines += 1; // numero de linhas
                        TotalService += PurchInvHeader.Amount; // valor total dos serviços
                                                               // TotalDedu := 0;// valor total das deduções

                        varWriteText := '4';//1) Tipo de registro	1	1	1	S	Numérico	Preencher com "4"
                        varWriteText += '02';//2) Tipo do documento	2	3	2	S	Numérico	Preencher com "02"
                        varWriteText += FormatValueText(PurchInvHeader."CADBR Print Serie", 5, ' '); //3) Série do Documento	4	8	5	N	Texto	Preencher com a série da NF
                        varWriteText += FormatValue(PurchInvHeader."Vendor Invoice No.", 12, '0');//4) Número do Documento	9	20	12	S	Numérico	Preencher com o numero do documento. É obrigatório completar com zeros a esquerda para compeltar 12 posições
                        varWriteText += format(PurchInvHeader."Document Date", 0, '<Year4><Month,2><Day,2>'); //5) Data da prestação dos serviços	21	28	8	S	AAAAMMDD	Informar a data do documento
                        varWriteText += 'N';//6) Situação da NFTS	29	29	1	S	Texto	Preencher com "N"
                        varWriteText += 'T';//7) Tributação do Serviço	30	30	1	S	Caractere	Preencher "T"
                        varWriteText += FormatValue(format(PurchInvHeader.Amount, 0, '<Precision,2:2><Standard Format,2>'), 15, '0');//8) Valor dos Serviços	31	45	15	S	Numérico	Preencher com o valor do serviço. Ex: R$ 500,85 – 000000000050085

                        clear(DeductionAmount);
                        VatEntry.Reset();
                        VatEntry.SetRange("Document No.", PurchInvHeader."No.");
                        VatEntry.SetRange("Posting Date", PurchInvHeader."Posting Date");
                        VatEntry.SetRange("CADBR Tax Identification", VatEntry."CADBR Tax Identification"::"ISS Ret.");
                        if VatEntry.FindFirst() then
                            repeat
                                if PurchInvHeader."CADBR Service Delivery City" = CADBRNFeSetup."CADBR Service Delivery City" then
                                    if VatEntry."CADBR Reduction Factor" <> 0 then begin
                                        DeductionAmount += VatEntry."CADBR Exempt Basis Amount";
                                        TotalDedu += VatEntry."CADBR Exempt Basis Amount";
                                    end;
                            until VatEntry.Next = 0;

                        varWriteText += FormatValue(Format(DeductionAmount, 0, '<Precision,2:2><Standard Format,2>'), 15, '0'); //9) Valor das Deduções	46	60	15	S	Numérico

                        PurchInvLine.Reset();
                        PurchInvLine.SetRange("Document No.", PurchInvHeader."No.");
                        PurchInvLine.SetFilter(Type, '<>%1', PurchInvLine.Type::" ");
                        if PurchInvLine.FindFirst() then begin

                            //if StrLen(PurchInvLine."CADBR Service Code") <> 5 then
                            //Error('Codigo de Serviço %1 precisa ter 5 caracteres no Documento %2', PurchInvLine."CADBR Service Code", PurchInvHeader."No.");

                            if ServiceCode.Get(PurchInvLine."CADBR Service Code") then;
                            varWriteText += FormatValue(CopyStr(DelChr(ServiceCode."Code", '=', ',./-'), 1, 5), 5, '0');//10) Código do Serviço Tomado ou Intermediado	61	65	5	S	Numérico	Informar o Código do Serviço da NFTS com 05 posições.
                            varWriteText += FormatValue(CopyStr(DelChr(ServiceCode."Service Item Code", '=', ',./-'), 1, 4), 4, '0'); //11) Código do Subitem da lista	66	69	4	N	Numérico	Informar o código do Serviço da LC116, ou seja, campo "Código IBPT" quando "Tipo Código IBPT" = "Serviço - LC 116"
                        end;

                        VatEntry.Reset();
                        VatEntry.SetRange("Document No.", PurchInvHeader."No.");
                        VatEntry.SetRange("Posting Date", PurchInvHeader."Posting Date");
                        VatEntry.SetRange("CADBR Tax Identification", VatEntry."CADBR Tax Identification"::"ISS Ret.");
                        if VatEntry.FindFirst() then begin
                            if PurchInvHeader."CADBR Service Delivery City" <> CADBRNFeSetup."CADBR Service Delivery City" then begin
                                varWriteText += FormatValue('0', 4, '0');//12) Alíquota	70	73	4	S	Numérico	Informar a Alíquota do ISS Retido com 4 posições. Ex: 5,00% – 0500
                                varWriteText += '2'; //13) ISS Retido	74	74	1	S	Numérico	Preencher com "1" se tiver valor de ISS Ret ou preencher com "2" se não tiver valor de ISS Ret
                            end else begin
                                varWriteText += FormatValue(format(VatEntry."CADBR Tax %" * 100), 4, '0');//12) Alíquota	70	73	4	S	Numérico	Informar a Alíquota do ISS Retido com 4 posições. Ex: 5,00% – 0500
                                varWriteText += '1'; //13) ISS Retido	74	74	1	S	Numérico	Preencher com "1" se tiver valor de ISS Ret ou preencher com "2" se não tiver valor de ISS Ret
                            end
                        end else begin
                            varWriteText += FormatValue('0', 4, '0');//12) Alíquota	70	73	4	S	Numérico	Informar a Alíquota do ISS Retido com 4 posições. Ex: 5,00% – 0500
                            varWriteText += '2'; //13) ISS Retido	74	74	1	S	Numérico	Preencher com "1" se tiver valor de ISS Ret ou preencher com "2" se não tiver valor de ISS Ret
                        end;

                        if Vendor."CADBR Category" = Vendor."CADBR Category"::"1.- Person" then
                            varWriteText += '1';//14) Indicador de CPF/CNPJ do Prestador	75	75	1	S	Numérico	Preencher com "1" para CPF, "2" para CNPJ e "3" para Prestador estabelecido no exterior
                        if Vendor."CADBR Category" = Vendor."CADBR Category"::"2.- Company" then
                            varWriteText += '2';//14) Indicador de CPF/CNPJ do Prestador	75	75	1	S	Numérico	Preencher com "1" para CPF, "2" para CNPJ e "3" para Prestador estabelecido no exterior
                        if Vendor."CADBR Category" = Vendor."CADBR Category"::"5.- Foreign Person" then
                            varWriteText += '3';//14) Indicador de CPF/CNPJ do Prestador	75	75	1	S	Numérico	Preencher com "1" para CPF, "2" para CNPJ e "3" para Prestador estabelecido no exterior

                        varWriteText += FormatValue(Vendor."CADBR C.N.P.J./C.P.F.", 14, 0);//15) CPF ou CNPJ do Prestador	76	89	14	S	Numérico	Preencher com o CNPJ ou CPF. Se for CPF, preencher com zeros a esquerda para completar as 14 posições.

                        //if StrLen(Vendor."CADBR C.C.M.") > 8 then
                        //    Error('Inscrição Municipal do Fornecedor %1 maior que 8 caracteres, favor corrigir o cadastro', Vendor."No.");

                        varWriteText += FormatValueText('', 8, ' ');//16) Inscrição Municipal do Prestador	90	97	8	N	Numérico	Preencher com a inscrição municipal do Fornecedor
                        varWriteText += FormatValueText(Vendor.Name, 75, ' ');//17) Nome/ Razão Social do Prestador	98	172	75	N	Texto	Preencher com o nome do Fornecedor
                        varWriteText += FormatValueText('', 3, ' ');//18) Tipo do Endereço do Prestador (Rua, Av, ...)	173	175	3	N	Texto	Preencher com o tipo de endereço do Fornecedor. Informar os 3 primeiros descritivos do campo Endereço. Ex: Rua, AV
                        varWriteText += FormatValueText(Vendor.Address, 50, ' ');//19) Endereço do Prestador	176	225	50	N	Texto	Preencher com o endereço do Fornecedor. 
                        varWriteText += FormatValueText(Vendor."CADBR Number", 10, ' ');//20) Número do Endereço do Prestador	226	235	10	N	Texto	Preencher com o número do endereço do Fornecedor.
                        varWriteText += FormatValueText(CopyStr(Vendor."Address 2", 1, 30), 30, ' ');//21) Complemento do Endereço do Prestador	236	265	30	N	Texto	Preencher com o endereço complementar do fornecedor.
                        varWriteText += FormatValueText(Vendor."CADBR District", 30, ' ');//22) Bairro do Prestador	266	295	30	N	Texto	Preencher com o bairro do fornecedor.
                        varWriteText += FormatValueText(Vendor.City, 50, ' ');//23) Cidade do Prestador	296	345	50	N	Texto	Preencher com a cidade do fornecedor.
                        varWriteText += FormatValueText(Vendor."Territory Code", 2, ' ');//24) UF do Prestador	346	347	2	N	Texto	Preencher com a UF do fornecedor.
                        varWriteText += FormatValue(Vendor."Post Code", 8, 0);//25) CEP do Prestador	348	355	8	S	Numérico	Preencher com o CEP do fornecedor.
                        varWriteText += FormatValueTextEmail(CopyStr(Vendor."E-Mail", 1, 75), 75, ' ');//26) E-mail do Prestador	356	430	75	N	Texto	Preencher com o email do cartão do fornecedor.
                        varWriteText += '1';//27) Tipo de NFTS	431	431	1	N	Numérico	Preencher com "1".

                        if vendor."Regime de Tributacao" = Vendor."Regime de Tributacao"::"0 Normal ou Simples Nacional (DAMSP)" then
                            varWriteText += '0';//28) Regime de Tributação	432	432	1	S	Numérico	Preencher com o "código do regime de tributação" informado no cartão do fornecedor.
                        if vendor."Regime de Tributacao" = Vendor."Regime de Tributacao"::"4 Simples Nacional (DAS)" then
                            varWriteText += '4';//28) Regime de Tributação	432	432	1	S	Numérico	Preencher com o "código do regime de tributação" informado no cartão do fornecedor.
                        if vendor."Regime de Tributacao" = Vendor."Regime de Tributacao"::"5 Microempreendedor Individual - MEI" then
                            varWriteText += '5';//28) Regime de Tributação	432	432	1	S	Numérico	Preencher com o "código do regime de tributação" informado no cartão do fornecedor.

                        varWriteText += FormatValue('', 8, ' ');//29) Data de Pagamento da Nota	433	440	8	N	AAAAMMDD	Preencher com a data de pagamento da NF. Caso não tenha, deixar em branco.
                                                                //PurchInvLine.Description
                        varWriteText += ServiceCode.Description;//30) Discriminação dos Serviços	441	441+(N-1)	N (N ≤ 1000) (*)	N	Texto	Preencher com a descrição do serviço, ou seja, a descrição da linha.

                        varWriteText += CRLF;//Caractere de Fim de Linha	442 + N	443 + N	2	S	ASCII(13) + ASCII(10)	Caractere de Fim de Linha (Chr(13) + Chr(10)).

                        OutStr.WriteText(varWriteText);

                    end;

            until PurchInvHeader.Next() = 0;

        varWriteText := '9';
        varWriteText += FormatValue(format(TotalLines), 7, '0');
        varWriteText += FormatValue(format(TotalService), 15, '0');
        varWriteText += FormatValue(format(TotalDedu, 0, '<Precision,2:2><Standard Format,2>'), 15, '0');
        varWriteText += CRLF;
        OutStr.WriteText(varWriteText);

        //Fecha Arquivo
        TempBlob.CreateInStream(InStr, TextEncoding::Windows);
        DownloadFromStream(InStr, '', '', '', FileName);

    end;


    procedure FormatValue(ValueText: Text; LenInt: Integer; CharValue: Char): Text
    var
        TextValue: Text;

    begin
        TextValue := DelChr(format(ValueText), '=', ',./-');
        textValue := textValue.PadLeft(LenInt, CharValue);
        exit(TextValue);
    end;

    procedure FormatValueText(ValueText: Text; LenInt: Integer; CharValue: Char): Text
    var
        TextValue: Text;

    begin
        TextValue := DelChr(format(ValueText), '=', ',./-');
        textValue := textValue.PadRight(LenInt, CharValue);
        exit(TextValue);
    end;

    procedure FormatValueTextEmail(ValueText: Text; LenInt: Integer; CharValue: Char): Text
    var
        TextValue: Text;

    begin
        TextValue := ValueText;
        textValue := textValue.PadRight(LenInt, CharValue);
        exit(TextValue);
    end;




}