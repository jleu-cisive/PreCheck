CREATE TABLE [dbo].[refRescreeningPeriod] (
    [refRescreeningPeriodID] INT          IDENTITY (1, 1) NOT NULL,
    [Description]            VARCHAR (25) NOT NULL,
    [Months]                 INT          NULL,
    CONSTRAINT [PK_refRescreeningPeriod] PRIMARY KEY CLUSTERED ([refRescreeningPeriodID] ASC) WITH (FILLFACTOR = 50)
);

