-- ================================================================================
-- Author:		Dongmei He
-- Create date: 07/17/2019
-- Description:	Insert Cisive counties to [dbo].[County_PartnerJurisdiction]
--              and map to PreCheck counties
-- ================================================================================


Create PROCEDURE [dbo].[InsertCountyToPartnerAndPreCheckMap] --'', null, ''
     @LeadType varchar(50),
	 @State varchar(25),
	 @County varchar(100),
	 @JurisdictionName varchar(100),
	 @PreCheckJurisdictionName varchar(100),
	 @PreCheckComment varchar(500),
	 @PartnerId int
	 

AS
BEGIN

--DECLARE @CNTY_NO int

--SELECT TOP 1 @CNTY_NO = CNTY_NO FROM [dbo].[Counties] WHERE County = LTRIM(RTRIM(@PreCheckJurisdictionName))

INSERT INTO [dbo].[County_PartnerJurisdiction]
           ([CNTY_NO]
           ,[LeadType]
           ,[State]
           ,[County]
		   ,[PreCheckCounty]
           ,[JurisdictionName]
           ,[PreCheckJurisdictionName]
           ,[PreCheckComment]
		   ,[PartnerId]
           ,[IsActive]
		   ,[CreateBy]
           ,[CreateDate]
           ,[ModifyBy]
           ,[ModifyDate])
     VALUES
           (0--ISNULL(@CNTY_NO, 0)
           ,LTRIM(RTRIM(@LeadType))
           ,LTRIM(RTRIM(@State))
           ,LTRIM(RTRIM(@County))
		   ,null
           ,LTRIM(RTRIM(@JurisdictionName))
           ,LTRIM(RTRIM(@PreCheckJurisdictionName))
           ,LTRIM(RTRIM(@PreCheckComment))
		   ,@PartnerId
           ,1
		   ,1
		   ,GETDATE()
		   ,1
		   ,GETDATE()
		   )
                                                         
END
--SELECT CNTY_NO FROM [dbo].[Counties] WHERE County = 'Alabama Middle District - US Federal'

