tableextension 50018 INTPurchInvLine extends "Purch. Inv. Line"

{
    fields
    {
        field(50000; "Descricao Area de Imposto"; Text[100])
        {
            Caption = 'Descricao Area de Imposto';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup("Tax Area".Description where(Code = field("Tax Area Code")));

        }
        field(50001; "Município Prestação Serviço"; code[7])
        {
            Caption = 'Município Prestação Serviço';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup("Purch. Inv. Header"."CADBR Service Delivery City" where("No." = field("Document No.")));
        }
        field(50002; "Município Fornecedor"; Text[30])
        {
            Caption = 'Município Fornecedor';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup("Purch. Inv. Header"."Buy-from City" where("No." = field("Document No.")));
        }
        field(50003; "Fiscal Doc. No."; Code[35])
        {
            Caption = 'Número Doc. Fiscal';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup("Purch. Inv. Header"."Vendor Invoice No." where("No." = field("Document No.")));
        }
        field(50004; "Cidade Prestação Serviço"; Text[60])
        {
            Caption = 'Cidade Prestação Serviço';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup("CADBR Municipio".City where(Code = field("Município Prestação Serviço")));
        }
        field(50005; "Document Date"; Date)
        {
            Caption = 'Data de emissão';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup("Purch. Inv. Header"."Document Date" where("No." = field("Document No.")));
        }
        field(50006; "Vendor Name"; Text[100])
        {
            Caption = 'Nome Fornecedor';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup("Purch. Inv. Header"."Buy-from Vendor Name" where("No." = field("Document No.")));
        }
        field(50020; "New Service Code"; code[20])
        {
            Caption = 'Novo Service Code';
            TableRelation = "CADBR NFS Service Code";
        }
        field(50021; "New Municipio"; code[7])
        {
            Caption = 'Novo Município Prestação Serviço';
            TableRelation = "CADBR Municipio";
        }
    }
}