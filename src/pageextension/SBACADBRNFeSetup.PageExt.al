pageextension 50022 "SBA CADBR NFe Setup" extends "CADBR NFe Setup"
{
    layout
    {
        addafter("NFS-e XML Path")
        {
            field("Versao do Layout NFST em Lote"; rec."Versao do Layout NFST em Lote")
            {
                ApplicationArea = All;
                ToolTip = 'Versao do Layout NFST em Lote';
            }
            field("CADBR Service Delivery City"; rec."CADBR Service Delivery City")
            {
                ApplicationArea = All;
                ToolTip = 'CADBR Service Delivery City';
            }

        }
    }
}
