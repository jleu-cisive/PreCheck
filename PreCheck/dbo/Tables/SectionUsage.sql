CREATE TABLE [dbo].[SectionUsage] (
    [SectionUsageID] INT          IDENTITY (1, 1) NOT NULL,
    [TableName]      VARCHAR (50) NOT NULL,
    [TableID]        VARCHAR (20) NOT NULL,
    [APNO]           INT          NOT NULL,
    [TimeOpen]       DATETIME     NULL,
    [TimeClose]      DATETIME     NULL,
    [UserID]         VARCHAR (8)  NULL,
    [Role]           VARCHAR (50) NULL,
    CONSTRAINT [PK_SectionUsage] PRIMARY KEY CLUSTERED ([SectionUsageID] ASC) WITH (FILLFACTOR = 50)
);

