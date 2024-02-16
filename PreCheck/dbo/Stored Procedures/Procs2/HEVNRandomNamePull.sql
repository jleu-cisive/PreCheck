




-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[HEVNRandomNamePull] 
	AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   SELECT cc.clno,c.Name,cc.HRNGNumberOfRandomRecords,cc.HRNGFrequencyPeriod,cc.HRNGInterval,cc.HRNGLastRunDate
	--,'christopherchaupin@precheck.com,robertperez@precheck.com' As Email,ccs.FirstName
	, ccs.Email,ccs.FirstName
 FROM ClientConfig AS cc INNER JOIN Client AS c ON cc.clno = c.clno
 INNER JOIN ClientContacts as ccs ON cc.HRNGClientContactID = ccs.ContactID
	WHERE cc.HRNGIsActive = 1

END






