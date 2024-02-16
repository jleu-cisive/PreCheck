
CREATE PROCEDURE [dbo].[InsUpdAdverseAction] 
@Apno Int,
@StatusId Int,
@ClientEmail VarChar(1000) ,
@Name VarChar(50),
@Add1 VarChar(50),
@Add2 VarChar(50) = '',
@City VarChar(25),
@State VarChar(2),
@Zip VarChar(5),
@ApplicantEmail varchar(100)
AS

Declare @cnt int
Declare @AdverseId Int
Declare @oldStatusId int

SELECT @cnt = count(*), @AdverseId = AdverseActionID,@oldStatusId = StatusID  FROM AdverseAction WHERE Apno =  @Apno
group by AdverseActionID, StatusID

IF @cnt>0 
	BEGIN
		if @StatusId > 0
			begin
	--			set @StatusId = @oldStatusId
	--		end
				Update AdverseAction set StatusID = @StatusId,
					ClientEmail = @ClientEmail,
					Name = @Name, Address1 = @Add1, Address2 = @Add2,
					City = @City,State = @State,Zip = @Zip, ApplicantEmail = @ApplicantEmail
				WHERE APNO = @Apno

				--Insert into adverse history to maintain the change log

				--if @StatusId != @oldStatusID
				--Begin
					Insert into AdverseActionHistory(AdverseActionID,AdverseChangeTypeID,StatusID,UserID,Date)
					Values (@AdverseId,1,@StatusId,'Client',getdate())
				--END
			end
	END
ELSE
	BEGIN		
		if @StatusId = 0
		begin
			set @StatusId = 1
		end
		Insert into AdverseAction(APNO,StatusID,ClientEmail,Name,Address1,Address2,City,State,Zip,ApplicantEmail) 
		Values(@Apno,@StatusId, @ClientEmail, @Name, @Add1, @Add2, @City, @State, @Zip, @ApplicantEmail)

		set @AdverseId =  IDENT_CURRENT('AdverseAction')

		--insert into adverse history to maintain the change log
		Insert into AdverseActionHistory(AdverseActionID,AdverseChangeTypeID,StatusID,UserID,Date)
		Values (@AdverseId,1,@StatusId,'Client',getdate())
	END

