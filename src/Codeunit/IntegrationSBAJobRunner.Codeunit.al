codeunit 50009 "Integration SBA Job Runner"
{
    TableNo = "Job Queue Entry";
    Permissions = tabledata IntegrationSales = RIMD;

    trigger OnRun()
    var
        ImportExcelBuffer: codeunit "Import Excel Buffer";
        FTPIntegrationType: Enum "FTP Integration Type";
        FTPSetup: Record "FTP Integration Setup";
        IntPurch: Record "Integration Purchase";
        IntegrationPurchase: codeunit "Integration Purchase";
        IntPurhRet: Record "Integration Purchase Return";
        IntegrationPurchaseReturn: codeunit "Integration Purchase Return";
        IntegSales: Record IntegrationSales;
        IntegrationSales: codeunit IntegrationSales;
        IntSalesCred: Record IntSalesCreditNote;
        IntSalesCreditNote: codeunit IntSalesCreditNote;
        IntPurchPayment: codeunit IntPurchPayment;
        IntPurchPaymentApply: codeunit IntPurchPaymentApply;
        IntPurchPaymentUnapply: Codeunit IntPurchPaymentUnapply;

    begin
        Rec.TestField("Parameter String");

        FTPSetup.Reset();
        FTPSetup.SetCurrentKey("Integration Relation", Sequence);
        FTPSetup.SetRange("Integration Relation", Rec."Parameter String");
        if FTPSetup.FindSet() then
            repeat

                if FTPSetup.Integration = FTPSetup.Integration::Sales then begin
                    if FTPSetup."Import Excel" then
                        ImportExcelBuffer.ImportExcelSales();

                    if FTPSetup."Create Order" then
                        IntegrationSales.CreateSales(IntegSales);

                    if FTPSetup."Post Order" then
                        IntegrationSales.PostSales(IntegSales);

                end;

                if FTPSetup.Integration = FTPSetup.Integration::"Sales Credit Note" then begin
                    if FTPSetup."Import Excel" then
                        ImportExcelBuffer.ImportExcelSalesReturn();

                    if FTPSetup."Create Order" then
                        IntSalesCreditNote.CreateSalesCredit(IntSalesCred);

                    if FTPSetup."Post Order" then
                        IntSalesCreditNote.PostSalesCredit(IntSalesCred);
                end;

                if FTPSetup.Integration = FTPSetup.Integration::Purchase then begin

                    if FTPSetup."Import Excel" then
                        ImportExcelBuffer.ImportExcelPurchase();

                    if FTPSetup."Create Order" then
                        IntegrationPurchase.CreatePurchase(IntPurch);

                    if FTPSetup."Release Order" then
                        IntegrationPurchase.PurchRealse(IntPurch);

                    if FTPSetup."Post Order" then
                        IntegrationPurchase.PostPurchase(IntPurch);

                    if FTPSetup."Export Purch Tax" then
                        ImportExcelBuffer.ExportExcelPurchaseTax();

                    if FTPSetup."Import Purch Post" then
                        ImportExcelBuffer.ImportExcelPurchasePost();

                end;

                if FTPSetup.Integration = FTPSetup.Integration::"Purchase Credit Note" then begin
                    if FTPSetup."Post Order" then
                        ImportExcelBuffer.ImportExcelPurchase();

                    if FTPSetup."Post Order" then
                        IntegrationPurchaseReturn.PostPurchaseReturn(IntPurhRet);

                end;

                if FTPSetup.Integration = FTPSetup.Integration::"Purchase Payment" then begin
                    if FTPSetup."Post Order" then begin
                        ImportExcelBuffer.ImportExcelPaymentPurchaseJournal(FTPIntegrationType::"Purchase Apply");
                        Commit();
                        IntPurchPayment.Run();
                    end;
                end;

                if FTPSetup.Integration = FTPSetup.Integration::"Purchase Apply" then begin
                    if FTPSetup."Post Order" then begin
                        ImportExcelBuffer.ImportExcelPaymentPurchaseJournal(FTPIntegrationType::"Purchase Apply");
                        Commit();
                        IntPurchPaymentApply.Run();

                    end;

                end;

                if FTPSetup.Integration = FTPSetup.Integration::"Purchase Unapply" then begin
                    if FTPSetup."Post Order" then begin
                        ImportExcelBuffer.ImportExcelPaymentPurchaseJournal(FTPIntegrationType::"Purchase Unapply");
                        Commit();
                        IntPurchPaymentUnapply.Run();
                    end;
                end;

            until FTPSetup.Next() = 0;

    end;

}