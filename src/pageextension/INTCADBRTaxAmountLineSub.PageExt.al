pageextension 50024 "INTCADBRTaxAmountLineSub" extends "CADBR Tax Amount Line Subform"
{

    trigger OnAfterGetRecord()
    var
        ModTaxAmountLine: Record "CADBR Modified Tax Amount Line";
    begin

        if ModTaxAmountLine.Get(39, ModTaxAmountLine."Document Type"::Order,
                rec."Document No.", rec."Document Line No.", Rec."Tax Area Code",
                    rec."Tax Jurisdiction Code") then
            rec."Payment/Receipt Amount" := ModTaxAmountLine."Payment/Receipt Amount";
    end;

    trigger OnModifyRecord(): Boolean
    var
        ModTaxAmountLine: Record "CADBR Modified Tax Amount Line";
    begin

        if ModTaxAmountLine.Get(39, ModTaxAmountLine."Document Type"::Order,
                rec."Document No.", rec."Document Line No.", Rec."Tax Area Code",
                    rec."Tax Jurisdiction Code") then begin
            ModTaxAmountLine."Payment/Receipt Amount" := Rec."Payment/Receipt Amount";
            ModTaxAmountLine.Modify();
        end;
    end;

}
