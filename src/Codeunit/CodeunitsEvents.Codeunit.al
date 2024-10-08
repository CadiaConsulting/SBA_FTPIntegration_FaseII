codeunit 50017 "Codeunits Events"
{
    trigger OnRun()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnBeforeInsertGLEntryBuffer', '', false, false)]
    local procedure Codeunit_12_OnBeforeInsertGLEntryBuffer(var TempGLEntryBuf: Record "G/L Entry" temporary; var GenJournalLine: Record "Gen. Journal Line"; var BalanceCheckAmount: Decimal; var BalanceCheckAmount2: Decimal; var BalanceCheckAddCurrAmount: Decimal; var BalanceCheckAddCurrAmount2: Decimal; var NextEntryNo: Integer)
    begin
        if GenJournalLine."Applies-to Doc. Type" <> GenJournalLine."Applies-to Doc. Type"::" " then
            TempGLEntryBuf."Applies-to Doc. Type" := GenJournalLine."Applies-to Doc. Type"
        else
            TempGLEntryBuf."Applies-to Doc. Type" := GenJournalLine."CADBR Tax Applies-to Doc. Type";
        if GenJournalLine."Applies-to Doc. No." <> '' then
            TempGLEntryBuf."Applies-to Doc. No." := GenJournalLine."Applies-to Doc. No."
        else
            TempGLEntryBuf."Applies-to Doc. No." := GenJournalLine."CADBR Tax Applies-to Doc. No.";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Copy Document Mgt.", 'OnAfterCopyPurchLinesToBufferFields', '', false, false)]
    local procedure Codeunit_6620_OnAfterCopyPurchLinesToBufferFields(var TempPurchaseLine: Record "Purchase Line" temporary; FromPurchaseLine: Record "Purchase Line"; FromPurchLine: Record "Purchase Line"; ToPurchHeader: Record "Purchase Header")
    begin
        TempPurchaseLine."Line No." := FromPurchLine."Line No.";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Copy Document Mgt.", 'OnCopyPurchDocLineOnAfterSetNextLineNo', '', false, false)]
    local procedure Codeunit_6620_OnCopyPurchDocLineOnAfterSetNextLineNo(var ToPurchLine: Record "Purchase Line"; var FromPurchLine: Record "Purchase Line"; var NextLineNo: Integer);
    begin
        NextLineNo := FromPurchLine."Line No.";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Copy Document Mgt.", 'OnAfterCopySalesLinesToBufferFields', '', false, false)]
    local procedure Codeunit_6620_OnAfterCopySalesLinesToBufferFields(var TempSalesLine: Record "Sales Line" temporary; FromSalesLineParam: Record "Sales Line"; FromSalesLine: Record "Sales Line")
    begin
        TempSalesLine."Line No." := FromSalesLineParam."Line No.";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Copy Document Mgt.", 'OnBeforeUpdateSalesLine', '', false, false)]
    local procedure Codeunit_6620_OnBeforeUpdateSalesLine(var ToSalesHeader: Record "Sales Header"; var ToSalesLine: Record "Sales Line"; var FromSalesHeader: Record "Sales Header"; var FromSalesLine: Record "Sales Line"; var CopyThisLine: Boolean; RecalculateAmount: Boolean; FromSalesDocType: Option; var CopyPostedDeferral: Boolean)
    begin
        ToSalesLine."Line No." := FromSalesLine."Line No.";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"CADBR Fiscal Books Mgt", 'OnBeforeParticipantAdd', '', false, false)]
    local procedure Codeunit_52006600_OnBeforeParticipantAdd(var Doc: Record "CADBR Settlement Document"; CreateParticipant: Boolean; ParticipantIncome: Boolean; var IsHandled: Boolean);
    var
        Participant: Record "CADBR EFD Participant";
    begin
        IsHandled := true;

        if (doc."Participant No." <> '') and CreateParticipant then begin
            doc."Participant No." := DelChr(doc."C.N.P.J.", '=', './-');
            doc.Modify();
            participant.SBA_Add(doc."Tax Settlement No.", doc."Company ID", DelChr(doc."C.N.P.J.", '=', './-'), doc."C.N.P.J.",
             doc."Customer/Vendor" = doc."customer/vendor"::Customer, ParticipantIncome);
            IsHandled := true;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"CADBR Sales-Post NAVBR", 'OnAfterCopyToVATEntry', '', false, false)]
    local procedure Codeunit_52006570_OnAfterCopyToVATEntry(var VATEntry: Record "VAT Entry"; SalesLine: Record "Sales Line"; GLAccountType: Integer; GLAccount: Code[20]);
    var
        Customer: Record Customer;
        CustomerPostinGroup: Record "Customer Posting Group";
    begin
        if GLAccountType = 2 then begin
            if Customer.get(GLAccount) then
                if CustomerPostinGroup.get(Customer."Customer Posting Group") then
                    VATEntry."GL Account Related" := CustomerPostinGroup."Receivables Account";
        end else
            VATEntry."GL Account Related" := GLAccount;
        VATEntry."Base Calculation Credit Code" := SalesLine."CADBR Base Calc. Credit Code";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"CADBR Fiscal Books Mgt", 'OnBeforeCustomerGet', '', false, false)]
    local procedure Codeunit_52006600_OnBeforeCustomerGet(CNPJ: Code[20]; var IsHandled: Boolean);
    var
        Customer: Record Customer;
    begin
        IsHandled := True;
        Customer.Reset;
        Customer.Setrange("CADBR C.N.P.J./C.P.F.", CNPJ);
        Customer.Findfirst;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"CADBR Fiscal Books Mgt", 'OnBeforeParticipantF100Add', '', false, false)]
    local procedure Codeunit_52006600_OnBeforeParticipantF100Add(var efdF100: Record "CADBR EFD F100 New"; CompanyID: text[30]; var IsHandled: Boolean);
    var
        Participant: Record "CADBR EFD Participant";
        CNPJCPF: Code[20];
        Vendor: Record Vendor;
        Customer: Record Customer;
    begin
        if (efdF100."Partner Type" <> efdF100."partner type"::" ") and (efdF100."Partner Code" <> '') then begin
            CNPJCPF := efdF100."Partner Code";
            if StrLen(cnpjcpf) = 11 then
                cnpjcpf := CopyStr(cnpjcpf, 1, 3) + '.' + CopyStr(cnpjcpf, 4, 3) + '.' + CopyStr(cnpjcpf, 7, 3) + '-' + CopyStr(cnpjcpf, 10, 2)
            else
                cnpjcpf := CopyStr(cnpjcpf, 1, 2) + '.' + CopyStr(cnpjcpf, 3, 3) + '.' + CopyStr(cnpjcpf, 6, 3) + '/' +
                           CopyStr(cnpjcpf, 9, 4) + '-' + CopyStr(cnpjcpf, 13, 2);

            // if efdF100."Partner type" = efdF100."Partner Type"::Vendor then begin
            //     Vendor.Reset;
            //     Vendor.Setfilter("CADBR C.N.P.J./C.P.F.", CNPJCPF);
            //     Vendor.Findfirst;

            Participant.SBA_Add(efdF100."Tax Settlement No.", CompanyID, efdf100."Partner Code", CNPJCPF,
                    efdF100."Partner Type" = efdf100."partner type"::Customer, false);

            IsHandled := true;
        end;
    END;

    //[EventSubscriber(ObjectType::Codeunit, Codeunit::"CADBR Fiscal Books Mgt", 'OnAfterCreateRegisterContribF100', '', false, false)]
    // local procedure Codeunit_52006600_OnAfterCreateRegisterContribF100(var TaxSettlement: Code[20]);
    // var
    //     Doc: Record "CADBR Settlement Document";
    //     DocLine: Record "CADBR Settlement Document Line";
    //     F100: Record "CADBR EFD F100";
    //     F100New: Record "CADBR EFD F100 NEW";
    //     CreateRegister: Codeunit CreateRegisterContribF100;
    // begin
    //     Doc.reset;
    //     Doc.SetRange("Tax Settlement No.", TaxSettlement);
    //     doc.SetRange("Document Issuer", doc."Document Issuer"::"No Fiscal Value");
    //     Doc.SetRange(Service, true);

    //     f100.Reset;
    //     f100.SetRange("Tax Settlement No.", TaxSettlement);
    //     if not f100.IsEmpty then
    //         f100.DeleteAll();

    //     F100New.Reset;
    //     F100New.SetRange("Tax Settlement No.", TaxSettlement);
    //     if not F100New.IsEmpty then
    //         F100New.DeleteAll();


    //     if Doc.FindFirst then
    //         repeat
    //             if not Doc.Cancelled then begin
    //                 DocLine.Reset;
    //                 DocLine.SetRange("Tax Settlement No.", TaxSettlement);
    //                 DocLine.SetRange("Document ID", Doc."Document ID");
    //                 if DocLine.FindFirst then
    //                     repeat
    //                         CreateRegister.InsertF100(doc, docline);
    //                     until DocLine.Next = 0;
    //             end;
    //         until doc.Next = 0;
    // end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"CADBR Fiscal Books Mgt", 'OnBeforeVendorGet', '', false, false)]
    local procedure Codeunit_52006600_OnBeforeVendorGet(CNPJ: Code[20]; var IsHandled: Boolean);
    var
        Vendor: Record Vendor;
    begin
        IsHandled := True;
        Vendor.Reset;
        Vendor.Setrange("CADBR C.N.P.J./C.P.F.", CNPJ);
        Vendor.Findfirst;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"CADBR REINF Process", 'OnBeforeFilterGroupDate', '', false, false)]
    local procedure Codeunit_52006970_OnBeforeFilterGroupDate(var GroupDate: Record "CADBR REINF4000 GroupDate"; VendorNo: Code[20]; var IsHandled: Boolean);
    var
        Vendor: Record Vendor;
    begin
        IsHandled := true;

        if Vendor.get(VendorNo) then
            if Vendor."CADBR Category" = Vendor."CADBR Category"::"3.- Foreign" then
                GroupDate.SETRANGE("Vendor No.", VendorNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnLookUpAppliesToDocVendOnAfterUpdateDocumentTypeAndAppliesTo', '', false, false)]
    local procedure OnLookUpAppliesToDocVendOnAfterUpdateDocumentTypeAndAppliesTo(var GenJournalLine: Record "Gen. Journal Line"; VendorLedgerEntry: Record "Vendor Ledger Entry");
    begin
        GenJournalLine."External Document No." := VendorLedgerEntry."External Document No.";

    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnBeforeOnDelete', '', false, false)]
    local procedure PurcHeaderOnBeforeOnDelete(var PurchaseHeader: Record "Purchase Header");
    var
        intPur: Record "Integration Purchase";
    begin

        PurchaseHeader."Posting No." := '';

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Release Purchase Document", 'OnAfterManualReopenPurchaseDoc', '', false, false)]
    local procedure ReleasePurcDoc_OnAfterManualReopenPurchaseDoc(var PurchaseHeader: Record "Purchase Header");
    var
        intPurch: Record "Integration Purchase";
        UserSetup: Record "User Setup";
    begin

        UserSetup.Reset();
        UserSetup.Get(USERID);
        if not UserSetup."Open PO" then
            error('Usuario %1 sem Permissão para Reabrir o Pedido', USERID);

        intPurch.Reset();
        intPurch.SetRange("Document No.", PurchaseHeader."No.");
        if intPurch.Find('-') then
            intPurch.ModifyAll(Status, intPurch.Status::Created);

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Check Line", 'OnBeforeRunCheck', '', false, false)]
    local procedure GenJnlCheckLine_OnBeforeRunCheck(var GenJournalLine: Record "Gen. Journal Line");
    var
        VendorLedEntry: Record "Vendor Ledger Entry";
        Text50005: Label 'Document No. %1 já existe para o Fornecedor %2.';
        Text50006: Label 'External Document No. %1 já existe para o Fornecedor %2.';
    begin

        if GenJournalLine.EmptyLine() then
            exit;

        if GenJournalLine."Journal Template Name" = 'PURCHASES' then begin

            GenJournalLine.TestField("External Document No.", ErrorInfo.Create());

            if GenJournalLine."Document No." <> '' then begin

                VendorLedEntry.Reset();
                VendorLedEntry.SetRange("Vendor No.", GenJournalLine."Account No.");
                VendorLedEntry.SetRange("Document No.", GenJournalLine."Document No.");
                if VendorLedEntry.FindFirst() then
                    Error(
                        ErrorInfo.Create(StrSubstNo(Text50005, GenJournalLine."Document No.", GenJournalLine."Account No.")));

                VendorLedEntry.Reset();
                VendorLedEntry.SetRange("Vendor No.", GenJournalLine."Account No.");
                VendorLedEntry.SetRange("External Document No.", GenJournalLine."External Document No.");
                if VendorLedEntry.FindFirst() then
                    Error(
                        ErrorInfo.Create(StrSubstNo(Text50006, GenJournalLine."External Document No.", GenJournalLine."Account No.")));

            end;
        end;

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Release Purchase Document", 'OnAfterReleasePurchaseDoc', '', false, false)]
    local procedure Codeunit_414_OnAfterReleaseSalesDoc(var PurchaseHeader: Record "Purchase Header"; PreviewMode: Boolean; var LinesWereModified: Boolean)
    var
        PurchLine: Record "Purchase Line";
    begin

        if PurchaseHeader.Status = PurchaseHeader.Status::Released then begin
            PurchLine.Reset;
            PurchLine.SetRange("Document Type", PurchaseHeader."Document Type");
            PurchLine.SetRange("Document No.", PurchaseHeader."No.");
            PurchLine.SetFilter(Type, '<>%1', PurchLine.Type::" ");
            PurchLine.ModifyAll("Status SBA", PurchLine."Status SBA"::Released);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Release Purchase Document", 'OnAfterReopenPurchaseDoc', '', false, false)]
    local procedure Codeunit_411_OnAfterReopenSalesDoc(var PurchaseHeader: Record "Purchase Header"; PreviewMode: Boolean)
    var
        PurchLine: Record "Purchase Line";
    begin

        if PurchaseHeader.Status = PurchaseHeader.Status::Open then begin
            PurchLine.Reset;
            PurchLine.SetRange("Document Type", PurchaseHeader."Document Type");
            PurchLine.SetRange("Document No.", PurchaseHeader."No.");
            PurchLine.SetFilter(Type, '<>%1', PurchLine.Type::" ");
            PurchLine.ModifyAll("Status SBA", PurchLine."Status SBA"::Open);
        end;
    end;

}