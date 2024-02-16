CREATE TABLE [dbo].[Iris_County_Rules] (
    [id]          INT            IDENTITY (1, 1) NOT NULL,
    [beg_date]    NVARCHAR (50)  NULL,
    [end_date]    NVARCHAR (50)  NULL,
    [Active]      NVARCHAR (1)   NULL,
    [notes]       NVARCHAR (200) NULL,
    [vendor1]     INT            NULL,
    [vendor2]     INT            NULL,
    [vendor3]     INT            NULL,
    [vendor4]     INT            NULL,
    [vendor5]     INT            NULL,
    [vendor6]     INT            NULL,
    [CountyState] INT            NULL,
    CONSTRAINT [PK_Iris_County_Rules] PRIMARY KEY CLUSTERED ([id] ASC) WITH (FILLFACTOR = 50)
);

