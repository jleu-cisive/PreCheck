CREATE TABLE [dbo].[CrimSendLog] (
    [CrimSendLogID]  INT          IDENTITY (1, 1) NOT NULL,
    [DeliveryMethod] VARCHAR (50) NULL,
    [Status]         VARCHAR (50) NULL,
    [LinkID]         INT          NULL,
    [LogDate]        DATETIME     NOT NULL,
    CONSTRAINT [PK_CrimSendLog] PRIMARY KEY CLUSTERED ([CrimSendLogID] ASC) WITH (FILLFACTOR = 50)
);

