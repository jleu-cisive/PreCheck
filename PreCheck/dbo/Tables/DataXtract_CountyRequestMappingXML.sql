CREATE TABLE [dbo].[DataXtract_CountyRequestMappingXML] (
    [DataXtract_CountyRequestMappingXMLID] INT           IDENTITY (1, 1) NOT NULL,
    [CNTY_NO]                              INT           NOT NULL,
    [RequestMappingXML]                    VARCHAR (MAX) NULL,
    CONSTRAINT [PK_DataXtract_CountyRequestMappingXML] PRIMARY KEY CLUSTERED ([DataXtract_CountyRequestMappingXMLID] ASC)
) TEXTIMAGE_ON [PRIMARY];

