CREATE TABLE [dbo].[refHEVNEmployerStatus] (
    [HEVNEmployerStatusID] INT          IDENTITY (1, 1) NOT NULL,
    [HEVNEmployerStatus]   VARCHAR (50) NULL,
    CONSTRAINT [PK_refHEVNEmployerStatus] PRIMARY KEY CLUSTERED ([HEVNEmployerStatusID] ASC) WITH (FILLFACTOR = 50)
);

