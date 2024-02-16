CREATE TABLE [StudentCheck].[DWHLog] (
    [DWHLogId]     INT           IDENTITY (1, 1) NOT NULL,
    [StartTime]    DATETIME      NULL,
    [EndTime]      DATETIME      NULL,
    [HasError]     BIT           NULL,
    [ErrorMessage] VARCHAR (MAX) NULL,
    [IsComplete]   BIT           NULL,
    [CreateDate]   DATETIME      NOT NULL,
    [CountInsert]  INT           NULL,
    [ModifyDate]   DATETIME      NULL,
    [CountUpdate]  INT           NULL,
    [DateRange]    VARCHAR (200) NULL,
    [CountBadApps] INT           NULL,
    CONSTRAINT [PK_SSISPackageScheduleLog] PRIMARY KEY CLUSTERED ([DWHLogId] ASC)
);

