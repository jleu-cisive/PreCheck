CREATE TABLE [dbo].[ApplAdditionalData] (
    [ApplAdditionalDataID]           INT           IDENTITY (1, 1) NOT NULL,
    [CLNO]                           INT           NOT NULL,
    [APNO]                           INT           NULL,
    [SSN]                            VARCHAR (11)  NULL,
    [Crim_SelfDisclosed]             BIT           NULL,
    [Empl_CanContactPresentEmployer] BIT           NULL,
    [DataSource]                     VARCHAR (10)  NULL,
    [DateCreated]                    DATETIME      CONSTRAINT [DF_ApplAdditionalData_DateCreated] DEFAULT (getdate()) NOT NULL,
    [SalaryRange]                    VARCHAR (100) DEFAULT (NULL) NULL,
    [StateEmploymentOccur]           VARCHAR (20)  DEFAULT (NULL) NULL,
    [DateUpdated]                    DATETIME      NULL,
    [ClientCertReceived]             VARCHAR (5)   NULL,
    [ClientCertBy]                   VARCHAR (500) NULL,
    [CityEmploymentOccur]            VARCHAR (50)  NULL,
    [CountyEmploymentOccur]          VARCHAR (50)  NULL,
    [CreateBy]                       VARCHAR (50)  NULL,
    [ModifyBy]                       VARCHAR (50)  NULL,
    CONSTRAINT [PK_ApplAdditionalData] PRIMARY KEY CLUSTERED ([ApplAdditionalDataID] ASC) WITH (FILLFACTOR = 50)
);


GO
CREATE NONCLUSTERED INDEX [IX_ApplAdditionalData_01]
    ON [dbo].[ApplAdditionalData]([APNO] ASC, [CLNO] ASC, [SSN] ASC, [Crim_SelfDisclosed] ASC) WITH (FILLFACTOR = 50);


GO
CREATE NONCLUSTERED INDEX [IX_ApplAdditionalData_APNO]
    ON [dbo].[ApplAdditionalData]([APNO] ASC)
    INCLUDE([Crim_SelfDisclosed], [SalaryRange], [StateEmploymentOccur]) WITH (FILLFACTOR = 50);


GO
CREATE NONCLUSTERED INDEX [IX_ApplAdditionalData_CLNO_SSN]
    ON [dbo].[ApplAdditionalData]([CLNO] ASC, [SSN] ASC)
    INCLUDE([Crim_SelfDisclosed]) WITH (FILLFACTOR = 50);


GO
CREATE NONCLUSTERED INDEX [IX_ApplAdditionalData_SSN]
    ON [dbo].[ApplAdditionalData]([SSN] ASC)
    INCLUDE([Crim_SelfDisclosed], [SalaryRange], [StateEmploymentOccur]) WITH (FILLFACTOR = 90)
    ON [FG_INDEX];

