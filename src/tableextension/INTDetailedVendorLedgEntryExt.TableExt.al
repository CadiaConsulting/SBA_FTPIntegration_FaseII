tableextension 50004 "INTDetailedVendorLedgEntryExt" extends "Detailed Vendor Ledg. Entry"
{
    fields
    {
        field(50000; Integrated; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Integrated';
        }
    }
    keys
    {
        key(ExtKey1; "Vendor Ledger Entry No.", "Entry Type", Unapplied)
        {

        }
    }
}
