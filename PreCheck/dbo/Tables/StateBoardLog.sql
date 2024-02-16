CREATE TABLE [dbo].[StateBoardLog] (
    [StateBoardLogID]             INT            IDENTITY (1, 1) NOT NULL,
    [StateBoardDisciplinaryRunID] INT            NULL,
    [UserID]                      VARCHAR (20)   NULL,
    [CommentDate]                 DATETIME       NULL,
    [Comment]                     VARCHAR (8000) NULL,
    CONSTRAINT [PK_StateBoardLog] PRIMARY KEY CLUSTERED ([StateBoardLogID] ASC) WITH (FILLFACTOR = 50)
);

