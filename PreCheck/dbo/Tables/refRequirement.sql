CREATE TABLE [dbo].[refRequirement] (
    [refRequirementID]   INT           IDENTITY (1, 1) NOT NULL,
    [CLNO]               INT           NULL,
    [RecordType]         VARCHAR (10)  NULL,
    [SpecialNote]        VARCHAR (100) NULL,
    [NumOfRecord]        INT           CONSTRAINT [DF_refRequirement_NumOfRecord] DEFAULT ((0)) NULL,
    [TimeSpan]           INT           CONSTRAINT [DF_refRequirement_TimeSpan] DEFAULT ((0)) NULL,
    [LevelNum]           INT           CONSTRAINT [DF_refRequirement_EducationLevel] DEFAULT ((0)) NULL,
    [IsSeeNotes]         BIT           CONSTRAINT [DF_refRequirement_IsSeeNotes] DEFAULT ((0)) NULL,
    [IsMostRecent]       BIT           CONSTRAINT [DF_refRequirement_IsMostRecent] DEFAULT ((0)) NULL,
    [IsOrdered]          BIT           CONSTRAINT [DF_refRequirement_IsOrdered] DEFAULT ((0)) NULL,
    [IsCalled]           BIT           CONSTRAINT [DF_refRequirement_IsCalled] DEFAULT ((0)) NULL,
    [IsHighestCompleted] BIT           CONSTRAINT [DF_refRequirement_IsHighestCompleted] DEFAULT ((0)) NULL,
    [IsHighSchool]       BIT           CONSTRAINT [DF_refRequirement_IsHighSchool] DEFAULT ((0)) NULL,
    [IsCollege]          BIT           CONSTRAINT [DF_refRequirement_IsCollege] DEFAULT ((0)) NULL,
    [IsHCA]              BIT           CONSTRAINT [DF_refRequirement_IsHCA] DEFAULT ((0)) NULL,
    CONSTRAINT [PK_refRequirement] PRIMARY KEY CLUSTERED ([refRequirementID] ASC) WITH (FILLFACTOR = 50)
);


GO
CREATE NONCLUSTERED INDEX [IDX_refRequirement_CLNO_RecordType]
    ON [dbo].[refRequirement]([CLNO] ASC, [RecordType] ASC)
    INCLUDE([SpecialNote], [LevelNum], [IsSeeNotes], [IsOrdered], [IsHCA]) WITH (FILLFACTOR = 70);

