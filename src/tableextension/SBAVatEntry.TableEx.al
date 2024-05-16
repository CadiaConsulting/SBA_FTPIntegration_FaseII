tableextension 50030 SBAVatEntry extends "VAT Entry"
{
    fields
    {
        field(50000; "Vendor CNPJ/CPF"; text[20])
        {
            Caption = 'Vendor CNPJ/CPF';
            CalcFormula = lookup(Vendor."CADBR C.N.P.J./C.P.F." where("No." = field("Bill-to/Pay-to No.")));
            FieldClass = FlowField;
            Editable = false;

        }
        field(50001; "Customer CNPJ/CPF"; text[20])
        {
            Caption = 'Customer CNPJ/CPF';
            CalcFormula = lookup(Customer."CADBR C.N.P.J./C.P.F." where("No." = field("Bill-to/Pay-to No.")));
            FieldClass = FlowField;
            Editable = false;
        }
        field(50002; "Sale Document Value"; Decimal)
        {
            Caption = 'Sale Document Value';
            CalcFormula = sum("Sales Invoice Line"."Amount Including VAT" where("Document No." = field("Document No."),
                                                                              "Sell-to Customer No." = field("Bill-to/Pay-to No."),
                                                                              "No." = field("CADBR No.")));
            FieldClass = FlowField;
            Editable = false;

        }
        field(50003; "Purchase Document Value"; Decimal)
        {
            Caption = 'Purchase Document Value';
            CalcFormula = sum("purch. inv. line"."Amount Including VAT" where("Document No." = field("Document No."),
                                                                              "Buy-from Vendor No." = field("Bill-to/Pay-to No."),
                                                                              "No." = field("CADBR No.")));
            FieldClass = FlowField;
            Editable = false;
        }
        field(50004; "GL Account Related"; Code[20])
        {
            Caption = 'GL Account Related';
        }
        field(50005; "Base Calculation Credit Code"; Code[20])
        {
            Caption = 'Base Calculation Credit Code';
            Editable = false;
        }
    }
}
