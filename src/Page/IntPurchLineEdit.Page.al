page 50027 PurchLineEdit
{
    ApplicationArea = ALL;
    Caption = 'PurchLineEdit';
    PageType = List;
    SourceTable = "Purch. Inv. Line";
    UsageCategory = Tasks;
    DeleteAllowed = false;
    Editable = true;
    InsertAllowed = false;
    ModifyAllowed = true;
    ShowFilter = false;
    Permissions = tabledata "Purch. Inv. Header" = RIMD,
                  tabledata "Purch. Inv. Line" = RIMD,
                  tabledata "VAT Entry" = RIMD;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Document No."; Rec."Document No.")
                {
                    ToolTip = 'Specifies the number of the invoice that this line belongs to.';
                    Editable = false;
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ToolTip = 'Posting Date';
                    Editable = false;
                }
                field("No."; Rec."No.")
                {
                    ToolTip = 'Specifies the number of the involved entry or record, according to the specified number series.';
                    Editable = false;
                }
                field("Line No."; Rec."Line No.")
                {
                    ToolTip = 'Specifies the value of the Line No. field.';
                    Editable = false;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies either the name of, or a description of, the item or general ledger account.';
                    Editable = false;
                }
                field("CADBR Service Code"; Rec."CADBR Service Code")
                {
                    ToolTip = 'CADBR Service Code';
                    Editable = false;
                }
                field(NewServiceCode; rec."New Service Code")
                {
                    ToolTip = 'Novo Service Code';
                    Caption = 'Novo Service Code';

                }
                field("Município Prestação Serviço"; Rec."Município Prestação Serviço")
                {
                    ToolTip = 'Município Prestação Serviço';
                    Editable = false;
                }
                field("New Municipio"; Rec."New Municipio")
                {
                    ToolTip = 'Novo Município Prestação Serviço';

                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(UpdateData)
            {
                ApplicationArea = All;
                Caption = 'Update Data';
                Image = UpdateDescription;
                ToolTip = 'Update Data';

                trigger OnAction();
                var
                    PurchHeader: Record "Purch. Inv. Header";
                    UpdatePurchLine: Page PurchLineEdit;
                    PurchLine: Record "Purch. Inv. Line";
                    VatEntry: Record "VAT Entry";
                begin
                    CurrPage.SetSelectionFilter(PurchLine);
                    PurchLine.CopyFilters(Rec);

                    if PurchLine.FindSet() then
                        repeat
                            PurchHeader.get(PurchLine."Document No.");
                            if PurchLine."New Municipio" <> '' then begin
                                PurchHeader."CADBR Service Delivery City" := PurchLine."New Municipio";
                                PurchHeader.Modify();
                            end;

                            if PurchLine."New Service Code" <> '' then begin
                                PurchLine."CADBR Service Code" := PurchLine."New Service Code";
                                PurchLine.Modify();

                                VatEntry.Reset();
                                VatEntry.SetCurrentKey("Document No.", "Posting Date");
                                VatEntry.SetRange("Document No.", PurchLine."Document No.");
                                VatEntry.SetRange("CADBR Invoice Line No.", PurchLine."Line No.");
                                if VatEntry.FindSet() then
                                    repeat
                                        VatEntry."CADBR Service Code" := PurchLine."New Service Code";
                                        VatEntry.Modify();
                                    until VatEntry.Next() = 0;
                            end;

                            PurchLine."New Service Code" := '';
                            PurchLine."New Municipio" := '';
                            PurchLine.Modify();

                        until PurchLine.Next() = 0;

                    //CurrPage.SaveRecord();
                    //CurrPage.Update();
                    Message('Updated');
                end;
            }
        }
    }

    var

}
