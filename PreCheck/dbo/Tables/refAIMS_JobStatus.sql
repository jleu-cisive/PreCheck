CREATE TABLE [dbo].[refAIMS_JobStatus] (
    [AIMS_JobStatus] VARCHAR (1)  NOT NULL,
    [Description]    VARCHAR (50) NOT NULL,
    CONSTRAINT [PK_refAIMS_JobStatus] PRIMARY KEY CLUSTERED ([AIMS_JobStatus] ASC) WITH (FILLFACTOR = 50)
);

