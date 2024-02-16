CREATE TABLE [dbo].[QReportUserMap] (
    [QReportUserMapID] INT           IDENTITY (1, 1) NOT NULL,
    [UserID]           VARCHAR (8)   NOT NULL,
    [QReportID]        INT           NOT NULL,
    [LastParameters]   VARCHAR (400) NULL,
    CONSTRAINT [PK_QReportUserMap] PRIMARY KEY CLUSTERED ([QReportUserMapID] ASC) WITH (FILLFACTOR = 50)
);


GO
CREATE NONCLUSTERED INDEX [IDX_QReportUserMap_UserID]
    ON [dbo].[QReportUserMap]([UserID] ASC) WITH (FILLFACTOR = 70);

