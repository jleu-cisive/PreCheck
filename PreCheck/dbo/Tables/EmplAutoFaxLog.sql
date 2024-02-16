CREATE TABLE [dbo].[EmplAutoFaxLog] (
    [FaxID]              INT           IDENTITY (1, 1) NOT NULL,
    [Client]             INT           NULL,
    [APNO]               INT           NOT NULL,
    [EmplID]             INT           NOT NULL,
    [Employer]           VARCHAR (120) NULL,
    [First]              VARCHAR (30)  NULL,
    [Last]               VARCHAR (30)  NULL,
    [Fax]                VARCHAR (50)  NULL,
    [Phone]              VARCHAR (50)  NULL,
    [Completed]          BIT           NOT NULL,
    [DateSent]           DATETIME      NULL,
    [DateExpected]       DATETIME      NULL,
    [CurrentExpected]    VARCHAR (30)  NULL,
    [Note]               VARCHAR (255) NULL,
    [LastUpdate]         DATETIME      NULL,
    [UserName]           VARCHAR (8)   NULL,
    [ClientEmployerID]   INT           NULL,
    [FollowUp1Completed] BIT           CONSTRAINT [DF_EmplAutoFaxLog_FollowUp1Completed] DEFAULT ((0)) NOT NULL,
    [FollowUp2Completed] BIT           CONSTRAINT [DF_EmplAutoFaxLog_FollowUp2Completed] DEFAULT ((0)) NOT NULL,
    [FollowUp3Completed] BIT           CONSTRAINT [DF_EmplAutoFaxLog_FollowUp3Completed] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_EmplAutoFaxLog] PRIMARY KEY CLUSTERED ([FaxID] ASC) WITH (FILLFACTOR = 50)
);

