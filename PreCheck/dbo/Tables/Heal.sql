CREATE TABLE [dbo].[Heal] (
    [id]              INT            IDENTITY (1, 1) NOT NULL,
    [LastName]        NVARCHAR (50)  NULL,
    [FirstName]       NVARCHAR (50)  NULL,
    [MI]              NVARCHAR (20)  NULL,
    [City]            NVARCHAR (30)  NULL,
    [State]           NVARCHAR (30)  NULL,
    [Curr_Amt_Due]    NVARCHAR (53)  NULL,
    [Discipline]      NVARCHAR (100) NULL,
    [School_Name]     NVARCHAR (100) NULL,
    [City1]           NVARCHAR (30)  NULL,
    [State1]          NVARCHAR (30)  NULL,
    [Grad_Date]       SMALLDATETIME  NULL,
    [Web_Change_Date] SMALLDATETIME  NULL,
    [Web_Code]        NVARCHAR (100) NULL,
    [Prev_Name]       NVARCHAR (100) NULL,
    [Prev_State]      NVARCHAR (30)  NULL,
    [category]        VARCHAR (50)   NULL,
    [Action]          VARCHAR (50)   NULL,
    [Source]          VARCHAR (50)   NULL,
    [link]            VARCHAR (100)  NULL,
    CONSTRAINT [PK_Heal] PRIMARY KEY CLUSTERED ([id] ASC) WITH (FILLFACTOR = 50)
);

