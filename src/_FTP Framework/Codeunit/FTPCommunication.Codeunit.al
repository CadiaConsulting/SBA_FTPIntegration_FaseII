codeunit 50001 "FTP Communication"
{

    procedure DoAction(action: Enum "FTP Actions"; filename: Text; dir: Text; destination: Text; fileBase64: Text): Variant
    var
        FTPSetup: Record "FTP Integration Setup";
        RESTHelper: Codeunit "FTP REST Helper";
        WSurl: Text;
        response: Text;
        url: Text;
        user: Text;
        pass: Text;
        act: Text;
        EntryNo: BigInteger;
    begin

        FTPSetup.Get();
        FTPSetup.TestField("URL Azure");
        FTPSetup.TestField("URL Address FTP");
        FTPSetup.TestField("FTP User");
        FTPSetup.TestField("FTP Password");

        WSurl := FTPSetup."URL Azure";
        url := FTPSetup."URL Address FTP";
        user := FTPSetup."FTP User";
        pass := FTPSetup."FTP Password";

        act := action.Names.Get(action.Ordinals.IndexOf(action.AsInteger()));

        CLEAR(RESTHelper);
        if fileBase64 <> '' then begin
            RESTHelper.Initialize('POST', WSurl);
            RESTHelper.AddBody(fileBase64);
        end else
            RESTHelper.Initialize('GET', WSurl);

        RESTHelper.AddRequestHeader('action', act);
        RESTHelper.AddRequestHeader('url', url);
        RESTHelper.AddRequestHeader('file', filename);
        RESTHelper.AddRequestHeader('dir', dir);
        RESTHelper.AddRequestHeader('destination', destination);
        RESTHelper.AddRequestHeader('user', user);
        RESTHelper.AddRequestHeader('pass', pass);

        EntryNo := RESTHelper.Send();

        if RESTHelper.GetHttpStatusCode() <> 200 then
            error('FTP Error - %1 - %2 - %3' + RESTHelper.GetResponseReasonPhrase() + ':\' + RESTHelper.GetResponseContentAsText(), filename, dir, destination);

        if action = Enum::"FTP Actions"::download then begin
            exit(EntryNo);
        end;

        exit(RESTHelper.GetResponseContentAsText());

    end;


}
