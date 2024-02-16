CREATE TABLE [dbo].[OCHS_PDFReports_Temp] (
    [TID]       INT            NOT NULL,
    [PDFReport] NVARCHAR (MAX) NULL,
    [Reason]    VARCHAR (50)   NULL,
    [AddedOn]   DATETIME       CONSTRAINT [DF_OCHS_PDFReports_Temp_AddedOn] DEFAULT (getdate()) NOT NULL,
    [ID]        INT            IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [PK_OCHS_PDFReports_Temp] PRIMARY KEY CLUSTERED ([ID] ASC) WITH (FILLFACTOR = 70)
);

