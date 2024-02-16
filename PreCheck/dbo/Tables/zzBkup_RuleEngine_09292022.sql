CREATE TABLE [dbo].[zzBkup_RuleEngine_09292022] (
    [RulesEngineId]       INT            IDENTITY (1, 1) NOT NULL,
    [ResultsFound]        VARCHAR (500)  NOT NULL,
    [CreateDate]          DATETIME       NULL,
    [ModifyDate]          DATETIME       NULL,
    [CreatedBy]           VARCHAR (100)  NULL,
    [ModifyBy]            VARCHAR (100)  NULL,
    [IsActive]            BIT            NOT NULL,
    [PrecheckStatus]      CHAR (1)       NOT NULL,
    [PrecheckWebStatus]   INT            NOT NULL,
    [PublicNotesID]       INT            NULL,
    [AlternateStatus]     NVARCHAR (250) NULL,
    [ExternalSourceLogic] VARCHAR (1024) NULL
);

