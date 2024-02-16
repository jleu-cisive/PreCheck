-- =============================================
-- Author:		Liel Alimole
-- Create date: 12/08/2013
-- Description:	Returns a value indicating if the client has viewed the last update for a report
-- =============================================
CREATE  PROCEDURE [dbo].[InsertApplUpdateReviewLog] 
@apno int,
@user varchar(50),
@reopendate datetime,
@logtime datetime = getdate
as
BEGIN

--declare @check int;

insert into ApplUpdateReviewLog (apno, ReviewedBy, ReopenDate, LogTime) values (@apno, @user, @reopendate, @logtime)
	
END



