codeunit 50018 CreateRegisterContribF100
{
    procedure InsertF100(Doc: Record "CADBR Settlement Document"; DocLine: Record "CADBR Settlement Document Line")
    var
        RegF100: Record "CADBR EFD F100 New";
        FiscalDocumentType: Record "CADBR Fiscal Document Type";
        PostedSales: Record "Sales Invoice Header";
        PostedPurchase: Record "Purch. Inv. Header";
        LineNo: Integer;

    begin
        if not RegF100.Get(Doc."Tax Settlement No.", UserId, Doc."Branch Code", DocLine."Line No.") then begin
            RegF100.Init;
            RegF100."Tax Settlement No." := Doc."Tax Settlement No.";
            RegF100."Branch Code" := Doc."Branch Code";
            regf100."User ID" := UserId;
            LineNo += DocLine."Line No.";
            RegF100."Line No." += LineNo;
            if ((DocLine."PIS CST Code") in ['50', '51', '52', '53', '54', '55', '56', '60', '61', '62', '63', '64', '65', '66']) or
               ((DocLine."Cofins CST Code") in ['50', '51', '52', '53', '54', '55', '56', '60', '61', '62', '63', '64', '65', '66']) then
                RegF100."Operation Type Indicator" := RegF100."Operation Type Indicator"::"0-Operação Representativa de Aquisição Custos Despesas ou Encargos Sujeita a Incidencia de Credito";
            if ((DocLine."PIS CST Code") in ['01', '02', '03', '05']) or
               ((DocLine."Cofins CST Code") in ['01', '02', '03', '05']) then
                RegF100."Operation Type Indicator" := RegF100."Operation Type Indicator"::"1-Operação Representativa de Receita Auferida Sujeita ao Pagamento da Contribuição";
            if ((DocLine."PIS CST Code") in ['04', '06', '07', '08', '09', '49', '99']) or
               ((DocLine."Cofins CST Code") in ['04', '06', '07', '08', '09', '49', '99']) then
                RegF100."Operation Type Indicator" := RegF100."Operation Type Indicator"::"2-Operação Representativa de Receita Auferida Não Sujeito ao Pagamento da Contribuição";
            regf100."Partner Code" := Doc."C.N.P.J.";
            regf100."partner type" := Doc."Customer/Vendor";
            if DocLine.type = DocLine.type::Item then
                RegF100."Item Type" := RegF100."Item type"::item;
            if DocLine.type = DocLine.type::"Fixed Asset" then
                RegF100."Item Type" := RegF100."Item type"::"Ativo Fixo";
            regf100."item code" := DocLine."No.";
            regf100."operation date" := Doc."Posting Date";
            regf100."operation amount" := DocLine."Line Amount";
            RegF100."COFINS %" := DocLine."COFINS %";
            RegF100."COFINS amount" := docline."COFINS amount";
            RegF100."COFINS base amount" := DocLine."COFINS base";
            RegF100."COFINS cst code" := DocLine."cofins CST Code";
            RegF100."COFINS CST Income Nature" := DocLine."COFINS CST Income Nature";
            regf100."PIS %" := DocLine."PIS %";
            RegF100."PIS amount" := DocLine."PIS amount";
            RegF100."PIS base amount" := DocLine."PIS base";
            RegF100."PIS cst code" := DocLine."PIS CST Code";
            RegF100."PIS CST Income Nature" := Docline."PIS CST Income Nature";
            regf100."Credit Base Code" := DocLine."Base Calculation Credit Code";
            regf100."G/L Account" := DocLine."G/L Account";
            RegF100."Credit Source Indicator" := RegF100."Credit Source Indicator"::"0-Operação Mercado Interno";
            regf100."Cost Center Code" := DocLine."Cost Center";
            if doc."Document Type" = doc."Document Type"::"Purch. Invoice" then
                if PostedPurchase.get(doc."Document No.") then
                    RegF100."Operation Description" := PostedPurchase."CADBR Operation Nature";
            if doc."Document Type" = doc."Document Type"::"Sales Invoice" then
                if PostedSales.get(doc."Document No.") then
                    RegF100."Operation Description" := PostedSales."CADBR Operation Nature";
            RegF100.Insert;
        end
        else begin

            RegF100.Modify;
        end;
    end;
}
