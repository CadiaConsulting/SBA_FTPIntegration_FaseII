codeunit 50100 "FTP REST Helper"
{
    Access = Public;

    var
        WebClient: HttpClient;
        WebRequest: HttpRequestMessage;
        WebResponse: HttpResponseMessage;
        WebRequestHeaders: HttpHeaders;
        WebContentHeaders: HttpHeaders;
        WebContent: HttpContent;
        CurrentContentType: Text;
        RestHeaders: TextBuilder;
        ContentTypeSet: Boolean;

    procedure Initialize(Method: Text; URI: Text);
    begin
        WebRequest.Method := Method;
        WebRequest.SetRequestUri(URI);

        WebRequest.GetHeaders(WebRequestHeaders);
    end;

    procedure AddCertificate(Cert64: Text; Pass: Text)
    begin
        WebClient.AddCertificate(Cert64, Pass);
    end;

    procedure AddRequestHeader(HeaderKey: Text; HeaderValue: Text)
    begin
        RestHeaders.AppendLine(HeaderKey + ': ' + HeaderValue);

        WebRequestHeaders.Add(HeaderKey, HeaderValue);
    end;

    procedure AddBody(Body: Text)
    begin
        WebContent.WriteFrom(Body);
        ContentTypeSet := true;
    end;

    procedure SetContentType(ContentType: Text)
    begin
        CurrentContentType := ContentType;

        webcontent.GetHeaders(WebContentHeaders);
        if WebContentHeaders.Contains('Content-Type') then
            WebContentHeaders.Remove('Content-Type');
        WebContentHeaders.Add('Content-Type', ContentType);
    end;

    procedure Send() EntryNo: BigInteger
    var
        StartDateTime: DateTime;
        TotalDuration: Duration;
        SendSuccess: Boolean;
    begin
        if ContentTypeSet then
            WebRequest.Content(WebContent);

        OnBeforeSend(WebRequest, WebResponse);
        StartDateTime := CurrentDateTime();
        SendSuccess := WebClient.Send(WebRequest, WebResponse);
        TotalDuration := CurrentDateTime() - StartDateTime;
        OnAfterSend(WebRequest, WebResponse);

        if SendSuccess then
            if not WebResponse.IsSuccessStatusCode() then
                SendSuccess := false;

        exit(Log(StartDateTime, TotalDuration));

    end;

    procedure GetResponseContentAsText() ResponseContentText: Text
    var
        RestBlob: record "FTP Blob";
        Instr: Instream;
    begin

        RESTBlob.Blob.CreateInStream(Instr);
        WebResponse.Content().ReadAs(ResponseContentText);
    end;

    procedure GetResponseReasonPhrase(): Text
    begin
        exit(WebResponse.ReasonPhrase());
    end;

    procedure GetHttpStatusCode(): Integer
    begin
        exit(WebResponse.HttpStatusCode());
    end;

    local procedure Log(StartDateTime: DateTime; TotalDuration: Duration): BigInteger
    var
        RESTLog: Record "FTP Log";
        FTPBlob: record "FTP Blob";
        Instr: InStream;
        ResponseInstr: InStream;
        Outstr: OutStream;
        RString: Text;
        TempExcelBuffer: Record "Excel Buffer" temporary;

    begin

        FTPBlob.BLOB.CreateInStream(Instr);
        WebContent.ReadAs(Instr);

        WebResponse.Content().ReadAs(RString);
        WebResponse.Content().ReadAs(ResponseInstr);

        //with RESTLog do begin
        RESTLog.Init();
        RESTLog.RequestUrl := copystr(WebRequest.GetRequestUri(), 1, MaxStrLen(RESTLog.RequestUrl));
        RESTLog.RequestMethod := copystr(WebRequest.Method(), 1, MaxStrLen(RESTLog.RequestMethod));

        RESTLog.RequestBody.CreateOutStream(Outstr);
        CopyStream(Outstr, Instr);
        RESTLog.RequestBodySize := RESTLog.RequestBody.Length();
        RESTLog.ContentType := copystr(CurrentContentType, 1, MaxStrLen(RESTLog.ContentType));
        RESTLog.RequestHeaders := copystr(RestHeaders.ToText(), 1, MaxStrLen(RESTLog.RequestHeaders));

        RESTLog.ResponseHttpStatusCode := GetHttpStatusCode();
        RESTLog.Response.CreateOutStream(Outstr);
        CopyStream(Outstr, ResponseInstr);
        RESTLog.ResponseSize := RESTLog.Response.Length();

        RESTLog.DateTimeCreated := StartDateTime;
        RESTLog.User := copystr(userid(), 1, MaxStrLen(RESTLog.User));
        RESTLog.Duraction := TotalDuration;
        RESTLog.Insert();

        exit(RESTLog."Entry No.");
        //end;
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeSend(WebRequest: HttpRequestMessage; WebResponse: HttpResponseMessage)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnAfterSend(WebRequest: HttpRequestMessage; WebResponse: HttpResponseMessage)
    begin
    end;

}