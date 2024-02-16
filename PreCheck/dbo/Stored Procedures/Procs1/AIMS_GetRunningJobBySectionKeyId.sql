
CREATE procedure [dbo].[AIMS_GetRunningJobBySectionKeyId]
@sectionKeyId varchar(50), @section varchar(10),@pullOnly bit = false

as 
begin

declare @AIMS_JobID int , @AIMS_JobStatus varchar(1)


SELECT  @AIMS_JobID = AIMS_JobID,@AIMS_JobStatus = AIMS_JobStatus 
FROM dbo.AIMS_Jobs WITH (NOLOCK) 
WHERE SectionKeyId = @sectionKeyId AND section = @section 
and AIMS_JobStatus in ('A','R','Q','E','U','X') and isnull(RetryCount,0)<3
Print @AIMS_JobStatus
IF (@AIMS_JobStatus) in ('Q','E','U') --If already queued or attempted less than 3 times, activate it for the utility
	BEGIN
		Update dbo.AIMS_Jobs  Set AIMS_JobStatus= case when @pullOnly = 1 then 'R' else 'A' end,JobStart=CURRENT_TIMESTAMP,Last_Updated=CURRENT_TIMESTAMP,IsPriority=1
		WHERE AIMS_JobID = @AIMS_JobID

	END
ELSE IF (IsNull(@AIMS_JobStatus,'')) not in ('A','R') --IF NOT already an ACTIVE Job, activate it for the utility
	BEGIN
		Insert into dbo.AIMS_Jobs(Section,SectionKeyId,AIMS_JobStatus,JobStart,CreatedDate,IsPriority)
		select @section,@sectionKeyId,case when @pullOnly = 1 then 'R' else 'A' end,CURRENT_TIMESTAMP,CURRENT_TIMESTAMP,1	
		
		Select @AIMS_JobID = SCOPE_IDENTITY()
	END
Else --IF Job is already ACTIVE by service or utility, the utility will warn the user that there is an active Job
	Select @AIMS_JobID = 0
		
Select @AIMS_JobID as JobId




END
