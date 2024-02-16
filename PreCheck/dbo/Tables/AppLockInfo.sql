CREATE TABLE [dbo].[AppLockInfo] (
    [ID]           INT           IDENTITY (1, 1) NOT NULL,
    [Apno]         INT           NULL,
    [Date]         DATETIME      NULL,
    [LockedbyUser] VARCHAR (30)  NULL,
    [Unlocker]     VARCHAR (50)  NULL,
    [Reason]       VARCHAR (200) NULL,
    CONSTRAINT [PK_AppLockInfo] PRIMARY KEY CLUSTERED ([ID] ASC) WITH (FILLFACTOR = 50)
);

