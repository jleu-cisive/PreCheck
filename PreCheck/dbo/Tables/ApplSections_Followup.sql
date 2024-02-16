CREATE TABLE [dbo].[ApplSections_Followup] (
    [ApplSections_FollowupID] INT          IDENTITY (1, 1) NOT NULL,
    [ApplSectionID]           INT          NOT NULL,
    [Apno]                    INT          NULL,
    [SectionID]               VARCHAR (10) NOT NULL,
    [Reason]                  VARCHAR (50) NOT NULL,
    [CreatedBy]               VARCHAR (10) NOT NULL,
    [CreatedOn]               DATETIME     CONSTRAINT [DF_ApplSections_Followup_CreatedOn] DEFAULT (getdate()) NOT NULL,
    [FollowupOn]              DATETIME     NOT NULL,
    [CompletedBy]             VARCHAR (50) NULL,
    [CompletedOn]             DATETIME     NULL,
    [IsCompleted]             BIT          CONSTRAINT [DF_Table_2_IsCompleted?] DEFAULT ((0)) NOT NULL,
    [Repeat_Followup]         BIT          CONSTRAINT [DF_Table_2_FollowupAgain] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_ApplSections_Followup] PRIMARY KEY CLUSTERED ([ApplSections_FollowupID] ASC) WITH (FILLFACTOR = 50)
);


GO
CREATE NONCLUSTERED INDEX [IX_ApplSections_Followup_SectionID_IsCompleted_Inc]
    ON [dbo].[ApplSections_Followup]([SectionID] ASC, [IsCompleted] ASC, [Repeat_Followup] ASC, [FollowupOn] ASC)
    INCLUDE([ApplSectionID], [Apno]) WITH (FILLFACTOR = 70);


GO
CREATE NONCLUSTERED INDEX [ApplSectionID_Apno_Includes]
    ON [dbo].[ApplSections_Followup]([ApplSectionID] ASC, [Apno] ASC)
    INCLUDE([SectionID], [Reason], [FollowupOn], [Repeat_Followup]) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [ApplSectionID_Apno_Repeat_Followup]
    ON [dbo].[ApplSections_Followup]([ApplSectionID] ASC, [Apno] ASC, [Repeat_Followup] ASC) WITH (FILLFACTOR = 100);

