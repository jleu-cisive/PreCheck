CREATE TABLE [dbo].[PositiveIDResponseLog] (
    [ResponseID] INT          IDENTITY (1, 1) NOT NULL,
    [Response]   TEXT         NULL,
    [SSN]        VARCHAR (11) NOT NULL,
    [SearchDate] DATETIME     CONSTRAINT [DF_PositiveIDResponseLog_SearchDate] DEFAULT (getdate()) NOT NULL,
    [Aliases]    TEXT         NULL,
    [Counties]   TEXT         NULL,
    CONSTRAINT [PK_PositiveIDResponseLog] PRIMARY KEY CLUSTERED ([ResponseID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [SearchDate_Includes]
    ON [dbo].[PositiveIDResponseLog]([SearchDate] ASC)
    INCLUDE([SSN]) WITH (FILLFACTOR = 100);

