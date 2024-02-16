CREATE TABLE [dbo].[ClientCrimOverallStatus] (
    [ClientCrimOverallStatusId] INT          IDENTITY (1, 1) NOT NULL,
    [CLNO]                      INT          NOT NULL,
    [StatusCode]                VARCHAR (1)  NOT NULL,
    [OverallStatus]             INT          NOT NULL,
    [IsActive]                  BIT          NOT NULL,
    [CreateDate]                DATETIME     CONSTRAINT [DF_ClientCrimOverallStatus_CreateDate] DEFAULT (getdate()) NOT NULL,
    [CreateBy]                  VARCHAR (50) CONSTRAINT [DF_ClientCrimOverallStatus_CreateBy] DEFAULT ('sa') NOT NULL,
    [ModifyDate]                DATETIME     CONSTRAINT [DF_ClientCrimOverallStatus_ModifyDate] DEFAULT (getdate()) NOT NULL,
    [ModifyBy]                  VARCHAR (50) CONSTRAINT [DF_ClientCrimOverallStatus_ModifyBy] DEFAULT ('sa') NOT NULL,
    CONSTRAINT [PK_ClientCrimOverallStatus] PRIMARY KEY CLUSTERED ([ClientCrimOverallStatusId] ASC)
);

