CREATE TABLE [dbo].[Education$] (
    [Client ID]          FLOAT (53)     NULL,
    [SSN]                NVARCHAR (255) NULL,
    [Status]             NVARCHAR (255) NULL,
    [Investigator]       NVARCHAR (255) NULL,
    [Attended To]        DATETIME       NULL,
    [Degree]             NVARCHAR (255) NULL,
    [Studies]            NVARCHAR (255) NULL,
    [Contact Name]       NVARCHAR (255) NULL,
    [Contact Title]      NVARCHAR (255) NULL,
    [Contact Date]       DATETIME       NULL,
    [Public Notes]       VARCHAR (MAX)  NULL,
    [Private Notes]      VARCHAR (MAX)  NULL,
    [In Progress Review] NVARCHAR (255) NULL
);

