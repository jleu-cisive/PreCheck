CREATE TABLE [dbo].[OCHS_ResultDetails_backup] (
    [TID]            INT          IDENTITY (1, 1) NOT NULL,
    [ProviderID]     VARCHAR (25) NULL,
    [OrderIDOrApno]  VARCHAR (25) NULL,
    [SSNOrOtherID]   VARCHAR (25) NULL,
    [ScreeningType]  VARCHAR (25) NULL,
    [FirstName]      VARCHAR (25) NULL,
    [LastName]       VARCHAR (25) NULL,
    [FullName]       VARCHAR (50) NULL,
    [OrderStatus]    VARCHAR (25) NULL,
    [DateReceived]   DATETIME     NULL,
    [TestResult]     VARCHAR (25) NULL,
    [TestResultDate] DATETIME     NULL,
    [LastUpdate]     DATETIME     CONSTRAINT [DF_dbo]].[OCHS_ResultDetails_New_LastUpdate] DEFAULT (getdate()) NOT NULL,
    [CoC]            VARCHAR (25) NULL,
    [ReasonForTest]  VARCHAR (25) NULL,
    [CLNO]           SMALLINT     NULL,
    CONSTRAINT [PK_OCHS_ResultDetails_New] PRIMARY KEY CLUSTERED ([TID] ASC) WITH (FILLFACTOR = 50)
);

