CREATE TABLE [dbo].[ApplClientDataHistory] (
    [ApplClientDataHistoryID] INT          IDENTITY (1, 1) NOT NULL,
    [APNO]                    INT          NOT NULL,
    [ClientAPNO]              VARCHAR (50) NOT NULL,
    [PackageCode]             VARCHAR (25) NULL,
    [ClientNote]              TEXT         NULL,
    [CreatedDate]             DATETIME     NOT NULL,
    CONSTRAINT [PK_ApplClientDataHistory] PRIMARY KEY CLUSTERED ([ApplClientDataHistoryID] ASC) WITH (FILLFACTOR = 90)
) TEXTIMAGE_ON [PRIMARY];


GO
CREATE NONCLUSTERED INDEX [APNO_Includes]
    ON [dbo].[ApplClientDataHistory]([APNO] ASC)
    INCLUDE([PackageCode]) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [APNO]
    ON [dbo].[ApplClientDataHistory]([APNO] ASC) WITH (FILLFACTOR = 100);

