CREATE TABLE [dbo].[DisciplinaryUserRun] (
    [DisciplinaryUserRunID]       INT          IDENTITY (1, 1) NOT NULL,
    [StateBoardDisciplinaryRunID] INT          NULL,
    [User]                        VARCHAR (10) NULL,
    [RunDate]                     DATETIME     NULL,
    [IsFirst]                     BIT          NOT NULL,
    CONSTRAINT [PK_DisciplinaryUserRun] PRIMARY KEY CLUSTERED ([DisciplinaryUserRunID] ASC) WITH (FILLFACTOR = 50)
);

