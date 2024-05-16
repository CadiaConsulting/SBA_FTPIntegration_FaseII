codeunit 50003 "Integration Receipt Journal"
{
    procedure CreateJournal(var IntRecJour: Record "Integration Receipt Journal")
    var
        IntReceiptJournal: Record "Integration Receipt Journal";
        DialogCreReceiptJournalLbl: label 'Create Receipt Journal   #1#############', Comment = '#1 IntReceiptJournal';
        FTPIntSetup: Record "FTP Integration Setup";
        IntegrationEmail: Codeunit "Integration Email";
    begin

        IntReceiptJournal.Reset();
        IntReceiptJournal.CopyFilters(IntRecJour);
        // IntReceiptJournal.SetRange("Excel File Name", IntReceiptJournal."Excel File Name");
        //  IntReceiptJournal.SetRange("Journal Template Name", IntReceiptJournal."Journal Template Name");
        //  IntReceiptJournal.SetRange("Journal Batch Name", IntReceiptJournal."Journal Batch Name");
        IntReceiptJournal.SetFilter(Status, '%1|%2', IntReceiptJournal.Status::Imported,
                                                   IntReceiptJournal.Status::"Data Error");
        if IntReceiptJournal.Find('-') then begin
            if GuiAllowed then
                WindDialog.Open(DialogCreReceiptJournalLbl);
            repeat
                if GuiAllowed then
                    WindDialog.Update(1, IntReceiptJournal."Document No.");

                IntReceiptJournal."Posting Message" := '';
                IntReceiptJournal.Modify();

                if not ValidateIntReceiptJournal(IntReceiptJournal) then
                    CreateReceiptJournal(IntReceiptJournal)
                else begin
                    FTPIntSetup.Get(FTPIntSetup.Integration::"Sales Payment");
                    if FTPIntSetup."Send Email" then
                        IntegrationEmail.SendMail(FTPIntSetup."E-mail Rejected Data", True, IntReceiptJournal."Posting Message", IntReceiptJournal."Excel File Name");
                end;


            until IntReceiptJournal.Next() = 0;

            if GuiAllowed then
                WindDialog.Close();

        end;

    end;

    procedure PostReceiptJournal()
    var
        IntReceiptJournal: Record "Integration Receipt Journal";
    begin
        IntReceiptJournal.Reset();
        IntReceiptJournal.SetFilter(Status, '%1', IntReceiptJournal.Status::Created);
        IntReceiptJournal.CalcFields("Error Order");
        IntReceiptJournal.SetFilter("Error Order", '%1', 0);
        if IntReceiptJournal.Find('-') then
            repeat
                CreatePost(IntReceiptJournal);
            until IntReceiptJournal.Next() = 0;

    end;

    procedure CreateReceiptJournal(var IntReceiptJournal: Record "Integration Receipt Journal")
    var
        ReceiptJournal: Record "Gen. Journal Line";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";

    begin

        //IntReceiptJournal.FindFirst();
        //repeat

        ReceiptJournal.Reset();

        ReceiptJournal.InitNewLine(IntReceiptJournal."Posting Date", IntReceiptJournal."Posting Date", IntReceiptJournal."Posting Date",
                                     IntReceiptJournal.Description, IntReceiptJournal."dimension 1",
                                     IntReceiptJournal."dimension 2", 0, '');

        ReceiptJournal."Journal Template Name" := IntReceiptJournal."Journal Template Name";
        ReceiptJournal."Journal Batch Name" := IntReceiptJournal."Journal Batch Name";
        ReceiptJournal."Line No." := IntReceiptJournal."Line No.";
        ReceiptJournal."Account Type" := IntReceiptJournal."Account Type";
        ReceiptJournal."Account No." := IntReceiptJournal."Account No.";
        ReceiptJournal.VALIDATE(Amount, IntReceiptJournal.Amount);
        ReceiptJournal."Applies-to Doc. No." := IntReceiptJournal."Applies-to Doc. No.";
        ReceiptJournal."Applies-to Doc. Type" := IntReceiptJournal."Applies-to Doc. Type";
        ReceiptJournal."Bal. Account No." := IntReceiptJournal."Bal. Account No.";
        ReceiptJournal."Bal. Account Type" := IntReceiptJournal."Bal. Account Type";
        ReceiptJournal."Document No." := IntReceiptJournal."Document No.";
        ReceiptJournal."Document Type" := IntReceiptJournal."Document Type";

        ReceiptJournal.Validate("Shortcut Dimension 1 Code", IntReceiptJournal."dimension 1");
        ReceiptJournal.Validate("Shortcut Dimension 2 Code", IntReceiptJournal."dimension 2");
        ReceiptJournal.ValidateShortcutDimCode(3, IntReceiptJournal."dimension 3");
        ReceiptJournal.ValidateShortcutDimCode(4, IntReceiptJournal."dimension 4");
        ReceiptJournal.ValidateShortcutDimCode(5, IntReceiptJournal."dimension 5");
        ReceiptJournal.ValidateShortcutDimCode(6, IntReceiptJournal."dimension 6");

        //  ReceiptJournal.Insert();

        IntReceiptJournal.Status := IntReceiptJournal.Status::Created;
        IntReceiptJournal.Modify();
        //until IntReceiptJournal.Next() = 0;

        //   if ReceiptJournal.Find('-') then
        //     repeat
        GenJnlPostLine.RunWithCheck(ReceiptJournal);
        IntReceiptJournal.Status := IntReceiptJournal.Status::Posted;
        IntReceiptJournal.Modify();
        //   until ReceiptJournal.Next() = 0;

    end;

    procedure CreatePost(IntReceiptJournal: Record "Integration Receipt Journal")
    var
        ReceiptJournal: Record "Gen. Journal Line";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";

    begin

        ReceiptJournal.Reset();
        ReceiptJournal.SetRange("Journal Template Name", IntReceiptJournal."Journal Template Name");
        ReceiptJournal.SetRange("Journal Batch Name", IntReceiptJournal."Journal Batch Name");
        if ReceiptJournal.Find('-') then
            repeat
                GenJnlPostLine.RunWithCheck(ReceiptJournal);
                IntReceiptJournal.Status := IntReceiptJournal.Status::Posted;
                IntReceiptJournal.Modify();

            until ReceiptJournal.Next() = 0;

    End;

    procedure ValidateIntReceiptJournal(var IntReceiptJournal: Record "Integration Receipt Journal"): Boolean;
    var
        Vendor: Record Vendor;
        Item: Record Item;
        GeneralPostingSetup: Record "General Posting Setup";
        GLAccount: Record "G/L Account";
        Cust01Err: label 'Customer %1 Not Found', Comment = '%1 - Customer No.';
        Item01Err: label ' - Item %1 Not Found', Comment = '%1 - Item No.';
        GL01Err: label ' - G/L Account not sent by GP';
        GL02Err: label ' - G/L Account GP %1 different from G/L Account %2', Comment = '%1 - G/L Accoun No. , %2 - G/L Accoun No.';

    begin

        if IntReceiptJournal."Account No." = '' then begin
            IntReceiptJournal."Posting Message" += GL01Err;
            IntReceiptJournal.Modify();
        end else
            if GeneralPostingSetup.get(Vendor."Gen. Bus. Posting Group", Item."Gen. Prod. Posting Group") then
                if GLAccount.Get(GeneralPostingSetup."Purch. Credit Memo Account") then
                    if (GLAccount."No. 2" <> IntReceiptJournal."Account No.") then begin
                        IntReceiptJournal."Posting Message" += StrSubstNo(GL02Err, IntReceiptJournal."Account No.", GeneralPostingSetup."Sales Account");
                        IntReceiptJournal.Modify();
                    end;

        if IntReceiptJournal."dimension 1" <> '' then
            if not ValidateDim(1, IntReceiptJournal."dimension 1") then
                CreateDim(1, IntReceiptJournal."dimension 1");

        if IntReceiptJournal."dimension 2" <> '' then
            if not ValidateDim(2, IntReceiptJournal."dimension 2") then
                CreateDim(2, IntReceiptJournal."dimension 2");

        if IntReceiptJournal."dimension 3" <> '' then
            if not ValidateDim(3, IntReceiptJournal."dimension 3") then
                CreateDim(3, IntReceiptJournal."dimension 3");

        if IntReceiptJournal."dimension 4" <> '' then
            if not ValidateDim(4, IntReceiptJournal."dimension 4") then
                CreateDim(4, IntReceiptJournal."dimension 4");

        if IntReceiptJournal."dimension 5" <> '' then
            if not ValidateDim(5, IntReceiptJournal."dimension 5") then
                CreateDim(5, IntReceiptJournal."dimension 5");

        if IntReceiptJournal."dimension 6" <> '' then
            if not ValidateDim(6, IntReceiptJournal."dimension 6") then
                CreateDim(6, IntReceiptJournal."dimension 6");

        if IntReceiptJournal."Posting Message" <> '' then begin
            IntReceiptJournal.Status := IntReceiptJournal.Status::"Data Error";
            IntReceiptJournal.Modify();

            exit(true);

        end;


    end;

    procedure ValidateDim(DimSeq: Integer; ValueDim: Code[20]): Boolean
    var
        DimensionValue: Record "Dimension Value";
        GeneralLedgerSetup: Record "General Ledger Setup";

    begin
        GeneralLedgerSetup.Get();

        if DimSeq = 1 then
            DimensionCode := GeneralLedgerSetup."Shortcut Dimension 1 Code";
        if DimSeq = 2 then
            DimensionCode := GeneralLedgerSetup."Shortcut Dimension 2 Code";
        if DimSeq = 3 then
            DimensionCode := GeneralLedgerSetup."Shortcut Dimension 3 Code";
        if DimSeq = 4 then
            DimensionCode := GeneralLedgerSetup."Shortcut Dimension 4 Code";
        if DimSeq = 5 then
            DimensionCode := GeneralLedgerSetup."Shortcut Dimension 5 Code";
        if DimSeq = 6 then
            DimensionCode := GeneralLedgerSetup."Shortcut Dimension 6 Code";
        if DimSeq = 7 then
            DimensionCode := GeneralLedgerSetup."Shortcut Dimension 7 Code";
        if DimSeq = 8 then
            DimensionCode := GeneralLedgerSetup."Shortcut Dimension 8 Code";

        DimensionValue.Reset();
        exit(DimensionValue.Get(DimensionCode, ValueDim));

    end;

    procedure CreateDim(DimSeq: Integer; ValueDim: Code[20]): Boolean
    var
        DimensionValue: Record "Dimension Value";

    begin

        DimensionValue.Init();
        DimensionValue.Validate("Dimension Code", DimensionCode);
        DimensionValue.Validate(Code, ValueDim);
        DimensionValue.Name := ValueDim;
        DimensionValue."Dimension Value Type" := DimensionValue."Dimension Value Type"::Standard;
        if DimSeq in [1, 2] then
            DimensionValue."Global Dimension No." := DimSeq;

        DimensionValue.Insert(true);

    end;

    // procedure ImportExcelReceiptJournal()
    // var
    //     IntReceiptJournal: Record "Integration Receipt Journal";
    //     DialogCreReceiptJournalLbl: label 'Create Receipt Journal   #1#############', Comment = '#1 IntReceiptJournal';
    // begin
    //     IntReceiptJournal.Reset();
    //     IntReceiptJournal.SetFilter(Status, '%1|%2', IntReceiptJournal.Status::Imported,
    //                                            IntReceiptJournal.Status::"Data Error");
    //     if IntReceiptJournal.Find('-') then begin
    //         if GuiAllowed then
    //             WindDialog.Open(DialogCreReceiptJournalLbl);
    //         repeat
    //             if GuiAllowed then
    //                 WindDialog.Update(1, IntReceiptJournal."document No.");

    //             IntReceiptJournal."Posting Message" := '';
    //             IntReceiptJournal.Modify();

    //             if not ValidateIntReceiptJournal(IntReceiptJournal) then
    //                 CreateReceiptJournal(IntReceiptJournal);

    //         until IntReceiptJournal.Next() = 0;

    //         if GuiAllowed then
    //             WindDialog.Close();

    //     end;

    // end;

    // [EventSubscriber(ObjectType::Codeunit, Codeunit::"", 'OnBeforePostReceiptJournalDoc', '', false, false)]
    // local procedure OnBeforePostReceiptJournalDocReceiptJournalPost(var HideProgressWindow: Boolean)
    // begin
    //     HideProgressWindow := booHideDialog;
    // end;

    // [EventSubscriber(ObjectType::Codeunit, Codeunit::"", 'OnBeforeCheckHeaderPostingType', '', false, false)]
    // local procedure OnBeforeCheckHeaderPostingTypeReceiptJournalPost(var IsHandled: Boolean)
    // begin
    //     IsHandled := booIsHandled;
    // end;

    var
        DimensionCode: Code[20];
        booHideDialog: Boolean;
        booIsHandled: Boolean;
        WindDialog: Dialog;


}
