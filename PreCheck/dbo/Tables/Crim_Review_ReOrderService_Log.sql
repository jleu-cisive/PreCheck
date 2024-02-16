CREATE TABLE [dbo].[Crim_Review_ReOrderService_Log] (
    [ReviewReOrderServiceLogID] INT          IDENTITY (1, 1) NOT NULL,
    [APNO]                      INT          NOT NULL,
    [OldStatus]                 VARCHAR (1)  NULL,
    [NewStatus]                 VARCHAR (1)  NULL,
    [Createddate]               DATETIME     DEFAULT (getdate()) NULL,
    [CNTY_NO]                   INT          NULL,
    [County]                    VARCHAR (50) NULL,
    CONSTRAINT [PK_[ReviewReOrderServiceLogID] PRIMARY KEY CLUSTERED ([ReviewReOrderServiceLogID] ASC) WITH (FILLFACTOR = 90)
);

