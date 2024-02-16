-- =============================================
-- Author:		Najma Begum	
-- Create date: <06/21/2011
-- Description:	To update Empl table with EZVerify data
-- Updated on: 08/02/2012- To flip apstatus from final to pending;
-- Modified: SectStat cannot be int and so commented by Radhika dereddy on 09/23/2020 to accommodate other statuses like 'A','U','R' etc from Sectstat table

-- =============================================
CREATE PROCEDURE [dbo].[EZVerify_UpdateEduVerificationInfo]
	-- Add the parameters for the stored procedure here
	@EduID int, @PublicNotes text = null,@PrivateNotes text = null,	
	 --@SectStat int, -- SectStat cannot be int and so commented by Radhika dereddy on 09/23/2020 to accommodate other statuses like 'A','U','R' etc from Sectstat table
	@SectStat varchar(1),
	@WebStatus int, @To_V varchar(12)= null, @VerifiedBy varchar(25) = null,
	@VDegree varchar(25)= null,@VStudies varchar(25)= null, @VHasGraduated varchar(25)= null, @From_V varchar(12)= null, @Title varchar(25) = null
	AS
BEGIN
	-- SET NOCOUNT ON --added to prevent extra result sets from
	-- interfering with SELECT statements.
	Declare @ApStatus char(1);
	Declare @ApNo int;
	--Declare @OSectStat int; -- SectStat cannot be int and so commented by Radhika dereddy on 09/23/2020 to accommodate other statuses like 'A','U','R' etc from Sectstat table
	Declare @OSectStat varchar(1);

	Select @Apno = apno, @OSectStat=sectstat from educat where educatid=@EduID;
	select @ApStatus = apstatus from dbo.appl where apno = @ApNo;
	
	begin transaction
	
	UPDATE dbo.Educat set pub_notes = @PublicNotes, priv_notes = @PrivateNotes, sectstat = @SectStat, web_status = @WebStatus, Degree_V= @VDegree,
	Studies_V = @VStudies, From_V = @From_V, To_V = @To_V, HasGraduated=@VHasGraduated, Contact_Name= @VerifiedBy, Contact_Title=@Title, Contact_Date= getdate(), Last_Updated = getdate() where educatid = @EduID
	
	if(@@Error <> 0)
	begin
	Rollback Transaction;
	Return;
	end
	else
	begin
	if(@OSectStat <> @SectStat)
	begin
	insert into dbo.ChangeLog (TableName, ID, OldValue, NewValue, ChangeDate, UserID) values('Educat.SectStat',@EduID,@OSectStat, @SectStat,getdate(),'EZVerify');
	end
	
	if(@ApStatus = 'F')
	begin
	Update dbo.Appl set apstatus = 'P', reopendate = getdate() where apno = @Apno;
	insert into dbo.ChangeLog (TableName, ID, OldValue, NewValue, ChangeDate, UserID) values('Appl.ApStatus',@Apno,'F', 'P',getdate(),'EZVerify');
	

	end
	Commit transaction;
	end
	
	
	
END