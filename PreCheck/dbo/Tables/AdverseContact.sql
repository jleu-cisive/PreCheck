CREATE TABLE [dbo].[AdverseContact] (
    [AdverseContactID]     INT          IDENTITY (1, 1) NOT NULL,
    [CLNO]                 INT          NULL,
    [ContactName]          VARCHAR (50) NULL,
    [WorkPhone]            VARCHAR (20) NULL,
    [WorkExt]              CHAR (10)    NULL,
    [HomePhone]            VARCHAR (20) NULL,
    [CellPhone]            VARCHAR (20) NULL,
    [Email]                VARCHAR (50) NULL,
    [AdverseContactTypeID] INT          NULL,
    CONSTRAINT [PK_AdverseContact] PRIMARY KEY CLUSTERED ([AdverseContactID] ASC) WITH (FILLFACTOR = 50)
);

