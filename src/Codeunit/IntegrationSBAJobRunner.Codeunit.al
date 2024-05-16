codeunit 50009 "Integration SBA Job Runner"
{
    TableNo = "Job Queue Entry";
    Permissions = tabledata IntegrationSales = RIMD;

    trigger OnRun()
    var

    begin
        //Processing Sales ( Import, Create, Post)
        if rec."Parameter String" = '1' then
            IntSales();

        //Processing Return Sales ( Import, Create, Post)
        if rec."Parameter String" = '2' then
            IntReturnSales();

        //Processing Purchase ( Import, Create, Post)
        if rec."Parameter String" = '3' then
            IntPurchase();

        //Processing Purchase ( Import, Create, Post)
        if rec."Parameter String" = '4' then
            IntPurchasereturn();

        //Processing Purchase ( Import, Create, Post)
        if rec."Parameter String" = '5' then
            IntPurchPayment();

        //Processing Purchase ( Import, Create, Post)
        if rec."Parameter String" = '6' then
            IntPurchPaymentApply();

        //Processing Purchase ( Import, Create, Post)
        if rec."Parameter String" = '7' then
            IntPurchPaymentUnapply();

    end;

    local procedure IntSales()
    var
        IntegSales: Record IntegrationSales;
        IntegrationSales: codeunit IntegrationSales;
    begin
        ImportExcelBuffer.ImportExcelSales();
        IntegrationSales.CreateSales(IntegSales);
        IntegrationSales.PostSales(IntegSales);

    end;

    local procedure IntReturnSales()
    var
        IntSalesCred: Record IntSalesCreditNote;
        IntSalesCreditNote: codeunit IntSalesCreditNote;
    begin
        ImportExcelBuffer.ImportExcelSalesReturn();
        IntSalesCreditNote.CreateSalesCredit(IntSalesCred);
        IntSalesCreditNote.PostSalesCredit(IntSalesCred);

    end;

    local procedure IntPurchase()
    var
        IntPurch: Record "Integration Purchase";
        IntegrationPurchase: codeunit "Integration Purchase";
    begin
        ImportExcelBuffer.ImportExcelPurchase();
        IntegrationPurchase.CreatePurchase(IntPurch);
        IntegrationPurchase.PostPurchase(IntPurch);

    end;

    local procedure IntPurchasereturn()
    var
        IntPurhRet: Record "Integration Purchase Return";
        IntegrationPurchaseReturn: codeunit "Integration Purchase Return";

    begin
        ImportExcelBuffer.ImportExcelPurchase();
        IntegrationPurchaseReturn.PostPurchaseReturn(IntPurhRet);
        IntegrationPurchaseReturn.PostPurchaseReturn(IntPurhRet);

    end;

    local procedure IntPurchPayment()
    var
        IntPurchPayment: codeunit IntPurchPayment;
    begin
        //Import Excel
        ImportExcelBuffer.ImportExcelPaymentPurchaseJournal(FTPIntegrationType::"Purchase Apply");
        Commit();
        IntPurchPayment.Run();
    end;

    local procedure IntPurchPaymentApply()
    var
        IntPurchPaymentApply: codeunit IntPurchPaymentApply;
    begin
        ImportExcelBuffer.ImportExcelPaymentPurchaseJournal(FTPIntegrationType::"Purchase Apply");
        Commit();
        IntPurchPaymentApply.Run();
    end;

    procedure IntPurchPaymentUnapply()
    var
        IntPurchPaymentUnapply: Codeunit IntPurchPaymentUnapply;
    begin
        ImportExcelBuffer.ImportExcelPaymentPurchaseJournal(FTPIntegrationType::"Purchase Unapply");
        Commit();
        IntPurchPaymentUnapply.Run();
    end;

    var
        ImportExcelBuffer: codeunit "Import Excel Buffer";
        FTPIntegrationType: Enum "FTP Integration Type";

}