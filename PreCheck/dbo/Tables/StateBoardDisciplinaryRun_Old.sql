CREATE TABLE [dbo].[StateBoardDisciplinaryRun_Old] (
    [StateBoardDisciplinaryRunID] INT          IDENTITY (1, 1) NOT NULL,
    [StateBoardSourceInfoID]      INT          NULL,
    [StatedDate]                  DATETIME     NULL,
    [AvailabilityDate]            DATETIME     NULL,
    [UserA]                       VARCHAR (10) NULL,
    [DateWorkedA]                 DATETIME     NULL,
    [UserB]                       VARCHAR (10) NULL,
    [DateWorkedB]                 DATETIME     NULL,
    [IsComplete]                  BIT          CONSTRAINT [DF_StateBoardDisciplinaryRun_IsComplete] DEFAULT (0) NOT NULL,
    [InUseBy]                     VARCHAR (10) NULL,
    [InUseTime]                   DATETIME     NULL,
    [IsCompleteA]                 BIT          CONSTRAINT [DF_StateBoardDisciplinaryRun_IsComplete1] DEFAULT ((0)) NOT NULL,
    [IsCompleteB]                 BIT          CONSTRAINT [DF_StateBoardDisciplinaryRun_IsComplete2] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_StateBoardDisciplinaryRun1] PRIMARY KEY CLUSTERED ([StateBoardDisciplinaryRunID] ASC) WITH (FILLFACTOR = 50)
);

