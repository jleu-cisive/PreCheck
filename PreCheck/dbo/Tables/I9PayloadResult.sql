CREATE TABLE [dbo].[I9PayloadResult] (
    [I9PayloadId]       INT           IDENTITY (1, 1) NOT NULL,
    [I9LogId]           BIGINT        NOT NULL,
    [I9Payload]         VARCHAR (MAX) NOT NULL,
    [CreateDate]        DATETIME      CONSTRAINT [DF_I9PayloadResult_CreateDate] DEFAULT (getdate()) NULL,
    [i9CallbackRequest] VARCHAR (MAX) NULL,
    CONSTRAINT [PK_I9PayloadResult] PRIMARY KEY CLUSTERED ([I9PayloadId] ASC)
);

