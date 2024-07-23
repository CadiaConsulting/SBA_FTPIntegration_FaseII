pageextension 50020 "INTRBusinessMngrRoleCenter" extends "Business Manager Role Center"
{

    actions
    {
        addfirst(sections)
        {
            group(Integration)
            {
                Caption = 'SBA Integration';

                group(SalesInt)
                {
                    Caption = 'Sales Integration';

                    action(CustomerInt)
                    {
                        Caption = 'Integration Customer Master Data';
                        ApplicationArea = all;
                        RunObject = page "Integration Customer";
                    }
                    group(SalesDocsInt)
                    {
                        Caption = 'Sales Documents';
                        action(SalesOrderInt)
                        {
                            Caption = 'Integration Sales Order';
                            ApplicationArea = all;
                            RunObject = page IntegrationSales;
                        }
                        action(SalesCredMemoInt)
                        {
                            Caption = 'Integration Sales Credit Memo';
                            ApplicationArea = all;
                            RunObject = page IntSalesCreditNote;
                        }
                    }
                    group(CashReceiptInt)
                    {
                        Caption = 'Cash Receipt';
                        action(ReceiptJournalInt)
                        {
                            Caption = 'Integration Receipt Journal';
                            ApplicationArea = all;
                            RunObject = page "Integration Receipt Journal";
                        }
                        action(RcptJnlApplyInt)
                        {
                            Caption = 'Integration Receipt Journal Apply';
                            ApplicationArea = all;
                            RunObject = page "Integration Rcpt Jnl Apply";
                        }
                        action(RcptJnlUnApplyInt)
                        {
                            Caption = 'Integration Receipt Journal UnApply';
                            ApplicationArea = all;
                            RunObject = page "Integration Rcpt Jnl UnApply";
                        }
                    }
                }
                group(PurchaseInt)
                {
                    Caption = 'Purchasing Integration';

                    action(VendorInt)
                    {
                        Caption = 'Integration Vendor Master Data';
                        ApplicationArea = all;
                        RunObject = page "Integration Vendor";
                    }
                    group(PurchaseDocsInt)
                    {
                        Caption = 'Purchase Documents';

                        action(PurchaseReturnInt)
                        {
                            Caption = 'Integration Purchase Return';
                            ApplicationArea = all;
                            RunObject = page "Integration Purchase Return";
                        }
                        action(PurchaseOrderInt)
                        {
                            Caption = 'Integration Purchase Order';
                            ApplicationArea = all;
                            RunObject = page "Integration Purchase";
                        }
                        action(PurchaseOrderIntPosted)
                        {
                            Caption = 'Integration Purchase Order Posted/Cancelled';
                            ApplicationArea = all;
                            RunObject = page "Integration Purchase Posted";
                        }
                    }
                    group(PaymentsInt)
                    {
                        Caption = 'Purchase Payments';


                        action(PaymentsFromBCInt)
                        {
                            Caption = 'Integration Payments from BC';
                            ApplicationArea = all;
                            RunObject = page IntPurchPaymentsFromBC;
                        }

                        group(PaymentsJournalInt)
                        {
                            Caption = 'Payment Journal Integration';
                            action(PaymentJournalInt)
                            {
                                Caption = 'Integration Purchase Payment';
                                ApplicationArea = all;
                                RunObject = page IntPurchPayment;
                            }
                            action(PaymentApplyJournalInt)
                            {
                                Caption = 'Integration Purchase Payment Apply';
                                ApplicationArea = all;
                                RunObject = page IntPurchPaymentApply;
                            }
                            action(PaymentUnApplyJournalInt)
                            {
                                Caption = 'Integration Purchase Payment Unapply';
                                ApplicationArea = all;
                                RunObject = page IntPurchPaymentUnApply;
                            }
                        }
                    }
                    group(PurchaseLandlord)
                    {
                        Caption = 'Purchase Landlord';

                        action(Landlord)
                        {
                            Caption = 'Integration Purchase Landlord';
                            ApplicationArea = all;
                            RunObject = page "Integration Landlord";
                        }
                        action(LandlordPosted)
                        {
                            Caption = 'Integration Purchase Landlord Posted';
                            ApplicationArea = all;
                            RunObject = page "Integration Landlord Posted";
                        }
                    }
                }

                group(JournalEntriesInt)
                {
                    Caption = 'Journal Entries';

                    action(JournalInt)
                    {
                        Caption = 'Integration Accounting Entries';
                        ApplicationArea = all;
                        RunObject = page IntAccountingEntries;
                    }
                    action(JournalPostedInt)
                    {
                        Caption = 'Integration Accounting Entries Posted';
                        ApplicationArea = all;
                        RunObject = page IntAccountingEntriesPosted;
                    }
                }
                group(Config)
                {
                    Caption = 'Configurations';
                    action(FtpLogList)
                    {
                        Caption = 'FTP Log List';
                        ApplicationArea = all, administration;
                        RunObject = page "FTP Log List";
                    }
                    action(FtpSetup)
                    {
                        Caption = 'FTP Setup';
                        ApplicationArea = all, administration;
                        RunObject = page "FTP Integration Setup";
                    }
                    action(IntegrationErrors)
                    {
                        Caption = 'Integration Errors';
                        ApplicationArea = all;
                        RunObject = page IntegrationErros;
                    }
                    action(FromTo)
                    {
                        Caption = 'From/To US GAAP';
                        ApplicationArea = all, administration;
                        RunObject = page "From/To US GAAP";
                    }
                }
            }
        }
    }
}
