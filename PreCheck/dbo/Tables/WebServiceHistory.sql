CREATE TABLE [dbo].[WebServiceHistory] (
    [WebServiceHistoryID] INT          IDENTITY (1, 1) NOT NULL,
    [ClientID]            INT          NULL,
    [ServiceDate]         DATETIME     CONSTRAINT [DF_WebServiceHistory_ServiceDate] DEFAULT (getdate()) NULL,
    [NameOfService]       VARCHAR (50) NULL,
    [RequestStartDate]    DATETIME     NULL,
    [RequestEndDate]      DATETIME     NULL,
    [CompletedOnly]       VARCHAR (4)  NULL,
    [ActivityCode]        VARCHAR (50) NULL,
    [Pdf]                 VARCHAR (5)  NULL,
    CONSTRAINT [PK_WebServiceHistory] PRIMARY KEY CLUSTERED ([WebServiceHistoryID] ASC) WITH (FILLFACTOR = 50)
);

