CREATE TABLE [dbo].[WinServiceRunStatus] (
    [ID]               INT          IDENTITY (1, 1) NOT NULL,
    [ServiceName]      VARCHAR (50) NOT NULL,
    [ServiceRunDate]   DATETIME     NOT NULL,
    [ServiceRunStatus] BIT          NOT NULL
);

