-- =============================================
-- Author:	Radhika Dereddy
-- Create date: 10/17/2016
-- Description:	On Hold/Waiting on money items not received via Student Check
-- Modified BY Radhika Dereddy on 07/12/2021 to add MCIC flag.
-- =============================================
CREATE PROCEDURE [dbo].[StudentCheck_OnHold_MoneyItems_NotReceived]
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

SELECT Appl.APNO AS [App #],ApDate AS [App date],First AS [App First Name],Last AS [App Last Name],
CASE WHEN Isnull(ClientCertReceived,'No') = 'No' then 'M-OHPCR ' else 'M' end AS [Report Status],  
CONVERT(numeric(7,2), dbo.NewElapsedBusinessDays(appl.Reopendate,appl.ApDate, getdate())) as [Elapsed], 
Client.[Name] AS [Client Name], EnteredVia,
CASE WHEN ISNULL(it.IsMCICOrder ,0) = 0 THEN 'False' ELSE 'True' END as [MCIC],
dbo.Client.CAM as [CAM], dbo.Appl.Investigator, appl.Priv_Notes as [Private Notes]
Into #temp1	
FROM Appl WITH (NOLOCK) 
INNER JOIN Client WITH (NOLOCK) ON Appl.CLNO = Client.CLNO  
LEFT JOIN ClientCertification WITH (NOLOCK) on  Appl.Apno = ClientCertification.Apno
LEFT JOIN [Enterprise].[Report].[InvitationTurnaround] AS IT WITH (NOLOCK) ON Appl.APNO = IT.OrderNumber
WHERE Appl.ApStatus = 'M' and Appl.CreatedDate > '9/1/2015' 
AND Appl.EnteredVia not in( 'StuWeb','System') 
AND Appl.Inuse is null and Appl.CLNO not in (3468,2135)
	
SELECT [App #], [App date], [App First Name], [App Last Name], [Report Status], [Elapsed], [Client Name],
 EnteredVia, [MCIC], [CAM], Investigator, [Private Notes] 
 FROM #temp1	
	
UNION

SELECT APNO AS [App #],ApDate AS [App date],First AS [App First Name],Last AS [App Last Name],
case when priv_notes like '%OHOR%' then 'M-OHOR' else 'M' end AS [Report Status], CONVERT(numeric(7,2),
 dbo.NewElapsedBusinessDays(appl.Reopendate,appl.ApDate, getdate())) as [Elapsed],
Client.[Name] AS [Client Name], EnteredVia,
CASE WHEN ISNULL(it.IsMCICOrder ,0) = 0 THEN 'False' ELSE 'True' END as [MCIC],
dbo.Client.CAM as [CAM], dbo.Appl.Investigator, Priv_Notes as [Private Notes]
FROM Appl  WITH (NOLOCK) 
INNER JOIN Client WITH (NOLOCK) ON Appl.CLNO = Client.CLNO
LEFT JOIN [Enterprise].[Report].[InvitationTurnaround] AS IT WITH (NOLOCK) ON Appl.APNO = IT.OrderNumber
WHERE Apstatus = 'M' AND not Enteredvia = 'StuWeb' 
and Appl.CLNO not in (2135,3468) 
and APNO not in (Select [App #] from #temp1)

drop table #temp1

END
