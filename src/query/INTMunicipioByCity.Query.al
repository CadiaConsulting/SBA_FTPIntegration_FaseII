query 50001 "INTMunicipioByCity"
{
    QueryType = Normal;

    elements
    {
        dataitem(Municipios; "CADBR Municipio")
        {
            column(City; City)
            {

            }
            column(Municipio; Code)
            {

            }
            column(RecordsNo)
            {
                Method = Count;
            }
        }
    }
}