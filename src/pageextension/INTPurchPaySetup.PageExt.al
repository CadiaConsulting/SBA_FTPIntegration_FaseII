pageextension 50006 INTPurchPaySetup extends "Purchases & Payables Setup"
{
    layout
    {

        addbefore("Disable Search by Name")
        {

            field("Activate Auxiliary Taxes"; rec."Activate Auxiliary Taxes")
            {
                ApplicationArea = All;
                ToolTip = 'Activate Auxiliary Taxes';
            }

        }

        // Add changes to page layout here
        addafter("Default Accounts")
        {


            group(Landlord)


            {
                Caption = 'Landlord Import';

                field("Item Serv. Landlord"; rec."Item Serv. Landlord")
                {
                    Caption = 'Item Serv. Landlord';
                    ApplicationArea = all;
                    ToolTip = 'Item Serv. Landlord';
                }
            }
        }
    }
}

