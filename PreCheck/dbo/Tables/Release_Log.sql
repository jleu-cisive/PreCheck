CREATE TABLE [dbo].[Release_Log] (
    [Id]             INT           IDENTITY (1, 1) NOT NULL,
    [ClientIdIn]     NVARCHAR (5)  NULL,
    [ClientAppNo]    NVARCHAR (20) NULL,
    [RecruiterEmail] NVARCHAR (50) NULL,
    [ReqNumber]      NVARCHAR (20) NULL,
    [COID]           NVARCHAR (50) NULL,
    [ClientIdOut]    NVARCHAR (5)  NULL,
    [CreatedDate]    DATETIME      CONSTRAINT [DF_Release_Log_CreatedDate] DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_Release_Log] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 50)
);

