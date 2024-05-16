// Codeunit 55000 "XML Test"
// {
//     trigger OnRun()
//     var
//         NFeXMLImpSetup: Record "CADBR NFe XML Import Setup";
//         NFeXMLImpMgt: Codeunit "CADBR NFe XML Importation Mgt";
//         NFeXMLtoPurchInv: Codeunit "CADBR NFe XML to Purch. Inv.";
//         PurchHeader: Record "Purchase Header";
//         PurchOrderRecon: Page "CADBR Purc.Order Reconciliat";
//         PurchInvoice: Page "Purchase Invoice";
//         PathToFile: Text;
//         InStr: InStream;
//         XMLtxt: Text;
//         TmpNFeHeader: Record "CADBR NFe XML" temporary;
//         TmpNFeLine: Record "CADBR NFe XML Line" temporary;
//         TmpNFeLineTax: Record "CADBR NFe XML Line Tax" temporary;
//         outOutStream: OutStream;


//     begin

//         NFeXMLImpSetup.GET;
//         NFeXMLImpSetup.TESTFIELD("Fiscal Document Type");
//         NFeXMLImpSetup.TESTFIELD("Item Tax Area Code");
//         NFeXMLImpSetup.TESTFIELD("Item Charge Tax Area Code");
//         NFeXMLImpSetup.TESTFIELD("Freight Item Charge Code");
//         NFeXMLImpSetup.TESTFIELD("Insurance Item Charge Code");
//         NFeXMLImpSetup.TESTFIELD("Other Exp. Item Charge Code");

//         UploadIntoStream('Select File', '', 'Xml (*.xml)|*.xml', PathToFile, InStr);

//         if PathToFile = '' then
//             exit;


//         CLEAR(XMLBuffer);
//         XMLBuffer.DeleteAll();

//         XMLBuffer.LoadFromStream(InStr);  //Levar XML para tabela Buffer

//         XMLBuffer.Reset();
//         if XMLBuffer.FindFirst() then
//             repeat
//                 XMLBufferAux.Init();
//                 XMLBufferAux.TransferFields(XMLBuffer);
//                 XMLBufferAux.Insert();

//                 XMLBufferTax.Init();
//                 XMLBufferTax.TransferFields(XMLBuffer);
//                 XMLBufferTax.Insert();
//             until XMLBuffer.Next = 0;

//         ImportFile;
//         ThrowErrors;

//         NFeXMLImpMgt.GetRecords(TmpNFeHeader, TmpNFeLine, TmpNFeLineTax);

//         NFeXMLtoPurchInv.SetRecords(TmpNFeHeader, TmpNFeLine, TmpNFeLineTax);
//         NFeXMLtoPurchInv.Run;
//         NFeXMLtoPurchInv.GetCreatedPurchHeader(PurchHeader);

//         if PurchHeader.FindFirst then begin
//             nfeXMLImpSetup.Get;
//             if nfeXMLImpSetup."Open Order Reconciliation" then begin
//                 Commit;
//                 purchOrderRecon.SetPurchInvoice(purchHeader);
//                 purchOrderRecon.RunModal;
//                 purchInvoice.SetRecord(purchHeader);
//                 purchInvoice.Run;
//             end else begin
//                 purchInvoice.SetRecord(purchHeader);
//                 purchInvoice.Run;
//             end;
//         end;
//     end;

//     var
//         TxtFile: Text;
//         TmpNFeXML: Record "CADBR NFe XML" temporary;
//         TmpNFeXMLLine: Record "CADBR NFe XML Line" temporary;
//         TmpNFeXMLLineTax: Record "CADBR NFe XML Line Tax" temporary;
//         LineCount: Integer;
//         ErrorCount: Integer;
//         EmptyElement: label 'Elemento %1 vazio.';
//         DecimalConvertError: label 'Impossível converter %1 em Decimal.';
//         DetTagNotFound: label 'Nenhum tag <det> encontrado.';
//         NfeProcTagNotFound: label 'Tag <nfeProc> não encontrada.';
//         ErrorList: array[100] of Text;
//         InStr: InStream;

//     procedure ImportFile()
//     var
//         InfNFeFound: Boolean;
//         DetFound: Boolean;
//         DateText: Text;
//         vDate: Date;
//         vTime: Time;
//     begin
//         TmpNFeXML.Init();

