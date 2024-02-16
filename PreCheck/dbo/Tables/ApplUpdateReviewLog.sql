CREATE TABLE [dbo].[ApplUpdateReviewLog] (
    [ApplUpdateReviewLogID] INT          IDENTITY (1, 1) NOT NULL,
    [APNO]                  INT          NULL,
    [ReopenDate]            DATETIME     NULL,
    [ReviewedBy]            VARCHAR (50) NULL,
    [LogTime]               DATETIME     NULL,
    CONSTRAINT [PK_dbo.ApplUpdateReviewLog] PRIMARY KEY CLUSTERED ([ApplUpdateReviewLogID] ASC) WITH (FILLFACTOR = 50)
);


GO
CREATE NONCLUSTERED INDEX [APNO]
    ON [dbo].[ApplUpdateReviewLog]([APNO] ASC) WITH (FILLFACTOR = 100);

