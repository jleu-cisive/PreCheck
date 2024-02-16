CREATE TABLE [dbo].[refFollowupInterval] (
    [refFollowupIntervalID] INT          IDENTITY (1, 1) NOT NULL,
    [Interval]              VARCHAR (50) NOT NULL,
    [Sequence]              INT          NULL,
    [ShowForCallback]       BIT          CONSTRAINT [DF_refFollowupInterval_ShowForCallback] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_refFollowupInterval] PRIMARY KEY CLUSTERED ([refFollowupIntervalID] ASC)
);

