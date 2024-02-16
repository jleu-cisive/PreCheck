-- =============================================
-- Author:		Liel Alimole
-- Create date: 12/08/2013
-- Description:	Returns a value indicating if the client has viewed the last update for a report
-- =============================================
CREATE  PROCEDURE [dbo].[ClientAccess_CheckIfClientHasViewedUpdate] 
@apno int,
@reopendate datetime
as
BEGIN
SET NOCOUNT ON 

	declare @check int = 0;
	declare @top int = null;
	if(@reopendate < '4/15/2014') --cut off
	begin
		select 1
	end
	else
	begin
		set @top = (select top(1) ApplUpdateReviewLogID from DBO.ApplUpdateReviewLog a  (NOLOCK) where a.APNO = @apno order by LogTime desc);
		
		if(@top is not null)
		begin
			set @check = (select count(1) from DBO.ApplUpdateReviewLog a (NOLOCK)  where a.APNO = @apno and a.ReopenDate = @reopendate and a.ApplUpdateReviewLogID = @top) 
		end

		
		select @check


	end
SET NOCOUNT OFF
END
