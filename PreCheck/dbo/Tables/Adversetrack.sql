CREATE TABLE [dbo].[Adversetrack] (
    [id]           INT           IDENTITY (1, 1) NOT NULL,
    [apno]         INT           NULL,
    [mailed]       VARCHAR (3)   NULL,
    [Mail_Time]    DATETIME      CONSTRAINT [DF_Adversetrack_Mail_Time] DEFAULT (getdate()) NULL,
    [ssn]          VARCHAR (20)  NULL,
    [notes]        VARCHAR (200) NULL,
    [client]       INT           NULL,
    [UserMaildate] VARCHAR (15)  NULL,
    CONSTRAINT [PK_Adversetrack] PRIMARY KEY CLUSTERED ([id] ASC) WITH (FILLFACTOR = 50)
);

