codeunit 50007 "Integration Email"
{

    procedure SendMail(ToEmail: Text; ErrorData: Boolean; ErrorMessage: Text; filename: Text)
    var
        Mail: Codeunit "Email";
        EmailMessage: Codeunit "Email Message";
        EmailAccount: Record "Email Account" temporary;
        EmailAccountMgt: Codeunit "Email Account";
        Payload: Text;
        Subject: Text;

    begin

        CLEAR(Mail);
        CLEAR(EmailMessage);

        EmailAccountMgt.GetAllAccounts(EmailAccount);
        EmailAccount.RESET;
        EmailAccount.SetRange(Name, 'FTP');
        if not EmailAccount.findfirst then begin
            Message('Conta de email "FTP" não configurada');
            EmailAccount.findfirst;
        end;

        if ErrorData then begin
            Subject := 'Erro Integração: Arquivo rejeitado por falha de dados. ' + filename;
            Payload := ErrorMessage;
        end else begin
            Subject := 'Erro Integração: Estrutura do arquivo rejeitada. ' + filename;
            Payload := Subject;
        end;

        EmailMessage.Create(ToEmail, Subject, Payload, True);
        Mail.Send(EmailMessage, EmailAccount);

    end;

}
