CREATE TABLE [dbo].[ApplStudentActionHGC] (
    [ApplStudentActionHGCID] INT          IDENTITY (1, 1) NOT NULL,
    [SSN]                    VARCHAR (11) NOT NULL,
    [CLNO_School]            INT          NOT NULL,
    [StudentActionID]        INT          NOT NULL,
    [DateAssigned]           DATETIME     NULL,
    [DateStatusSet]          DATETIME     NULL,
    [Isactive]               BIT          NOT NULL,
    CONSTRAINT [PK_ApplStudentActionHGC] PRIMARY KEY CLUSTERED ([ApplStudentActionHGCID] ASC) WITH (FILLFACTOR = 50)
);

