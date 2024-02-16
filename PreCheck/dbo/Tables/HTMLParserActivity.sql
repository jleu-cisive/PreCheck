CREATE TABLE [dbo].[HTMLParserActivity] (
    [HTMLParserActivityID] INT           IDENTITY (1, 1) NOT NULL,
    [UserId]               VARCHAR (8)   NULL,
    [APNO]                 INT           NULL,
    [CLNO]                 INT           NULL,
    [First]                VARCHAR (30)  NULL,
    [Last]                 VARCHAR (30)  NULL,
    [SSN]                  VARCHAR (30)  NULL,
    [DOB]                  VARCHAR (30)  NULL,
    [Zip]                  VARCHAR (30)  NULL,
    [CreatedDate]          DATETIME      NULL,
    [Failed]               BIT           NULL,
    [OnHold]               BIT           NULL,
    [Cleared]              BIT           NULL,
    [FailedFile]           VARCHAR (300) NULL,
    CONSTRAINT [PK_HTMLParserActivity] PRIMARY KEY CLUSTERED ([HTMLParserActivityID] ASC) WITH (FILLFACTOR = 50)
);

