

/****** Object:  StoredProcedure [dbo].[EZVerify_UpdateEmplVerificationInfo]    Script Date: 06/22/2011 11:08:48 ******/

-- =============================================
-- Author:		Najma Begum	
-- Create date: <06/21/2011
-- Description:	To update Empl table with EZVerify data
-- Modified: SectStat cannot be int and so commented by Radhika dereddy on 09/23/2020 to accommodate other statuses like 'A','U','R' etc from Sectstat table
-- =============================================
--Updated On: 08/02/2012-to flip apstatus if in Final to pending status by Najma Begum	
-- =============================================
CREATE PROCEDURE [dbo].[EZVerify_UpdateEmplVerificationInfo]
	-- Add the parameters for the stored procedure here
	@EmplID int, @PublicNotes text = null,@PrivateNotes text = null, 
	--@SectStat int, -- SectStat cannot be int and so commented by Radhika dereddy on 09/23/2020 to accommodate other statuses like 'A','U','R' etc from Sectstat table
	@SectStat varchar(1),
	@WebStatus int, @VPosition varchar(25)= null, @VerifiedBy varchar(25) = null,
	@To_V varchar(12)= null, @From_V varchar(12)= null, @Title varchar(25) = null, @EmplType char(1), @ReleaseCond char(1), @Rehire char(1)= null
	
	AS
BEGIN
	-- SET NOCOUNT ON --added to prevent extra result sets from
	-- interfering with SELECT statements.
	
	Declare @ApStatus char(1);
	Declare @ApNo int;
	--Declare @OSectStat int; -- SectStat cannot be int and so commented by Radhika dereddy on 09/23/2020 to accommodate other statuses like 'A','U','R' etc from Sectstat table
	Declare @OSectStat varchar(1);
	
	Select @Apno = apno, @OSectStat=sectstat from dbo.Empl where emplid=@EmplID;
	select @ApStatus = apstatus from dbo.appl where appl.apno = @ApNo;

	begin transaction
	UPDATE dbo.Empl set pub_notes = @PublicNotes, priv_notes = @PrivateNotes, sectstat = @SectStat, web_status = @WebStatus, Position_V=  @VPosition,
	Ver_By = @VerifiedBy, From_V = @From_V, To_V = @To_V, title = @Title, emp_type = @EmplType, rel_cond = @ReleaseCond, rehire = @Rehire, Last_Updated = getdate() where emplid = @EmplID
	
	if(@@Error <> 0)
	begin
	Rollback Transaction;
	Return;
	end
	else
	begin
	if(@OSectStat <> @SectStat)
	begin
	insert into dbo.ChangeLog (TableName, ID, OldValue, NewValue, ChangeDate, UserID) values('Empl.SectStat',@EmplID,@OSectStat, @SectStat,getdate(),'EZVerify');
	end
	
	if(@ApStatus = 'F')
	begin
	Update dbo.Appl set apstatus = 'P', reopendate = getdate(),CompDate = Null where apno = @Apno;
	insert into dbo.ChangeLog (TableName, ID, OldValue, NewValue, ChangeDate, UserID) values('Appl.ApStatus',@Apno,'F', 'P',getdate(),'EZVerify');
	END
	Commit transaction;
	END
	
END


