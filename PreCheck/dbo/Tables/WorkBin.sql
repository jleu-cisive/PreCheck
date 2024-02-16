CREATE TABLE [dbo].[WorkBin] (
    [WorkBinID]     INT          IDENTITY (1, 1) NOT NULL,
    [APNO]          INT          NULL,
    [UserProfileID] INT          NULL,
    [WorkBinType]   VARCHAR (15) NULL,
    [UserID]        VARCHAR (8)  NULL,
    [CreatedDate]   DATETIME     CONSTRAINT [DF_WorkBin_CreatedDate] DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_WorkBin] PRIMARY KEY CLUSTERED ([WorkBinID] ASC) WITH (FILLFACTOR = 50)
);

