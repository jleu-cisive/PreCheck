CREATE TABLE [dbo].[LightningFaxStatus] (
    [LightningFaxStatusID] INT          IDENTITY (1, 1) NOT NULL,
    [Subject]              VARCHAR (50) NULL,
    [Company]              VARCHAR (50) NULL,
    [FaxNumber]            VARCHAR (50) NULL,
    [ReturnCode]           VARCHAR (50) CONSTRAINT [DF_LightningFaxStatus_ReturnCode] DEFAULT ((-1)) NOT NULL,
    [CreatedDate]          DATETIME     NULL,
    [RetriesLeft]          VARCHAR (20) NULL,
    [UserId]               VARCHAR (30) NULL,
    [ChannelNumber]        VARCHAR (30) NULL,
    [NbOfFaxPages]         VARCHAR (30) NULL,
    [RecordStatus]         VARCHAR (50) NULL,
    CONSTRAINT [PK_LightningFaxStatus] PRIMARY KEY CLUSTERED ([LightningFaxStatusID] ASC) WITH (FILLFACTOR = 50)
);

