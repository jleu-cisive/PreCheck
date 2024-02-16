CREATE TABLE [dbo].[refApplFlagStatus] (
    [FlagStatusID] INT          NOT NULL,
    [FlagStatus]   VARCHAR (50) NOT NULL,
    CONSTRAINT [PK_refApplFlagStatus] PRIMARY KEY CLUSTERED ([FlagStatusID] ASC) WITH (FILLFACTOR = 50)
);

