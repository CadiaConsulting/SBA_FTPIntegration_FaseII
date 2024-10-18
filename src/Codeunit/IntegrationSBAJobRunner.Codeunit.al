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
        IntPurchPay: Record IntPurchPayment;
        IntSalesCreditNote: codeunit IntSalesCreditNote;
        IntPurchPayment: codeunit IntPurchPayment;
        IntPurchPaymentApply: codeunit IntPurchPaymentApply;
        IntPurchPaymentUnapply: Codeunit IntPurchPaymentUnapply;
        IntPurchPaymentsFromBC: Codeunit IntPurchPaymentsFromBC;
        IntPurchVoidPay: Record IntPurchVoidPayment;
        IntPurchVoidPayment: Codeunit IntPurchVoidPayment;

    begin
        Rec.TestField("Parameter String");

        FTPSetup.Reset();
        //FTPSetup.SetCurrentKey("Integration Relation", Sequence);
        FTPSetup.SetRange("Integration Relation", Rec."Parameter String");
        if FTPSetup.FindSet() then
            repeat

                if FTPSetup.Integration = FTPSetup.Integration::Sales then begin
                    if FTPSetup."Import Excel" then
                        ImportExcelBuffer.ImportExcelSales();

                    if FTPSetup."Create Order" then
                        IntegrationSales.CreateSales(IntegSales);

                    if FTPSetup."Post Order\Journal" then
                        IntegrationSales.PostSales(IntegSales);

                end;

                if FTPSetup.Integration = FTPSetup.Integration::"Sales Credit Note" then begin
                    if FTPSetup."Import Excel" then
                        ImportExcelBuffer.ImportExcelSalesReturn();

                    if FTPSetup."Create Order" then
                        IntSalesCreditNote.CreateSalesCredit(IntSalesCred);

                    if FTPSetup."Post Order\Journal" then
                        IntSalesCreditNote.PostSalesCredit(IntSalesCred);
                end;

                if FTPSetup.Integration = FTPSetup.Integration::Purchase then begin

                    if FTPSetup."Import Excel" then begin
                        ImportExcelBuffer.ImportExcelPurchase();
                        Commit();
                    end;

                    if FTPSetup."Create Order" then begin
                        IntegrationPurchase.CreatePurchase(IntPurch);
                        Commit();
                    end;

                end;

                if FTPSetup.Integration = FTPSetup.Integration::"Purchase Tax Validation" then begin

                    if FTPSetup."Export Excel" then begin
                        ImportExcelBuffer.ExportExcelPurchaseTax();
                        Commit();
                    end;

                end;

                if FTPSetup.Integration = FTPSetup.Integration::"Purchase Posting" then begin

                    if FTPSetup."Import Purch Post" then begin
                        ImportExcelBuffer.ImportExcelPurchasePost();
                        Commit();
                    end;

                    if FTPSetup."Post Order\Journal" then begin
                        IntegrationPurchase.PostPurchase(IntPurch);
                        Commit();
                    end;

                end;


                if FTPSetup.Integration = FTPSetup.Integration::"Purchase Credit Note" then begin
                    //if FTPSetup."Post Order" then
                    //ImportExcelBuffer.ImportExcelPurchase();

                    // if FTPSetup."Post Order\Journal" then
                    //     IntegrationPurchaseReturn.PostPurchaseReturn(IntPurhRet);

                end;

                if FTPSetup.Integration = FTPSetup.Integration::"Purchase Payment" then begin
                    if FTPSetup."Import Excel" then begin
                        ImportExcelBuffer.ImportExcelPaymentPurchaseJournal(FTPIntegrationType::"Purchase Payment");
                        Commit();
                    end;

                    if FTPSetup."Copy to Journal" then begin
                        IntPurchPayment.CheckData(IntPurchPay);
                        Commit();
                    end;

                    if FTPSetup."Post Order\Journal" then begin
                        if IntPurchPayment.PostPaymentJournal(IntPurchPay) then;
                        Commit();
                        if IntPurchPayment.DeletePaymentJournal(IntPurchPay) then;
                    end;

                end;


                if FTPSetup.Integration = FTPSetup.Integration::"Payments From BC" then begin

                    if FTPSetup."Suggest Vendor Payments" then
                        IntPurchPaymentsFromBC.SuggestVendorPayments();

                    if FTPSetup."Export Excel" then
                        IntPurchPaymentsFromBC.ExportExcelIntPurchPaymentsFromBC();

                end;

                if FTPSetup.Integration = FTPSetup.Integration::"Purchase Void Payment" then begin

                    if FTPSetup."Import Excel" then begin
                        ImportExcelBuffer.ImportExcelPaymentVoidPurchaseJournal(FTPIntegrationType::"Purchase Void Payment");
                        Commit();

                        if IntPurchVoidPayment.UnapplyPaymentVoidJournal(IntPurchVoidPay) then;
                        Commit();
                    end;

                    if FTPSetup."Copy to Journal" then begin
                        if IntPurchVoidPayment.CheckData(IntPurchVoidPay) then;
                        Commit();
                    end;

                    if FTPSetup."Post Order\Journal" then begin
                        if IntPurchVoidPayment.PostPaymentJournal(IntPurchVoidPay) then;
                        Commit();
                    end;
                end;


            until FTPSetup.Next() = 0;

    end;

}