CREATE TABLE [dbo].[TalxInfo] (
    [ID]              INT          IDENTITY (1, 1) NOT NULL,
    [APNO]            INT          NOT NULL,
    [TALXOrderedDate] DATETIME     NULL,
    [CreatedDate]     DATETIME     NULL,
    [CreatedBy]       VARCHAR (50) NULL,
    CONSTRAINT [PK_TalxInfo] PRIMARY KEY CLUSTERED ([ID] ASC) ON [PRIMARY]
) ON [PRIMARY];

