CREATE TABLE [dbo].[MessageJobs] (
    [MessageJobsID] INT  IDENTITY (1, 1) NOT NULL,
    [Jobs]          TEXT NULL,
    [DepartmentID]  INT  NULL,
    CONSTRAINT [PK_MessageJobs] PRIMARY KEY CLUSTERED ([MessageJobsID] ASC) WITH (FILLFACTOR = 90)
) TEXTIMAGE_ON [PRIMARY];

