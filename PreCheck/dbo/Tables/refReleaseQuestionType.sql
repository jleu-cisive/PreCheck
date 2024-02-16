CREATE TABLE [dbo].[refReleaseQuestionType] (
    [ReleaseQuestionTypeID] INT          IDENTITY (1, 1) NOT NULL,
    [QuestionType]          VARCHAR (10) NOT NULL,
    CONSTRAINT [PK_ReleaseQuestionTypeID] PRIMARY KEY CLUSTERED ([ReleaseQuestionTypeID] ASC) WITH (FILLFACTOR = 50)
);

