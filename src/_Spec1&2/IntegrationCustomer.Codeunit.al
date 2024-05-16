codeunit 50015 "Integration Customer"
{
    procedure CreateCustomer()
    var
        IntegrationCustomer: Record "Integration Customer";
        DialogCreCustomerLbl: label 'Create Customer   #1#############', Comment = '#1 IntegrationCustomer';
    begin
        IntegrationCustomer.Reset();
        IntegrationCustomer.SetFilter(Status, '%1|%2', IntegrationCustomer.Status::Imported,
                                                     IntegrationCustomer.Status::"Data Error");
        //IntegrationCustomer.SetFilter("Error Order", '%1', 0);
        if IntegrationCustomer.Find('-') then begin
            if GuiAllowed then
                WindDialog.Open(DialogCreCustomerLbl);
            repeat
                if GuiAllowed then
                    WindDialog.Update(1, IntegrationCustomer."No.");

                IntegrationCustomer."Posting Message" := '';
                IntegrationCustomer.Modify();

                if not ValidateCustomer(IntegrationCustomer) then
                    CreateCustomer(IntegrationCustomer);

            until IntegrationCustomer.Next() = 0;

            if GuiAllowed then
                WindDialog.Close();

        end;

    end;

    procedure ValidateCustomer(IntegrationCustomer: Record "Integration Customer"): Boolean;
    var
        Customer: Record Customer;
        PostCode: Record "Post Code";
        Post01Err: label ' - Post Code %1 - %2 Not Found', Comment = '%1 - Post Code , %2 - City';
        Post02Err: label ' - Country %1 Not Found', Comment = '%1 - Country';
        Post03Err: label ' - Territory Code %1 Not Found', Comment = '%1 - Territory Code';
        Post04Err: label ' - City %1 Not Found', Comment = '%1 - City';
        CNPJ01Err: label ' - CNPJ/CPF %1 Not Found', Comment = '%1 - CNPJ/CPF';


    begin

        if IntegrationCustomer."Post Code" <> '' then
            if not PostCode.get(IntegrationCustomer."Post Code", IntegrationCustomer.City) then begin
                IntegrationCustomer."Posting Message" := StrSubstNo(Post01Err, IntegrationCustomer."Post Code", IntegrationCustomer.City);
                IntegrationCustomer.Modify();
            end else begin
                if PostCode."Country/Region Code" <> IntegrationCustomer.Country then begin
                    IntegrationCustomer."Posting Message" := StrSubstNo(Post02Err, IntegrationCustomer.Country);
                    IntegrationCustomer.Modify();
                end;
                if PostCode."CADBR Territory Code" <> IntegrationCustomer."Territory Code" then begin
                    IntegrationCustomer."Posting Message" += StrSubstNo(Post03Err, IntegrationCustomer."Territory Code");
                    IntegrationCustomer.Modify();
                end;
                //  if PostCode.City <> IntegrationCustomer.City then begin
                //      IntegrationCustomer."Posting Message" += StrSubstNo(Post04Err, IntegrationCustomer.City);
                //      IntegrationCustomer.Modify();
                //  end;
            end;
        if Integrationcustomer."C.N.P.J./C.P.F." = '' then begin
            IntegrationCustomer."Posting Message" += StrSubstNo(CNPJ01err, Integrationcustomer."C.N.P.J./C.P.F.");
            IntegrationCustomer.Modify();
        end;

        if IntegrationCustomer."Posting Message" <> '' then begin
            IntegrationCustomer.Status := IntegrationCustomer.Status::"Data Error";
            IntegrationCustomer.Modify();

            exit(true);

        end;

    end;

    procedure CreateCustomer(IntegrationCustomer: Record "Integration Customer")
    var
        Customer: Record Customer;

    begin

        Customer.Reset();

        if not Customer.Get(IntegrationCustomer."No.") then begin

            Customer.Init();
            Customer."No." := IntegrationCustomer."No.";
            Customer.Name := IntegrationCustomer.Name;
            Customer."Search Name" := IntegrationCustomer."Search Name";
            Customer.Validate("Country/Region Code", IntegrationCustomer.Country);
            if IntegrationCustomer."Post Code" <> '' then
                Customer.Validate(Customer."Post Code", IntegrationCustomer."Post Code");
            Customer.Validate("Territory Code", IntegrationCustomer."Territory Code");
            Customer.Validate(City, IntegrationCustomer.City);
            Customer.Address := IntegrationCustomer.Address;
            Customer."Address 2" := IntegrationCustomer."Address 2";
            Customer."Phone No." := IntegrationCustomer."Phone No.";
            Customer."Mobile Phone No." := IntegrationCustomer."Phone No. 2";
            Customer."CADBR Number" := IntegrationCustomer.Number;
            Customer."E-Mail" := IntegrationCustomer."E-Mail";
            if StrLen(IntegrationCustomer."C.N.P.J./C.P.F.") = 14 then
                Customer."CADBR Category" := Customer."CADBR Category"::"2.- Company"
            else
                Customer."CADBR Category" := Customer."CADBR Category"::"1.- Person";

            //Customer.Validate("CADBR C.N.P.J./C.P.F.", IntegrationCustomer."C.N.P.J./C.P.F.");
            Customer."CADBR C.N.P.J./C.P.F." := IntegrationCustomer."C.N.P.J./C.P.F.";

            Customer.Insert();

            Customer."Tax Liable" := True;
            Customer."Post Code" := IntegrationCustomer."Post Code";
            Customer.Blocked := Customer.Blocked::All;

            Customer.Modify();

            IntegrationCustomer.Status := IntegrationCustomer.Status::Created;
            IntegrationCustomer.Modify();

        end else begin
            Customer.get(IntegrationCustomer."No.");
            Customer.Name := IntegrationCustomer.Name;
            Customer."Search Name" := IntegrationCustomer."Search Name";
            Customer.Validate("Country/Region Code", IntegrationCustomer.Country);
            if integrationcustomer."Post Code" <> '' then
                Customer.Validate(Customer."Post Code", IntegrationCustomer."Post Code");
            Customer.Validate("Territory Code", IntegrationCustomer."Territory Code");
            Customer.Validate(City, IntegrationCustomer.City);
            Customer.Address := IntegrationCustomer.Address;
            Customer."Address 2" := IntegrationCustomer."Address 2";
            Customer."Phone No." := IntegrationCustomer."Phone No.";
            Customer."Mobile Phone No." := IntegrationCustomer."Phone No. 2";
            Customer."CADBR Number" := IntegrationCustomer.Number;
            Customer."E-Mail" := IntegrationCustomer."E-Mail";
            if StrLen(IntegrationCustomer."C.N.P.J./C.P.F.") = 14 then
                Customer."CADBR Category" := Customer."CADBR Category"::"2.- Company"
            else
                Customer."CADBR Category" := Customer."CADBR Category"::"1.- Person";

            if Customer."CADBR C.N.P.J./C.P.F." <> IntegrationCustomer."C.N.P.J./C.P.F." then
                // Customer.Validate("CADBR C.N.P.J./C.P.F.", IntegrationCustomer."C.N.P.J./C.P.F.");
                Customer."CADBR C.N.P.J./C.P.F." := IntegrationCustomer."C.N.P.J./C.P.F.";

            Customer."Tax Liable" := True;
            Customer."Post Code" := IntegrationCustomer."Post Code";
            Customer.Blocked := Customer.Blocked::All;

            Customer.Modify();

            IntegrationCustomer.Status := IntegrationCustomer.Status::Created;
            IntegrationCustomer.Modify();
        end;

    end;

    var
        WindDialog: Dialog;

}