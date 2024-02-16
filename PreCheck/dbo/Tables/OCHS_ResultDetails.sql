CREATE TABLE [dbo].[OCHS_ResultDetails] (
    [TID]            INT           IDENTITY (1, 1) NOT NULL,
    [ProviderID]     VARCHAR (25)  NULL,
    [OrderIDOrApno]  VARCHAR (25)  NULL,
    [SSNOrOtherID]   VARCHAR (25)  NULL,
    [ScreeningType]  VARCHAR (25)  NULL,
    [FirstName]      VARCHAR (50)  NULL,
    [LastName]       VARCHAR (50)  NULL,
    [FullName]       VARCHAR (100) NULL,
    [OrderStatus]    VARCHAR (25)  NULL,
    [DateReceived]   DATETIME      NULL,
    [TestResult]     VARCHAR (25)  NULL,
    [TestResultDate] DATETIME      NULL,
    [LastUpdate]     DATETIME      CONSTRAINT [DF_dbo]].[OCHS_ResultDetails_LastUpdate] DEFAULT (getdate()) NOT NULL,
    [CoC]            VARCHAR (25)  NULL,
    [ReasonForTest]  VARCHAR (25)  NULL,
    [CLNO]           SMALLINT      NULL,
    CONSTRAINT [PK_OCHS_ResultDetails] PRIMARY KEY CLUSTERED ([TID] ASC) WITH (FILLFACTOR = 50)
);


GO
CREATE NONCLUSTERED INDEX [IDX_OCHS_ResultDetails_OrderIDOrAPNO_Inc]
    ON [dbo].[OCHS_ResultDetails]([OrderIDOrApno] ASC, [LastUpdate] ASC)
    INCLUDE([TID], [SSNOrOtherID], [OrderStatus], [DateReceived]) WITH (FILLFACTOR = 70);


GO
CREATE NONCLUSTERED INDEX [IX_OCHS_ResultDetails_LastUpdate_Inc]
    ON [dbo].[OCHS_ResultDetails]([LastUpdate] ASC)
    INCLUDE([TID], [OrderIDOrApno], [SSNOrOtherID], [FirstName], [LastName], [OrderStatus], [TestResult], [TestResultDate], [CoC], [ReasonForTest], [CLNO]) WITH (FILLFACTOR = 70);


GO
CREATE NONCLUSTERED INDEX [IDX_OCHS_ResultDetails_SSNOrOtherId]
    ON [dbo].[OCHS_ResultDetails]([SSNOrOtherID] ASC, [OrderIDOrApno] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_OCHS_ResultDetails_CLNO]
    ON [dbo].[OCHS_ResultDetails]([CLNO] ASC)
    INCLUDE([TID], [OrderIDOrApno], [SSNOrOtherID], [FirstName], [LastName], [OrderStatus], [TestResult], [TestResultDate], [LastUpdate], [CoC], [ReasonForTest]);


GO
CREATE NONCLUSTERED INDEX [IX_OCHS_ResultDetails_ProviderID]
    ON [dbo].[OCHS_ResultDetails]([ProviderID] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_OCHS_ResultDetails_CLNO_LastUpdate]
    ON [dbo].[OCHS_ResultDetails]([CLNO] ASC, [LastUpdate] ASC)
    INCLUDE([TID], [FirstName], [LastName], [OrderStatus], [TestResult], [CoC], [OrderIDOrApno])
    ON [FG_INDEX];

