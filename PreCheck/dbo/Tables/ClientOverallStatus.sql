CREATE TABLE [dbo].[ClientOverallStatus] (
    [ClientOverallStatusId] INT          IDENTITY (1, 1) NOT NULL,
    [CLNO]                  INT          NOT NULL,
    [SectionId]             INT          NOT NULL,
    [SectStatusCode]        CHAR (1)     NOT NULL,
    [SectSubStatusId]       INT          NULL,
    [OverallStatus]         INT          NOT NULL,
    [IsActive]              BIT          NOT NULL,
    [CreateDate]            DATETIME     CONSTRAINT [DF_ClientOverallStatus_CreateDate] DEFAULT (getdate()) NOT NULL,
    [CreateBy]              VARCHAR (50) CONSTRAINT [DF_ClientOverallStatus_CreateBy] DEFAULT ('sa') NOT NULL,
    [ModifyDate]            DATETIME     CONSTRAINT [DF_ClientOverallStatus_ModifyDate] DEFAULT (getdate()) NOT NULL,
    [ModifyBy]              VARCHAR (50) CONSTRAINT [DF_ClientOverallStatus_ModifyBy] DEFAULT ('sa') NOT NULL,
    CONSTRAINT [PK_ClientOverallStatus] PRIMARY KEY CLUSTERED ([ClientOverallStatusId] ASC)
);

