CREATE TABLE [dbo].[ReleaseForm] (
    [ReleaseFormID]     INT          IDENTITY (1, 1) NOT NULL,
    [pdf]               IMAGE        NULL,
    [ssn]               VARCHAR (50) NULL,
    [date]              DATETIME     CONSTRAINT [DF_ReleaseForm_date] DEFAULT (getdate()) NULL,
    [first]             VARCHAR (50) NULL,
    [last]              VARCHAR (50) NULL,
    [CLNO]              INT          NULL,
    [i94]               VARCHAR (50) NULL,
    [EnteredVia]        VARCHAR (15) NULL,
    [DOB]               DATETIME     NULL,
    [ClientAPPNO]       VARCHAR (50) NULL,
    [ApplicantInfo_pdf] IMAGE        NULL,
    CONSTRAINT [PK_ReleaseForm] PRIMARY KEY CLUSTERED ([ReleaseFormID] ASC) WITH (FILLFACTOR = 90)
) TEXTIMAGE_ON [PRIMARY];


GO
CREATE NONCLUSTERED INDEX [IX_SSN_CLNO]
    ON [dbo].[ReleaseForm]([ssn] ASC, [CLNO] ASC)
    INCLUDE([ReleaseFormID], [date]) WITH (FILLFACTOR = 50);


GO
CREATE NONCLUSTERED INDEX [IDX_ReleaseForm_ClientAPPNO_CLNO]
    ON [dbo].[ReleaseForm]([ClientAPPNO] ASC, [CLNO] ASC) WITH (FILLFACTOR = 70);


GO
CREATE NONCLUSTERED INDEX [IDX_ReleaseForm_CLNO]
    ON [dbo].[ReleaseForm]([CLNO] ASC)
    INCLUDE([ReleaseFormID], [ssn], [first], [last], [ClientAPPNO]) WITH (FILLFACTOR = 70);


GO
CREATE STATISTICS [_dta_stat_releaseform]
    ON [dbo].[ReleaseForm]([CLNO], [date]);