//         XMLBuffer.RESET;
//         XMLBuffer.SETRANGE(XMLBuffer.Type, XMLBuffer.Type::Element);
//         If XMLBuffer.Findfirst() then
//             repeat
//                 case XMLBuffer.Path of
//                     '/NFe/infNFe',
//                     '/nfeProc/NFe/infNFe':
//                         InfNFeFound := true;
//                     '/NFe/infNFe/det',
//                     '/nfeProc/NFe/infNFe/det':
//                         DetFound := true;
//                     '/NFe/infNFe/ide/nNF',
//                     '/nfeProc/NFe/infNFe/ide/nNF':
//                         TmpNFeXML."No." := XMLBuffer.Value;
//                     '/NFe/infNFe/ide/serie',
//                     '/nfeProc/NFe/infNFe/ide/serie':
//                         TmpNFeXML."Print Serie" := XMLBuffer.Value;
//                     '/protNFe/infProt/chNFe',
//                     '/nfeProc/protNFe/infProt/chNFe':
//                         TmpNFeXML."Access Key" := XMLBuffer.Value;
//                     '/protNFe/infProt/nProt',
//                     '/nfeProc/protNFe/infProt/nProt':
//                         TmpNFeXML."Protocol No." := XMLBuffer.Value;
//                     '/protNFe/infProt/dhRecbto',
//                     '/nfeProc/protNFe/infProt/dhRecbto':
//                         begin
//                             dateText := XMLBuffer.Value;
//                             if dateText <> '' then begin
//                                 Evaluate(vDate, CopyStr(DateText, 1, 4) + '-' +
//                                                CopyStr(DateText, 6, 2) + '-' +
//                                                CopyStr(DateText, 9, 2));
//                                 Evaluate(vTime, CopyStr(DateText, 12, 8));
//                                 TmpNFeXML."Date/Time Received" := CreateDateTime(vDate, vTime);
//                             end;
//                         end;
//                     '/NFe/infNFe/ide/dhEmi',
//                     '/nfeProc/NFe/infNFe/ide/dhEmi':
//                         begin
//                             dateText := XMLBuffer.Value;
//                             if dateText <> '' then begin
//                                 Evaluate(vDate, CopyStr(DateText, 1, 4) + '-' +
//                                                CopyStr(DateText, 6, 2) + '-' +
//                                                CopyStr(DateText, 9, 2));
//                                 TmpNFeXML.Date := vDate;
//                             end;
//                         end;
//                     '/NFe/infNFe/emit/CNPJ',
//                     '/nfeProc/NFe/infNFe/emit/CNPJ':
//                         TmpNFeXML."Vendor CNPJ" := XMLBuffer.Value;
//                     '/NFe/infNFe/dest/CNPJ',
//                     '/nfeProc/NFe/infNFe/dest/CNPJ':
//                         TmpNFeXML."Customer CNPJ" := XMLBuffer.Value;
//                 end;
//             until XMLBuffer.next = 0;

//         if not InfNFeFound then begin
//             AddError(NfeProcTagNotFound);
//             exit;
//         end;

//         if not DetFound then begin
//             AddError(DetTagNotFound);
//             exit;
//         end;

//         TmpNFeXML.Insert;

//         ProcessDetNode;
//     end;

//     local procedure ProcessDetNode()
//     var
//         LineNo: Integer;

//     begin
//         XMLBuffer.RESET;
//         XMLBuffer.SetFilter(XMLBuffer.Path, '*/NFe/infNFe/det/*');
//         If XMLBuffer.Findfirst() then
//             repeat
//                 case XMLBuffer.Path of
//                     '/NFe/infNFe/det/@nItem',
//                     '/nfeProc/NFe/infNFe/det/@nItem':
//                         begin
//                             TmpNFeXMLLine.Init;
//                             TmpNFeXMLLine."NFe XML No." := TmpNFeXML."No.";

//                             Evaluate(TmpNFeXMLLine."Line No.", XMLBuffer.Value);

//                             TmpNFeXMLLine.Insert();
//                         end;

//                     '/NFe/infNFe/det/prod/cProd',
//                     '/nfeProc/NFe/infNFe/det/prod/cProd':
//                         TmpNFeXMLLine."Vendor Item No." := XMLBuffer.Value;

