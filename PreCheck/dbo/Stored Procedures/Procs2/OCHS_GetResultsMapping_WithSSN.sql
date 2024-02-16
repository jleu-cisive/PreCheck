
-- =============================================
-- Author:		Prasanna
-- Create date: 04/27/2015
-- Description:	Get DrugscreenResultMapping data with SSN
-- =============================================
CREATE PROCEDURE [dbo].[OCHS_GetResultsMapping_WithSSN] 
	
AS
BEGIN	
	select distinct rd.TID,rd.OrderIDOrApno,rd.FirstName,rd.LastName,rd.SSNOrOtherID,rd.CLNO,c.Name as ClientName, 
	CONVERT(VARCHAR(10),cast(rd.DateReceived as date), 101) as DateReceived,rd.OrderStatus from OCHS_ResultDetails rd 
	inner join client c on rd.clno = c.clno
	where rd.OrderIDOrApno = NULL or rd.OrderIDOrApno = '' order by TID desc
END