codeunit 50070 "IntPurchPayment"
{
    trigger OnRun()
    begin

        //Check data and create journal
        CallCheckData();
        Commit();
        //Post Journal
        CallPostJournal
    end;


    procedure CheckData(var IntPurchPayment: Record IntPurchPayment)
    var
        RecordTocheck: Record IntPurchPayment;
        GenJournalLine: Record "Gen. Journal Line";
        FTPIntSetup: Record "FTP Integration Setup";
        IntegrationEmail: Codeunit "Integration Email";
    begin
        RecordTocheck.CopyFilters(IntPurchPayment);
        RecordTocheck.SetFilter(Status, '%1|%2', IntPurchPayment.Status::Imported, IntPurchPayment.Status::"Data Error");
        if not RecordTocheck.IsEmpty then begin
            RecordTocheck.FindSet();
            repeat
                if ValidateIntPurchPaymentData(RecordTocheck) then
                    CreatePaymentJournal(RecordTocheck)
                else begin
                    FTPIntSetup.Get(FTPIntSetup.Integration::"Purchase Payment");
                    if FTPIntSetup."Send Email" then
                        IntegrationEmail.SendMail(FTPIntSetup."E-mail Rejected Data", True, RecordTocheck."Posting Message", RecordTocheck."Excel File Name");
                end;
            until RecordTocheck.Next() = 0;
        end;
    end;

    local procedure ValidateIntPurchPaymentData(var RecordToCheck: Record IntPurchPayment): Boolean
    begin
        RecordToCheck."Posting Message" := '';
        RecordToCheck.Modify();

        CheckJournalTemplate(RecordTocheck);
        CheckJournalBatch(RecordToCheck);
        CheckVendor(RecordToCheck);
        CheckBankAccount(RecordToCheck);
        ValidateDimensions(RecordToCheck);
        PrepareTempVendLedgEntry(RecordToCheck);

        if not RecordToCheck."Permitir Dif. Aplicação" then
            if RecordToCheck."Amount Entry" < (RecordToCheck."Order CSRF Ret" + RecordToCheck."Order DIRF Ret" + RecordToCheck.Amount) then
                RecordToCheck."Posting Message" += 'Error Amount Entry';

        if RecordToCheck."Posting Message" <> '' then begin
            RecordToCheck.Status := RecordToCheck.Status::"Data Error";
            RecordToCheck.Modify();
            exit(false);
        end
        else
            exit(true);
    end;

    local procedure PrepareTempVendLedgEntry(var RecordTocheck: Record IntPurchPayment)
    var
        OldVendLedgEntry: Record "Vendor Ledger Entry";
        PurchSetup: Record "Purchases & Payables Setup";
        IntPurcPay: Record IntPurchPayment;
        GenJnlApply: Codeunit "Gen. Jnl.-Apply";
        RemainingAmount: Decimal;
        DecimalValueTot: Decimal;
    begin

        if RecordTocheck."Applies-to Doc. No." <> '' then begin
            // Find the entry to be applied to
            OldVendLedgEntry.Reset();
            OldVendLedgEntry.SetLoadFields(Positive, "Posting Date", "Currency Code");
            OldVendLedgEntry.SetCurrentKey("Document No.");
            OldVendLedgEntry.SetRange("Document No.", RecordTocheck."Applies-to Doc. No.");
            OldVendLedgEntry.SetRange("Document Type", RecordTocheck."Applies-to Doc. Type");
            OldVendLedgEntry.SetRange("Vendor No.", RecordTocheck."Account No.");
            OldVendLedgEntry.SetRange(Open, true);
            if not OldVendLedgEntry.FindFirst() then
                RecordToCheck."Posting Message" := StrSubstNo('Não existe Movimento Aberto para o Fornecedor %1 Documento %2', RecordTocheck."Account No.", RecordTocheck."Applies-to Doc. No.");

        end;

        if not RecordTocheck."Permitir Dif. Aplicação" then begin

            IntPurcPay.Reset();
            IntPurcPay.SetCurrentKey("Excel File Name", "Journal Template Name", "Journal Batch Name", Status);
            IntPurcPay.setrange("Excel File Name", RecordTocheck."Excel File Name");
            IntPurcPay.SetRange("Applies-to Doc. No.", RecordTocheck."Applies-to Doc. No.");
            IntPurcPay.SetFilter("Line No.", '<%1', RecordTocheck."Line No.");
            if IntPurcPay.FindFirst() then begin
                repeat
                    DecimalValueTot += IntPurcPay.Amount + IntPurcPay."Order CSRF Ret" + IntPurcPay."Order IRRF Ret";
                until IntPurcPay.Next() = 0;

                DecimalValueTot += RecordTocheck.Amount + RecordTocheck."Order CSRF Ret" + RecordTocheck."Order IRRF Ret";

                if RecordTocheck."Amount Entry" < DecimalValueTot then begin

                    RecordTocheck."Different Amount" := true;
                    RecordTocheck.Status := RecordTocheck.Status::"Data Error";
                    RecordTocheck."Posting Message" += 'Existe mais de 1 linha com o mesmo documento Aplicado que ultrapassa o Valor pendente';

                end;

            end;

        end;


    end;

    local procedure CheckJournalTemplate(var RecordTocheck: Record IntPurchPayment)
    var
        GenJournaltemplate: Record "Gen. Journal Template";
        JournalTempError: Label 'The Journal Template %1 does not exist.';
    begin
        if not GenJournaltemplate.Get(RecordTocheck."Journal Template Name") then begin
            RecordToCheck."Posting Message" := MergePostingMessage(RecordToCheck."Posting Message", StrSubstNo(JournalTempError, RecordTocheck."Journal Template Name"));
        end;
    end;

    local procedure CheckJournalBatch(var RecordToCheck: Record IntPurchPayment)
    var
        GenJournalBatch: Record "Gen. Journal Batch";
        JournalBatchError: Label 'The Journal Batch %1 does not exist.';
    begin
        if not GenJournalBatch.Get(RecordToCheck."Journal Template Name", RecordTocheck."Journal Batch Name") then begin
            RecordToCheck."Posting Message" := MergePostingMessage(RecordToCheck."Posting Message", StrSubstNo(JournalBatchError, RecordTocheck."Journal Batch Name"));
        end;
    end;

    local procedure CheckVendor(var RecordToCheck: Record IntPurchPayment)
    var
        Vendor: Record Vendor;
        VendorError: Label 'the Vendor %1, does not exist.';
    begin
        if not Vendor.Get(RecordToCheck."Account No.") then begin
            RecordToCheck."Posting Message" := MergePostingMessage(RecordToCheck."Posting Message", StrSubstNo(VendorError, RecordToCheck."Account No."));
        end;
    end;

    local procedure CheckBankAccount(var RecordToCheck: Record IntPurchPayment)
    var
        BankAccount: Record "Bank Account";
        BankAccountError: Label 'the Bank Account %1 does not exist.';
    begin
        if not BankAccount.Get(RecordToCheck."Bal. Account No.") then begin
            RecordToCheck."Posting Message" := MergePostingMessage(RecordToCheck."Posting Message", StrSubstNo(BankAccountError, RecordToCheck."Bal. Account No."));
        end;
    end;

    local procedure ValidateDimensions(var RecordToCheck: Record IntPurchPayment)
    begin
        if RecordToCheck."Dimension 1" <> '' then begin
            ValidateDim(1, RecordToCheck."Dimension 1");
        end;
        if RecordToCheck."Dimension 2" <> '' then begin
            ValidateDim(2, RecordToCheck."Dimension 2");
        end;
        if RecordToCheck."Dimension 3" <> '' then begin
            ValidateDim(3, RecordToCheck."Dimension 3");
        end;
        if RecordToCheck."Dimension 4" <> '' then begin
            ValidateDim(4, RecordToCheck."Dimension 4");
        end;
        if RecordToCheck."Dimension 5" <> '' then begin
            ValidateDim(5, RecordToCheck."Dimension 5");
        end;
        if RecordToCheck."Dimension 6" <> '' then begin
            ValidateDim(6, RecordToCheck."Dimension 6");
        end;
        if RecordToCheck."Dimension 7" <> '' then begin
            ValidateDim(7, RecordToCheck."Dimension 7");
        end;
        if RecordToCheck."Dimension 8" <> '' then begin
            ValidateDim(8, RecordToCheck."Dimension 8");
        end;
    end;

    procedure ValidateDim(DimSeq: Integer; ValueDim: Code[20])
    var
        DimensionValue: Record "Dimension Value";
        GeneralLedgerSetup: Record "General Ledger Setup";
        DimensionCode: Code[20];
        DimMngt: Codeunit DimensionManagement;
        GLSetupShortcutDimCode: array[8] of Code[20];
    begin
        DimMngt.GetGLSetup(GLSetupShortcutDimCode);
        CreateDim(DimSeq, GLSetupShortcutDimCode[DimSeq], ValueDim);
    end;

    procedure CreateDim(DimSeq: Integer; DimensionCode: Code[20]; ValueDim: Code[20])
    var
        DimensionValue: Record "Dimension Value";
    begin
        if not DimensionValue.Get(DimensionCode, ValueDim) then begin
            DimensionValue.Init();
            DimensionValue.Validate("Dimension Code", DimensionCode);
            DimensionValue.Validate(Code, ValueDim);
            DimensionValue.Name := ValueDim;
            DimensionValue."Dimension Value Type" := DimensionValue."Dimension Value Type"::Standard;
            if DimSeq in [1, 2] then
                DimensionValue."Global Dimension No." := DimSeq;
            DimensionValue.Insert(true);
        end;
    end;

    local procedure CreatePaymentJournal(var RecordToPost: Record IntPurchPayment)
    var
        GenJournalLine: Record "Gen. Journal Line";
        VendorLedEntry: Record "Vendor Ledger Entry";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        CADBRPayTaxMgt: Codeunit "CADBR Payment Tax Mgt";

    begin

        GenJournalLine.Reset();
        GenJournalLine.InitNewLine(RecordToPost."Posting Date", RecordToPost."Posting Date", RecordToPost."Posting Date",
                                     RecordToPost.Description, RecordToPost."dimension 1",
                                     RecordToPost."dimension 2", 0, '');

        GenJournalLine."Journal Template Name" := RecordToPost."Journal Template Name";
        GenJournalLine."Journal Batch Name" := RecordToPost."Journal Batch Name";
        GenJournalLine."Line No." := RecordToPost."Line No.";
        GenJournalLine."Account Type" := RecordToPost."Account Type";
        GenJournalLine."Account No." := RecordToPost."Account No.";

        //Valor
        GenJournalLine.VALIDATE(Amount, RecordToPost."Amount" + RecordToPost."Order CSRF Ret" +
                         RecordToPost."Order DIRF Ret");

        GenJournalLine."Applies-to Doc. No." := RecordToPost."Applies-to Doc. No.";
        GenJournalLine."Applies-to Doc. Type" := RecordToPost."Applies-to Doc. Type";
        GenJournalLine."Bal. Account No." := RecordToPost."Bal. Account No.";
        GenJournalLine."Bal. Account Type" := RecordToPost."Bal. Account Type";
        GenJournalLine."Document No." := RecordToPost."Document No.";
        GenJournalLine."Document Type" := RecordToPost."Document Type";

        if RecordToPost."Applies-to Doc. No." <> '' then begin
            VendorLedEntry.Reset();
            VendorLedEntry.SetCurrentKey("Document No.");
            VendorLedEntry.SetRange("Document No.", RecordToPost."Applies-to Doc. No.");
            if VendorLedEntry.FindFirst() then
                if VendorLedEntry."External Document No." <> '' then
                    GenJournalLine."External Document No." := VendorLedEntry."External Document No."
                else
                    GenJournalLine."External Document No." := VendorLedEntry."Document No.";

        end;

        if RecordToPost."Dimension 1" <> '' then
            GenJournalLine.Validate("Shortcut Dimension 1 Code", RecordToPost."Dimension 1");
        if RecordToPost."Dimension 2" <> '' then
            GenJournalLine.Validate("Shortcut Dimension 2 Code", RecordToPost."Dimension 2");
        if RecordToPost."Dimension 3" <> '' then
            GenJournalLine.ValidateShortcutDimCode(3, RecordToPost."Dimension 3");
        if RecordToPost."Dimension 4" <> '' then
            GenJournalLine.ValidateShortcutDimCode(4, RecordToPost."Dimension 4");
        if RecordToPost."Dimension 5" <> '' then
            GenJournalLine.ValidateShortcutDimCode(5, RecordToPost."Dimension 5");
        if RecordToPost."Dimension 6" <> '' then
            GenJournalLine.ValidateShortcutDimCode(6, RecordToPost."Dimension 6");
        if RecordToPost."Dimension 7" <> '' then
            GenJournalLine.ValidateShortcutDimCode(7, RecordToPost."Dimension 7");
        if RecordToPost."Dimension 8" <> '' then
            GenJournalLine.ValidateShortcutDimCode(7, RecordToPost."Dimension 8");

        RecordToPost.Status := RecordToPost.Status::Created;
        RecordToPost.Modify();

        GenJournalLine.Insert();

        //CADBRPayTaxMgt.CalculatePaymentJnl(RecordToPost."Journal Template Name", RecordToPost."Journal Batch Name");

        //Insere Impostos
        InsertTaxJournal(RecordToPost, GenJournalLine);

        //GenJnlPostLine.RunWithCheck(GenJournalLine);
        //RecordToPost.Status := RecordToPost.Status::Posted;
        //RecordToPost.Modify();

    end;

    procedure InsertTaxJournal(IntPurchPayment: Record IntPurchPayment; GenJournalLine: Record "Gen. Journal Line")
    var
        GenJourTax: Record "CADBR Gen. Journal Tax";
        VatEntry: Record "VAT Entry";
        CTPostingAccounts: Record "CADBR Tax Posting Accounts";


    begin

        if IntPurchPayment."Order CSRF Ret" <> 0 then begin

            VatEntry.Reset();
            VatEntry.Setrange("Document No.", IntPurchPayment."Applies-to Doc. No.");
            VatEntry.SETRANGE("CADBR Tax Identification", VatEntry."CADBR Tax Identification"::PCC);
            if VatEntry.FindFirst() then;

            GenJourTax.Init();
            GenJourTax."VAT Entry No." := VatEntry."Entry No.";
            GenJourTax."Journal Template Name" := GenJournalLine."Journal Template Name";
            GenJourTax."Journal Batch Name" := GenJournalLine."Journal Batch Name";
            GenJourTax."Journal Line No." := GenJournalLine."Line No.";
            GenJourTax."Line No." := 1000;
            GenJourTax."Tax Identification" := GenJourTax."Tax Identification"::PCC;
            GenJourTax."Tax %" := IntPurchPayment."Tax % Order CSRF Ret";
            GenJourTax."Tax Amount" := IntPurchPayment."Order CSRF Ret";
            GenJourTax."Tax Base Amount" := IntPurchPayment."Order PO Total";
            GenJourTax."Payable Account Type" := GenJourTax."Payable Account Type"::Vendor;

            CTPostingAccounts.Reset();
            CTPostingAccounts.SetRange("Filter Type", CTPostingAccounts."Filter Type"::Jurisdiction);
            CTPostingAccounts.SetRange("Filter Code", VatEntry."Tax Jurisdiction Code");
            if CTPostingAccounts.FindFirst() then
                GenJourTax."Payable Account No." := CTPostingAccounts."Payable Account No.";

            GenJourTax.Insert();
        end;

        if IntPurchPayment."Order IRRF Ret" <> 0 then begin

            VatEntry.Reset();
            VatEntry.Setrange("Document No.", IntPurchPayment."Applies-to Doc. No.");
            VatEntry.SETRANGE("CADBR Tax Identification", VatEntry."CADBR Tax Identification"::IRRF);
            if VatEntry.FindFirst() then;

            GenJourTax.Init();
            GenJourTax."VAT Entry No." := VatEntry."Entry No.";
            GenJourTax."Journal Template Name" := GenJournalLine."Journal Template Name";
            GenJourTax."Journal Batch Name" := GenJournalLine."Journal Batch Name";
            GenJourTax."Journal Line No." := GenJournalLine."Line No.";
            GenJourTax."Line No." := 2000;
            GenJourTax."Tax Identification" := GenJourTax."Tax Identification"::IRRF;
            GenJourTax."Tax %" := IntPurchPayment."Tax % Order IRRF Ret";
            GenJourTax."Tax Amount" := IntPurchPayment."Order IRRF Ret";
            GenJourTax."Tax Base Amount" := IntPurchPayment."Order PO Total";

            GenJourTax."Payable Account Type" := GenJourTax."Payable Account Type"::Vendor;

            CTPostingAccounts.Reset();
            CTPostingAccounts.SetRange("Filter Type", CTPostingAccounts."Filter Type"::Jurisdiction);
            CTPostingAccounts.SetRange("Filter Code", VatEntry."Tax Jurisdiction Code");
            if CTPostingAccounts.FindFirst() then
                GenJourTax."Payable Account No." := CTPostingAccounts."Payable Account No.";

            GenJourTax.Insert();
        end;

        if (IntPurchPayment."Order DIRF Ret" <> 0) and (IntPurchPayment."Order IRRF Ret" = 0) then begin

            VatEntry.Reset();
            VatEntry.Setrange("Document No.", IntPurchPayment."Applies-to Doc. No.");
            VatEntry.SETRANGE("CADBR Tax Identification", VatEntry."CADBR Tax Identification"::IRRF);
            if VatEntry.FindFirst() then;

            GenJourTax.Init();
            GenJourTax."VAT Entry No." := VatEntry."Entry No.";
            GenJourTax."Journal Template Name" := GenJournalLine."Journal Template Name";
            GenJourTax."Journal Batch Name" := GenJournalLine."Journal Batch Name";
            GenJourTax."Journal Line No." := GenJournalLine."Line No.";
            GenJourTax."Line No." := 3000;
            GenJourTax."Tax Identification" := GenJourTax."Tax Identification"::IRRF;
            GenJourTax."Tax %" := IntPurchPayment."Tax % Order DIRF Ret";
            GenJourTax."Tax Amount" := IntPurchPayment."Order DIRF Ret";
            GenJourTax."Tax Base Amount" := IntPurchPayment."Order PO Total";

            GenJourTax."Payable Account Type" := GenJourTax."Payable Account Type"::Vendor;

            CTPostingAccounts.Reset();
            CTPostingAccounts.SetRange("Filter Type", CTPostingAccounts."Filter Type"::Jurisdiction);
            CTPostingAccounts.SetRange("Filter Code", VatEntry."Tax Jurisdiction Code");
            if CTPostingAccounts.FindFirst() then
                GenJourTax."Payable Account No." := CTPostingAccounts."Payable Account No.";

            GenJourTax.Insert();
        end;



    end;

    procedure PostPaymentJournal(IntPurchPayment: Record IntPurchPayment)
    var
        GenJournalLine: Record "Gen. Journal Line";
        PostIntPurchPayment: Record IntPurchPayment;
        GenJnlPostBatch: Codeunit "Gen. Jnl.-Post Batch";
    begin
        PostIntPurchPayment.SetCurrentKey("Excel File Name", "Journal Template Name", "Journal Batch Name", Status);
        PostIntPurchPayment.SetRange("Excel File Name", IntPurchPayment."Excel File Name");
        PostIntPurchPayment.SetRange("Journal Template Name", IntPurchPayment."Journal Template Name");
        PostIntPurchPayment.SetRange("Journal Batch Name", IntPurchPayment."Journal Batch Name");
        PostIntPurchPayment.SetRange(Status, PostIntPurchPayment.Status::Created);
        if not PostIntPurchPayment.IsEmpty then begin
            PostIntPurchPayment.FindSet();
            GenJournalLine.SetRange("Journal Template Name", PostIntPurchPayment."Journal Template Name");
            GenJournalLine.SetRange("Journal Batch Name", PostIntPurchPayment."Journal Batch Name");
            if GenJournalLine.FindFirst() then begin
                GenJnlPostBatch.SetPreviewMode(false);
                GenJnlPostBatch.Run(GenJournalLine);
                PostIntPurchPayment.ModifyAll(Status, PostIntPurchPayment.Status::Posted);
            end;
        end;
    end;

    local procedure MergePostingMessage(OldMessage: text; AddMessage: text): Text
    var
        RecordToCheck: Record IntPurchPayment;
    begin
        if OldMessage <> '' then
            exit(CopyStr(AddMessage + ' ' + OldMessage, 1, MaxStrLen(RecordToCheck."Posting Message")))
        else
            exit(CopyStr(AddMessage, 1, MaxStrLen(RecordToCheck."Posting Message")));
    end;

    local procedure CallCheckData()
    var
        IntPurchPayment: Record IntPurchPayment;
        FileToProcessTMP: Record IntPurchPayment temporary;
        LastFile: Text;
    begin
        IntPurchPayment.SetFilter(Status, '%1|%2', IntPurchPayment.Status::Imported, IntPurchPayment.Status::"Data Error");
        if not IntPurchPayment.IsEmpty then begin
            IntPurchPayment.FindSet();
            repeat
                if LastFile <> IntPurchPayment."Excel File Name" then begin
                    FileToProcessTMP."Excel File Name" := IntPurchPayment."Excel File Name";
                    FileToProcessTMP.Insert();
                    LastFile := FileToProcessTMP."Excel File Name";
                end;
            until IntPurchPayment.next = 0;
        end;

        if FileToProcessTMP.FindFirst() then
            repeat
                CheckData(FileToProcessTMP);
            until FileToProcessTMP.Next() = 0;
    end;

    local procedure CallPostJournal()
    var
        IntPurchPayment: Record IntPurchPayment;
        FileToProcessTMP: Record IntPurchPayment temporary;
        LastFile: Text;
    begin
        IntPurchPayment.SetRange(Status, IntPurchPayment.Status::Created);
        if not IntPurchPayment.IsEmpty then begin
            IntPurchPayment.FindSet();
            repeat
                if LastFile <> IntPurchPayment."Excel File Name" then begin
                    FileToProcessTMP."Excel File Name" := IntPurchPayment."Excel File Name";
                    FileToProcessTMP.Insert();
                    LastFile := FileToProcessTMP."Excel File Name";
                end;
            until IntPurchPayment.next = 0;
        end;

        if FileToProcessTMP.FindFirst() then
            repeat
                PostPaymentJournal(FileToProcessTMP);
            until FileToProcessTMP.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Batch", 'OnAfterCode', '', false, false)]
    local procedure Codeunit_13_OnCodeOnAfterCode(var GenJournalLine: Record "Gen. Journal Line")
    var
        IntPurchPayment: Record IntPurchPayment;
        GjLine: Record "Gen. Journal Line";
    begin
        GjLine.CopyFilters(GenJournalLine);
        if GjLine.FindSet() then
            repeat

                IntPurchPayment.Reset();
                IntPurchPayment.setrange("Journal Template Name", GjLine."Journal Template Name");
                IntPurchPayment.setrange("Journal Batch Name", GjLine."Journal Batch Name");
                IntPurchPayment.SetRange("Line No.", GjLine."Line No.");
                if IntPurchPayment.FindFirst() then begin

                    IntPurchPayment.Status := IntPurchPayment.Status::Posted;
                    IntPurchPayment.Modify();

                end;

            until GjLine.Next() = 0;

    end;

}
