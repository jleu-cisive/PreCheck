
/*
alter table [dbo].[AIMS_Jobs]
add AgentStatus varchar(50) 

alter table [dbo].[AIMS_Jobs]
add Last_Updated DateTime
*/


CREATE procedure [dbo].[AIMS_UpdateJobStatus_New]

@jobid int,

@status varchar(10) = null,

@agentStatus varchar(50) = null,

@LogID int = null

as

BEGIN
	-- DO WE HAVE A JOB STATUS
	IF (ISNULL(@status,'') <> '')
		BEGIN
			--IF(@status = 'A')
				UPDATE 
					[AIMS_Jobs]
				SET 
					AIMS_JobStatus = @status,
					JobStart = Case when @Status in ('A') then  CURRENT_TIMESTAMP else null end, 
					JobEnd = Case when @Status not in ('A') then CURRENT_TIMESTAMP else null end,
					DataXtract_LoggingId = @LogId
				WHERE 
					[AIMS_JobID] = @jobid
			/*ELSE
				UPDATE 
					[AIMS_Jobs]
				SET 
					AIMS_JobStatus = @status,
					JobEnd = CURRENT_TIMESTAMP,
					DataXtract_LoggingId = @LogID
				WHERE 
					[AIMS_JobID] = @jobid
			*/
		END
	-- WE HAVE AN AGENT STATUS 
	ELSE IF (ISNULL(@agentStatus,'') <> '')
		BEGIN
			UPDATE 
				[AIMS_Jobs]
			SET 
				AgentStatus = @agentStatus
			WHERE 
				[AIMS_JobID] = @jobid	
		END
END
