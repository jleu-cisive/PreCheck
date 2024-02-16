CREATE TABLE [dbo].[Countiesbis] (
    [County]           VARCHAR (25)  NOT NULL,
    [Crim_Source]      VARCHAR (2)   NULL,
    [Crim_Phone]       VARCHAR (20)  NULL,
    [Crim_Fax]         VARCHAR (20)  NULL,
    [Crim_Addr]        VARCHAR (255) NULL,
    [Crim_Comment]     VARCHAR (20)  NULL,
    [Crim_DefaultRate] SMALLMONEY    NOT NULL,
    [Civ_Source]       VARCHAR (2)   NULL,
    [Civ_Phone]        VARCHAR (20)  NULL,
    [Civ_Fax]          VARCHAR (20)  NULL,
    [Civ_Addr]         VARCHAR (255) NULL,
    [Civ_Comment]      VARCHAR (20)  NULL,
    [State]            VARCHAR (50)  NULL,
    [A_County]         VARCHAR (50)  NULL,
    CONSTRAINT [PK_Countiesbis] PRIMARY KEY CLUSTERED ([County] ASC) WITH (FILLFACTOR = 50)
);