//                     '/NFe/infNFe/det/prod/xProd',
//                     '/nfeProc/NFe/infNFe/det/prod/xProd':
//                         TmpNFeXMLLine.Description := CopyStr(XMLBuffer.Value, 1, MaxStrLen(TmpNFeXMLLine.Description));

//                     '/NFe/infNFe/det/prod/NCM',
//                     '/nfeProc/NFe/infNFe/det/prod/NCM':
//                         TmpNFeXMLLine."NCM Code" := CopyStr(XMLBuffer.Value, 1, 4) + '.' + CopyStr(XMLBuffer.Value, 5, 2) + '.' + CopyStr(XMLBuffer.Value, 7, 2);

//                     '/NFe/infNFe/det/prod/CFOP',
//                     '/nfeProc/NFe/infNFe/det/prod/CFOP':
//                         TmpNFeXMLLine."CFOP Code" := CopyStr(XMLBuffer.Value, 1, 1) + '.' + CopyStr(XMLBuffer.Value, 2, 3);

//                     '/NFe/infNFe/det/prod/qTrib',
//                     '/nfeProc/NFe/infNFe/det/prod/qTrib':
//                         TmpNFeXMLLine.Quantity := GetDecimal(XMLBuffer.Value);

//                     '/NFe/infNFe/det/prod/vUnTrib',
//                     '/nfeProc/NFe/infNFe/det/prod/vUnTrib':
//                         TmpNFeXMLLine."Unit Price" := GetDecimal(XMLBuffer.Value);

//                     '/NFe/infNFe/det/prod/vProd',
//                     '/nfeProc/NFe/infNFe/det/prod/vProd':
//                         TmpNFeXMLLine."Line Amount" := GetDecimal(XMLBuffer.Value);

//                     '/NFe/infNFe/det/prod/vDesc',
//                     '/nfeProc/NFe/infNFe/det/prod/vDesc':
//                         TmpNFeXMLLine."Line Discount Amount" := GetDecimal(XMLBuffer.Value);

//                     '/NFe/infNFe/det/prod/uTrib',
//                     '/nfeProc/NFe/infNFe/det/prod/uTrib':
//                         TmpNFeXMLLine."Vendor Unit of Measure Code" := CopyStr(XMLBuffer.Value, 1, MaxStrLen(TmpNFeXMLLine."Vendor Unit of Measure Code"));

//                     '/NFe/infNFe/det/prod/vFrete',
//                     '/nfeProc/NFe/infNFe/det/prod/vFrete':
//                         TmpNFeXMLLine."Freight Amount" := GetDecimal(XMLBuffer.Value);

//                     '/NFe/infNFe/det/prod/vSeg',
//                     '/nfeProc/NFe/infNFe/det/prod/vSeg':
//                         TmpNFeXMLLine."Insurance Amount" := GetDecimal(XMLBuffer.Value);

//                     '/NFe/infNFe/det/prod/vOutro',
//                     '/nfeProc/NFe/infNFe/det/prod/vOutro':
//                         TmpNFeXMLLine."Other Expenses Amount" := GetDecimal(XMLBuffer.Value);

//                     '/NFe/infNFe/det/imposto',
//                     '/nfeProc/NFe/infNFe/det/imposto':
//                         begin
//                             ProcessTaxesNode(XMLBuffer."Entry No.");
//                             TmpNFeXMLLine.Modify();
//                         end;
//                 end;
//             until XMLBuffer.Next = 0;
//     end;

//     local procedure ProcessTaxesNode(ParentEntry: Integer)
//     var
//         taxAreaLine: Record "Tax Area Line";
//     begin
//         ProcessTax(taxAreaLine."CADBR Tax Identification"::ICMS, ParentEntry);
//         ProcessTax(taxAreaLine."CADBR Tax Identification"::ST, ParentEntry);
//         ProcessTax(taxAreaLine."CADBR Tax Identification"::IPI, ParentEntry);
//         ProcessTax(taxAreaLine."CADBR Tax Identification"::PIS, ParentEntry);
//         ProcessTax(taxAreaLine."CADBR Tax Identification"::COFINS, ParentEntry);
//         ProcessTax(taxAreaLine."CADBR Tax Identification"::II, ParentEntry);
//     end;

