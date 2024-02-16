CREATE TABLE [dbo].[ClientConfig] (
    [ClientConfigID]            INT          IDENTITY (1, 1) NOT NULL,
    [CLNO]                      INT          NOT NULL,
    [HRNGNumberOfRandomRecords] INT          NOT NULL,
    [HRNGFrequencyPeriod]       VARCHAR (30) NULL,
    [HRNGInterval]              INT          NULL,
    [HRNGLastRunDate]           DATETIME     NULL,
    [HRNGIsActive]              BIT          NULL,
    [HRNGClientContactID]       INT          NULL,
    [ShortRelease]              BIT          CONSTRAINT [DF_ClientConfig_ShortRelease] DEFAULT ((0)) NULL,
    [ComboEmplPersRefCount]     BIT          NULL,
    [WebServiceParentCLNO]      INT          NULL,
    [DisplayPendingOrderMgmt]   BIT          CONSTRAINT [DF_ClientConfig_DisplayPendingOrderMgmt_1] DEFAULT ((0)) NULL,
    [DisplayAdverseAction]      BIT          NULL,
    [TimeZoneID]                INT          NULL,
    CONSTRAINT [PK_ClientConfig] PRIMARY KEY CLUSTERED ([ClientConfigID] ASC) WITH (FILLFACTOR = 50)
);


GO
CREATE NONCLUSTERED INDEX [IDX_ClientConfig_CLNO]
    ON [dbo].[ClientConfig]([CLNO] ASC) WITH (FILLFACTOR = 70);

