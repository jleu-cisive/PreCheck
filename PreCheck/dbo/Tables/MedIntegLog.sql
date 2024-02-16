CREATE TABLE [dbo].[MedIntegLog] (
    [MedIntegLogID]        INT          IDENTITY (1, 1) NOT NULL,
    [APNO]                 INT          NULL,
    [Username]             VARCHAR (25) NULL,
    [Status]               VARCHAR (25) NULL,
    [ChangeDate]           DATETIME     NULL,
    [MedIntegApplReviewID] INT          NULL,
    CONSTRAINT [PK_MedIntegLog] PRIMARY KEY CLUSTERED ([MedIntegLogID] ASC) WITH (FILLFACTOR = 50)
);


GO
CREATE NONCLUSTERED INDEX [Status_ChangeDate_Includes]
    ON [dbo].[MedIntegLog]([Status] ASC, [ChangeDate] ASC)
    INCLUDE([APNO]) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [<Name of Missing Index, sysname,>]
    ON [dbo].[MedIntegLog]([APNO] ASC)
    INCLUDE([Status]);

