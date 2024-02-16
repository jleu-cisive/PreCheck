CREATE TABLE [dbo].[HTMLClientMap] (
    [HTMLClientMapID] INT           IDENTITY (1, 1) NOT NULL,
    [CLNOin]          INT           NOT NULL,
    [CLNOout]         INT           NOT NULL,
    [IsActive]        BIT           NOT NULL,
    [IsRelative]      BIT           NOT NULL,
    [FilterCode]      INT           NULL,
    [ClientNote]      VARCHAR (500) NULL,
    CONSTRAINT [PK_HTMLClientMap] PRIMARY KEY CLUSTERED ([HTMLClientMapID] ASC) WITH (FILLFACTOR = 50)
);

