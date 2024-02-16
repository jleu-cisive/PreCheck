CREATE TABLE [dbo].[Web_Edu_History] (
    [id]             INT           IDENTITY (1, 1) NOT NULL,
    [History_apno]   VARCHAR (50)  NULL,
    [history_date]   SMALLDATETIME NULL,
    [history_status] VARCHAR (50)  NULL,
    [Educatid]       INT           NULL,
    CONSTRAINT [PK_Edu_web_status] PRIMARY KEY CLUSTERED ([id] ASC) WITH (FILLFACTOR = 50)
);

