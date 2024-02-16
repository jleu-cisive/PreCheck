CREATE TABLE [dbo].[refApplFlagStatusCustom] (
    [refApplFlagStatusCustomID] INT          IDENTITY (1, 1) NOT NULL,
    [FlagStatusID]              INT          NOT NULL,
    [CustomFlagStatus]          VARCHAR (50) NOT NULL,
    [CLNO]                      INT          NOT NULL,
    CONSTRAINT [PK_refApplFlagStatusCustom] PRIMARY KEY CLUSTERED ([refApplFlagStatusCustomID] ASC) WITH (FILLFACTOR = 50)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [U_CLNO_FlagStatusID]
    ON [dbo].[refApplFlagStatusCustom]([FlagStatusID] ASC, [CLNO] ASC) WITH (FILLFACTOR = 50)
    ON [FG_INDEX];

