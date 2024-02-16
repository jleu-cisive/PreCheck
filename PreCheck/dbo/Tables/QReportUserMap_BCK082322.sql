CREATE TABLE [dbo].[QReportUserMap_BCK082322] (
    [QReportUserMapID] INT           IDENTITY (1, 1) NOT NULL,
    [UserID]           VARCHAR (8)   NOT NULL,
    [QReportID]        INT           NOT NULL,
    [LastParameters]   VARCHAR (400) NULL
);

