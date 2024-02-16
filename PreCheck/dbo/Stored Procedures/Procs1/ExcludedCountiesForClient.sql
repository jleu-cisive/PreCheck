-- Alter Procedure ExcludedCountiesForClient
-- =============================================
-- Author:		Prasanna
-- Create date: 01/10/2017
-- Description:	Excluded Counties for Client
-- Exec [dbo].[ExcludedCountiesForClient] 0
-- =============================================
CREATE PROCEDURE [dbo].[ExcludedCountiesForClient] 
  @CLNO int = 0
AS
BEGIN    

	select c.CLNO as ClientID, c.Name as ClientName, ccr.County as ExcludedCountyName,
	(select Top (1) apdate from Appl where CLNO = IIF(@CLNO=0,C.CLNO,@CLNO)  order by 1 desc) as [Last App Received/Ordered Date],
	cnty.PassThroughCharge as [Pass Through for Search (applies when not excluded)] from ClientCrimRate ccr 
	inner join Client c on ccr.CLNO = c.CLNO 
	inner join dbo.TblCounties cnty on ccr.CNTY_NO = cnty.CNTY_NO
	inner join Appl appl on appl.CLNO = ccr.CLNO
	where C.CLNO = IIF(@CLNO=0,C.CLNO,@CLNO) and ccr.ExcludeFromRules = 1 and c.IsInactive = 0
	group by c.CLNO,c.Name,ccr.County,cnty.PassThroughCharge

END
