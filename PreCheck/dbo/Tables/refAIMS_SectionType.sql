CREATE TABLE [dbo].[refAIMS_SectionType] (
    [refAIMS_SectionTypeCode] VARCHAR (10) NOT NULL,
    [SectionType]             VARCHAR (50) NOT NULL,
    [Section]                 VARCHAR (50) NULL,
    CONSTRAINT [PK_refAIMS_SectionType] PRIMARY KEY CLUSTERED ([refAIMS_SectionTypeCode] ASC) WITH (FILLFACTOR = 50)
);

