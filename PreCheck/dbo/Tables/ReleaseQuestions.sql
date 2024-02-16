CREATE TABLE [dbo].[ReleaseQuestions] (
    [ReleaseQuestionsID] INT           IDENTITY (1, 1) NOT NULL,
    [CLNO]               INT           NOT NULL,
    [Question]           VARCHAR (700) NOT NULL,
    [QuestionType]       VARCHAR (10)  NOT NULL,
    [Sequence]           INT           NOT NULL,
    [IsMandatory]        BIT           NULL,
    CONSTRAINT [PK_ReleaseQuestions] PRIMARY KEY CLUSTERED ([ReleaseQuestionsID] ASC) WITH (FILLFACTOR = 50)
);

