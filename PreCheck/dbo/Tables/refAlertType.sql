CREATE TABLE [dbo].[refAlertType] (
    [refAlertTypeID]      INT          IDENTITY (1, 1) NOT NULL,
    [Description]         VARCHAR (50) NULL,
    [refPC_ApplicationID] INT          NULL,
    CONSTRAINT [PK_refApplAlertStatus] PRIMARY KEY CLUSTERED ([refAlertTypeID] ASC) WITH (FILLFACTOR = 50)
);

