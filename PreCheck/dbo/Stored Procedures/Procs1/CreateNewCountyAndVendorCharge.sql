-- Alter Procedure CreateNewCountyAndVendorCharge
-- ================================================================================
-- Author:		Dongmei He
-- Create date: 07/08/2019
-- Description:	Insert new counties to counties and Iris_Researcher_Charges tables
-- ================================================================================


CREATE PROCEDURE [dbo].[CreateNewCountyAndVendorCharge] --'', null, ''
	 @ResearchId int,
	 @Researcher_combo decimal(9,2),
	 @Researcher_CourtFees decimal(9,2),
	 @PassThrough decimal(9,2),
	 @Country varchar(25),
	 @DefaultRate decimal(9,2),
	 @Researcher_other varchar(50),
	 @County varchar(100),
	 @State varchar(25),
	 @Researcher_Aliases_count varchar(4),
	 @Researcher_Default varchar(3),
	 @ACounty varchar(25)
AS
BEGIN	

DECLARE @Id int

INSERT INTO [dbo].[TblCounties] 
		          ([County]           
                  ,[Crim_Source]           
                  ,[Crim_Phone]          
                  ,[Crim_Fax]          
                  ,[Crim_Addr]          
                  ,[Crim_Comment]        
                  ,[Crim_DefaultRate]     
                  ,[Civ_Source]           
                  ,[Civ_Phone]           
                  ,[Civ_Fax]          
                  ,[Civ_Addr]          
                  ,[Civ_Comment]       
                  ,[State]        
                  ,[A_County]         
                  ,[Country]            
                  ,[PassThroughCharge]          
                  ,[isStatewide]           
                  ,[FIPS]           
                  ,[refCountyTypeID])      
	       VALUES (SUBSTRING(@ACounty, 1, 40)        
                  ,null            
                  ,null            
                  ,null            
                  ,null            
                  ,null         
                  ,@DefaultRate          
                  ,null            
                  ,null            
                  ,null            
                  ,null            
                  ,null            
                  ,@State            
                  ,SUBSTRING(@ACounty, 1, 25)           
                  ,@Country          
                  ,@PassThrough         
                  ,0            
                  ,null            
                  ,3)

SELECT @Id = SCOPE_IDENTITY()

UPDATE [dbo].[County_PartnerJurisdiction]
   SET CNTY_NO = @Id,
       PreCheckCounty = @ACounty
   WHERE RTRIM(LTRIM(PreCheckJurisdictionName)) = RTRIM(LTRIM(@County))


INSERT INTO [dbo].[Iris_Researcher_Charges]
           ([Researcher_id]
           ,[Researcher_county]
           ,[Researcher_state]
           ,[Researcher_Fel]
           ,[Researcher_Mis]
           ,[Researcher_fed]
           ,[Researcher_alias]
           ,[Researcher_combo]
           ,[Researcher_other]
           ,[Researcher_Default]
           ,[Researcher_Aliases_count]
           ,[cnty_no]
           ,[Researcher_CourtFees]
           ,[TxDPS])
     VALUES
           (@ResearchId
           ,@ACounty
           ,@State
           ,null
           ,null
           ,null
           ,null
           ,CAST(@Researcher_combo as varchar(50))
           ,@Researcher_other
           ,@Researcher_Default
           ,@Researcher_Aliases_count
           ,@Id
           ,cast(@Researcher_CourtFees as varchar(50))
           ,null)


                                                                                          
END
