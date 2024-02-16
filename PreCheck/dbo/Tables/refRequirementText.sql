CREATE TABLE [dbo].[refRequirementText] (
    [RequirementTextID] INT           IDENTITY (1, 1) NOT NULL,
    [CLNO]              INT           NULL,
    [ProfRef]           VARCHAR (100) NULL,
    [DOT]               VARCHAR (100) NULL,
    [SpecialReg]        VARCHAR (100) NULL,
    [Civil]             VARCHAR (100) NULL,
    [Federal]           VARCHAR (100) NULL,
    [Statewide]         VARCHAR (100) NULL,
    [StatewideID]       INT           NULL,
    [SpecialRegID]      INT           NULL,
    [CivilID]           INT           NULL,
    [FederalID]         INT           NULL,
    CONSTRAINT [PK_refRequirementText] PRIMARY KEY CLUSTERED ([RequirementTextID] ASC) WITH (FILLFACTOR = 50)
);


GO
CREATE NONCLUSTERED INDEX [IDX_refRequirementText_CLNO]
    ON [dbo].[refRequirementText]([CLNO] ASC)
    INCLUDE([ProfRef], [DOT], [SpecialReg], [Civil], [Federal], [Statewide], [StatewideID]) WITH (FILLFACTOR = 70);

