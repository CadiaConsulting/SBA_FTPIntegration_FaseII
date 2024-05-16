tableextension 50015 "INTVendorLedgerEntryExt" extends "Vendor Ledger Entry"
{
    fields
    {
        field(50000; Integrated; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Integrated';
        }
        field(50001; "Service Delivery City"; Code[7])
        {
            DataClassification = ToBeClassified;
            Caption = 'Service Delivery City';
            TableRelation = "CADBR Municipio";
        }
        field(50002; "SBA Applies-to Doc. No."; Code[20])
        {
            Caption = 'Applies-to Doc. No.';
        }
    }
    keys
    {
        key(ExtKey1; "Vendor No.", "Document Type", "Document No.", Open)
        {

        }
        key(ExtKey2; "Source Code")
        {
        }
    }
}