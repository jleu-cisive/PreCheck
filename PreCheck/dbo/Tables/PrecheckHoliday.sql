CREATE TABLE [dbo].[PrecheckHoliday] (
    [PrecheckHolidayID] INT          IDENTITY (1, 1) NOT NULL,
    [Name]              VARCHAR (50) NULL,
    [Date]              DATETIME     NULL,
    CONSTRAINT [PK_PrecheckHoliday] PRIMARY KEY CLUSTERED ([PrecheckHolidayID] ASC) WITH (FILLFACTOR = 50)
);

