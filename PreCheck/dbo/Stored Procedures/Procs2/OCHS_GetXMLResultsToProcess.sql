
-- =============================================
-- Author:		Najma Begum
-- Create date: 04/30/2013
-- Description:	Get drugscreen XML results to process
-- =============================================
CREATE PROCEDURE [dbo].[OCHS_GetXMLResultsToProcess]
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--on 11/17/2017 schapyala commented and rewrote the logic below
	----SELECT ID, XMLResponse from OCHS_ResultsLog where ProcessStatus is NULL;
	----Update OCHS_ResultsLog set ProcessStatus = 'Processing' where ProcessStatus is NULL;
	
	--on 11/17/2017 schapyala fixed this SP to pick Processing records instead of ProcessStatus is Null. Flipped the select and update which were both using ProcessStatus is Null as criteria
	--This will prevent from records getting stuck in processing
    Update OCHS_ResultsLog set ProcessStatus = 'Processing' where ProcessStatus is NULL; --Update records that are ready to be processed
	SELECT ID, XMLResponse from OCHS_ResultsLog (nolock) where  ProcessStatus = 'Processing' order by ID; --Pick up the updated records and any leftovers stuck in processing state
	
END

