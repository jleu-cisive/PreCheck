
CREATE PROCEDURE [dbo].FromTaskApproverDelete
(
	@Original_TaskApproverID int,
	@Original_Client varchar(20),
	@Original_DeadLine datetime,
	@Original_DeadLineMet char(1),
	@Original_Description varchar(500),
	@Original_DetailPriority int,
	@Original_DeveloperID int,
	@Original_EstCost decimal(18,2),
	@Original_EstDuration int,
	@Original_EstReturn decimal(18,2),
	@Original_Name varchar(200),
	@Original_ParentTaskID int,
	@Original_PriorityLevelID int,
	@Original_ProjectTypeID int,
	@Original_ROI decimal(18,2),
	@Original_StatusID int,
	@Original_Structure varchar(100),
	@Original_TaskID int,
	@Original_TaskTypeID int,
	@Original_ViewOrder int,
	@Original_inUse varchar(12)
)
AS
	SET NOCOUNT OFF;
DELETE FROM dbo.TaskApprover WHERE (TaskApproverID = @Original_TaskApproverID) AND (Client = @Original_Client OR @Original_Client IS NULL AND Client IS NULL) AND (DeadLine = @Original_DeadLine OR @Original_DeadLine IS NULL AND DeadLine IS NULL) AND (DeadLineMet = @Original_DeadLineMet OR @Original_DeadLineMet IS NULL AND DeadLineMet IS NULL) AND (Description = @Original_Description OR @Original_Description IS NULL AND Description IS NULL) AND (DetailPriority = @Original_DetailPriority OR @Original_DetailPriority IS NULL AND DetailPriority IS NULL) AND (DeveloperID = @Original_DeveloperID) AND (EstCost = @Original_EstCost OR @Original_EstCost IS NULL AND EstCost IS NULL) AND (EstDuration = @Original_EstDuration OR @Original_EstDuration IS NULL AND EstDuration IS NULL) AND (EstReturn = @Original_EstReturn OR @Original_EstReturn IS NULL AND EstReturn IS NULL) AND (Name = @Original_Name) AND (ParentTaskID = @Original_ParentTaskID OR @Original_ParentTaskID IS NULL AND ParentTaskID IS NULL) AND (PriorityLevelID = @Original_PriorityLevelID OR @Original_PriorityLevelID IS NULL AND PriorityLevelID IS NULL) AND (ProjectTypeID = @Original_ProjectTypeID OR @Original_ProjectTypeID IS NULL AND ProjectTypeID IS NULL) AND (ROI = @Original_ROI OR @Original_ROI IS NULL AND ROI IS NULL) AND (StatusID = @Original_StatusID OR @Original_StatusID IS NULL AND StatusID IS NULL) AND (Structure = @Original_Structure OR @Original_Structure IS NULL AND Structure IS NULL) AND (TaskID = @Original_TaskID OR @Original_TaskID IS NULL AND TaskID IS NULL) AND (TaskTypeID = @Original_TaskTypeID OR @Original_TaskTypeID IS NULL AND TaskTypeID IS NULL) AND (ViewOrder = @Original_ViewOrder OR @Original_ViewOrder IS NULL AND ViewOrder IS NULL) AND (inUse = @Original_inUse OR @Original_inUse IS NULL AND inUse IS NULL)
