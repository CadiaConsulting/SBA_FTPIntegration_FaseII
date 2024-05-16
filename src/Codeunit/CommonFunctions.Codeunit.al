codeunit 50074 "CommonFunctions"
{
    Procedure DecimalFromUStoBR(ToDecimal: Text): Decimal
    var
        TypeHelper: Codeunit "Type Helper";
        CultureInfo: Text;
        V: Variant;
        D: Decimal;
    begin
        CultureInfo := TypeHelper.LanguageIDToCultureName(1033);
        V := D;
        TypeHelper.Evaluate(V, ToDecimal, 'G', CultureInfo);
        D := V;
        exit(D);

    end;

    Procedure DateFromUStoBR(ToDecimal: Text): Date
    var
        TypeHelper: Codeunit "Type Helper";
        CultureInfo: Text;
        V: Variant;
        D: Date;
    begin
        CultureInfo := TypeHelper.LanguageIDToCultureName(1033);
        V := D;
        TypeHelper.Evaluate(V, ToDecimal, 'd', CultureInfo);
        D := V;
        exit(D);
    end;
}