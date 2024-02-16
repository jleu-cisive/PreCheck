CREATE TABLE [dbo].[Integration_OrderMgmt_refUserAction] (
    [refUserActionID] INT          IDENTITY (1, 1) NOT NULL,
    [UserAction]      VARCHAR (50) NOT NULL,
    CONSTRAINT [PK_Integration_refUserAction] PRIMARY KEY CLUSTERED ([refUserActionID] ASC) WITH (FILLFACTOR = 50)
);