//     local procedure ProcessTax(TaxId: Integer; ParentEntry: Integer)
//     var
//         taxIdText: Text;
//         path: Text;
//         suffix: Text;

//     begin
//         TmpNFeXMLLineTax."Tax Identification" := TaxId;

//         taxIdText := Format(TmpNFeXMLLineTax."Tax Identification");

//         if taxId = TmpNFeXMLLineTax."Tax Identification"::ST then begin
//             taxIdText := Format(TmpNFeXMLLineTax."Tax Identification"::ICMS);
//             suffix := 'ST';
//         end else
//             suffix := '';

//         if taxId = TmpNFeXMLLineTax."Tax identification"::II then
//             path := '*/NFe/infNFe/det/imposto/II/'
//         else
//             path := StrSubstNo('*/NFe/infNFe/det/imposto/%1*', taxIdText);

//         XMLBufferTax.RESET;
//         XMLBufferTax.SetRange(XMLBufferTax.Type, XMLBufferTax.Type::Element);
//         XMLBufferTax.SetFilter(XMLBufferTax.Path, path);
//         XMLBufferTax.SetRange(XMLBufferTax."Parent Entry No.", ParentEntry);
//         If XMLBufferTax.Findfirst() then begin
//             TmpNFeXMLLineTax.init;
//             TmpNFeXMLLineTax."NFe XML No." := TmpNFeXMLLine."NFe XML No.";
//             TmpNFeXMLLineTax."Line No." := TmpNFeXMLLine."Line No.";
//             TmpNFeXMLLineTax."Tax Identification" := TaxId;

//             taxIdText := Format(TmpNFeXMLLineTax."Tax Identification");

//             XMLBufferAux.reset;
//             XMLBufferAux.SetRange(XMLBufferAux.Type, XMLBufferAux.Type::Element);
//             XMLBufferAux.SetFilter(XMLBufferAux.Path, path);
//             XMLBufferAux.SetRange(XMLBufferAux."Parent Entry No.", XMLBufferTax."Entry No.", XMLBufferTax."Entry No." + 2);
//             if XMLBufferAux.FindFirst() then
//                 repeat
//                     case XMLBufferAux.Name of
//                         StrSubstNo('vBC%1', suffix):
//                             TmpNFeXMLLineTax.Base := GetDecimal(XMLBufferAux.Value);
//                         StrSubstNo('p%1%2', taxIdText, suffix):
//                             TmpNFeXMLLineTax.Percentage := GetDecimal(XMLBufferAux.Value);
//                         StrSubstNo('v%1%2', taxIdText, suffix):
//                             TmpNFeXMLLineTax.Amount := GetDecimal(XMLBufferAux.Value);
//                         StrSubstNo('pRedBC%1', suffix):
//                             TmpNFeXMLLineTax."Reduction Percentage" := GetDecimal(XMLBufferAux.Value);
//                         'CST':
//                             begin
//                                 if (TaxId in [TmpNFeXMLLineTax."Tax identification"::PIS, TmpNFeXMLLineTax."Tax identification"::COFINS]) AND (XMLBufferAux.Value = '') then
//                                     AddError(StrSubstNo(EmptyElement, XMLBufferAux.Path));
//                                 TmpNFeXMLLineTax."CST Code" := XMLBufferAux.Value;
//                             end;
//                         'orig':
//                             begin
//                                 // if (TaxId = TmpNFeXMLLineTax."Tax Identification"::ICMS) AND (XMLBufferAux.Value = '') then
//                                 TmpNFeXMLLineTax."Origin Code" := XMLBufferAux.Value;
//                             end;
//                         'vICMSDeson':
//                             TmpNFeXMLLineTax."Discounted Amount" := GetDecimal(XMLBufferAux.Value);
//                         'CSOSN':
//                             if (TaxId = TmpNFeXMLLineTax."Tax Identification"::ICMS) AND (TmpNFeXMLLineTax."CST Code" = '') then
//                                 TmpNFeXMLLineTax."CST Code" := XMLBufferAux.Value;
//                     end;
//                 until XMLBufferAux.Next = 0;

//             TmpNFeXMLLineTax.Insert();
//         end;
//     end;

