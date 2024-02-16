-- Alter Procedure DataXtract_Mapping_GetCounties
--sp_helptext 'dbo.DataXtract_Mapping_GetCounties'
--select cnty_no,a_county,country,state from counties where a_county like '%osage'
  
CREATE procedure [dbo].[DataXtract_Mapping_GetCounties]  
 (@mapped bit)  
as  
begin  
if @mapped = 1   
begin  
  select cnty_no,(a_county + ', ' + State) as County from dbo.TblCounties c where cast(c.cnty_no as varchar) in (select sectionKeyid from DataXtract_RequestMapping where sectionKeyid is not null and section='crim') and a_county is not NULL and a_county <> '' and
 Country in ('USA','US') order by a_County ASC   
end  
if @mapped = 0  
begin  
 select cnty_no,(a_county + ', ' + State) as County from dbo.TblCounties c where cast(c.cnty_no as varchar) not in (select sectionKeyid from DataXtract_RequestMapping where sectionKeyid is not null  and section='crim') and a_county is not NULL and a_county <> ''
 and Country in ('USA','US') order by a_County ASC    
end  
end
