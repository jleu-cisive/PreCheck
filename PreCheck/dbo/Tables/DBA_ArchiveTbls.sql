CREATE TABLE [dbo].[DBA_ArchiveTbls] (
    [Table]               VARCHAR (255) NOT NULL,
    [Duration]            INT           NULL,
    [Archive Database]    VARCHAR (255) NULL,
    [Archive_Table]       VARCHAR (255) NULL,
    [Last_ArciveDate]     DATETIME      NULL,
    [ArchiveColumnFilter] VARCHAR (255) NULL,
    [Active]              BIT           DEFAULT ((1)) NULL,
    CONSTRAINT [PK_DBA_ArchiveTbls] PRIMARY KEY CLUSTERED ([Table] ASC)
);