//     procedure AddError(error: Text)
//     begin
//         ErrorCount += 1;
//         ErrorList[ErrorCount] := error;
//     end;

//     local procedure ThrowErrors()
//     var
//         errorMsg: Text;
//         i: Integer;
//         AutoNFeXMLImport: codeunit "CADBR NFe XML File Import Auto";

//     begin
//         IF GUIALLOWED THEN BEGIN

//             if ErrorCount = 0 then
//                 exit;

//             for i := 1 to ErrorCount do
//                 //errorMsg += ErrorList[ErrorCount] + '\';
//                 errorMsg += ErrorList[i] + '\';

//             Error(errorMsg);

//         END ELSE
//             IF ErrorCount <> 0 THEN
//                 AutoNFeXMLImport.SetStatus(1); // 0-Checked,1-Rejected,2-Already

//     end;

//     local procedure GetDecimal(text: Text) dec: Decimal
//     var
//         dummyDec: Text;
//         thousandSep: Text;
//         decimalSep: Text;
//         newText: Text;
//     begin
//         dummyDec := Format(1234.56, 0, '<Standard Format,0><Precision,2:2>');
//         decimalSep := CopyStr(dummyDec, 6, 1);
//         if decimalSep <> '.' then begin
//             thousandSep := CopyStr(dummyDec, 2, 1);
//             newText := ConvertStr(text, thousandSep + decimalSep, decimalSep + thousandSep);
//         end else
//             newText := text;

//         if not Evaluate(dec, newText) then begin
//             AddError(StrSubstNo(DecimalConvertError, text));
//             exit(0);
//         end;
//         exit(dec);
//     end;

//     procedure GetRecords(var _tmpNFeXML: Record "CADBR NFe XML" temporary; var _tmpNFeXMLLine: Record "CADBR NFe XML Line" temporary; var _tmpNFeXMLLineTax: Record "CADBR NFe XML Line Tax" temporary)
//     begin

//         _tmpNFeXML.RESET;
//         IF _tmpNFeXML.FINDFIRST THEN
//             _tmpNFeXML.DELETEALL;
//         _tmpNFeXMLLine.RESET;
//         IF _tmpNFeXMLLine.FINDFIRST THEN
//             _tmpNFeXMLLine.DELETEALL;
//         _tmpNFeXMLLineTax.RESET;
//         IF _tmpNFeXMLLineTax.FINDFIRST THEN
//             _tmpNFeXMLLineTax.DELETEALL;

//         if TmpNFeXML.FindSet then
//             repeat
//                 _tmpNFeXML.TransferFields(TmpNFeXML);
//                 _tmpNFeXML.Insert;
//             until TmpNFeXML.Next = 0;
//         if TmpNFeXMLLine.FindSet then
//             repeat
//                 _tmpNFeXMLLine.TransferFields(TmpNFeXMLLine);
//                 _tmpNFeXMLLine.Insert;
//             until TmpNFeXMLLine.Next = 0;
//         if TmpNFeXMLLineTax.FindSet then
//             repeat
//                 _tmpNFeXMLLineTax.TransferFields(TmpNFeXMLLineTax);
//                 _tmpNFeXMLLineTax.Insert;
//             until TmpNFeXMLLineTax.Next = 0;
//     end;

//     procedure ValidateFile()
//     var
//         NFeXMLImportSetup: Record "CADBR NFe XML Import Setup";
//         StatusXML: Enum "CADBR Status XML File";
//         EmptyPath: label 'Please ! Check XML Import Setting, file paths not found. %1 ';
//     begin
//         NFeXMLImportSetup.get;

//         IF (NFeXMLImportSetup."Received Files" = '') OR
//            (NFeXMLImportSetup."Rejected Files" = '') OR
//            (NFeXMLImportSetup."Imported Files" = '') OR
//            (NFeXMLImportSetup."Already Imported" = '') THEN BEGIN
//             StatusXML := StatusXML::Error;
//             AddError(StrSubstNo(EmptyPath, NFeXMLImportSetup));
//         END;
//     end;

//     var
//         XMLBuffer: Record "XML Buffer" temporary;
//         XMLBufferAux: Record "XML Buffer" temporary;
//         XMLBufferTax: Record "XML Buffer" temporary;

// }
