codeunit 50016 "Integration Vendor"
{
    procedure CreateVendor()
    var
        IntegrationVendor: Record "Integration Vendor";
        DialogCreVendorLbl: label 'Create Vendor   #1#############', Comment = '#1 IntegrationVendor';
    begin
        IntegrationVendor.Reset();
        IntegrationVendor.SetFilter(Status, '%1|%2', IntegrationVendor.Status::Imported,
                                                     IntegrationVendor.Status::"Data Error");
        //IntegrationVendor.SetFilter("Error Order", '%1', 0);
        if IntegrationVendor.Find('-') then begin
            if GuiAllowed then
                WindDialog.Open(DialogCreVendorLbl);
            repeat
                if GuiAllowed then
                    WindDialog.Update(1, IntegrationVendor."No.");

                IntegrationVendor."Posting Message" := '';
                IntegrationVendor.Modify();

                if not ValidateVendor(integrationvendor) then
                    CreateVendor(IntegrationVendor);

            until IntegrationVendor.Next() = 0;

            if GuiAllowed then
                WindDialog.Close();

        end;

    end;

    procedure ValidateVendor(IntegrationVendor: Record "Integration Vendor"): Boolean;
    var
        Vendor: Record Vendor;
        PostCode: Record "Post Code";
        PaymentTerms: Record "Payment Terms";
        PaymentMetho: Record "Payment Method";
        Post01Err: label ' - Post Code %1 - %2 Not Found', Comment = '%1 - Post Code , %2 - City';
        Post02Err: label ' - Country %1 Not Found', Comment = '%1 - Country';
        Post03Err: label ' - Territory Code %1 Not Found', Comment = '%1 - Territory Code';
        Post04Err: label ' - City %1 Not Found', Comment = '%1 - City';
        Paym01Err: label ' - Payment Terms %1 Not Found', Comment = '%1 - Payment Terms';
        Paym02Err: label ' - Payment Method %1 Not Found', Comment = '%1 - Payment Method';
        CNPJ01Err: label ' - CNPJ/CPF %1 Not Found', Comment = '%1 - CNPJ/CPF';

    begin

        if IntegrationVendor."Post Code" <> '' then
            if not PostCode.get(IntegrationVendor."Post Code", IntegrationVendor.City) then begin
                IntegrationVendor."Posting Message" := StrSubstNo(Post01Err, IntegrationVendor."Post Code", IntegrationVendor.City);
                IntegrationVendor.Modify();
            end else begin
                if PostCode."Country/Region Code" <> IntegrationVendor.Country then begin
                    IntegrationVendor."Posting Message" := StrSubstNo(Post02Err, IntegrationVendor.Country);
                    IntegrationVendor.Modify();
                end;
                if PostCode."CADBR Territory Code" <> IntegrationVendor."Territory Code" then begin
                    IntegrationVendor."Posting Message" += StrSubstNo(Post03Err, IntegrationVendor."Territory Code");
                    IntegrationVendor.Modify();
                end;
                //if PostCode.City <> IntegrationVendor.City then begin
                //    IntegrationVendor."Posting Message" += StrSubstNo(Post04Err, IntegrationVendor.City);
                //    IntegrationVendor.Modify();
                //end;
            end;

        if IntegrationVendor."C.N.P.J./C.P.F." = '' then begin
            IntegrationVendor."Posting Message" += StrSubstNo(CNPJ01err, IntegrationVendor."C.N.P.J./C.P.F.");
            IntegrationVendor.Modify();
        end;

        if not PaymentTerms.get(IntegrationVendor."Payment Terms Code") then begin
            IntegrationVendor."Posting Message" += StrSubstNo(Paym01Err, IntegrationVendor."Payment Terms Code");
            IntegrationVendor.Modify();
        end;

        if not PaymentMetho.get(IntegrationVendor."Payment Method Code") then begin
            IntegrationVendor."Posting Message" += StrSubstNo(Paym02Err, IntegrationVendor."Payment Method Code");
            IntegrationVendor.Modify();
        end;

        if IntegrationVendor."Posting Message" <> '' then begin
            IntegrationVendor.Status := IntegrationVendor.Status::"Data Error";
            IntegrationVendor.Modify();

            exit(true);

        end;

    end;

    procedure CreateVendor(IntegrationVendor: Record "Integration Vendor")
    var
        Vendor: Record Vendor;

    begin

        Vendor.Reset();

        if not Vendor.Get(IntegrationVendor."No.") then begin

            Vendor.Init();
            Vendor."No." := IntegrationVendor."No.";
            Vendor.Name := IntegrationVendor.Name;
            Vendor."Search Name" := IntegrationVendor."Search Name";
            Vendor.Validate("Country/Region Code", IntegrationVendor.Country);
            if IntegrationVendor."Post Code" <> '' then
                Vendor.Validate(Vendor."Post Code", IntegrationVendor."Post Code");
            Vendor.Validate("Territory Code", IntegrationVendor."Territory Code");
            Vendor.Validate(City, IntegrationVendor.City);
            Vendor.Address := IntegrationVendor.Address;
            Vendor."Address 2" := IntegrationVendor."Address 2";
            Vendor."Phone No." := IntegrationVendor."Phone No.";
            Vendor."Mobile Phone No." := IntegrationVendor."Phone No. 2";
            Vendor."CADBR Number" := IntegrationVendor.Number;
            Vendor."E-Mail" := IntegrationVendor."E-Mail";
            if StrLen(IntegrationVendor."C.N.P.J./C.P.F.") = 14 then
                Vendor."CADBR Category" := Vendor."CADBR Category"::"2.- Company"
            else
                Vendor."CADBR Category" := Vendor."CADBR Category"::"1.- Person";

            // Vendor.Validate("CADBR C.N.P.J./C.P.F.", IntegrationVendor."C.N.P.J./C.P.F.");
            vendor."CADBR C.N.P.J./C.P.F." := IntegrationVendor."C.N.P.J./C.P.F.";

            Vendor.Insert();

            Vendor."Tax Liable" := True;
            Vendor."Post Code" := IntegrationVendor."Post Code";
            Vendor."Payment Terms Code" := IntegrationVendor."Payment Terms Code";
            Vendor."Payment Method Code" := IntegrationVendor."Payment Method Code";
            Vendor.Blocked := Vendor.Blocked::All;

            Vendor.Modify();

            IntegrationVendor.Status := IntegrationVendor.Status::Created;
            IntegrationVendor.Modify();

        end else begin
            Vendor.get(IntegrationVendor."No.");
            Vendor.Name := IntegrationVendor.Name;
            Vendor."Search Name" := IntegrationVendor."Search Name";
            Vendor.Validate("Country/Region Code", IntegrationVendor.Country);
            if IntegrationVendor."Post Code" <> '' then
                Vendor.Validate(Vendor."Post Code", IntegrationVendor."Post Code");
            Vendor.Validate("Territory Code", IntegrationVendor."Territory Code");
            Vendor.Validate(City, IntegrationVendor.City);
            Vendor.Address := IntegrationVendor.Address;
            Vendor."Address 2" := IntegrationVendor."Address 2";
            Vendor."Phone No." := IntegrationVendor."Phone No.";
            Vendor."Mobile Phone No." := IntegrationVendor."Phone No. 2";
            Vendor."CADBR Number" := IntegrationVendor.Number;
            Vendor."E-Mail" := IntegrationVendor."E-Mail";
            if StrLen(IntegrationVendor."C.N.P.J./C.P.F.") = 14 then
                Vendor."CADBR Category" := Vendor."CADBR Category"::"2.- Company"
            else
                Vendor."CADBR Category" := Vendor."CADBR Category"::"1.- Person";

            if Vendor."CADBR C.N.P.J./C.P.F." <> IntegrationVendor."C.N.P.J./C.P.F." then
                //   Vendor.Validate("CADBR C.N.P.J./C.P.F.", IntegrationVendor."C.N.P.J./C.P.F.");
                Vendor."CADBR C.N.P.J./C.P.F." := IntegrationVendor."C.N.P.J./C.P.F.";

            Vendor."Tax Liable" := True;
            Vendor."Post Code" := IntegrationVendor."Post Code";
            Vendor."Payment Terms Code" := IntegrationVendor."Payment Terms Code";
            Vendor."Payment Method Code" := IntegrationVendor."Payment Method Code";
            Vendor.Blocked := Vendor.Blocked::All;

            Vendor.Modify();

            IntegrationVendor.Status := IntegrationVendor.Status::Created;
            IntegrationVendor.Modify();
        end;

    end;

    var
        WindDialog: Dialog;

}