CREATE TABLE [dbo].[OCHS_PDFReports] (
    [TID]       INT            NOT NULL,
    [PDFReport] NVARCHAR (MAX) NULL,
    [Reason]    VARCHAR (50)   NULL,
    [AddedOn]   DATETIME       CONSTRAINT [DF_OCHS_PDFReports_AddedOn] DEFAULT (getdate()) NOT NULL,
    [ID]        INT            IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [PK_OCHS_PDFReports] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_OCHS_PDFReports_OCHS_PDFReports] FOREIGN KEY ([ID]) REFERENCES [dbo].[OCHS_PDFReports] ([ID])
);


GO
CREATE NONCLUSTERED INDEX [IX_OCHS_OCHS_PDFReports_01]
    ON [dbo].[OCHS_PDFReports]([TID] ASC) WITH (FILLFACTOR = 50);

