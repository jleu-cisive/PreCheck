CREATE TABLE [dbo].[EZVerifyEmplLog] (
    [EZVLogID]       INT      IDENTITY (1, 1) NOT NULL,
    [EZVUserID]      INT      NOT NULL,
    [VerificationID] BIGINT   NOT NULL,
    [Success]        BIT      CONSTRAINT [DF_EZVerifyEmplLog_Success] DEFAULT ((0)) NOT NULL,
    [ErrorLog]       TEXT     NULL,
    [VIDInvalidated] BIT      CONSTRAINT [DF_EZVerifyEmplLog_VIDInValidated] DEFAULT ((0)) NOT NULL,
    [LastUpdated]    DATETIME CONSTRAINT [DF_EZVerifyEmplLog_LastUpdated] DEFAULT (getdate()) NOT NULL,
    [EmplID]         INT      NOT NULL,
    CONSTRAINT [PK_EZVerifyEmplLog] PRIMARY KEY CLUSTERED ([EZVLogID] ASC),
    CONSTRAINT [FK_EZVerifyEmplLog_EZVerifyUser] FOREIGN KEY ([EZVUserID]) REFERENCES [dbo].[EZVerifyUser] ([UID]) ON DELETE CASCADE
);

