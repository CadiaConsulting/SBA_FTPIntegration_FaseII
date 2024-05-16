tableextension 50016 "SBA CADBR NF-e Setup" extends "CADBR NF-e Setup"
{
    fields
    {
        field(50000; "Versao do Layout NFST em Lote"; Text[3])
        {
            Caption = 'Versão do Layout NFST em Lote';
            DataClassification = ToBeClassified;

        }
        field(50001; "CADBR Service Delivery City"; code[20])
        {
            Caption = 'CADBR Service Delivery City';
            DataClassification = ToBeClassified;
            TableRelation = "CADBR Municipio";

        }


    }
}
