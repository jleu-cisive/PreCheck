CREATE TABLE [dbo].[OCHS_CandidateInfo] (
    [OCHS_CandidateInfoID]                INT            IDENTITY (1, 1) NOT NULL,
    [CLNO]                                INT            NOT NULL,
    [APNO]                                INT            NULL,
    [LastName]                            VARCHAR (50)   NOT NULL,
    [FirstName]                           VARCHAR (50)   NOT NULL,
    [Middle]                              VARCHAR (20)   NULL,
    [SSN]                                 VARCHAR (11)   NULL,
    [DOB]                                 DATE           NULL,
    [Address1]                            VARCHAR (100)  NULL,
    [Address2]                            VARCHAR (20)   NULL,
    [City]                                VARCHAR (50)   NULL,
    [State]                               CHAR (2)       NOT NULL,
    [Zip]                                 VARCHAR (10)   NOT NULL,
    [Email]                               VARCHAR (100)  NOT NULL,
    [Phone]                               VARCHAR (12)   NOT NULL,
    [TestReason]                          INT            NOT NULL,
    [CostCenter]                          VARCHAR (50)   NULL,
    [ClientIdent]                         VARCHAR (100)  NULL,
    [CreatedDate]                         DATETIME       NOT NULL,
    [LastUpdateDate]                      DATETIME       NOT NULL,
    [IsActive]                            BIT            NULL,
    [ClientConfiguration_DrugScreeningID] INT            NULL,
    [RequisitionNumber]                   NVARCHAR (100) NULL,
    CONSTRAINT [PK_OCHS_CandidateInfo] PRIMARY KEY CLUSTERED ([OCHS_CandidateInfoID] ASC) WITH (FILLFACTOR = 50)
);


GO
CREATE NONCLUSTERED INDEX [IDX_OCHS_CandidateInfo_APNO_Inc]
    ON [dbo].[OCHS_CandidateInfo]([APNO] ASC)
    INCLUDE([OCHS_CandidateInfoID], [SSN]) WITH (FILLFACTOR = 70);


GO
CREATE NONCLUSTERED INDEX [IDX_LastName]
    ON [dbo].[OCHS_CandidateInfo]([LastName] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_OCHS_CandidateInfo_CreatedDate]
    ON [dbo].[OCHS_CandidateInfo]([CreatedDate] ASC)
    INCLUDE([OCHS_CandidateInfoID], [CLNO], [LastName], [FirstName], [SSN]);

