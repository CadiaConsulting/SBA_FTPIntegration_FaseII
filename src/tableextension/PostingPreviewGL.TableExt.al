tableextension 50001 PostingPreviewGL extends "G/L Entry"
{
    fields
    {
        field(50000; "No. 2"; Code[20])
        {
            Caption = 'No. 2';
            FieldClass = FlowField;
            CalcFormula = Lookup("G/L Account"."No. 2" WHERE("No." = FIELD("G/L Account No.")));
        }
        field(50001; "Applies-to Doc. Type"; Enum "Gen. Journal Document Type")
        {
            Caption = 'Applies-to Doc. Type';
        }
        field(50002; "Applies-to Doc. No."; Code[20])
        {
            Caption = 'Applies-to Doc. No.';
        }
    }
}
