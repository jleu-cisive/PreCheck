CREATE TABLE [dbo].[Integration_Verification_MVRLogging] (
    [MVRLoggingId] INT          IDENTITY (1, 1) NOT NULL,
    [Request]      XML          NULL,
    [Response]     XML          NULL,
    [Created]      DATETIME     NULL,
    [CreatedBy]    VARCHAR (30) NULL,
    CONSTRAINT [PK_Integration_Verification_MVRLogging] PRIMARY KEY CLUSTERED ([MVRLoggingId] ASC)
);

