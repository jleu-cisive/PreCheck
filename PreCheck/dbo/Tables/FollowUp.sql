CREATE TABLE [dbo].[FollowUp] (
    [FollowUpID]   INT      IDENTITY (1, 1) NOT NULL,
    [Apno]         INT      NOT NULL,
    [UserID]       CHAR (8) NULL,
    [FollowUpDate] DATETIME NULL,
    [IsCompleted]  BIT      CONSTRAINT [DF_FollowUp_IsCompleted] DEFAULT ((0)) NULL,
    [Note]         TEXT     NULL,
    [CreatedDate]  DATETIME NULL,
    CONSTRAINT [PK_FollowUp] PRIMARY KEY CLUSTERED ([FollowUpID] ASC)
) TEXTIMAGE_ON [PRIMARY];


GO
CREATE NONCLUSTERED INDEX [IX_APNO]
    ON [dbo].[FollowUp]([Apno] ASC)
    INCLUDE([FollowUpDate]) WITH (FILLFACTOR = 50)
    ON [FG_INDEX];

