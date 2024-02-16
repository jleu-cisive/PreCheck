CREATE TABLE [dbo].[SectSubStatus] (
    [SectSubStatusID]    INT           IDENTITY (1, 1) NOT NULL,
    [ApplSectionID]      INT           NOT NULL,
    [SectStatusCode]     CHAR (1)      NOT NULL,
    [SectSubStatus]      VARCHAR (100) NOT NULL,
    [IsActive]           BIT           CONSTRAINT [DF_ModuleSectSubStatus_IsActive] DEFAULT ((1)) NOT NULL,
    [Blurb]              VARCHAR (MAX) NULL,
    [CreatedDate]        DATETIME      CONSTRAINT [DF_SectSubStatus_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [CreatedBy]          VARCHAR (50)  NOT NULL,
    [ModifiedDate]       DATETIME      NULL,
    [ModifiedBy]         VARCHAR (50)  NULL,
    [ResultFound]        VARCHAR (100) NULL,
    [JobTiltleVerified]  BIT           NULL,
    [WithDatePolicy]     BIT           NULL,
    [ReasonForDischarge] BIT           NULL,
    [EligbleForRehire]   BIT           NULL,
    [OverallStatus]      INT           NULL,
    CONSTRAINT [PK_SectSubStatus] PRIMARY KEY CLUSTERED ([SectSubStatusID] ASC),
    CONSTRAINT [FK_SectSubStatus_SectStat] FOREIGN KEY ([SectStatusCode]) REFERENCES [dbo].[SectStat] ([Code])
);

