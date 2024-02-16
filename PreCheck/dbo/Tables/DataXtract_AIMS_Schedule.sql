CREATE TABLE [dbo].[DataXtract_AIMS_Schedule] (
    [DataXtract_AIMS_ScheduleID]     INT          IDENTITY (1, 1) NOT NULL,
    [DataXtract_RequestMappingXMLID] INT          NOT NULL,
    [refAIMS_SectionTypeCode]        VARCHAR (10) NOT NULL,
    [NextRunTime]                    DATETIME     NOT NULL,
    [Interval]                       VARCHAR (50) NOT NULL,
    [TimeValue]                      INT          NOT NULL,
    [IsActive]                       BIT          NOT NULL,
    [VendorAccountId]                INT          NOT NULL,
    CONSTRAINT [PK_DBO.DataXtract_AIMS_Schedule] PRIMARY KEY CLUSTERED ([DataXtract_AIMS_ScheduleID] ASC) WITH (FILLFACTOR = 50),
    CONSTRAINT [FK_DataXtract_AIMS_Schedule_DataXtract_RequestMapping] FOREIGN KEY ([DataXtract_RequestMappingXMLID]) REFERENCES [dbo].[DataXtract_RequestMapping] ([DataXtract_RequestMappingXMLID]),
    CONSTRAINT [FK_DataXtract_AIMS_Schedule_refAIMS_SectionType] FOREIGN KEY ([refAIMS_SectionTypeCode]) REFERENCES [dbo].[refAIMS_SectionType] ([refAIMS_SectionTypeCode])
);

