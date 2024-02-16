CREATE TABLE [dbo].[EZVerifyLog] (
    [EZVLogID]       INT           IDENTITY (1, 1) NOT NULL,
    [EZVUserID]      INT           NOT NULL,
    [VerificationID] NVARCHAR (50) NOT NULL,
    [Success]        BIT           CONSTRAINT [DF_EZVerifyLog_Success] DEFAULT ((0)) NOT NULL,
    [ErrorLog]       TEXT          NULL,
    [VIDInvalidated] BIT           CONSTRAINT [DF_EZVerifyLog_VIDInValidated] DEFAULT ((0)) NOT NULL,
    [LastUpdated]    DATETIME      CONSTRAINT [DF_EZVerifyLog_LastUpdated] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_EZVerifyLog] PRIMARY KEY CLUSTERED ([EZVLogID] ASC),
    CONSTRAINT [FK_EZVerifyLog_EZVerifyUser] FOREIGN KEY ([EZVUserID]) REFERENCES [dbo].[EZVerifyUser] ([UID]) ON DELETE CASCADE
);

