tableextension 50007 "SBA EFD Participant" extends "CADBR EFD Participant"
{
    procedure SBA_Add(taxSettlementNo: Code[20]; companyID: Text[30]; participCode: Code[20]; CNPJCPF: Code[20]; isCustomer: Boolean; Income: Boolean)
    var
        cust: Record Customer;
        vendor: Record Vendor;
        countryRegion: Record "Country/Region";
        cep: Record "Post Code";
    begin
        if Get(taxSettlementNo, companyID, participCode) then begin
            if Income then begin
                "No Income" := false;
                Modify;
            end;
            exit;
        end;

        if isCustomer then
            AddCustomer(taxSettlementNo, companyID, participCode, CNPJCPF)
        else
            AddVendor(taxSettlementNo, companyID, participCode, CNPJCPF);
    end;

    local procedure AddVendor(taxSettlementNo: Code[20]; companyID: Text[30]; participCode: Code[20]; CNPJCPF: Code[20])
    var
        vend: Record Vendor;
        countryRegion: Record "Country/Region";
        cep: Record "Post Code";
    begin
        Init;
        "Tax Settlement No." := taxSettlementNo;
        "Company ID" := companyID;
        Code := participCode;

        vend.Reset();
        vend.SetRange("CADBR C.N.P.J./C.P.F.", CNPJCPF);
        vend.FindFirst();

        Name := vend.Name;

        vend.TestField("Country/Region Code");
        countryRegion.Get(vend."Country/Region Code");
        countryRegion.TestField("CADBR BACEN Code");
        "Country Code" := countryRegion."CADBR BACEN Code";

        Address := vend.Address;
        Number := DelChr(vend."CADBR Number", '<>', ' ');
        "Address 2" := vend."Address 2";
        District := vend."CADBR District";

        vend.TestField("CADBR Category");
        if vend."CADBR Category" <> vend."CADBR Category"::"3.- Foreign" then begin
            if vend."CADBR Category" = vend."CADBR Category"::"1.- Person" then
                CPF := DelChr(vend."CADBR C.N.P.J./C.P.F.", '=', './-');
            if vend."CADBR Category" = vend."CADBR Category"::"2.- Company" then
                CNPJ := DelChr(vend."CADBR C.N.P.J./C.P.F.", '=', './-');

            IE := vend."CADBR I.E.";
            if UpperCase(IE) in ['ISENTO', 'ISENTA'] then
                IE := '';

            cep.reset;
            cep.Setrange(Code, vend."Post Code");
            if cep.FindFirst() then
                "IBGE City Code" := cep."CADBR IBGE City Code";

        end else
            if vend."CADBR Category" = vend."CADBR Category"::"3.- Foreign" then begin
                "IBGE City Code" := '9999999';
            end;

        Insert;
    end;

    local procedure AddCustomer(taxSettlementNo: Code[20]; companyID: Text[30]; participCode: Code[20]; CNPJCPF: Code[20])
    var
        cust: Record Customer;
        countryRegion: Record "Country/Region";
        cep: Record "Post Code";
    begin
        Init;
        "Tax Settlement No." := taxSettlementNo;
        "Company ID" := companyID;
        Code := participCode;

        cust.Reset();
        cust.SetRange("CADBR C.N.P.J./C.P.F.", CNPJCPF);
        cust.FindFirst();

        Name := cust.Name;

        cust.TestField("Country/Region Code");
        countryRegion.Get(cust."Country/Region Code");
        countryRegion.TestField("CADBR BACEN Code");
        "Country Code" := countryRegion."CADBR BACEN Code";

        Address := cust.Address;
        Number := DelChr(cust."CADBR Number", '<>', ' ');
        "Address 2" := cust."Address 2";
        District := cust."CADBR District";

        cust.TestField("CADBR Category");
        if cust."CADBR Category" <> cust."CADBR Category"::"3.- Foreign" then begin
            if cust."CADBR Category" = cust."CADBR Category"::"1.- Person" then
                CPF := DelChr(cust."CADBR C.N.P.J./C.P.F.", '=', './-');
            if cust."CADBR Category" = cust."CADBR Category"::"2.- Company" then
                CNPJ := DelChr(cust."CADBR C.N.P.J./C.P.F.", '=', './-');

            IE := cust."CADBR I.E.";
            if UpperCase(IE) in ['ISENTO', 'ISENTA'] then
                IE := '';

            cep.reset;
            cep.Setrange(Code, cust."Post Code");
            if cep.FindFirst() then
                "IBGE City Code" := cep."CADBR IBGE City Code";

        end else
            if cust."CADBR Category" = cust."CADBR Category"::"3.- Foreign" then begin
                "IBGE City Code" := '9999999';
            end;

        Insert;
    end;

}
