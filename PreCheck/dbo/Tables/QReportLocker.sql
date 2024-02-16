CREATE TABLE [dbo].[QReportLocker] (
    [QReportLockerID] INT          IDENTITY (1, 1) NOT NULL,
    [LockedBy]        VARCHAR (50) NULL,
    CONSTRAINT [PK_QReportLocker] PRIMARY KEY CLUSTERED ([QReportLockerID] ASC) WITH (FILLFACTOR = 50)
);

