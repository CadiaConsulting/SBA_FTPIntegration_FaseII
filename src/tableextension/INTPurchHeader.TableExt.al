tableextension 50013 INTPurchHeader extends "Purchase Header"
{
    fields
    {
        // Add changes to table fields here
        // field(50104; "Doc. URL"; Text[250])
        // {
        //     Caption = 'Doc. URL';
        //     ExtendedDatatype = URL;
        //     Editable = false;
        // }
        field(50000; "IRRF Ret"; Decimal)
        {
            Caption = 'IRRF Ret';
            Editable = false;
        }
        field(50001; "CSRF Ret"; Decimal)
        {
            Caption = 'CSRF Ret';
            Editable = false;
        }
        field(50002; "INSS Ret"; Decimal)
        {
            Caption = 'INSS Ret';
            Editable = false;
        }
        field(50003; "ISS Ret"; Decimal)
        {
            Caption = 'ISS Ret';
            Editable = false;
        }
        field(50004; "PIS Credit"; Decimal)
        {
            Caption = 'PIS Credit';
            Editable = false;
        }
        field(50005; "Cofins Credit"; Decimal)
        {
            Caption = 'Cofins Credit';
            Editable = false;
        }
        field(50006; "DIRF"; Decimal)
        {
            Caption = 'DIRF';
            Editable = false;
        }
        field(50007; "PO Total"; Decimal)
        {
            Caption = 'PO Total';
            Editable = false;
        }
    }

}