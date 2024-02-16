CREATE PROCEDURE [dbo].FormTaskTaskDeleteNew
(
	@Original_TaskID int,
	@Original_ActDuration int,
	@Original_BugCountClient int,
	@Original_BugCountQA int,
	@Original_CollectivePriority varchar(20),
	@Original_DeadLine datetime,
	@Original_DeadLineMet char(1),
	@Original_Description varchar(500),
	@Original_DetailPriority int,
	@Original_DeveloperID int,
	@Original_EstDuration int,
	@Original_ExpandCollapse char(1),
	@Original_IndentLevel int,
	@Original_IsHidden bit,
	@Original_IsLowestDisplayLevel bit,
	@Original_Name varchar(50),
	@Original_ParentTaskID int,
	@Original_Priority int,
	@Original_StatusID int,
	@Original_Structure varchar(100),
	@Original_TaskTypeID int,
	@Original_TimeToEst int,
	@Original_ViewOrder int,
	@Original_inUse varchar(8),
	@Original_isReportLevel char(1)
)
AS
	SET NOCOUNT OFF;
DELETE FROM dbo.Task WHERE (TaskID = @Original_TaskID) AND (ActDuration = @Original_ActDuration OR @Original_ActDuration IS NULL AND ActDuration IS NULL) AND (BugCountClient = @Original_BugCountClient OR @Original_BugCountClient IS NULL AND BugCountClient IS NULL) AND (BugCountQA = @Original_BugCountQA OR @Original_BugCountQA IS NULL AND BugCountQA IS NULL) AND (CollectivePriority = @Original_CollectivePriority OR @Original_CollectivePriority IS NULL AND CollectivePriority IS NULL) AND (DeadLine = @Original_DeadLine OR @Original_DeadLine IS NULL AND DeadLine IS NULL) AND (DeadLineMet = @Original_DeadLineMet OR @Original_DeadLineMet IS NULL AND DeadLineMet IS NULL) AND (Description = @Original_Description OR @Original_Description IS NULL AND Description IS NULL) AND (DetailPriority = @Original_DetailPriority OR @Original_DetailPriority IS NULL AND DetailPriority IS NULL) AND (DeveloperID = @Original_DeveloperID) AND (EstDuration = @Original_EstDuration) AND (ExpandCollapse = @Original_ExpandCollapse) AND (IndentLevel = @Original_IndentLevel) AND (IsHidden = @Original_IsHidden) AND (IsLowestDisplayLevel = @Original_IsLowestDisplayLevel) AND (Name = @Original_Name) AND (ParentTaskID = @Original_ParentTaskID OR @Original_ParentTaskID IS NULL AND ParentTaskID IS NULL) AND (Priority = @Original_Priority) AND (StatusID = @Original_StatusID OR @Original_StatusID IS NULL AND StatusID IS NULL) AND (Structure = @Original_Structure OR @Original_Structure IS NULL AND Structure IS NULL) AND (TaskTypeID = @Original_TaskTypeID OR @Original_TaskTypeID IS NULL AND TaskTypeID IS NULL) AND (TimeToEst = @Original_TimeToEst OR @Original_TimeToEst IS NULL AND TimeToEst IS NULL) AND (ViewOrder = @Original_ViewOrder) AND (inUse = @Original_inUse OR @Original_inUse IS NULL AND inUse IS NULL) AND (isReportLevel = @Original_isReportLevel OR @Original_isReportLevel IS NULL AND isReportLevel IS NULL)