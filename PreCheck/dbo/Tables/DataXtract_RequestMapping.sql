CREATE TABLE [dbo].[DataXtract_RequestMapping] (
    [DataXtract_RequestMappingXMLID] INT           IDENTITY (1, 1) NOT NULL,
    [SectionKeyID]                   VARCHAR (50)  NOT NULL,
    [Section]                        VARCHAR (50)  NULL,
    [RequestMappingXML]              VARCHAR (MAX) NULL,
    [IsAutomationEnabled]            BIT           CONSTRAINT [DF_DataXtract_RequestMapping_IsAutomationEnabled] DEFAULT ((0)) NULL,
    [OffPeakHoursOnly]               BIT           CONSTRAINT [DF_DataXtract_RequestMapping_OffPeakHoursOnly] DEFAULT ((0)) NOT NULL,
    [IsBackgroundAutomationEnabled]  BIT           CONSTRAINT [DF_DataXtract_RequestMapping_IsBackgroundAutomationEnabled] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_DataXtract_RequestMappingXML] PRIMARY KEY CLUSTERED ([DataXtract_RequestMappingXMLID] ASC)
) TEXTIMAGE_ON [PRIMARY];


GO
CREATE NONCLUSTERED INDEX [IX_DataXtract_RequestMapping_Main]
    ON [dbo].[DataXtract_RequestMapping]([SectionKeyID] ASC, [Section] ASC) WITH (FILLFACTOR = 50)
    ON [FG_INDEX];

