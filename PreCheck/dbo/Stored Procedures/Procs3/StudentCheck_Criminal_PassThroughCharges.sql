-- Alter Procedure StudentCheck_Criminal_PassThroughCharges


CREATE PROCEDURE [dbo].[StudentCheck_Criminal_PassThroughCharges] --'12/06/2015','01/06/2016'
(
	@StartDate datetime
	,@EndDate datetime
)
AS
BEGIN

	SELECT	CT.ClientType,Cl.CLNO,Cl.Name as ClientName,A.Apno as ReportNumber,C.PassThroughCharge as [Criminal Pass-through amount added],C.County, A.CompDate as [Report Completed Date]
	FROM	dbo.TblCounties C
			INNER JOIN dbo.Crim C2 ON C.CNTY_NO = C2.CNTY_NO AND C.PassThroughCharge > 0 AND C2.IsHidden = 0
			INNER JOIN dbo.Appl A ON C2.APNO = A.APNO
			INNER JOIN dbo.Client Cl ON Cl.CLNO = A.CLNO
			INNER JOIN [dbo].[refClientType] CT ON CT.ClientTypeID = Cl.ClientTypeID
	where A.CompDate between @StartDate and @EndDate		
	GROUP BY C2.APNO, C2.CNTY_NO, CT.ClientType,Cl.CLNO,Cl.Name,A.Apno,C.PassThroughCharge, A.CompDate, C.County
END
