CREATE TABLE [Config].[IntegrationAction] (
    [IntegrationActionId]  INT           IDENTITY (1, 1) NOT NULL,
    [ActionCode]           VARCHAR (10)  NOT NULL,
    [ActionTitle]          VARCHAR (100) NOT NULL,
    [Description]          VARCHAR (250) NULL,
    [InternalHire]         BIT           NOT NULL,
    [EnableOrder]          BIT           NOT NULL,
    [CheckForDrugTest]     BIT           NOT NULL,
    [CanOverrideBGPackage] BIT           CONSTRAINT [DF_IntegrationAction_CanOverrideBGPackage] DEFAULT ((0)) NOT NULL,
    [BGPackageId]          INT           NULL,
    [IsActive]             BIT           CONSTRAINT [DF_IntegrationAction_IsActive] DEFAULT ((1)) NOT NULL,
    [CreateDate]           DATETIME      CONSTRAINT [DF_IntegrationAction_CreateDate] DEFAULT (getdate()) NOT NULL,
    [CreateBy]             VARCHAR (50)  NOT NULL,
    [ModifyDate]           DATETIME      CONSTRAINT [DF_IntegrationAction_ModifyDate] DEFAULT (getdate()) NOT NULL,
    [ModifyBy]             VARCHAR (50)  NOT NULL,
    CONSTRAINT [PK_IntegrationAction] PRIMARY KEY CLUSTERED ([IntegrationActionId] ASC),
    CONSTRAINT [UNQ_ActionCode] UNIQUE NONCLUSTERED ([ActionCode] ASC)
);

