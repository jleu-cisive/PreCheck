CREATE TABLE [dbo].[SanctionCheckLog] (
    [LogId]         INT           IDENTITY (1, 1) NOT NULL,
    [apno]          INT           NULL,
    [first]         VARCHAR (50)  NULL,
    [middle]        VARCHAR (50)  NULL,
    [last]          VARCHAR (50)  NULL,
    [createdby]     VARCHAR (50)  NULL,
    [createddate]   DATETIME      NULL,
    [hitcount]      INT           NULL,
    [searchtypes]   VARCHAR (300) NULL,
    [searchoptions] VARCHAR (MAX) NULL,
    [status]        VARCHAR (300) NULL,
    [aliases]       VARCHAR (MAX) NULL,
    [hitlist]       VARCHAR (MAX) NULL
);

