CREATE TABLE [dbo].[HCA_ProcessLevel_Requirements_Staging] (
    [ClientProcessJobRequirementId] NVARCHAR (255) NULL,
    [ProcessLevel]                  FLOAT (53)     NULL,
    [ParentCLNO]                    NVARCHAR (255) NULL,
    [HasPatientContact]             NVARCHAR (255) NULL,
    [IncludeDrugTest]               NVARCHAR (255) NULL,
    [DrugTestPackageId]             NVARCHAR (255) NULL,
    [JobState]                      NVARCHAR (255) NULL,
    [IsActive]                      NVARCHAR (255) NULL,
    [Action]                        NVARCHAR (255) NOT NULL,
    [F10]                           NVARCHAR (255) NOT NULL,
    [F11]                           NVARCHAR (255) NOT NULL
);

