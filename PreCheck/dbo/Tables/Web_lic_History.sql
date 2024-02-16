CREATE TABLE [dbo].[Web_lic_History] (
    [id]             INT           IDENTITY (1, 1) NOT NULL,
    [history_apno]   VARCHAR (50)  NULL,
    [history_date]   SMALLDATETIME NULL,
    [history_status] VARCHAR (50)  NULL,
    [proflicid]      INT           NULL,
    CONSTRAINT [PK_Web_lic_History] PRIMARY KEY CLUSTERED ([id] ASC) WITH (FILLFACTOR = 50)
);

