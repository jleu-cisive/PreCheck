
-- =============================================
-- Author:		Najma Begum
-- Create date: 04/30/2013
-- Description:	Update Process Status of XML response
-- =============================================
CREATE PROCEDURE [dbo].[OCHS_UpdateProcessingStatus]
@FromStatus varchar(12), @ToStatus varchar(12), @Id int
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	Update OCHS_ResultsLog set ProcessStatus = @ToStatus where ID = @Id and ProcessStatus = @FromStatus;

	/* schapyala commented on 11/17/2017 because he fixed the root cause in SP - [OCHS_GetXMLResultsToProcess]
	--schapyala added below on 11/17/2017 -- Release Records stuck in Processing Status - to be reprocessed.
	Begin Try
		Update RL Set ProcessStatus=null 
		--Select *
		from OCHS_ResultsLog RL where ID in (
		Select Max(ID) from OCHS_ResultsLog 
		Group By ProviderID Having ProviderID in (
		select ProviderID  from OCHS_ResultsLog R 
		where ProcessStatus like 'pro%' and datediff(MI,Lastupdated,current_timestamp)>30 and  lastupdated >'11/17/2017')) and ProcessStatus = 'Processing'
	End Try
	Begin Catch
		--Ignore (remove from critical path
	End Catch
	*/
END

