tableextension 50013 INTPurchHeader extends "Purchase Header"
{
    fields
    {
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
        field(50099; "Posting Message"; text[200])
        {
            Caption = 'Posting Message';
        }
    }

}