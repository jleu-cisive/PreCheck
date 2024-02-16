CREATE TABLE [dbo].[ARefChexStatusMapping] (
    [MappingID]       INT           IDENTITY (1, 1) NOT NULL,
    [ApplSectionID]   INT           NOT NULL,
    [Status]          VARCHAR (50)  NULL,
    [StatusCode]      CHAR (1)      NULL,
    [SectSubStatusID] INT           NULL,
    [WebStatusID]     INT           NULL,
    [Comments]        VARCHAR (MAX) NULL,
    [Active]          BIT           CONSTRAINT [DF__ARefChexS__Activ__691E3D2D] DEFAULT ((1)) NOT NULL,
    [CreatedBy]       VARCHAR (50)  NULL,
    [CreatedDate]     DATETIME      NULL,
    [ModifiedBy]      VARCHAR (50)  NULL,
    [ModifiedDate]    DATETIME      NULL,
    CONSTRAINT [PK_ARefChexStatusMapping] PRIMARY KEY CLUSTERED ([MappingID] ASC) ON [PRIMARY],
    CONSTRAINT [FK_ARefChexStatusMapping_SectStat] FOREIGN KEY ([StatusCode]) REFERENCES [dbo].[SectStat] ([Code]),
    CONSTRAINT [FK_ARefChexStatusMapping_SectSubStatus] FOREIGN KEY ([SectSubStatusID]) REFERENCES [dbo].[SectSubStatus] ([SectSubStatusID])
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY];

