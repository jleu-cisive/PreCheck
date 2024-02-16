CREATE TABLE [dbo].[Appl_StatusLog] (
    [AppStatusLogID]     INT           IDENTITY (1, 1) NOT NULL,
    [Apno]               INT           NOT NULL,
    [HostName]           VARCHAR (100) NULL,
    [login_name]         VARCHAR (100) NULL,
    [client_net_address] VARCHAR (100) NULL,
    [ProgramName]        VARCHAR (150) NULL,
    [Prev_apstatus]      CHAR (1)      NULL,
    [Curr_apstatus]      CHAR (1)      NULL,
    [ChangeDate]         DATETIME      CONSTRAINT [DF_Appl_StatusLog_ChangeDate] DEFAULT (getdate()) NULL,
    PRIMARY KEY CLUSTERED ([AppStatusLogID] ASC) WITH (FILLFACTOR = 50)
);


GO
CREATE NONCLUSTERED INDEX [IDX_ChangeDate_Apno]
    ON [dbo].[Appl_StatusLog]([ChangeDate] ASC)
    INCLUDE([Apno]);


GO
CREATE NONCLUSTERED INDEX [Apno_ChangeDate]
    ON [dbo].[Appl_StatusLog]([Apno] ASC, [ChangeDate] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [IX_Appl_StatusLog_Curr_apstatus_ChangeDate]
    ON [dbo].[Appl_StatusLog]([Curr_apstatus] ASC, [ChangeDate] ASC)
    INCLUDE([Apno]) WITH (FILLFACTOR = 95)
    ON [FG_INDEX];

