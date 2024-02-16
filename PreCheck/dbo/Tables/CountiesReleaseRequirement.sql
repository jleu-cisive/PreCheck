CREATE TABLE [dbo].[CountiesReleaseRequirement] (
    [CNTY_NO]           INT NOT NULL,
    [IsReleaseRequired] BIT NULL,
    CONSTRAINT [PK_CountiesReleaseRequirement] PRIMARY KEY CLUSTERED ([CNTY_NO] ASC) WITH (FILLFACTOR = 70)
);

