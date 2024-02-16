

--DexterAudit 0,'1/16/2012'


CREATE PROCEDURE [dbo].[DexterAudit]
(@vendorid int,@Date datetime)
AS

if @vendorid = 0
Begin
SELECT APNO ,Name, County,  CNTY_NO ,Ordered, Crimenteredtime , Last_Updated,clear FROM        
 dbo.Crim  WHERE   vendorid in (SELECT    R_id
FROM         dbo.Iris_Researchers where R_Name like '%DEXTER%')
 and  (Last_Updated > CONVERT(DATETIME, @Date, 102)) 
and (Last_Updated < dateadd(d,1,(CONVERT(DATETIME, @Date, 102))))
and clear in ('T','F')
order by APNO

end
else



SELECT APNO ,Name, County,  CNTY_NO ,Ordered, Crimenteredtime , Last_Updated FROM        
 dbo.Crim  WHERE   vendorid = @vendorid
 and  (Last_Updated > CONVERT(DATETIME, @Date, 102)) order by APNO









