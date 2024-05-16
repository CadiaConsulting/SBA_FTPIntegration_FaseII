query 50000 "INTPostCode"
{
    QueryType = Normal;

    elements
    {
        dataitem(Post_Code;
        "Post Code")
        {
            column(Municipio; "CADBR IBGE City Code")
            {

            }
            column(CEP; Code)
            {

            }
            column(RecordNo)
            {
                Method = Count;
            }

        }
    }
}