CREATE TABLE [dbo].[EmployerCommonNameNormalize] (
    [ID]          INT           IDENTITY (1, 1) NOT NULL,
    [CommonName]  NVARCHAR (55) NOT NULL,
    [IsActive]    BIT           NOT NULL,
    [CreatedDate] DATETIME      NULL,
    CONSTRAINT [PK_EmployerCommonNameNormalize] PRIMARY KEY CLUSTERED ([ID] ASC) ON [PRIMARY]
) ON [PRIMARY];

