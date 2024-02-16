
-- =============================================
-- Author:		Prasanna
-- Create date: 04/27/2015
-- Description:	Get ResultMapping data
-- Modified by Radhika Dereddy on 09/03/2021 to add the date field in the filter to 2019 
-- Modified by Radhika Dereddy on 09/09/2021 changing the date to anything greater than 2021.
-- =============================================
CREATE PROCEDURE [dbo].[OCHS_GetResultsMapping] 
	
AS
BEGIN	   

	select distinct rd.TID,rd.OrderIDOrApno,rd.FirstName,rd.LastName,
	'XXX-XX-'+Right((rd.SSNOrOtherID),4) as SSNOrOtherID,rd.CLNO,c.Name as ClientName, 
	CONVERT(VARCHAR(10),cast(rd.DateReceived as date), 101) as DateReceived,OrderStatus 
	from Precheck.dbo.OCHS_ResultDetails rd (nolock)
	inner join Precheck.dbo.client c (nolock) on rd.clno = c.clno
	where rd.OrderIDOrApno = NULL or rd.OrderIDOrApno = '' 
	and cast(rd.DateReceived as date) >'01/01/2021'
	order by TID desc
END

