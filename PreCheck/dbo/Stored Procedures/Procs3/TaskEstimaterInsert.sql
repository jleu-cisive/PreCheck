

CREATE PROCEDURE [dbo].[TaskEstimaterInsert] AS

--first clear up the table
DELETE TaskEstimaterNew
FROM TaskEstimaterNew INNER JOIN TaskEstimaterTemp 
   ON TaskEstimaterNew.taskid = TaskEstimaterTemp.taskid

--isert new rows now
INSERT INTO dbo.TaskEstimaterNew
                      (TaskID, Name, DetailPriority, PriorityLevelID, Description, Notes, DeadLine, DeadLineMet, TaskTypeID, ProjectTypeID, Structure, EstDuration, EstCost,
                       EstReturn, ROI, ParentTaskID, DeveloperID, Client, StatusID, InUse)
SELECT     TaskID, Name, DetailPriority, PriorityLevelID, Description, Notes, DeadLine, DeadLineMet, TaskTypeID, ProjectTypeID, Structure, EstDuration, EstCost, 
                      EstReturn, ROI, ParentTaskID, DeveloperID, Client, StatusID, InUse
FROM         dbo.TaskEstimaterTemp

delete from TaskEstimaterTemp
