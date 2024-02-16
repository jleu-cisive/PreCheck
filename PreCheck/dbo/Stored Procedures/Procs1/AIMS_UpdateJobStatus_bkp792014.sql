/*
alter table [dbo].[AIMS_Jobs]
add AgentStatus varchar(50) 

alter table [dbo].[AIMS_Jobs]
add Last_Updated DateTime
*/


Create procedure [dbo].[AIMS_UpdateJobStatus_bkp792014]

@jobid int,

@status varchar(10) = null,

@agentStatus varchar(50) = null,

@LogID int = null

as

BEGIN

	if (IsNull(@status,'') <> '')
		BEGIN
			if(@status = 'A')

	UPDATE [AIMS_Jobs]

	SET AIMS_JobStatus = @status, JobStart = CURRENT_TIMESTAMP

	WHERE [AIMS_JobID] = @jobid

else

	UPDATE [AIMS_Jobs]

	SET AIMS_JobStatus = @status, JobEnd = CURRENT_TIMESTAMP,DataXtract_LoggingId = @LogID

	WHERE [AIMS_JobID] = @jobid
		END
	else if (IsNull(@agentStatus,'') <> '')
		BEGIN
			UPDATE [AIMS_Jobs]
				SET AgentStatus = @agentStatus
			 WHERE [AIMS_JobID] = @jobid	
		END

END