CREATE TABLE [dbo].[ClientProgram] (
    [ClientProgramID] INT          IDENTITY (1, 1) NOT NULL,
    [CLNO]            INT          NOT NULL,
    [Name]            VARCHAR (50) NOT NULL,
    [IsActive]        BIT          NULL,
    CONSTRAINT [PK_ClientProgram] PRIMARY KEY CLUSTERED ([ClientProgramID] ASC) WITH (FILLFACTOR = 50)
);

