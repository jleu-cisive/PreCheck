CREATE TABLE [dbo].[Crim_Web_History] (
    [id]              INT          IDENTITY (1, 1) NOT NULL,
    [ordered]         VARCHAR (50) NULL,
    [clear]           VARCHAR (50) NULL,
    [crimenteredtime] VARCHAR (50) NULL,
    [status]          VARCHAR (50) NULL,
    [batchnumber]     VARCHAR (50) NULL,
    [changedate]      DATETIME     NULL,
    [crimid]          INT          NULL,
    [apno]            INT          NULL,
    [cnty_no]         VARCHAR (20) NULL,
    [userid]          VARCHAR (8)  NULL,
    [iris_flag]       VARCHAR (2)  NULL,
    CONSTRAINT [PK_Crim_Web_History] PRIMARY KEY CLUSTERED ([id] ASC) WITH (FILLFACTOR = 50)
);

