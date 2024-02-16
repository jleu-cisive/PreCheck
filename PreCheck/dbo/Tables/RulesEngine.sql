CREATE TABLE [dbo].[RulesEngine] (
    [RulesEngineId]       INT            IDENTITY (1, 1) NOT NULL,
    [ResultsFound]        VARCHAR (500)  NOT NULL,
    [CreateDate]          DATETIME       NULL,
    [ModifyDate]          DATETIME       NULL,
    [CreatedBy]           VARCHAR (100)  NULL,
    [ModifyBy]            VARCHAR (100)  NULL,
    [IsActive]            BIT            DEFAULT ((1)) NOT NULL,
    [PrecheckStatus]      CHAR (1)       NOT NULL,
    [PrecheckWebStatus]   INT            NOT NULL,
    [PublicNotesID]       INT            NULL,
    [AlternateStatus]     NVARCHAR (250) NULL,
    [ExternalSourceLogic] VARCHAR (1024) NULL,
    [ApplSectionID]       INT            NULL,
    [EnterpriseStatus]    VARCHAR (250)  NULL,
    [EnterpriseSubStatus] VARCHAR (250)  NULL,
    [PrecheckSubStatusId] INT            NULL,
    CONSTRAINT [PK_SJVRulesEngine] PRIMARY KEY CLUSTERED ([RulesEngineId] ASC) WITH (FILLFACTOR = 70),
    CONSTRAINT [FK_RulesEngine_SJVNotes_publicNotesID] FOREIGN KEY ([PublicNotesID]) REFERENCES [dbo].[VerificationsNotes] ([VerificationsNotesId])
);

