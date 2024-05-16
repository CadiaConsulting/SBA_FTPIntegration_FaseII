page 50001 "FTP Directory"
{
    Caption = 'FTP Directory';
    PageType = ListPart;
    SourceTable = "FTP Directory";
    //Editable = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(IsDirectory; Rec.IsDirectory)
                {
                    ApplicationArea = All;
                }
                field(Filename; Rec.Filename)
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    // trigger OnOpenPage()
    // var
    //     glEntry: Record "G/L Entry";
    //     CreationDate: Date;
    // begin

    //     CreationDate := DMY2Date(28, 6, 2022);

    //     glEntry.Reset();
    //     glEntry.SetRange(glEntry.SystemCreatedAt, CreateDateTime(CreationDate, 0T), CreateDateTime(CreationDate, 235959T));
    //     glEntry.FindFirst();
    //     Message(format(glEntry.Count));

    // end;
}
