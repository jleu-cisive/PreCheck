
/*
Procedure Name : BadAppsDetails
Requested By: Valerie K. Salazar
Developer: Deepak Vodethela
Execution : EXEC [BadAppsDetails] '06/01/2020', '06/14/2020',''
Updates: 4/10/2017 Suchi: Added columns Component Type, Default Rate, per HDT 12930 from Valerie Salazar
         4/12/2017 Suchi: Added Client Name column and Affiliate search param per HDT 13426 from Valerie K. Salazar
         
*/

CREATE PROCEDURE [dbo].[BadAppsDetails]
@StartDate DateTime,
@EndDate DateTime,
@Affiliate varchar(50)= null
AS
BEGIN

if(@Affiliate is null or @Affiliate='null' or @Affiliate ='')
begin
set @Affiliate=0
end

	SELECT A.APNO AS Report#, C.OldValue, C.NewValue, C.ChangeDate, C.UserID,A.EnteredVia, A.Priv_Notes AS 'Private Notes'
	into #tempCL
	FROM ChangeLog(NOLOCK) C 
	INNER JOIN APPL A ON A.APNO = C.ID
	WHERE TableName = 'Appl.CLNO'
	  AND NewValue = '3468'
	  AND ChangeDate >= @StartDate and ChangeDate < dateadd(day,1,@EndDate)
	ORDER BY ChangeDate DESC


Select a.APNO as Report#, a.CLNO, a.ApDate 'Apdate', A.UserID as'UserID',A.EnteredVia, A.Priv_Notes as [Private Notes]
into #tempAPPL
FROM APPL a 
where A.CLNO =3468
AND A.Apdate >= @StartDate AND A.APdate < DATEADD(d,1,@EndDate)



--Suchi: Added the SQL below for adding columns Component Type, Default Rate, per HDT 12930 from Valerie Salazar
select TCL.Report#, TCL.OldValue,C.Name [Client Name],RA.Affiliate,TCL.NewValue,R.RateType as [Component Type],D.DefaultRate,TCL.ChangeDate, '' Apdate,TCL.UserID,TCL.EnteredVia,TCL.[Private Notes] 
from #tempCL TCL
inner join Client C on C.CLNO = TCL.OldValue
inner join ClientRates R on  C.CLNO =R.CLNO
inner join DefaultRates D on  R.ServiceID = D.ServiceID 
inner join refAffiliate RA on C.AffiliateID= RA.AffiliateID 
where RA.Affiliate = IIF(@Affiliate=0,RA.Affiliate,@Affiliate)


UNION ALL

Select a.Report#, '' OldValue,C.Name [Client Name],RA.Affiliate, '' NewValue, R.RateType as [Component Type],D.DefaultRate, '' ChangeDate, A.Apdate, A.UserID as'UserID',A.EnteredVia, A.[Private Notes]
FROM #tempAPPL a
inner join Client C on a.CLNO =  C.CLNO
inner join ClientRates R on  C.CLNO =R.CLNO 
inner join DefaultRates D on  R.ServiceID = D.ServiceID
inner join refAffiliate RA on  C.AffiliateID =RA.AffiliateID 
where RA.Affiliate = IIF(@Affiliate=0,RA.Affiliate,@Affiliate)



drop table #tempCL
drop table #tempAPPL


END




