CREATE TABLE [dbo].[AppStatusDetail] (
    [AppStatusDetailID] INT          IDENTITY (1, 1) NOT NULL,
    [AppStatusItem]     VARCHAR (3)  NULL,
    [AppStatusValue]    VARCHAR (20) NULL
) ON [PRIMARY];

