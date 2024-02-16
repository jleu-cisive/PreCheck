CREATE TABLE [dbo].[refEmplAutoFaxStatus] (
    [refEmplAutoFaxStatusID] INT          NOT NULL,
    [Name]                   VARCHAR (20) NULL,
    CONSTRAINT [PK_refEmplAutoFaxStatus] PRIMARY KEY CLUSTERED ([refEmplAutoFaxStatusID] ASC) WITH (FILLFACTOR = 50)
);

