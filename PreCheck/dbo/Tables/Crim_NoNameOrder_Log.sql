CREATE TABLE [dbo].[Crim_NoNameOrder_Log] (
    [ID]         INT      IDENTITY (1, 1) NOT NULL,
    [crimID]     INT      NOT NULL,
    [APNO]       INT      NOT NULL,
    [txtlast]    CHAR (1) NULL,
    [txtalias]   CHAR (1) NULL,
    [txtalias2]  CHAR (1) NULL,
    [txtalia3]   CHAR (1) NULL,
    [txtalias4]  CHAR (1) NULL,
    [LastUpdate] DATETIME CONSTRAINT [DF_Crim_NoNameOrder_Log_LastUpdate] DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_Crim_NoNameOrder_Log] PRIMARY KEY CLUSTERED ([ID] ASC) WITH (FILLFACTOR = 50)
);

