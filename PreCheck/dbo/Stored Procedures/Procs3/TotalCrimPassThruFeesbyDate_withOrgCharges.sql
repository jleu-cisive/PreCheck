-- Alter Procedure TotalCrimPassThruFeesbyDate_withOrgCharges

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[TotalCrimPassThruFeesbyDate_withOrgCharges]
	
@StartDate datetime,
@EndDate datetime

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


select c.clno,c.name,i.* ,z.orgCharge,descp
from invdetail i with (nolock) 
inner join appl a  with (nolock) on i.apno = a.apno
inner join client c  with (nolock) on c.clno = a.clno 
inner join 
(
SELECT	C2.APNO,C2.CNTY_NO, MIN(C1.A_County) + ', ' + MIN(C1.State) + ' Service Charge' as descp, MIN(C1.PassThroughCharge) as orgCharge 
FROM	dbo.TblCounties C1  with (nolock)
		INNER JOIN dbo.Crim C2  with (nolock) ON C1.CNTY_NO = C2.CNTY_NO	AND C1.PassThroughCharge > 0
		INNER JOIN dbo.Appl A1  with (nolock) ON C2.APNO = A1.APNO
		INNER JOIN dbo.Client Cl  with (nolock) ON Cl.CLNO = A1.CLNO
inner join invdetail i1 with (nolock)  on a1.APNO = i1.APNO
where 
i1.createdate >= @StartDate and i1.createdate < @EndDate 
and 
(i1.description like '%service charge%' --or i.description like '%Criminal Search%'  **STATEWIDE (DO NOT USE), NY Service Charge
)


		
GROUP BY C2.APNO, C2.CNTY_NO
) z on  i.apno = z.apno and i.Description  = Replace(z.descp,'**STATEWIDE (DO NOT USE)','**STATEWIDE**')

where 
 i.createdate >= @StartDate and i.createdate < @EndDate
and 
(i.description like '%service charge%' --or i.description like '%Criminal Search%'
)

END
