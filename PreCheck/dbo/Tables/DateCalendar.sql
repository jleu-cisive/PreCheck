CREATE TABLE [dbo].[DateCalendar] (
    [DATE]         DATETIME      NULL,
    [Year]         INT           NULL,
    [QTR]          NVARCHAR (30) NULL,
    [MONTH]        NVARCHAR (30) NULL,
    [Week_of_Year] NVARCHAR (30) NULL,
    [IsWeekDay]    BIT           NULL,
    [IsWorkDay]    BIT           NULL
);

