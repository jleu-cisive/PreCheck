CREATE TABLE [Config].[ClientProcessJobRequirement] (
    [ClientProcessJobRequirementId] INT          IDENTITY (1, 1) NOT NULL,
    [ProcessLevel]                  VARCHAR (10) NULL,
    [ParentCLNO]                    INT          NOT NULL,
    [HasPatientContact]             BIT          NULL,
    [IncludeDrugTest]               BIT          NULL,
    [DrugTestPackageId]             INT          NULL,
    [JobState]                      VARCHAR (5)  NULL,
    [IsActive]                      BIT          CONSTRAINT [DF_ClientProcessJobRequirement_IsActive] DEFAULT ((1)) NOT NULL,
    [CreateBy]                      INT          CONSTRAINT [DF_ClientProcessJobRequirement_CreateBy] DEFAULT ((0)) NOT NULL,
    [CreateDate]                    DATETIME     CONSTRAINT [DF_ClientProcessJobRequirement_CreateDate] DEFAULT (getdate()) NOT NULL,
    [ModifyBy]                      INT          CONSTRAINT [DF_ClientProcessJobRequirement_ModifyBy] DEFAULT ((0)) NOT NULL,
    [ModifyDate]                    DATETIME     CONSTRAINT [DF_ClientProcessJobRequirement_ModifyDate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_ClientProcessJobRequirement] PRIMARY KEY CLUSTERED ([ClientProcessJobRequirementId] ASC),
    CONSTRAINT [UNQ_Client_ProcessLevel_HasPatientContact] UNIQUE NONCLUSTERED ([ProcessLevel] ASC, [ParentCLNO] ASC, [HasPatientContact] ASC)
);

