CREATE TABLE [dbo].[refApplActivityCode] (
    [refApplActivityCodeID] INT          IDENTITY (1, 1) NOT NULL,
    [ActivityCode]          INT          NOT NULL,
    [Description]           VARCHAR (50) NOT NULL,
    CONSTRAINT [PK_refApplActivityCode] PRIMARY KEY CLUSTERED ([refApplActivityCodeID] ASC) WITH (FILLFACTOR = 50)
);

