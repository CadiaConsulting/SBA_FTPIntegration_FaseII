enum 50001 "FTP Actions"
{
    Extensible = true;
    
    value(0; "list")
    {
        Caption = 'list';
    }
    value(1; download)
    {
        Caption = 'download';
    }
    value(2; upload)
    {
        Caption = 'upload';
    }
    value(3; delete)
    {
        Caption = 'delete';
    }
    value(4; rename)
    {
        Caption = 'rename';
    }
}
