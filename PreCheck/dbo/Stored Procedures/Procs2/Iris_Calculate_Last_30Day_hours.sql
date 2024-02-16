CREATE PROCEDURE Iris_Calculate_Last_30Day_hours @Vendorid int AS

Declare @Last30Day DateTime

Set @Last30Day = (Select Dateadd(Day,-30,getdate()))


--Select @Last30Day



SELECT avg(CONVERT(numeric(7,2), dbo.ElapsedBusinesshours(c.ordered,c.last_updated)))  as average
FROM    Crim c  where (dbo.Fix_Crim_Ordered_Date(ordered) between @last30Day and getdate())
and c.vendorid =  @Vendorid