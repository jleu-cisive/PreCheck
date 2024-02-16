CREATE TABLE [dbo].[refTeam] (
    [TeamID]       INT           IDENTITY (1, 1) NOT NULL,
    [Team]         NVARCHAR (50) NULL,
    [Investigator] VARCHAR (8)   NULL,
    [TeamEmail]    VARCHAR (100) NULL,
    CONSTRAINT [PK_refTeams] PRIMARY KEY CLUSTERED ([TeamID] ASC) WITH (FILLFACTOR = 50)
);

