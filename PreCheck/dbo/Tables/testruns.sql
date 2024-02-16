CREATE TABLE [dbo].[testruns] (
    [EmployerID]    VARCHAR (200) NULL,
    [month]         VARCHAR (2)   NULL,
    [year]          VARCHAR (5)   NULL,
    [run]           VARCHAR (2)   NULL,
    [licensecount]  INT           NULL,
    [initialclient] BIT           NULL,
    [startdate]     DATETIME      NULL,
    [duedate]       DATETIME      NULL
) ON [PRIMARY];

