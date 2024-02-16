CREATE TABLE [dbo].[OccHealthServicesResultsLog] (
    [ID]             INT            IDENTITY (1, 1) NOT NULL,
    [ProviderID]     VARCHAR (25)   NULL,
    [OrderID]        VARCHAR (25)   NULL,
    [SSNOrOtherID]   VARCHAR (25)   NULL,
    [ScreeningType]  VARCHAR (25)   NULL,
    [FirstName]      VARCHAR (25)   NULL,
    [LastName]       VARCHAR (25)   NULL,
    [OrderStatus]    VARCHAR (25)   NULL,
    [DateReceived]   DATETIME       NULL,
    [PDFResult]      NVARCHAR (MAX) NULL,
    [TestResult]     VARCHAR (25)   NULL,
    [ResultDate]     DATETIME       NULL,
    [LastUpdated]    DATETIME       CONSTRAINT [DF_OccHealthServicesResultsLog_LastUpdated] DEFAULT (getdate()) NOT NULL,
    [ChainOfCustody] VARCHAR (25)   NULL,
    [ReasonForTest]  VARCHAR (25)   NULL,
    [XMLResponse]    XML            NULL,
    CONSTRAINT [PK_OccHealthServicesResultsLog] PRIMARY KEY CLUSTERED ([ID] ASC)
);

