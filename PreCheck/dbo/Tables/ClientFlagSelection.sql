CREATE TABLE [dbo].[ClientFlagSelection] (
    [ClientFlagSelectionID] INT          IDENTITY (1, 1) NOT NULL,
    [CLNO]                  INT          NOT NULL,
    [Section]               VARCHAR (50) NOT NULL,
    [SectionStatusID]       INT          NOT NULL,
    [ClientFlag]            BIT          NOT NULL,
    CONSTRAINT [PK_ClientFlagSelection] PRIMARY KEY CLUSTERED ([ClientFlagSelectionID] ASC) WITH (FILLFACTOR = 50)
);

