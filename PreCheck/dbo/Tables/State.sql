CREATE TABLE [dbo].[State] (
    [State]           NVARCHAR (20) NOT NULL,
    [DL_SearchType]   CHAR (2)      NULL,
    [IsReleaseNeeded] BIT           CONSTRAINT [DFLT_STATE_IsReleaseNeeded] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_State] PRIMARY KEY CLUSTERED ([State] ASC) WITH (FILLFACTOR = 50)
);

