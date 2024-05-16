codeunit 50006 "Hold Apply Entries"
{
    SingleInstance = true;

    var
        Active: Boolean;
        ApplyIntegration: Boolean;
        AmountToAplly: Decimal;

    procedure SetActive(_active: Boolean)
    begin
        Active := _active;
    end;

    procedure IsActive(): Boolean
    begin
        exit(Active);
    end;

    procedure SetApplyIntegration(_ApplyIntegration: Boolean; ApplyAmount: Decimal)
    begin
        ApplyIntegration := _ApplyIntegration;
        AmountToAplly := ApplyAmount;
    end;

    procedure IsApplyIntegration(): Boolean
    begin
        exit(ApplyIntegration);
    end;

    // [EventSubscriber(ObjectType::Codeunit, Codeunit::"CustEntry-Apply Posted Entries", 'OnApplyCustEntryFormEntryOnBeforeRunCustEntryEdit', '', false, false)]
    // local procedure OnApplyCustEntryFormEntryOnBeforeRunCustEntryEdit_CodeunitCustEntryApplyPostedEntries(var ApplyingCustLedgEntry: Record "Cust. Ledger Entry")
    // begin
    //     ApplyingCustLedgEntry."Amount to Apply" := AmountToAplly * (abs(ApplyingCustLedgEntry."Amount to Apply") / ApplyingCustLedgEntry."Amount to Apply");
    // end;
}
