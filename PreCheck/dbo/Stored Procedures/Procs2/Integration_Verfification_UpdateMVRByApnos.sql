
---- Modified by Lalit for #96018 on 2 august 2023


CREATE procedure [dbo].[Integration_Verfification_UpdateMVRByApnos]
(
--@apnos varchar(max),
@resultsOrdered varchar(max),
@resultsNotOrdered varchar(max),
@message varchar(max),
@MaxAttemptCounterMessage varchar(50),
@loggingid int = null,
@MaxAttemptCounter int = 0
) as

if (@resultsOrdered is not null)
begin 
	if (IsNull(@message,'') = '') 
	begin
--  select @value,* from DL where apno in (select value from fn_Split(@apnos,','))
		
		update dbo.DL set MVRLoggingId = @loggingid,DateOrdered = GETDATE(),Last_Updated = CURRENT_TIMESTAMP,AttemptCounter = 0
		where apno in (select value from fn_Split(@resultsOrdered,','))
		
	end

	if (IsNull(@message,'') <> '')
	begin
		Update dbo.DL 
		set Report = @message + ';' + IsNull(Report,''),Last_Updated = CURRENT_TIMESTAMP,AttemptCounter = 0
		where apno in (select value from fn_Split(@resultsOrdered,',')) 
	end
end

if (@resultsNotOrdered is not null)
begin	
	update dbo.DL set AttemptCounter = coalesce(AttemptCounter,0) + 1 ---- update to fix failure to update attempt counter null values
	where apno in (select value from fn_Split(@resultsNotOrdered,',')) 
end
	
if (@MaxAttemptCounter > 0)
begin	
	update dbo.DL set Report = @MaxAttemptCounterMessage + ';' + IsNull(Report,''),Last_Updated = CURRENT_TIMESTAMP
	where AttemptCounter > @MaxAttemptCounter
end
