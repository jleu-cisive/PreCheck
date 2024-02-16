CREATE TABLE [dbo].[ApplSections] (
    [ApplSectionID] INT           IDENTITY (1, 1) NOT NULL,
    [Section]       VARCHAR (50)  NOT NULL,
    [Description]   VARCHAR (50)  NOT NULL,
    [UserID_MGR]    VARCHAR (20)  NULL,
    [MGR_Email]     VARCHAR (255) NULL,
    CONSTRAINT [PK_ApplSections] PRIMARY KEY CLUSTERED ([ApplSectionID] ASC) WITH (FILLFACTOR = 50)
);

