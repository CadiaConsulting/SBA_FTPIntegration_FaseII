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

    procedure IntPurchPaymentUpdateAmountEntry(): Boolean
    var
        VLE: Record "Vendor Ledger Entry";
        IPP: Record IntPurchPayment;
    begin

        IPP.Reset();
        IPP.SetFilter(Status, '<>%1', IPP.Status::Posted);
        if IPP.FindSet() then
            repeat
                VLE.Reset();
                VLE.SetRange("Document No.", IPP."Applies-to Doc. No.");
                if VLE.FindFirst() then begin
                    VLE.calcfields("Remaining Amount");
                    ipp."Amount Entry" := ABS(VLE."Remaining Amount");
                    ipp.Modify();

                end;

            until IPP.Next() = 0;
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

                    FTPIntSetup.Reset();
                    FTPIntSetup.SetRange(Integration, FTPIntSetup.Integration::"Purchase Payment");
                    FTPIntSetup.SetRange(Sequence, 0);
                    FTPIntSetup.FindSet();
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
        CheckTax(RecordToCheck);

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
        GJL: Record "Gen. Journal Line";
        VendorLedEntry: Record "Vendor Ledger Entry";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        CADBRPayTaxMgt: Codeunit "CADBR Payment Tax Mgt";
        LineNo: Integer;
    begin
        GJL.Reset();
        GJL.SetRange("Journal Template Name", RecordToPost."Journal Template Name");
        GJL.SetRange("Journal Batch Name", RecordToPost."Journal Batch Name");
        if GJL.FindLast() then
            LineNo := GJL."Line No." + 10000
        else
            LineNo := 10000;

        RecordToPost."Journal Line No." := LineNo;
        RecordToPost.Modify();

        GenJournalLine.Reset();
        GenJournalLine.InitNewLine(RecordToPost."Posting Date", RecordToPost."Posting Date", RecordToPost."Posting Date",
                                     RecordToPost.Description, RecordToPost."dimension 1",
                                     RecordToPost."dimension 2", 0, '');

        GenJournalLine."Journal Template Name" := RecordToPost."Journal Template Name";
        GenJournalLine."Journal Batch Name" := RecordToPost."Journal Batch Name";
        GenJournalLine."Line No." := RecordToPost."Journal Line No.";
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

        //Insere Impostos
        InsertTaxJournal(RecordToPost, GenJournalLine);

    end;

    procedure DeletePaymentJournal(var RecordToPost: Record IntPurchPayment): Boolean
    var
        GJL: Record "Gen. Journal Line";
        IntPurchPayment: Record IntPurchPayment;
    begin
        RecordToPost.CopyFilters(IntPurchPayment);
        if not RecordToPost.IsEmpty then
            if RecordToPost.FindSet() then begin

                GJL.Reset();
                GJL.SetRange("Journal Template Name", RecordToPost."Journal Template Name");
                GJL.SetRange("Journal Batch Name", RecordToPost."Journal Batch Name");
                if GJL.FindSet() then
                    repeat
                        IntPurchPayment.Reset();
                        IntPurchPayment.SetRange("Journal Line No.", GJL."Line No.");
                        IntPurchPayment.SetRange("Document No.", GJL."Document No.");
                        IntPurchPayment.SetRange(Status, IntPurchPayment.Status::Posted);
                        if IntPurchPayment.FindSet() then
                            GJL.Delete();

                    Until GJL.Next() = 0;


            end;

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

    procedure PostPaymentJournal(var IntPurchPayment: Record IntPurchPayment): Boolean;
    var
        GenJournalLine: Record "Gen. Journal Line";
        PostIntPurchPayment: Record IntPurchPayment;
        GenJnlPostBatch: Codeunit "Gen. Jnl.-Post Batch";
    begin

        PostIntPurchPayment.Reset();
        PostIntPurchPayment.SetCurrentKey("Excel File Name", "Journal Template Name", "Journal Batch Name", Status);
        PostIntPurchPayment.CopyFilters(IntPurchPayment);
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
            //aqui
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

    local procedure CheckTax(var RecordToCheck: Record IntPurchPayment): Boolean
    var
        intPurc: Record "Integration Purchase";
        IntPurcPay: Record IntPurchPayment;
        VatEntry: Record "VAT Entry";
        TotDirectUnit: Decimal;
    begin

        TotDirectUnit := 0;
        intPurc.reset();
        intPurc.SetRange("Document No.", RecordToCheck."Document No.");
        if intPurc.FindSet() then begin
            repeat
                TotDirectUnit += intPurc."Direct Unit Cost Excl. Vat" * intPurc.Quantity;
            until intPurc.Next() = 0;

        end;
        intPurc.reset();
        intPurc.SetRange("Document No.", RecordToCheck."Document No.");
        if intPurc.FindFirst() then begin
            if intPurc.Status = intPurc.Status::Posted then begin

                RecordToCheck."Order IRRF Ret" := intPurc."Order IRRF Ret";
                if intPurc."Order IRRF Ret" <> 0 then begin

                    VatEntry.Reset();
                    VatEntry.Setrange("Document No.", intPurc."Document No.");
                    VatEntry.SETRANGE("CADBR Tax Identification", VatEntry."CADBR Tax Identification"::IRRF);
                    if VatEntry.FindFirst() then
                        if VatEntry.Base <> 0 then
                            RecordToCheck."Order IRRF Ret" := 0;
                end;

                RecordToCheck."Order CSRF Ret" := intPurc."Order CSRF Ret";

                if intPurc."Order CSRF Ret" <> 0 then begin

                    VatEntry.Reset();
                    VatEntry.Setrange("Document No.", intPurc."Document No.");
                    VatEntry.SETRANGE("CADBR Tax Identification", VatEntry."CADBR Tax Identification"::PCC);
                    if VatEntry.FindFirst() then
                        if VatEntry.Base <> 0 then
                            RecordToCheck."Order CSRF Ret" := 0;

                    IntPurcPay.Reset();
                    IntPurcPay.SetCurrentKey("Excel File Name", "Journal Template Name", "Journal Batch Name", Status);
                    IntPurcPay.SetRange("Applies-to Doc. No.", RecordToCheck."Applies-to Doc. No.");
                    if IntPurcPay.FindFirst() then begin
                        RecordToCheck."Order CSRF Ret" := 0;
                    end;

                end;

                RecordToCheck."Order INSS Ret" := intPurc."Order INSS Ret";
                if intPurc."Order inss Ret" <> 0 then begin

                    VatEntry.Reset();
                    VatEntry.Setrange("Document No.", intPurc."Document No.");
                    VatEntry.SETRANGE("CADBR Tax Identification", VatEntry."CADBR Tax Identification"::"INSS Ret.");
                    if VatEntry.FindFirst() then
                        if VatEntry.Base <> 0 then
                            RecordToCheck."Order INSS Ret" := 0;

                end;

                RecordToCheck."Order ISS Ret" := intPurc."Order ISS Ret";
                if intPurc."Order iss Ret" <> 0 then begin

                    VatEntry.Reset();
                    VatEntry.Setrange("Document No.", intPurc."Document No.");
                    VatEntry.SETRANGE("CADBR Tax Identification", VatEntry."CADBR Tax Identification"::"ISS Ret.");
                    if VatEntry.FindFirst() then
                        if VatEntry.Base <> 0 then
                            RecordToCheck."Order ISS Ret" := 0;

                end;

                RecordToCheck."Order DIRF Ret" := intPurc."Order DIRF Ret";
                if intPurc."Order DIRF Ret" <> 0 then begin

                    VatEntry.Reset();
                    VatEntry.Setrange("Document No.", intPurc."Document No.");
                    VatEntry.SETRANGE("CADBR Tax Identification", VatEntry."CADBR Tax Identification"::IRRF);
                    if VatEntry.FindFirst() then
                        if VatEntry.Base <> 0 then
                            RecordToCheck."Order DIRF Ret" := 0;

                    IntPurcPay.Reset();
                    IntPurcPay.SetCurrentKey("Excel File Name", "Journal Template Name", "Journal Batch Name", Status);

                    IntPurcPay.SetRange("Applies-to Doc. No.", RecordToCheck."Applies-to Doc. No.");
                    if IntPurcPay.FindFirst() then begin
                        RecordToCheck."Order DIRF Ret" := 0;
                    end;

                end;

                RecordToCheck."Order PO Total" := TotDirectUnit;

                RecordToCheck."Tax % Order IRRF Ret" := intPurc."Tax % Order IRRF Ret";

                RecordToCheck."Tax % Order CSRF Ret" := intPurc."Tax % Order CSRF Ret";

                RecordToCheck."Tax % Order INSS Ret" := intPurc."Tax % Order INSS Ret";

                RecordToCheck."Tax % Order ISS Ret" := intPurc."Tax % Order ISS Ret";

                RecordToCheck."Tax % Order DIRF Ret" := intPurc."Tax % Order DIRF Ret";

            end else if intPurc.Status = intPurc.Status::Cancelled then begin

                RecordToCheck.Status := RecordToCheck.Status::"Data Error";
                RecordToCheck."Posting Message" := 'A Ordem de compra consta como Cancelada. Favor verificar.';

            end else begin

                RecordToCheck.Status := RecordToCheck.Status::"Data Error";
                RecordToCheck."Posting Message" := 'A Ordem de compra ainda não foi registrada.';

            end;
        end;

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Batch", 'OnAfterPostGenJournalLine', '', false, false)]
    local procedure Codeunit_13_OnAfterPostGenJournalLine(var GenJournalLine: Record "Gen. Journal Line"; var Result: Boolean)
    var
        IntPurchPayment: Record IntPurchPayment;
    begin
        if Result then begin

            IntPurchPayment.Reset();
            IntPurchPayment.setrange("Journal Template Name", GenJournalLine."Journal Template Name");
            IntPurchPayment.setrange("Journal Batch Name", GenJournalLine."Journal Batch Name");
            IntPurchPayment.SetRange("Line No.", GenJournalLine."Line No.");
            if IntPurchPayment.FindFirst() then begin

                IntPurchPayment.Status := IntPurchPayment.Status::Posted;
                IntPurchPayment.Modify();

            end;

        end;

    end;

}
