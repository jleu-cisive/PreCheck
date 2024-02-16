
CREATE PROCEDURE dbo.sp_DisciplinaryAction @Process int = 0,@UserCount int = null,@UserID varchar(10)=null , @RunID int = null AS




-- Process All StateBoards that need to be worked into the 
-- DisciplinaryActionRun Table
    IF (@Process = 1)  
       BEGIN
           INSERT INTO StateBoardDisciplinaryRun
            ([StateBoardSourceInfoID], [StatedDate], [AvailabilityDate])
         SELECT     
            LA.StateBoardSourceID,
            LA.LastUpdated, 
            LA.NextRunDate
            FROM    vwlicenseauthority LA LEFT OUTER JOIN
            dbo.StateBoardDisciplinaryRun ON LA.StateBoardSourceID = dbo.StateBoardDisciplinaryRun.StateBoardSourceInfoID
            WHERE     (convert(varchar(10),LA.NextRunDate,102) <=  convert(varchar(10),getdate(),102))
            AND 
            (NOT EXISTS
            (SELECT  *
            FROM   stateboarddisciplinaryrun
            WHERE  (stateboardsourceinfoid = LA.stateboardsourceID)
            AND 
(convert(varchar(10),AvailabilityDate,102) >= (convert(varchar(10),LA.NextRunDate,102)))))
     END


-- Extract StateBoardDisciplinaryRun to be worked
   IF(@Process = 0)
   BEGIN
       IF (@UserCount = 0)
           BEGIN
          INSERT into 
          DisciplinaryUserRun(StateBoardDisciplinaryRunID,[User],IsFirst)
          VALUES(@RunID,rtrim(@UserID),'1')
          Update StateBoardDisciplinaryRun
               Set UserA = rtrim(@UserID),DateWorkedA = getdate()
              where stateboarddisciplinaryRunID = @RunID
               END
      IF (@UserCount >= 1)
          BEGIN
                INSERT into 
                DisciplinaryUserRun(StateBoardDisciplinaryRunID,[User],IsFirst)
                VALUES(@RunID,rtrim(@UserID),'0')

              
          Update StateBoardDisciplinaryRun
          Set UserB = rtrim(@UserID),DateWorkedB = getdate()
          where stateboarddisciplinaryRunID = @RunID
          END
    END
   -- Update StateBoardDisciplinaryRun to Complete
   IF (@Process = 2)
     BEGIN
          Update StateBoardDisciplinaryRun
          Set IsComplete = '1'
          where stateboarddisciplinaryRunID = @RunID
     END
