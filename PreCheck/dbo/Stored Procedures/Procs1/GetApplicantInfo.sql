
/*
Procedure Name : [dbo].[GetApplicantInfo] 
Modified By: Deepak Vodethela
Description: Added logic for expiration link. 
Execution : EXEC [dbo].[GetApplicantInfo]  2655450,'227-55-8501','1989-08-20','Lilly','relilly891@gmail.com',176
			EXEC [dbo].[GetApplicantInfo]  null,'227-55-8501','1989-08-20','Lilly','relilly891@gmail.com',176
*/

CREATE  PROCEDURE [dbo].[GetApplicantInfo]    
	@APNO  INT = NULL,
    @SSN  Varchar(11) = NULL,
    @DOB  DateTime = NULL,
	@Last varchar(100) = NULL,
	@Email varchar(100) = NULL,
	@OCHS_ID Int = NULL
AS
BEGIN
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

DECLARE @IsAuthenticated Bit
--DECLARE  @OCHS_ApplInfo TABLE (APNO INT,SSN varchar(11),DOB Date)
DECLARE  @OCHS_ApplInfo TABLE (APNO INT,OCHS_CandidateInfoID INT,IsValidLink bit ,ClientName varchar(100),CLNO Int)

DECLARE @OldOrderStatus VARCHAR(25), @OldLastUpdate DATETIME, @TID INT, @OldIsValidLink BIT, @OldLastModifiedDate DATETIME, @OCHS_CandidateScheduleID INT


SET @SSN = Replace(@SSN, '-', '')

IF @SSN IS NOT NULL 
	BEGIN
		IF @APNO IS NOT NULL	
			BEGIN
				Insert into @OCHS_ApplInfo (APNO,OCHS_CandidateInfoID,IsValidLink,ClientName,CLNO)
				Select @APNO APNO, OCHS_CandidateInfoID,0,'',CLNO
				From dbo.OCHS_CandidateInfo A 
				Where (A.APNO = @APNO)  and Replace(A.SSN, '-', '')=@SSN and A.DOB=cast(@DOB as Date)

				IF (Select count(1) From @OCHS_ApplInfo)=0
					Insert into @OCHS_ApplInfo (APNO,OCHS_CandidateInfoID,IsValidLink,ClientName,CLNO)
					Select A.Apno,0,0,'',CLNO
					From dbo.Appl A
					Where A.APNO = @APNO and A.DOB=@DOB and Replace(A.SSN, '-', '')=@SSN
			END
		ELSE
			Insert into @OCHS_ApplInfo (APNO,OCHS_CandidateInfoID,IsValidLink,ClientName,CLNO)
			Select @OCHS_ID APNO, OCHS_CandidateInfoID,0,'',CLNO
			From dbo.OCHS_CandidateInfo A 
			Where (OCHS_CandidateInfoID = @OCHS_ID ) and Replace(A.SSN, '-', '')=@SSN and A.DOB=cast(@DOB as Date)		
	END
ELSE
	BEGIN
		IF @APNO IS NOT NULL
			BEGIN	
				Insert into @OCHS_ApplInfo (APNO,OCHS_CandidateInfoID,IsValidLink,ClientName,CLNO)
				Select isnull(@APNO,@OCHS_ID) APNO, OCHS_CandidateInfoID,0,'',CLNO
				From dbo.OCHS_CandidateInfo A 
				Where (A.APNO = @APNO) and A.[LASTNAME]=@Last and A.Email = @Email
				
				IF (Select count(1) From @OCHS_ApplInfo)=0
					Insert into @OCHS_ApplInfo (APNO,OCHS_CandidateInfoID,IsValidLink,ClientName,CLNO)
					Select A.Apno, 0,0,'',CLNO
					From dbo.Appl A
					Where A.APNO = @APNO and A.[LAST]=@Last and A.Email = @Email
			END
		ELSE
			Insert into @OCHS_ApplInfo (APNO,OCHS_CandidateInfoID,IsValidLink,ClientName,CLNO)
			Select @OCHS_ID APNO, OCHS_CandidateInfoID,0,'',CLNO
			From dbo.OCHS_CandidateInfo A 
			Where (OCHS_CandidateInfoID = @OCHS_ID) and A.[LASTNAME]=@Last and A.Email = @Email
	END

	-- Get the records to be authenticated
	IF (SELECT COUNT(1) FROM @OCHS_ApplInfo) > 0
		SET @IsAuthenticated = 1
	ELSE
		SET @IsAuthenticated = 0

	UPDATE O 
		SET ClientName = C.Name
	FROM @OCHS_ApplInfo O 
	INNER JOIN Client C on O.CLNO = C.CLNO


	EXEC DBO.DrugTestStatusUpdate_LinkExpirations --This is to update the link expirations

	-- Set the links value to true when the condition is set.
	If @IsAuthenticated = 1  
		BEGIN
			IF (SELECT COUNT(1) FROM OCHS_CandidateSchedule WHERE OCHS_CandidateID IN (SELECT OCHS_CandidateInfoID FROM  @OCHS_ApplInfo))>0
				UPDATE O 
					SET IsValidLink = 1 
				FROM @OCHS_ApplInfo O 
				WHERE O.OCHS_CandidateInfoID IN (SELECT TOP 1 OCHS_CandidateID FROM OCHS_CandidateSchedule WHERE ExpirationDate>=CURRENT_TIMESTAMP AND OCHS_CandidateID = O.OCHS_CandidateInfoID)
			ELSE
				UPDATE O 
					SET IsValidLink = 1 
				FROM @OCHS_ApplInfo O			
								
		END


	INSERT INTO [dbo].[OCHS_edrugVerifyLog]
			   ([APNO]
			   ,[OCHS_ID]
			   ,[SSN]
			   ,[DOB]
			   ,[Last]
			   ,[Email]
			   ,[LogDate],
			   IsAuthenticated,IsValidLink)
	SELECT @APNO,@OCHS_ID,@SSN,cast(@DOB as Date),@Last,@Email,current_timestamp,@IsAuthenticated,IsValidLink	
	FROM @OCHS_ApplInfo

	SELECT Apno,IsValidLink,ClientName from @OCHS_ApplInfo




SET TRANSACTION ISOLATION LEVEL READ COMMITTED
SET NOCOUNT OFF
END
