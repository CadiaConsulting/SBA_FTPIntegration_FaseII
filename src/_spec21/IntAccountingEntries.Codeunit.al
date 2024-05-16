codeunit 50075 "IntAccountingEntries"
{
    trigger OnRun()
    begin

        //Check data and create journal
        CallCheckData();
        Commit();
        //Post Journal
        CallPostJournal
    end;


    procedure CheckData(var IntAccountingEntries: Record IntAccountingEntries)
    var
        RecordTocheck: Record IntAccountingEntries;
    begin

        IntAccountingEntriesBuffer.Reset();
        IntAccountingEntriesBuffer.DeleteAll();

        SearchErrosByFile(IntAccountingEntries);

        //RecordTocheck.SetRange("Excel File Name", IntAccountingEntries."Excel File Name");
        RecordTocheck.SetFilter(Status, '%1|%2', IntAccountingEntries.Status::Imported, IntAccountingEntries.Status::"Data Error");
        if not RecordTocheck.IsEmpty then begin
            RecordTocheck.FindSet();
            repeat
                ValidateIntPurchPaymentData(RecordTocheck);
            until RecordTocheck.Next() = 0;
        end;

        CreateJournalByDoc();
    end;


    local procedure CreateJournalByDoc()
    var
        RecordToCreate: Record IntAccountingEntries;
        MarkAllDataErrorLbl: Label 'The document has data errors in other fields.';
    begin

        DeleteGenJournalOldLines(RecordToCreate);

        IntAccountingEntriesBuffer.SetAutoCalcFields(Amount, "Bal. Amount", "Line Errors");
        if IntAccountingEntriesBuffer.FindFirst() then
            repeat
                // if (IntAccountingEntriesBuffer.Amount + IntAccountingEntriesBuffer."Bal. Amount") = 0 then begin
                if IntAccountingEntriesBuffer."Line Errors" = 0 then begin
                    FilterRecordToCreate(RecordToCreate);
                    if not RecordToCreate.IsEmpty then begin
                        RecordToCreate.FindSet();
                        repeat
                            CreateJournal(RecordToCreate);
                        until RecordToCreate.Next() = 0;
                    end;
                end else begin
                    FilterRecordToCreate(RecordToCreate);
                    if not RecordToCreate.IsEmpty then begin
                        RecordToCreate.FindSet();
                        RecordToCreate.ModifyAll(Status, RecordToCreate.Status::"Data Error");
                    end;
                    FilterRecordToCreateErrorMessage(RecordToCreate);
                    if not RecordToCreate.IsEmpty then begin
                        RecordToCreate.FindSet();
                        RecordToCreate.ModifyAll("Posting Message", MarkAllDataErrorLbl);
                    end;
                end;
            // end else begin
            //     FilterRecordToCreate(RecordToCreate);
            //     if not RecordToCreate.IsEmpty then begin
            //         RecordToCreate.FindSet();
            //         RecordToCreate.ModifyAll(Status, RecordToCreate.Status::"Data Error");
            //     end;
            //     FilterRecordToCreateErrorMessage(RecordToCreate);
            //     if not RecordToCreate.IsEmpty then begin
            //         RecordToCreate.FindSet();
            //         RecordToCreate.ModifyAll("Posting Message", MarkAllDataErrorLbl);
            //     end;
            // end;
            until IntAccountingEntriesBuffer.Next() = 0;
    end;

    local procedure CreateJournal(var RecordToPost: Record IntAccountingEntries)
    var
        GenJournalLine: Record "Gen. Journal Line";
        LastGenJournalLine: Record "Gen. Journal Line";
        LineNo: Integer;
    begin
        LastGenJournalLine.SETRANGE("Journal Template Name", RecordToPost."Journal Template Name");
        LastGenJournalLine.SETRANGE("Journal Batch Name", RecordToPost."Journal Batch Name");
        IF LastGenJournalLine.FINDLAST THEN
            LineNo := LastGenJournalLine."Line No.";

        LineNo += 10000;
        GenJournalLine.Reset();
        GenJournalLine.Init();
        GenJournalLine."Journal Template Name" := RecordToPost."Journal Template Name";
        GenJournalLine."Journal Batch Name" := RecordToPost."Journal Batch Name";
        GenJournalLine."Line No." := LineNo;
        GenJournalLine.SetUpNewLine(LastGenJournalLine, 0, false);
        GenJournalLine.Validate("Posting Date", RecordToPost."Posting Date");
        GenJournalLine.Validate("Document Type", RecordToPost."Document Type");
        GenJournalLine.Validate("Document No.", RecordToPost."Document No.");
        GenJournalLine.Validate("Account Type", RecordToPost."Account Type");
        GenJournalLine.Validate("Account No.", RecordToPost."BR Account No.");
        GenJournalLine.Validate(Amount, RecordToPost.Amount);
        GenJournalLine.Validate("Bal. Account Type", RecordToPost."Bal. Account Type");
        GenJournalLine.Validate("Bal. Account No.", RecordToPost."BR Bal. Account No.");
        GenJournalLine.Validate(Description, CopyStr(RecordToPost.Description, 1, MaxStrLen(GenJournalLine.Description)));
        GenJournalLine.Validate("CADBR Additional Description", CopyStr(RecordToPost."Additional Description", 1, MaxStrLen(GenJournalLine."CADBR Additional Description")));
        GenJournalLine.Validate("CADBR Branch Code", RecordToPost."Branch Code");

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
            GenJournalLine.ValidateShortcutDimCode(8, RecordToPost."Dimension 8");

        GenJournalLine.Insert();

        RecordToPost.Status := RecordToPost.Status::Created;
        RecordToPost.Modify();
    end;

    local procedure ValidateIntPurchPaymentData(var RecordToCheck: Record IntAccountingEntries): Boolean
    begin
        RecordToCheck."Posting Message" := '';
        RecordToCheck.Modify();

        CheckJournalTemplate(RecordTocheck);
        CheckJournalBatch(RecordToCheck);
        CheckAccounts(RecordToCheck);
        ValidateDimensions(RecordToCheck);
        InsertBuffer(RecordToCheck);
        CheckDocumentNo(RecordToCheck);//rb

        if RecordToCheck."Posting Message" <> '' then begin
            RecordToCheck.Status := RecordToCheck.Status::"Data Error";
            RecordToCheck.Modify();
            exit(false);
        end
        else begin
            RecordToCheck.Status := RecordToCheck.Status::Created;
            RecordToCheck.Modify();
            exit(true);
        end;
    end;

    local procedure CheckJournalTemplate(var RecordTocheck: Record IntAccountingEntries)
    var
        GenJournaltemplate: Record "Gen. Journal Template";
        JournalTempError: Label 'The Journal Template %1 does not exist.';
    begin
        if not GenJournaltemplate.Get(RecordTocheck."Journal Template Name") then begin
            RecordToCheck."Posting Message" := MergePostingMessage(RecordToCheck."Posting Message", StrSubstNo(JournalTempError, RecordTocheck."Journal Template Name"));
        end;
    end;

    local procedure CheckDocumentNo(var RecordTocheck: Record IntAccountingEntries)
    var

        DocumentTempError: label 'The Document No. does not exist.';
    begin
        if RecordTocheck."Document No." = '' then
            RecordToCheck."Posting Message" := MergePostingMessage(RecordToCheck."Posting Message", DocumentTempError);

    end;

    local procedure CheckJournalBatch(var RecordToCheck: Record IntAccountingEntries)
    var
        GenJournalBatch: Record "Gen. Journal Batch";
        JournalBatchError: Label 'The Journal Batch %1 does not exist.';
    begin
        if not GenJournalBatch.Get(RecordToCheck."Journal Template Name", RecordTocheck."Journal Batch Name") then begin
            RecordToCheck."Posting Message" := MergePostingMessage(RecordToCheck."Posting Message", StrSubstNo(JournalBatchError, RecordTocheck."Journal Batch Name"));
        end;
    end;

    local procedure CheckVendor(var RecordToCheck: Record IntAccountingEntries; WhichField: Integer)
    var
        Vendor: Record Vendor;
        VendorError: Label 'the Vendor %1, does not exist.';
        BalVendorError: Label 'the Bal. Vendor %1, does not exist.';
    begin
        case WhichField of
            1:
                begin
                    if not Vendor.Get(RecordToCheck."Account No.") then begin
                        RecordToCheck."Posting Message" := MergePostingMessage(RecordToCheck."Posting Message", StrSubstNo(VendorError, RecordToCheck."Account No."));
                    end;
                end;
            2:
                begin
                    if RecordToCheck."Bal. Account No." <> '' then
                        if not Vendor.Get(RecordToCheck."Bal. Account No.") then begin
                            RecordToCheck."Posting Message" := MergePostingMessage(RecordToCheck."Posting Message", StrSubstNo(BalVendorError, RecordToCheck."Bal. Account No."));
                        end;
                end;
        end;
    end;

    local procedure CheckCustomer(var RecordToCheck: Record IntAccountingEntries; WhichField: Integer)
    var
        Customer: Record Customer;
        CustomerError: Label 'the Customer %1, does not exist.';
        BalCustomerError: Label 'the Bal. Customer %1, does not exist.';
    begin
        case WhichField of
            1:
                begin
                    if not Customer.Get(RecordToCheck."Account No.") then begin
                        RecordToCheck."Posting Message" := MergePostingMessage(RecordToCheck."Posting Message", StrSubstNo(CustomerError, RecordToCheck."Account No."));
                    end;
                end;
            2:
                begin
                    If RecordToCheck."Bal. Account No." <> '' then
                        if not Customer.Get(RecordToCheck."Bal. Account No.") then begin
                            RecordToCheck."Posting Message" := MergePostingMessage(RecordToCheck."Posting Message", StrSubstNo(BalCustomerError, RecordToCheck."Bal. Account No."));
                        end;
                end;
        end;
    end;

    local procedure CheckGLAcc(var RecordToCheck: Record IntAccountingEntries; WhichField: Integer)
    var
        GLAcc: Record "G/L Account";
        FromToUSGAAP: Record "From/To US GAAP";
        GLAccError: Label 'the G/L Account %1, does not exist.';
        BalGLAccError: Label 'the Bal. G/L Account %1, does not exist.';
        FromToUSGAAPErrorLbl: Label 'the combination of %1 %2 %3 %4 %5 %6 %7 %8 %9 does not exist on %10';
    begin
        case WhichField of
            1:
                begin
                    GLAcc.SetRange("No. 2", RecordToCheck."Account No.");
                    if GLAcc.FindFirst() then begin
                        RecordToCheck."BR Account No." := GLAcc."No.";
                    end else begin
                        FromToUSGAAP.SetRange("US GAAP", RecordToCheck."Account No.");
                        DimFilterFromToUSGAAP(RecordToCheck, FromToUSGAAP);
                        if FromToUSGAAP.FindFirst() then begin
                            if (FromToUSGAAP."BR GAAP" In ['1628012', '1639012', '1644012', '1645012', '1646012', '1647012', '1657012', '1662012', '1668012',
                                                            '1670012', '1672012', '1679012', '1681012']) and (RecordToCheck."Dimension 2" = 'OI  2,113 - GUARANI') then
                                RecordToCheck."BR Account No." := '4.2.01.0001'
                            else
                                RecordToCheck."BR Account No." := FromToUSGAAP."BR GAAP";

                            if not GLAcc.Get(RecordToCheck."BR Account No.") then begin
                                RecordToCheck."Posting Message" := MergePostingMessage(RecordToCheck."Posting Message", StrSubstNo(GLAccError, RecordToCheck."BR Account No."));
                            end;
                        end else begin
                            RecordToCheck."Posting Message" := MergePostingMessage(RecordToCheck."Posting Message", StrSubstNo(FromToUSGAAPErrorLbl, RecordToCheck."Account No.",
                                                                                                                                                    RecordToCheck."Dimension 1",
                                                                                                                                                    RecordToCheck."Dimension 2",
                                                                                                                                                    RecordToCheck."Dimension 3",
                                                                                                                                                    RecordToCheck."Dimension 4",
                                                                                                                                                    RecordToCheck."Dimension 5",
                                                                                                                                                    RecordToCheck."Dimension 6",
                                                                                                                                                    RecordToCheck."Dimension 7",
                                                                                                                                                    RecordToCheck."Dimension 8",
                                                                                                                                                    FromToUSGAAP.TableCaption));
                        end;
                    end;
                end;
            2:
                begin
                    GLAcc.SetRange("No. 2", RecordToCheck."Bal. Account No.");
                    if GLAcc.FindFirst() then begin
                        RecordToCheck."BR Bal. Account No." := GLAcc."No.";
                    end else begin
                        FromToUSGAAP.SetRange("US GAAP", RecordToCheck."Bal. Account No.");
                        DimFilterFromToUSGAAP(RecordToCheck, FromToUSGAAP);
                        if FromToUSGAAP.FindFirst() then begin
                            RecordToCheck."BR Bal. Account No." := FromToUSGAAP."BR GAAP";
                            if not GLAcc.Get(RecordToCheck."BR Bal. Account No.") then begin
                                RecordToCheck."Posting Message" := MergePostingMessage(RecordToCheck."Posting Message", StrSubstNo(GLAccError, RecordToCheck."BR Bal. Account No."));
                            end;
                        end else begin
                            RecordToCheck."Posting Message" := MergePostingMessage(RecordToCheck."Posting Message", StrSubstNo(FromToUSGAAPErrorLbl, RecordToCheck."Bal. Account No.",
                                                                                                                                                    RecordToCheck."Dimension 1",
                                                                                                                                                    RecordToCheck."Dimension 2",
                                                                                                                                                    RecordToCheck."Dimension 3",
                                                                                                                                                    RecordToCheck."Dimension 4",
                                                                                                                                                    RecordToCheck."Dimension 5",
                                                                                                                                                    RecordToCheck."Dimension 6",
                                                                                                                                                    RecordToCheck."Dimension 7",
                                                                                                                                                    RecordToCheck."Dimension 8",
                                                                                                                                                    FromToUSGAAP.TableCaption));
                        end;
                    end;
                end;
        end;
    end;

    local procedure CheckEmployee(var RecordToCheck: Record IntAccountingEntries; WhichField: Integer)
    var
        Employee: Record Employee;
        EmployeeError: Label 'the Employee %1, does not exist.';
        BalEmployeeError: Label 'the Bal. Employee %1, does not exist.';
    begin
        case WhichField of
            1:
                begin
                    if not Employee.Get(RecordToCheck."Account No.") then begin
                        RecordToCheck."Posting Message" := MergePostingMessage(RecordToCheck."Posting Message", StrSubstNo(EmployeeError, RecordToCheck."Account No."));
                    end;
                end;
            2:
                begin
                    if RecordToCheck."Bal. Account No." <> '' then
                        if not Employee.Get(RecordToCheck."Bal. Account No.") then begin
                            RecordToCheck."Posting Message" := MergePostingMessage(RecordToCheck."Posting Message", StrSubstNo(BalEmployeeError, RecordToCheck."Bal. Account No."));
                        end;
                end;
        end;
    end;

    local procedure CheckFixedAsset(var RecordToCheck: Record IntAccountingEntries; WhichField: Integer)
    var
        FixedAsset: Record "Fixed Asset";
        FixedAssetError: Label 'the Fixed Asset %1, does not exist.';
        BalFixedAssetError: Label 'the Bal. Fixed Asset %1, does not exist.';
    begin
        case WhichField of
            1:
                begin
                    if not FixedAsset.Get(RecordToCheck."Account No.") then begin
                        RecordToCheck."Posting Message" := MergePostingMessage(RecordToCheck."Posting Message", StrSubstNo(FixedAssetError, RecordToCheck."Account No."));
                    end;
                end;
            2:
                begin
                    if RecordToCheck."Bal. Account No." <> '' then
                        if not FixedAsset.Get(RecordToCheck."Bal. Account No.") then begin
                            RecordToCheck."Posting Message" := MergePostingMessage(RecordToCheck."Posting Message", StrSubstNo(BalFixedAssetError, RecordToCheck."Bal. Account No."));
                        end;
                end;
        end;
    end;

    local procedure CheckBankAccount(var RecordToCheck: Record IntAccountingEntries; WhichField: Integer)
    var
        BankAccount: Record "Bank Account";
        BankAccountError: Label 'the Bank Account %1 does not exist.';
        BalBankAccountError: Label 'the Bal. Bank Account %1 does not exist.';
    begin
        case WhichField of
            1:
                begin
                    if not BankAccount.Get(RecordToCheck."Account No.") then begin
                        RecordToCheck."Posting Message" := MergePostingMessage(RecordToCheck."Posting Message", StrSubstNo(BankAccountError, RecordToCheck."Account No."));
                    end;
                end;
            2:
                begin
                    if RecordToCheck."Bal. Account No." <> '' then
                        if not BankAccount.Get(RecordToCheck."Bal. Account No.") then begin
                            RecordToCheck."Posting Message" := MergePostingMessage(RecordToCheck."Posting Message", StrSubstNo(BalBankAccountError, RecordToCheck."Bal. Account No."));
                        end;
                end;
        end;
    end;

    local procedure ValidateDimensions(var RecordToCheck: Record IntAccountingEntries)
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

    procedure PostPaymentJournal(IntAccountingEntries: Record IntAccountingEntries)
    var
        GenJournalLine: Record "Gen. Journal Line";
        PostIntAccountingEntries: Record IntAccountingEntries;
        GenJnlPostBatch: Codeunit "Gen. Jnl.-Post Batch";
    begin
        PostIntAccountingEntries.SetRange("Excel File Name", IntAccountingEntries."Excel File Name");
        PostIntAccountingEntries.SetRange("Journal Template Name", IntAccountingEntries."Journal Template Name");
        PostIntAccountingEntries.SetRange("Journal Batch Name", IntAccountingEntries."Journal Batch Name");
        PostIntAccountingEntries.SetRange(Status, PostIntAccountingEntries.Status::Created);
        if not PostIntAccountingEntries.IsEmpty then begin
            PostIntAccountingEntries.FindSet();
            GenJournalLine.SetRange("Journal Template Name", PostIntAccountingEntries."Journal Template Name");
            GenJournalLine.SetRange("Journal Batch Name", PostIntAccountingEntries."Journal Batch Name");
            if GenJournalLine.FindFirst() then begin
                GenJnlPostBatch.SetPreviewMode(false);
                GenJnlPostBatch.Run(GenJournalLine);
                PostIntAccountingEntries.ModifyAll(Status, PostIntAccountingEntries.Status::Posted);
            end;
        end;
    end;

    local procedure MergePostingMessage(OldMessage: text; AddMessage: text): Text
    var
        RecordToCheck: Record IntAccountingEntries;
    begin
        if OldMessage <> '' then
            exit(CopyStr(OldMessage + ' ' + AddMessage, 1, MaxStrLen(RecordToCheck."Posting Message")))
        else
            exit(CopyStr(AddMessage, 1, MaxStrLen(RecordToCheck."Posting Message")));
    end;

    local procedure CallCheckData()
    var
        IntAccountingEntries: Record IntAccountingEntries;
        FileToProcessTMP: Record IntAccountingEntries temporary;
        LastFile: Text;
    begin
        IntAccountingEntries.SetFilter(Status, '%1|%2', IntAccountingEntries.Status::Imported, IntAccountingEntries.Status::"Data Error");
        if not IntAccountingEntries.IsEmpty then begin
            IntAccountingEntries.FindSet();
            repeat
                if LastFile <> IntAccountingEntries."Excel File Name" then begin
                    FileToProcessTMP."Excel File Name" := IntAccountingEntries."Excel File Name";
                    FileToProcessTMP.Insert();
                    LastFile := FileToProcessTMP."Excel File Name";
                end;
            until IntAccountingEntries.next = 0;
        end;

        if FileToProcessTMP.FindFirst() then
            repeat
                CheckData(FileToProcessTMP);
            until FileToProcessTMP.Next() = 0;
    end;

    local procedure CallPostJournal()
    var
        IntAccountingEntries: Record IntAccountingEntries;
        FileToProcessTMP: Record IntAccountingEntries temporary;
        LastFile: Text;
    begin
        IntAccountingEntries.SetRange(Status, IntAccountingEntries.Status::Created);
        if not IntAccountingEntries.IsEmpty then begin
            IntAccountingEntries.FindSet();
            repeat
                if LastFile <> IntAccountingEntries."Excel File Name" then begin
                    FileToProcessTMP."Excel File Name" := IntAccountingEntries."Excel File Name";
                    FileToProcessTMP.Insert();
                    LastFile := FileToProcessTMP."Excel File Name";
                end;
            until IntAccountingEntries.next = 0;
        end;

        if FileToProcessTMP.FindFirst() then
            repeat
                PostPaymentJournal(FileToProcessTMP);
            until FileToProcessTMP.Next() = 0;
    end;

    local procedure CheckAccounts(var RecordToCheck: Record IntAccountingEntries)
    begin

        case RecordToCheck."Account Type" of
            RecordToCheck."Account Type"::"Bank Account":
                CheckBankAccount(RecordToCheck, 1);
            RecordToCheck."Account Type"::Customer:
                CheckVendor(RecordToCheck, 1);
            RecordToCheck."Account Type"::"G/L Account":
                CheckGLAcc(RecordToCheck, 1);
            RecordToCheck."Account Type"::Vendor:
                CheckVendor(RecordToCheck, 1);
            RecordToCheck."Account Type"::"Fixed Asset":
                CheckFixedAsset(RecordToCheck, 1);
            RecordToCheck."Account Type"::Employee:
                CheckEmployee(RecordToCheck, 1);
        end;
        if RecordToCheck."Bal. Account No." <> '' then
            case RecordToCheck."Bal. Account Type" of
                RecordToCheck."Bal. Account Type"::"Bank Account":
                    CheckBankAccount(RecordToCheck, 2);
                RecordToCheck."Bal. Account Type"::Customer:
                    CheckVendor(RecordToCheck, 2);
                RecordToCheck."Bal. Account Type"::"G/L Account":
                    CheckGLAcc(RecordToCheck, 2);
                RecordToCheck."Bal. Account Type"::Vendor:
                    CheckVendor(RecordToCheck, 2);
                RecordToCheck."Bal. Account Type"::"Fixed Asset":
                    CheckFixedAsset(RecordToCheck, 2);
                RecordToCheck."Bal. Account Type"::Employee:
                    CheckEmployee(RecordToCheck, 2);
            end;
    end;

    local procedure DimFilterFromToUSGAAP(var RecordToCheck: Record IntAccountingEntries; var FromToUSGAAP: Record "From/To US GAAP")
    begin
        FromToUSGAAP.SetRange("Dimension 1", RecordToCheck."Dimension 1");
        FromToUSGAAP.SetRange("Dimension 2", RecordToCheck."Dimension 2");
        FromToUSGAAP.SetRange("Dimension 3", RecordToCheck."Dimension 3");
        FromToUSGAAP.SetRange("Dimension 4", RecordToCheck."Dimension 4");
        FromToUSGAAP.SetRange("Dimension 5", RecordToCheck."Dimension 5");
        FromToUSGAAP.SetRange("Dimension 6", RecordToCheck."Dimension 6");
        FromToUSGAAP.SetRange("Dimension 7", RecordToCheck."Dimension 7");
        FromToUSGAAP.SetRange("Dimension 8", RecordToCheck."Dimension 8");
    end;

    local procedure CheckDockBalance(var RecordToCheck: Record IntAccountingEntries)
    begin
        RecordToCheck.CalcFields("Bal. Amount");
        if RecordToCheck."Bal. Amount" <> 0 then begin
            RecordToCheck."Posting Message" := MergePostingMessage(RecordToCheck."Posting Message", StrSubstNo('The Document %1 is not balanced.', RecordTocheck."Document No."));
        end;
    end;

    local procedure InsertBuffer(var RecordToCheck: Record IntAccountingEntries)
    begin
        IntAccountingEntriesBuffer.Init();
        IntAccountingEntriesBuffer."Excel File Name" := RecordToCheck."Excel File Name";
        IntAccountingEntriesBuffer."Document Type" := RecordToCheck."Document Type";
        IntAccountingEntriesBuffer."Document No." := RecordToCheck."Document No.";
        IntAccountingEntriesBuffer."Posting Date" := RecordToCheck."Posting Date";
        if IntAccountingEntriesBuffer.Insert() then;
    end;

    local procedure FilterRecordToCreate(var RecordToCreate: Record IntAccountingEntries)
    begin
        RecordToCreate.Reset();
        RecordToCreate.SetCurrentKey("Excel File Name", "Document Type", "Document No.", "Posting Date");
        RecordToCreate.SetRange("Excel File Name", IntAccountingEntriesBuffer."Excel File Name");
        RecordToCreate.SetRange("Document Type", IntAccountingEntriesBuffer."Document Type");
        RecordToCreate.SetRange("Document No.", IntAccountingEntriesBuffer."Document No.");
        RecordToCreate.SetRange("Posting Date", IntAccountingEntriesBuffer."Posting Date");
    end;

    local procedure FilterRecordToCreateErrorMessage(var RecordToCreate: Record IntAccountingEntries)
    begin
        RecordToCreate.Reset();
        RecordToCreate.SetCurrentKey("Excel File Name", "Document Type", "Document No.", "Posting Date");
        RecordToCreate.SetRange("Excel File Name", IntAccountingEntriesBuffer."Excel File Name");
        RecordToCreate.SetRange("Document Type", IntAccountingEntriesBuffer."Document Type");
        RecordToCreate.SetRange("Document No.", IntAccountingEntriesBuffer."Document No.");
        RecordToCreate.SetRange("Posting Date", IntAccountingEntriesBuffer."Posting Date");
        RecordToCreate.SetFilter("Posting Message", '%1', '');
    end;

    local procedure DeleteGenJournalOldLines(var RecordToCreate: Record IntAccountingEntries)
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        GenJournalLine.SETRANGE("Journal Template Name", RecordToCreate."Journal Template Name");
        GenJournalLine.SETRANGE("Journal Batch Name", RecordToCreate."Journal Batch Name");
        IF not GenJournalLine.IsEmpty THEN
            GenJournalLine.DeleteAll(true);
    end;

    local procedure SearchErrosByFile(var IntAccountingEntries: Record IntAccountingEntries)
    var
        SearchFiles: Record IntAccountingEntries;
        LastFile: Text;
        FoundFiles: Record IntAccountingEntriesBuffer temporary;
    begin
        SearchFiles.SetFilter(Status, '%1|%2', IntAccountingEntries.Status::Imported, IntAccountingEntries.Status::"Data Error");
        if not SearchFiles.IsEmpty then begin
            SearchFiles.FindSet();
            repeat
                if LastFile <> SearchFiles."Excel File Name" then begin
                    LastFile := SearchFiles."Excel File Name";
                    FoundFiles."Excel File Name" := SearchFiles."Excel File Name";
                    if FoundFiles.Insert() then;
                end;
            until SearchFiles.Next() = 0;

            DeleteErros(FoundFiles);
        end;
    end;

    local procedure DeleteErros(var FoundFiles: Record IntAccountingEntriesBuffer temporary)
    var
        IntegrationErros: Record IntegrationErros;
    begin
        if not FoundFiles.IsEmpty then begin
            FoundFiles.FindSet();
            repeat
                IntegrationErros.SetRange("Excel File Name", FoundFiles."Excel File Name");
                if not IntegrationErros.IsEmpty then
                    IntegrationErros.DeleteAll();
            until FoundFiles.Next() = 0;
        end;
    end;

    var
        IntAccountingEntriesBuffer: Record IntAccountingEntriesBuffer temporary;
}