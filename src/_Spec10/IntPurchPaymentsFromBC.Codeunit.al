codeunit 50073 "IntPurchPaymentsFromBC"
{
    Permissions = TableData "Vendor Ledger Entry" = rm;

    // [EventSubscriber(ObjectType::Table, Database::"Vendor Ledger Entry", 'OnAfterCopyVendLedgerEntryFromGenJnlLine', '', false, false)]
    // local procedure OnAfterCopyVendLedgerEntryFromGenJnlLine_TableVendorLedgerEntry(var VendorLedgerEntry: Record "Vendor Ledger Entry"; GenJournalLine: Record "Gen. Journal Line")
    // var
    //     IPPFromBC: Record IntPurchPaymentsFromBC;
    //     CompareCNAB: Text;
    // begin

    //     CompareCNAB := GenJournalLine."Source Code";

    //     if CompareCNAB.Contains('CNAB') then begin
    //         IPPFromBC.Init();
    //         IPPFromBC."Journal Template Name" := GenJournalLine."Journal Template Name";
    //         IPPFromBC."Journal Batch Name" := GenJournalLine."Journal Batch Name";
    //         IPPFromBC."Line No." := GenJournalLine."Line No.";
    //         IPPFromBC."Account Type" := GenJournalLine."Account Type";
    //         IPPFromBC."Account No." := GenJournalLine."Account No.";
    //         IPPFromBC."Posting Date" := GenJournalLine."Posting Date";
    //         IPPFromBC."Document Type" := GenJournalLine."Account Type";
    //         IPPFromBC."Document No." := GenJournalLine."Document No.";
    //         IPPFromBC.Description := GenJournalLine.Description;
    //         IPPFromBC."Bal. Account Type" := GenJournalLine."Bal. Account Type";
    //         IPPFromBC."Bal. Account No." := GenJournalLine."Bal. Account No.";
    //         IPPFromBC.Amount := GenJournalLine.Amount;
    //         IPPFromBC."Dimension Set ID" := GenJournalLine."Dimension Set ID";
    //         IPPFromBC."Applies-to Doc. Type" := GenJournalLine."Applies-to Doc. Type";
    //         IPPFromBC."Applies-to Doc. No." := GenJournalLine."Applies-to Doc. No.";
    //         IPPFromBC."External Document No." := GenJournalLine."External Document No.";
    //         IPPFromBC.Status := IPPFromBC.Status::Created;
    //         VendorLedgerEntry.Integrated := IPPFromBC.Insert();
    //     end;
    // end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Vend. Entry-Edit", 'OnBeforeVendLedgEntryModify', '', false, false)]
    local procedure Codeunit_113_OnBeforeVendLedgEntryModify(var VendLedgEntry: Record "Vendor Ledger Entry"; FromVendLedgEntry: Record "Vendor Ledger Entry")
    begin
        VendLedgEntry.Integrated := FromVendLedgEntry.Integrated;
    end;

    procedure SuggestVendorPayments()
    var
        IPPFromBC: Record IntPurchPaymentsFromBC;
        CompareCNAB: Text;
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        DetailedVendorLed: Record "Detailed Vendor Ledg. Entry";
        CNABPaymentLine: Record "CADBR CNAB Payment Line";
        TotalAmount: Decimal;
        ExtDocumentNo: Code[20];
        EntryNo: Integer;
        DetEntryNo: Integer;
        LineNo: Integer;
        DocumentNo: Code[20];
        AppliesToDocNo: Code[20];
    begin

        //Payment
        VendorLedgerEntry.Reset;
        VendorLedgerEntry.SetCurrentKey("Source Code");
        VendorLedgerEntry.SetRange("Source Code", 'CNABCP');
        VendorLedgerEntry.SetRange(Integrated, false);
        VendorLedgerEntry.SetRange("Document Type", VendorLedgerEntry."Document Type"::Payment);
        if VendorLedgerEntry.FindSet then
            repeat

                DetailedVendorLed.Reset();
                DetailedVendorLed.SetRange("Document No.", VendorLedgerEntry."Document No.");
                DetailedVendorLed.SetFilter("Document Type", '%1|%2', DetailedVendorLed."Document Type"::" ", DetailedVendorLed."Document Type"::Payment);
                DetailedVendorLed.SetRange("Entry Type", DetailedVendorLed."Entry Type"::Application);
                DetailedVendorLed.SetFilter(Amount, '>%1', 0);
                if DetailedVendorLed.FindSet() then
                    repeat
                        DetailedVendorLed.CalcFields("CADBR VendLedg. Ext. Doc. No.");
                        DetailedVendorLed.CalcFields("CADBR Vend. Ledg. Document No.");

                        if DetailedVendorLed."CADBR VendLedg. Ext. Doc. No." <> '' then begin

                            if ExtDocumentNo <> DetailedVendorLed."CADBR VendLedg. Ext. Doc. No." then begin

                                IPPFromBC.Init();
                                IPPFromBC."Journal Template Name" := VendorLedgerEntry."Journal Templ. Name";
                                IPPFromBC."Journal Batch Name" := VendorLedgerEntry."Journal Batch Name";
                                IPPFromBC."Line No." := VendorLedgerEntry."Entry No.";
                                IPPFromBC."Detail Ledger Entry No." := DetailedVendorLed."Entry No.";
                                IPPFromBC."Account Type" := IPPFromBC."Account Type"::Vendor;
                                IPPFromBC."Account No." := VendorLedgerEntry."Vendor No.";
                                IPPFromBC."Posting Date" := VendorLedgerEntry."Posting Date";
                                IPPFromBC."Document Type" := VendorLedgerEntry."Document Type";
                                IPPFromBC."Document No." := VendorLedgerEntry."Document No.";
                                IPPFromBC.Description := VendorLedgerEntry.Description;
                                IPPFromBC."Bal. Account Type" := VendorLedgerEntry."Bal. Account Type";
                                IPPFromBC."Bal. Account No." := VendorLedgerEntry."Bal. Account No.";
                                IPPFromBC.Amount := DetailedVendorLed.Amount;

                                IPPFromBC."Dimension Set ID" := VendorLedgerEntry."Dimension Set ID";
                                IPPFromBC."Applies-to Doc. Type" := VendorLedgerEntry."Applies-to Doc. Type";
                                IPPFromBC."Applies-to Doc. No." := Format(DetailedVendorLed."CADBR Vend. Ledg. Document No.");
                                IPPFromBC."External Document No." := DetailedVendorLed."CADBR VendLedg. Ext. Doc. No."; //ajustar


                                IPPFromBC.Status := IPPFromBC.Status::Created;
                                if IPPFromBC.Insert then;
                                ExtDocumentNo := DetailedVendorLed."CADBR VendLedg. Ext. Doc. No.";
                                DocumentNo := VendorLedgerEntry."Document No.";
                                LineNo := VendorLedgerEntry."Entry No.";
                                EntryNo := DetailedVendorLed."Entry No.";
                                TotalAmount := DetailedVendorLed.Amount;

                            end else begin
                                IPPFromBC.Reset();
                                IPPFromBC.SetRange("External Document No.", ExtDocumentNo);
                                IPPFromBC.SetRange("Line No.", LineNo);
                                IPPFromBC.SetRange("Detail Ledger Entry No.", EntryNo);
                                IPPFromBC.SetRange("Document No.", DocumentNo);
                                if IPPFromBC.FindFirst() then begin
                                    IPPFromBC.Amount := TotalAmount + DetailedVendorLed.Amount;

                                    IPPFromBC.Modify(true);

                                    TotalAmount := TotalAmount + DetailedVendorLed.Amount;
                                end;

                            end;
                        end else begin

                            if ExtDocumentNo <> Format(DetailedVendorLed."CADBR Vend. Ledg. Document No.") then begin

                                IPPFromBC.Init();
                                IPPFromBC."Journal Template Name" := VendorLedgerEntry."Journal Templ. Name";
                                IPPFromBC."Journal Batch Name" := VendorLedgerEntry."Journal Batch Name";
                                IPPFromBC."Line No." := VendorLedgerEntry."Entry No.";
                                IPPFromBC."Detail Ledger Entry No." := DetailedVendorLed."Entry No.";
                                IPPFromBC."Account Type" := IPPFromBC."Account Type"::Vendor;
                                IPPFromBC."Account No." := VendorLedgerEntry."Vendor No.";
                                IPPFromBC."Posting Date" := VendorLedgerEntry."Posting Date";
                                IPPFromBC."Document Type" := VendorLedgerEntry."Document Type";
                                IPPFromBC."Document No." := VendorLedgerEntry."Document No.";
                                IPPFromBC.Description := VendorLedgerEntry.Description;
                                IPPFromBC."Bal. Account Type" := VendorLedgerEntry."Bal. Account Type";
                                IPPFromBC."Bal. Account No." := VendorLedgerEntry."Bal. Account No.";
                                IPPFromBC.Amount := DetailedVendorLed.Amount;
                                IPPFromBC."Dimension Set ID" := VendorLedgerEntry."Dimension Set ID";
                                IPPFromBC."Applies-to Doc. Type" := VendorLedgerEntry."Applies-to Doc. Type";
                                IPPFromBC."Applies-to Doc. No." := Format(DetailedVendorLed."CADBR Vend. Ledg. Document No.");
                                IPPFromBC."External Document No." := Format(DetailedVendorLed."CADBR Vend. Ledg. Document No."); //ajustar

                                IPPFromBC.Status := IPPFromBC.Status::Created;
                                if IPPFromBC.Insert then;

                                ExtDocumentNo := Format(DetailedVendorLed."CADBR Vend. Ledg. Document No.");
                                DocumentNo := VendorLedgerEntry."Document No.";
                                LineNo := VendorLedgerEntry."Entry No.";
                                EntryNo := DetailedVendorLed."Entry No.";
                                TotalAmount := DetailedVendorLed.Amount;

                            end else begin
                                IPPFromBC.Reset();
                                IPPFromBC.SetRange("External Document No.", ExtDocumentNo);
                                IPPFromBC.SetRange("Line No.", LineNo);
                                IPPFromBC.SetRange("Detail Ledger Entry No.", EntryNo);
                                IPPFromBC.SetRange("Document No.", DocumentNo);
                                if IPPFromBC.FindFirst() then begin
                                    IPPFromBC.Amount := TotalAmount + DetailedVendorLed.Amount;

                                    IPPFromBC.Modify(true);

                                    TotalAmount := TotalAmount + DetailedVendorLed.Amount;
                                end;

                            end;

                        end;

                    until DetailedVendorLed.Next() = 0;

            until VendorLedgerEntry.Next = 0;


        //Finance Charge Memo - Juros e Multa
        VendorLedgerEntry.Reset;
        VendorLedgerEntry.SetCurrentKey("Source Code");
        VendorLedgerEntry.SetRange("Source Code", 'CNABCP');
        VendorLedgerEntry.SetRange(Integrated, false);
        VendorLedgerEntry.SetRange("Document Type", VendorLedgerEntry."Document Type"::"Finance Charge Memo");
        if VendorLedgerEntry.FindSet then
            repeat

                DetailedVendorLed.Reset();
                DetailedVendorLed.SetRange("Document No.", VendorLedgerEntry."Document No.");
                DetailedVendorLed.SetRange("Document Type", VendorLedgerEntry."Document Type");
                DetailedVendorLed.SetRange("Entry Type", DetailedVendorLed."Entry Type"::Application);
                DetailedVendorLed.SetFilter(Amount, '>%1', 0);
                if DetailedVendorLed.FindSet() then
                    repeat
                        DetailedVendorLed.CalcFields("CADBR VendLedg. Ext. Doc. No.");
                        DetailedVendorLed.CalcFields("CADBR Vend. Ledg. Document No.");

                        if DetailedVendorLed."CADBR VendLedg. Ext. Doc. No." <> '' then begin

                            if ExtDocumentNo <> DetailedVendorLed."CADBR VendLedg. Ext. Doc. No." then begin

                                IPPFromBC.Init();
                                IPPFromBC."Journal Template Name" := VendorLedgerEntry."Journal Templ. Name";
                                IPPFromBC."Journal Batch Name" := VendorLedgerEntry."Journal Batch Name";
                                IPPFromBC."Line No." := VendorLedgerEntry."Entry No.";
                                IPPFromBC."Detail Ledger Entry No." := DetailedVendorLed."Entry No.";
                                IPPFromBC."Account Type" := IPPFromBC."Account Type"::Vendor;
                                IPPFromBC."Account No." := VendorLedgerEntry."Vendor No.";
                                IPPFromBC."Posting Date" := VendorLedgerEntry."Posting Date";
                                IPPFromBC."Document Type" := IPPFromBC."Document Type"::"Finance Charge Memo";
                                IPPFromBC."Document No." := VendorLedgerEntry."Document No.";
                                IPPFromBC.Description := VendorLedgerEntry.Description;
                                IPPFromBC."Bal. Account Type" := VendorLedgerEntry."Bal. Account Type";
                                IPPFromBC."Bal. Account No." := VendorLedgerEntry."Bal. Account No.";
                                IPPFromBC.Amount := DetailedVendorLed.Amount;

                                IPPFromBC."Dimension Set ID" := VendorLedgerEntry."Dimension Set ID";
                                IPPFromBC."Applies-to Doc. Type" := VendorLedgerEntry."Applies-to Doc. Type";
                                IPPFromBC."Applies-to Doc. No." := Format(DetailedVendorLed."CADBR Vend. Ledg. Document No.");
                                IPPFromBC."External Document No." := DetailedVendorLed."CADBR VendLedg. Ext. Doc. No."; //ajustar


                                IPPFromBC.Status := IPPFromBC.Status::Created;
                                if IPPFromBC.Insert then;

                                ExtDocumentNo := DetailedVendorLed."CADBR VendLedg. Ext. Doc. No.";
                                DocumentNo := VendorLedgerEntry."Document No.";
                                LineNo := VendorLedgerEntry."Entry No.";
                                EntryNo := DetailedVendorLed."Entry No.";
                                TotalAmount := DetailedVendorLed.Amount;

                            end else begin

                                IPPFromBC.Reset();
                                IPPFromBC.SetRange("External Document No.", ExtDocumentNo);
                                IPPFromBC.SetRange("Line No.", LineNo);
                                IPPFromBC.SetRange("Detail Ledger Entry No.", EntryNo);
                                IPPFromBC.SetRange("Document No.", DocumentNo);
                                if IPPFromBC.FindFirst() then begin
                                    IPPFromBC.Amount := TotalAmount + DetailedVendorLed.Amount;

                                    IPPFromBC.Modify(true);

                                    TotalAmount := TotalAmount + DetailedVendorLed.Amount;
                                end;

                            end;
                        end else begin

                            if ExtDocumentNo <> Format(DetailedVendorLed."CADBR Vend. Ledg. Document No.") then begin

                                IPPFromBC.Init();
                                IPPFromBC."Journal Template Name" := VendorLedgerEntry."Journal Templ. Name";
                                IPPFromBC."Journal Batch Name" := VendorLedgerEntry."Journal Batch Name";
                                IPPFromBC."Line No." := VendorLedgerEntry."Entry No.";
                                IPPFromBC."Detail Ledger Entry No." := DetailedVendorLed."Entry No.";
                                IPPFromBC."Account Type" := IPPFromBC."Account Type"::Vendor;
                                IPPFromBC."Account No." := VendorLedgerEntry."Vendor No.";
                                IPPFromBC."Posting Date" := VendorLedgerEntry."Posting Date";
                                IPPFromBC."Document Type" := IPPFromBC."Document Type"::"Finance Charge Memo";
                                IPPFromBC."Document No." := VendorLedgerEntry."Document No.";
                                IPPFromBC.Description := VendorLedgerEntry.Description;
                                IPPFromBC."Bal. Account Type" := VendorLedgerEntry."Bal. Account Type";
                                IPPFromBC."Bal. Account No." := VendorLedgerEntry."Bal. Account No.";
                                IPPFromBC.Amount := DetailedVendorLed.Amount;
                                IPPFromBC."Dimension Set ID" := VendorLedgerEntry."Dimension Set ID";
                                IPPFromBC."Applies-to Doc. Type" := VendorLedgerEntry."Applies-to Doc. Type";
                                IPPFromBC."Applies-to Doc. No." := Format(DetailedVendorLed."CADBR Vend. Ledg. Document No.");
                                IPPFromBC."External Document No." := Format(DetailedVendorLed."CADBR Vend. Ledg. Document No."); //ajustar
                                IPPFromBC.Status := IPPFromBC.Status::Created;

                                if IPPFromBC.Insert then;

                                ExtDocumentNo := Format(DetailedVendorLed."CADBR Vend. Ledg. Document No.");
                                DocumentNo := VendorLedgerEntry."Document No.";
                                LineNo := VendorLedgerEntry."Entry No.";
                                EntryNo := DetailedVendorLed."Entry No.";
                                TotalAmount := DetailedVendorLed.Amount;

                            end else begin

                                IPPFromBC.Reset();
                                IPPFromBC.SetRange("External Document No.", ExtDocumentNo);
                                IPPFromBC.SetRange("Line No.", LineNo);
                                IPPFromBC.SetRange("Detail Ledger Entry No.", EntryNo);
                                IPPFromBC.SetRange("Document No.", DocumentNo);
                                if IPPFromBC.FindFirst() then begin
                                    IPPFromBC.Amount := TotalAmount + DetailedVendorLed.Amount;

                                    IPPFromBC.Modify(true);

                                    TotalAmount := TotalAmount + DetailedVendorLed.Amount;
                                end;

                            end;

                        end;

                    until DetailedVendorLed.Next() = 0;

            until VendorLedgerEntry.Next = 0;

        //Desconto 
        VendorLedgerEntry.Reset;
        VendorLedgerEntry.SetCurrentKey("Source Code");
        VendorLedgerEntry.SetRange("Source Code", 'CNABCP');
        VendorLedgerEntry.SetRange(Integrated, false);
        VendorLedgerEntry.SetRange("Document Type", VendorLedgerEntry."Document Type"::" ");
        if VendorLedgerEntry.FindSet then
            repeat

                DetailedVendorLed.Reset();
                DetailedVendorLed.SetRange("Document No.", VendorLedgerEntry."Document No.");
                DetailedVendorLed.SetRange("Document Type", VendorLedgerEntry."Document Type");
                DetailedVendorLed.SetRange("Entry Type", DetailedVendorLed."Entry Type"::Application);
                DetailedVendorLed.SetFilter(Amount, '>%1', 0);
                if DetailedVendorLed.FindSet() then
                    repeat
                        DetailedVendorLed.CalcFields("CADBR VendLedg. Ext. Doc. No.");
                        DetailedVendorLed.CalcFields("CADBR Vend. Ledg. Document No.");

                        if DetailedVendorLed."CADBR VendLedg. Ext. Doc. No." <> '' then begin

                            if ExtDocumentNo <> DetailedVendorLed."CADBR VendLedg. Ext. Doc. No." then begin


                                IPPFromBC.Init();
                                IPPFromBC."Journal Template Name" := VendorLedgerEntry."Journal Templ. Name";
                                IPPFromBC."Journal Batch Name" := VendorLedgerEntry."Journal Batch Name";
                                IPPFromBC."Line No." := VendorLedgerEntry."Entry No.";
                                IPPFromBC."Detail Ledger Entry No." := DetailedVendorLed."Entry No.";
                                IPPFromBC."Account Type" := IPPFromBC."Account Type"::Vendor;
                                IPPFromBC."Account No." := VendorLedgerEntry."Vendor No.";
                                IPPFromBC."Posting Date" := VendorLedgerEntry."Posting Date";
                                IPPFromBC."Document Type" := IPPFromBC."Document Type"::" ";
                                IPPFromBC."Document No." := VendorLedgerEntry."Document No.";
                                IPPFromBC.Description := VendorLedgerEntry.Description;
                                IPPFromBC."Bal. Account Type" := VendorLedgerEntry."Bal. Account Type";
                                IPPFromBC."Bal. Account No." := VendorLedgerEntry."Bal. Account No.";
                                IPPFromBC.Amount := -DetailedVendorLed.Amount;
                                IPPFromBC."Dimension Set ID" := VendorLedgerEntry."Dimension Set ID";
                                IPPFromBC."Applies-to Doc. Type" := VendorLedgerEntry."Applies-to Doc. Type";
                                IPPFromBC."Applies-to Doc. No." := Format(DetailedVendorLed."CADBR Vend. Ledg. Document No.");
                                IPPFromBC."External Document No." := DetailedVendorLed."CADBR VendLedg. Ext. Doc. No."; //ajustar
                                IPPFromBC.Status := IPPFromBC.Status::Created;

                                if IPPFromBC.Insert then;

                                ExtDocumentNo := DetailedVendorLed."CADBR VendLedg. Ext. Doc. No.";
                                DocumentNo := VendorLedgerEntry."Document No.";
                                LineNo := VendorLedgerEntry."Entry No.";
                                EntryNo := DetailedVendorLed."Entry No.";
                                TotalAmount := -DetailedVendorLed.Amount;

                            end else begin

                                IPPFromBC.Reset();
                                IPPFromBC.SetRange("External Document No.", ExtDocumentNo);
                                IPPFromBC.SetRange("Line No.", LineNo);
                                IPPFromBC.SetRange("Detail Ledger Entry No.", EntryNo);
                                IPPFromBC.SetRange("Document No.", DocumentNo);
                                if IPPFromBC.FindFirst() then begin
                                    IPPFromBC.Amount := TotalAmount - DetailedVendorLed.Amount;

                                    IPPFromBC.Modify(true);

                                    TotalAmount := TotalAmount - DetailedVendorLed.Amount;
                                end;

                            end;
                        end else begin

                            if ExtDocumentNo <> Format(DetailedVendorLed."CADBR Vend. Ledg. Document No.") then begin

                                IPPFromBC.Init();
                                IPPFromBC."Journal Template Name" := VendorLedgerEntry."Journal Templ. Name";
                                IPPFromBC."Journal Batch Name" := VendorLedgerEntry."Journal Batch Name";
                                IPPFromBC."Line No." := VendorLedgerEntry."Entry No.";
                                IPPFromBC."Detail Ledger Entry No." := DetailedVendorLed."Entry No.";
                                IPPFromBC."Account Type" := IPPFromBC."Account Type"::Vendor;
                                IPPFromBC."Account No." := VendorLedgerEntry."Vendor No.";
                                IPPFromBC."Posting Date" := VendorLedgerEntry."Posting Date";
                                IPPFromBC."Document Type" := IPPFromBC."Document Type"::" ";
                                IPPFromBC."Document No." := VendorLedgerEntry."Document No.";
                                IPPFromBC.Description := VendorLedgerEntry.Description;
                                IPPFromBC."Bal. Account Type" := VendorLedgerEntry."Bal. Account Type";
                                IPPFromBC."Bal. Account No." := VendorLedgerEntry."Bal. Account No.";
                                IPPFromBC.Amount := -DetailedVendorLed.Amount;
                                IPPFromBC."Dimension Set ID" := VendorLedgerEntry."Dimension Set ID";
                                IPPFromBC."Applies-to Doc. Type" := VendorLedgerEntry."Applies-to Doc. Type";
                                IPPFromBC."Applies-to Doc. No." := Format(DetailedVendorLed."CADBR Vend. Ledg. Document No.");
                                IPPFromBC."External Document No." := Format(DetailedVendorLed."CADBR Vend. Ledg. Document No."); //ajustar
                                IPPFromBC.Status := IPPFromBC.Status::Created;

                                if IPPFromBC.Insert then;

                                ExtDocumentNo := Format(DetailedVendorLed."CADBR Vend. Ledg. Document No.");
                                DocumentNo := VendorLedgerEntry."Document No.";
                                LineNo := VendorLedgerEntry."Entry No.";
                                EntryNo := DetailedVendorLed."Entry No.";
                                TotalAmount := -DetailedVendorLed.Amount;

                            end else begin
                                IPPFromBC.Reset();
                                IPPFromBC.SetRange("External Document No.", ExtDocumentNo);
                                IPPFromBC.SetRange("Line No.", LineNo);
                                IPPFromBC.SetRange("Detail Ledger Entry No.", EntryNo);
                                IPPFromBC.SetRange("Document No.", DocumentNo);
                                if IPPFromBC.FindFirst() then begin
                                    IPPFromBC.Amount := TotalAmount - DetailedVendorLed.Amount;

                                    IPPFromBC.Modify(true);

                                    TotalAmount := TotalAmount - DetailedVendorLed.Amount;
                                end;

                            end;

                        end;

                    until DetailedVendorLed.Next() = 0;

            until VendorLedgerEntry.Next = 0;

    end;

    procedure ExportExcelIntPurchPaymentsFromBC()
    var
        FTPIntSetup: Record "FTP Integration Setup";
        OutStr: OutStream;
        InSTR: InStream;
        FTPCommunication: codeunit "FTP Communication";
        Base64: codeunit "Base64 Convert";
        TempBlob: codeunit "Temp Blob";
        FileBase64: Text;
        PathToFile: Text;
        FileName: Text;
        TempExcelBuffer: Record "Excel Buffer" temporary;
        IntPurchPaymentsFromBC: Record IntPurchPaymentsFromBC;
        VendorLedgerEntry: Record "Vendor Ledger Entry";
    begin

        TempExcelBuffer.Reset();
        TempExcelBuffer.DeleteAll();

        SearchDimValues();
        Commit();

        IntPurchPaymentsFromBC.SetRange(Status, IntPurchPaymentsFromBC.Status::Created);
        IF IntPurchPaymentsFromBC.FindSet() then begin
            if IntPurchPaymentsFromBC.Findfirst() then begin

                FileName := 'PaymentsFromBC' + DelChr(Format(Today) + Format(Time), '=', '/:') + '.xlsx';

                TempExcelBuffer.NewRow();
                TempExcelBuffer.AddColumn(IntPurchPaymentsFromBC.FieldCaption("Journal Template Name"), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(IntPurchPaymentsFromBC.FieldCaption("Journal Batch Name"), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(IntPurchPaymentsFromBC.FieldCaption("Line No."), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(IntPurchPaymentsFromBC.FieldCaption("Account Type"), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(IntPurchPaymentsFromBC.FieldCaption("Account No."), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(IntPurchPaymentsFromBC.FieldCaption("Posting Date"), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(IntPurchPaymentsFromBC.FieldCaption("Document Type"), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(IntPurchPaymentsFromBC.FieldCaption("Document No."), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(IntPurchPaymentsFromBC.FieldCaption(Description), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(IntPurchPaymentsFromBC.FieldCaption("Bal. Account Type"), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(IntPurchPaymentsFromBC.FieldCaption("Bal. Account No."), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(IntPurchPaymentsFromBC.FieldCaption(Amount), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(IntPurchPaymentsFromBC.FieldCaption(WiteOffAmount), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(IntPurchPaymentsFromBC.FieldCaption("Dimension 1"), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(IntPurchPaymentsFromBC.FieldCaption("Dimension 2"), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(IntPurchPaymentsFromBC.FieldCaption("Dimension 3"), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(IntPurchPaymentsFromBC.FieldCaption("Dimension 4"), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(IntPurchPaymentsFromBC.FieldCaption("Dimension 5"), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(IntPurchPaymentsFromBC.FieldCaption("Dimension 6"), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(IntPurchPaymentsFromBC.FieldCaption("Dimension 7"), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(IntPurchPaymentsFromBC.FieldCaption("Dimension 8"), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(IntPurchPaymentsFromBC.FieldCaption("Applies-to Doc. Type"), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(IntPurchPaymentsFromBC.FieldCaption("Applies-to Doc. No."), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(IntPurchPaymentsFromBC.FieldCaption("External Document No."), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                repeat
                    TempExcelBuffer.NewRow();
                    TempExcelBuffer.AddColumn(IntPurchPaymentsFromBC."Journal Template Name", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                    TempExcelBuffer.AddColumn(IntPurchPaymentsFromBC."Journal Batch Name", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                    TempExcelBuffer.AddColumn(IntPurchPaymentsFromBC."Line No.", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);
                    TempExcelBuffer.AddColumn(Format(IntPurchPaymentsFromBC."Account Type"), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                    TempExcelBuffer.AddColumn(IntPurchPaymentsFromBC."Account No.", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                    TempExcelBuffer.AddColumn(IntPurchPaymentsFromBC."Posting Date", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Date);
                    TempExcelBuffer.AddColumn(Format(IntPurchPaymentsFromBC."Document Type"), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                    TempExcelBuffer.AddColumn(IntPurchPaymentsFromBC."Document No.", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                    TempExcelBuffer.AddColumn(IntPurchPaymentsFromBC.Description, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                    TempExcelBuffer.AddColumn(Format(IntPurchPaymentsFromBC."Bal. Account Type"), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                    TempExcelBuffer.AddColumn(IntPurchPaymentsFromBC."Bal. Account No.", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                    TempExcelBuffer.AddColumn(IntPurchPaymentsFromBC.Amount, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);
                    TempExcelBuffer.AddColumn(IntPurchPaymentsFromBC.WiteOffAmount, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);
                    TempExcelBuffer.AddColumn(IntPurchPaymentsFromBC."Dimension 1", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                    TempExcelBuffer.AddColumn(IntPurchPaymentsFromBC."Dimension 2", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                    TempExcelBuffer.AddColumn(IntPurchPaymentsFromBC."Dimension 3", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                    TempExcelBuffer.AddColumn(IntPurchPaymentsFromBC."Dimension 4", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                    TempExcelBuffer.AddColumn(IntPurchPaymentsFromBC."Dimension 5", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                    TempExcelBuffer.AddColumn(IntPurchPaymentsFromBC."Dimension 6", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                    TempExcelBuffer.AddColumn(IntPurchPaymentsFromBC."Dimension 7", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                    TempExcelBuffer.AddColumn(IntPurchPaymentsFromBC."Dimension 8", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                    TempExcelBuffer.AddColumn(Format(IntPurchPaymentsFromBC."Applies-to Doc. Type"), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                    TempExcelBuffer.AddColumn(IntPurchPaymentsFromBC."Applies-to Doc. No.", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                    TempExcelBuffer.AddColumn(IntPurchPaymentsFromBC."External Document No.", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);

                    IntPurchPaymentsFromBC.Status := IntPurchPaymentsFromBC.Status::Exported;
                    IntPurchPaymentsFromBC."Excel Export File Name" := FileName;

                    IntPurchPaymentsFromBC.Modify();

                    VendorLedgerEntry.get(IntPurchPaymentsFromBC."Line No.");
                    VendorLedgerEntry.Integrated := true;
                    VendorLedgerEntry.Modify;

                until IntPurchPaymentsFromBC.Next() = 0;

                TempExcelBuffer.CreateNewBook(IntPurchPaymentsFromBC.TableCaption);
                TempExcelBuffer.WriteSheet(IntPurchPaymentsFromBC.TableCaption, CompanyName, UserId);
                TempExcelBuffer.CloseBook();

                TempBlob.CreateOutStream(OutStr);
                TempExcelBuffer.SaveToStream(OutStr, true);

                TempBlob.CreateInStream(InSTR);

                FileBase64 := Base64.ToBase64(InSTR);
                //FTPIntSetup.Get(FTPIntSetup.Integration::"Payments From BC");
                FTPIntSetup.Reset();
                FTPIntSetup.SetRange(Integration, FTPIntSetup.Integration::"Payments From BC");
                FTPIntSetup.SetRange(Sequence, 0);
                FTPIntSetup.FindSet();

                FTPCommunication.DoAction(Enum::"FTP Actions"::upload, FileName, FTPIntSetup.Directory, '', FileBase64);
                Message('Uploaded');

            end;
        end;

    end;

    local procedure SearchDimValues()
    var
        DimValue: array[8] of Code[20];
        IntPurchPaymentsFromBC: Record IntPurchPaymentsFromBC;
    begin

        IntPurchPaymentsFromBC.SetRange(Status, IntPurchPaymentsFromBC.Status::Created);
        if IntPurchPaymentsFromBC.findset() then
            repeat
                clear(DimValue);
                GetDimensions(IntPurchPaymentsFromBC."Dimension Set ID", DimValue);
                IntPurchPaymentsFromBC."Dimension 1" := DimValue[1];
                IntPurchPaymentsFromBC."Dimension 2" := DimValue[2];
                IntPurchPaymentsFromBC."Dimension 3" := DimValue[3];
                IntPurchPaymentsFromBC."Dimension 4" := DimValue[4];
                IntPurchPaymentsFromBC."Dimension 5" := DimValue[5];
                IntPurchPaymentsFromBC."Dimension 6" := DimValue[6];
                IntPurchPaymentsFromBC."Dimension 7" := DimValue[7];
                IntPurchPaymentsFromBC."Dimension 8" := DimValue[8];
                IntPurchPaymentsFromBC.Modify();
            until IntPurchPaymentsFromBC.next() = 0;
    end;

    procedure GetDimensions(DimSetID: Integer; var DimValue: array[8] of Code[20])
    var
        DimSetEntry: Record "Dimension Set Entry" temporary;
        DimMngt: Codeunit DimensionManagement;
        DimCode: array[8] of Code[20];
        i: Integer;
    begin
        DimMngt.GetGLSetup(DimCode);
        DimMngt.GetDimensionSet(DimSetEntry, DimSetID);

        for i := 1 to ArrayLen(DimCode) do begin
            GetDimValues(DimCode[i], DimValue[i], DimSetEntry)
        end;

    end;

    procedure GetDimValues(DimCode: Code[20]; var DimValue: Code[20]; var DimSetEntry: Record "Dimension Set Entry" temporary)
    begin
        DimSetEntry.SetRange("Dimension Code", DimCode);
        if DimSetEntry.FindSet() then
            DimValue := DimSetEntry."Dimension Value Code"
        else
            DimValue := '';
    end;
}