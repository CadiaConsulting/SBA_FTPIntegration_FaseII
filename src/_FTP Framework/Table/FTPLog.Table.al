table 50101 "FTP Log"
{
    Access = Public;
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; BigInteger)
        {
            DataClassification = CustomerContent;
            Caption = 'Entry No.';
            AutoIncrement = true;
        }

        field(2; RequestUrl; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'RequestUrl';
        }
        field(3; RequestMethod; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'RequestMethod';
        }
        field(4; RequestBody; Blob)
        {
            DataClassification = CustomerContent;
            Caption = 'RequestBody';
        }
        field(5; RequestBodySize; BigInteger)
        {
            DataClassification = CustomerContent;
            Caption = 'RequestBodySize';
        }
        field(6; ContentType; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Content Type';
        }
        field(7; RequestHeaders; Text[1000])
        {
            DataClassification = CustomerContent;
            Caption = 'Headers';
        }
        field(8; ResponseHttpStatusCode; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'ResponseHttpStatusCode';
        }
        field(9; Response; Blob)
        {
            DataClassification = CustomerContent;
            Caption = 'Response';
        }
        field(10; ResponseSize; BigInteger)
        {
            DataClassification = CustomerContent;
            Caption = 'ResponseSize';
        }
        field(11; DateTimeCreated; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Date Time Created';
        }
        field(12; Duraction; Duration)
        {
            DataClassification = CustomerContent;
            Caption = 'Duration';
        }
        field(20; User; Text[50])
        {
            Caption = 'User';
            DataClassification = EndUserIdentifiableInformation;
        }

    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }


    procedure ShowRequestMessage()
    begin
        DoShowRequestMessage(Rec);
    end;

    local procedure DoShowRequestMessage(var Log: Record "FTP Log");
    var
        Instr: Instream;
        RequestMessage: Text;
    begin

        log.CalcFields(RequestBody);
        log.RequestBody.CreateInStream(Instr);
        Instr.ReadText(RequestMessage);

        Message(RequestMessage);
    end;

    procedure ShowResponseMessage()
    begin
        DoShowResponseMessage(Rec);
    end;

    local procedure DoShowResponseMessage(var Log: Record "FTP Log");
    var
        Instr: Instream;
        RequestMessage: Text;
    begin

        log.CalcFields(Response);
        log.Response.CreateInStream(Instr);
        Instr.ReadText(RequestMessage);

        Message(RequestMessage);
    end;


}