codeunit 50077 "Hold Vendor Apply Entries"
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

    // [EventSubscriber(ObjectType::Codeunit, Codeunit::"VendEntry-Apply Posted Entries", 'OnApplyVendEntryFormEntryOnBeforeRunVendEntryEdit', '', false, false)]
    // local procedure OnApplyCustEntryFormEntryOnBeforeRunCustEntryEdit_CodeunitCustEntryApplyPostedEntries(var ApplyingVendLedgEntry: Record "Vendor Ledger Entry")
    // begin
    //     ApplyingVendLedgEntry."Amount to Apply" := -1 * AmountToAplly; //* (abs(ApplyingVendLedgEntry."Amount to Apply") / ApplyingVendLedgEntry."Amount to Apply");
    // end;
}
