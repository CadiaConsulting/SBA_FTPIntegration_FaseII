table 50012 "IntegrationErros"
{
    Caption = 'Integration Erros';
    DataClassification = CustomerContent;
    LookupPageId = IntegrationErros;
    DrillDownPageId = IntegrationErros;

    fields
    {

        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
        }
        field(2; "Integration Type"; enum IntegrationErrosType)
        {
            Caption = 'Integration Type';
        }
        field(3; "Document No."; Code[20])
        {
            Caption = 'Document No.';
        }

        field(5; "Errors"; Text[250])
        {
            Caption = 'Errors';
        }
        field(6; "Field Error"; Text[50])
        {
            Caption = 'Field Error';
        }
        field(7; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
        }
        field(8; "Value Error"; Text[250])
        {
            Caption = 'Value Error';
        }

        field(4; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }

        field(9; "Excel File Name"; text[200])
        {
            Caption = 'Excel File Name';
            Editable = false;
        }
    }

    keys
    {
        key("Key1"; "Entry No.")
        {
            Clustered = true;
        }
    }

    var


    trigger OnInsert()
    begin

    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin

    end;

    procedure InsertErros(IntegrationType: enum IntegrationErrosType; DocumentNo: Code[20]; LineNo: Integer; tfield: Text[50]; tErros: Text[250]; tValueErros: Text; tfile: Text[200])
    var
        IntegrationErros: Record IntegrationErros;
        EntryNo: Integer;
    begin
        IntegrationErros.Reset();
        if IntegrationErros.FindLast() then
            EntryNo := IntegrationErros."Entry No." + 1
        else
            EntryNo := 1;

        IntegrationErros.Init();
        IntegrationErros."Entry No." := EntryNo;
        IntegrationErros."Integration Type" := IntegrationType;
        IntegrationErros."document No." := DocumentNo;
        IntegrationErros."Line No." := LineNo;
        IntegrationErros."Field Error" := tField;
        IntegrationErros.Errors := tErros;
        IntegrationErros."Value Error" := CopyStr(tValueErros, 1, 250);
        IntegrationErros."Posting Date" := Today;
        IntegrationErros."Excel File Name" := tfile;

        IntegrationErros.Insert();
    end;

}