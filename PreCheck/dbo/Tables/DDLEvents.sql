CREATE TABLE [dbo].[DDLEvents] (
    [EventID]       INT            IDENTITY (1, 1) NOT NULL,
    [EventDate]     DATETIME       CONSTRAINT [DF__DDLEvents__Event__143CDA05] DEFAULT (getdate()) NOT NULL,
    [PrevObjectDef] NVARCHAR (MAX) NULL,
    [CurrObjectDef] NVARCHAR (MAX) NULL,
    [EventType]     NVARCHAR (64)  NULL,
    [EventDDL]      NVARCHAR (MAX) NULL,
    [EventXML]      XML            NULL,
    [DatabaseName]  NVARCHAR (255) NULL,
    [SchemaName]    NVARCHAR (255) NULL,
    [ObjectName]    NVARCHAR (255) NULL,
    [HostName]      VARCHAR (64)   NULL,
    [IPAddress]     VARCHAR (48)   NULL,
    [ProgramName]   NVARCHAR (255) NULL,
    [LoginName]     NVARCHAR (255) NULL,
    CONSTRAINT [PK_DDLEvents] PRIMARY KEY CLUSTERED ([EventID] ASC) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY];


GO
CREATE NONCLUSTERED INDEX [IX_DDLEvents_ObjectName]
    ON [dbo].[DDLEvents]([ObjectName] ASC)
    ON [PRIMARY];

