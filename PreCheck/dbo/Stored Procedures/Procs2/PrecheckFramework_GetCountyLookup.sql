-- Alter Procedure PrecheckFramework_GetCountyLookup

-- =============================================    
-- Author:  Douglas DeGenaro    
-- Create date: 02/25/2013    
-- Description: Get county information for countylookup 
--[dbo].[PrecheckFramework_GetCountyLookup] @sectionList = 'CountyLookup',@City = null
--[dbo].[PrecheckFramework_GetCountyLookup] @sectionList = 'Lists'  
--select * from MainDB.[dbo].[ZipCode] where Zip = '77380'   
-- Modified by Doug 04/22/2021 to use the Isactive flag on the tblCounties in the union   HDT#85921 and 83223   
-- =============================================      
CREATE PROCEDURE [dbo].[PrecheckFramework_GetCountyLookup]   
@Zip varchar(11) = null,  
@City varchar(50) = null,  
@sectionList varchar(1000) = null  
 -- Add the parameters for the stored procedure here     
AS    
declare @count int  
declare @flag int  
declare @sectionOption varchar(50)  
  
if (@sectionList = 'All')  
 set @sectionList = 'CountyLookup|CountyLists'  
  
set @count = (select count(*) from fn_Split(@sectionList,'|'));  
set @flag = 0  
while (@flag <= @count)  
BEGIN    
  set @sectionOption = (select value from fn_Split(@sectionList,'|') where idx = @flag);     
 -- SET NOCOUNT ON added to prevent extra result sets from    
 -- interfering with SELECT statements.    
 SET NOCOUNT ON;    
    
    
    
 --if (@sectionOption = 'ZipCityCountyLookup')    
 --Begin  
 --select distinct 'ZipCityCountyLookup' as SectionName,c.CNTY_NO,A_County County,c.State,country,PassThroughCharge, Percentage,c.refCountyTypeID,cg.refCountyGroupingID,CITY,ZC.ZIP    
 --from  counties c left join MainDB.[dbo].[ZipCode_County] ZC on c.FIPS = ZC.FIPS    
 --inner join MainDB.[dbo].[ZipCode] Z on ZC.Zip = Z.Zip    
 --left join Counties_Group cg on c.cnty_NO = cg.cnty_NO  
 --where ZC.ZIP = @Zip or CITY = @City   
 --order by ZC.Zip,Percentage desc  
 --End  
   
 if (@sectionOption = 'CountyLookup')    
 Begin  
     select   'CountyLookup' as SectionName,tbl.CNTY_NO, --case when (tbl.County = null or tbl.County = '')then tbl.A_County else tbl.County end as County, 
		 tbl.County,
		 tbl.State,tbl.country,tbl.PassThroughCharge,tbl.Percentage,
		 tbl.refCountyTypeID as CountyTypeId,refCountyGroupingID as CountyGroupingId,
		 tbl.CITY as City,tbl.ZIP as Zip  
     from   
			 (select c.CNTY_NO, A_County County, --c.County, 
					 c.State,country,PassThroughCharge,NULL Percentage,
					 c.refCountyTypeID,cg.refCountyGroupingID,NULL CITY, NULL ZIP      
				 from  dbo.TblCounties c (nolock)
				 left join dbo.Counties_Group cg (nolock) on c.cnty_NO = cg.cnty_NO  
				 Where c.IsActive=1 --Doug 04/22/2021 
				 --order by c.State,A_County  
			 
				 union  
			 
				 select c.CNTY_NO, A_County County, --c.County, 
					c.State,country,PassThroughCharge, 
					Percentage,c.refCountyTypeID,cg.refCountyGroupingID,CITY,ZC.ZIP    
				 from  dbo.TblCounties c (nolock)
				 left join MainDB.[dbo].[ZipCode_County] ZC(nolock) on c.FIPS = ZC.FIPS    
				 inner join MainDB.[dbo].[ZipCode] Z(nolock) on ZC.Zip = Z.Zip    
				 left join dbo.Counties_Group cg (nolock) on c.cnty_NO = cg.cnty_NO  
				 where ((ZC.ZIP like @Zip + '%') or (CITY like  @City + '%'))
				 and c.IsActive=1 --Doug 04/22/2021 
			 ) tbl  
 order by tbl.State,tbl.County,Percentage  Desc
 --order by Zip,Percentage ,tbl.County desc  
 End  
   
   
 if (@sectionOption = 'CountyLists')  
 Begin  
 select 'CountyGrouping' as SectionName,refCountyGroupingId,CountyGrouping from dbo.refCountyGroupings (nolock)where IsActive = 1       
 select 'CountyType' as SectionName,refCountyTypeId,CountyType from dbo.refCountyType (nolock) where IsActive = 1    
 select 'State' as SectionName,state_name,full_name from Metastorm9_2..pc_state (nolock) order by State_name    
 End    
   
 set @flag = @flag + 1    
END
