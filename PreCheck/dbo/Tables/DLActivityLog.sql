CREATE TABLE [dbo].[DLActivityLog] (
    [DLActivityLogID] INT          IDENTITY (1, 1) NOT NULL,
    [APNO]            INT          NOT NULL,
    [UserName]        VARCHAR (50) NULL,
    [Status]          VARCHAR (5)  NULL,
    [ChangeDate]      DATETIME     CONSTRAINT [DF_DLActivityLog_ChangeDate] DEFAULT (getdate()) NOT NULL,
    [ReOrdered]       BIT          CONSTRAINT [DF_DLActivityLog_ReOrdered] DEFAULT ((0)) NOT NULL,
    [ReleaseSent]     BIT          CONSTRAINT [DF_DLActivityLog_ReleaseSent] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_DLActivityLog] PRIMARY KEY CLUSTERED ([DLActivityLogID] ASC) WITH (FILLFACTOR = 50)
);

