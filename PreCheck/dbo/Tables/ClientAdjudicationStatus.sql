CREATE TABLE [dbo].[ClientAdjudicationStatus] (
    [ClientAdjudicationStatusID] INT           IDENTITY (1, 1) NOT NULL,
    [Description]                VARCHAR (100) NOT NULL,
    [DisplayName]                VARCHAR (100) NULL,
    [CLNO]                       INT           NULL,
    CONSTRAINT [PK_ClientAdjudicationStatus] PRIMARY KEY CLUSTERED ([ClientAdjudicationStatusID] ASC) WITH (FILLFACTOR = 50)
);

