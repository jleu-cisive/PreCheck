CREATE TABLE [dbo].[refServiceType] (
    [ServiceType] INT          NOT NULL,
    [Description] VARCHAR (25) NOT NULL,
    CONSTRAINT [PK_ServiceType] PRIMARY KEY CLUSTERED ([ServiceType] ASC) WITH (FILLFACTOR = 50) ON [PRIMARY]
) ON [PRIMARY];

