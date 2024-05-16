pageextension 50030 SBAVatEntries extends "VAT Entries"
{
    layout
    {
        addafter("CADBR Tax Jurisdiction Code")
        {
            field("CADBR CST Code"; rec."CADBR CST Code")
            {
                ApplicationArea = All;
            }
            field("Base Calculation Credit Code"; rec."Base Calculation Credit Code")
            {
                ApplicationArea = All;
            }
        }
        addafter("Bill-to/Pay-to No.")
        {
            field("Vendor CNPJ/CPF"; rec."Vendor CNPJ/CPF")
            {
                ApplicationArea = All;
            }
            field("Customer CNPJ/CPF"; Rec."Customer CNPJ/CPF")
            {
                ApplicationArea = All;
            }
            field("Purchase Document Value"; Rec."Purchase Document Value")
            {
                ApplicationArea = All;
            }
            field("Sale Document Value"; Rec."Sale Document Value")
            {
                ApplicationArea = All;
            }
            field("GL Account Related"; rec."GL Account Related")
            {
                ApplicationArea = All;
            }
        }
    }
}
