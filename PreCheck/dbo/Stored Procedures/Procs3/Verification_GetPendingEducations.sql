
/***************************************************************************
* Procedure Name: [dbo].[Verification_GetPendingEducations]
* Created By: Doug DeGenaro
* Created On: 7/11/2012 1:18 PM
*****************************************************************************/

/***************************************************************************
* Procedure Name: [dbo].[Verification_GetPendingEducations]
* Updated By: Doug DeGenaro
* Updated On: 7/11/2012 1:18 PM
* Description : Changed when @vendor is null, then use 'REFPRO'
*****************************************************************************/

  
CREATE procedure [dbo].[Verification_GetPendingEducations]
(@vendor varchar(30) = null)
as  

if (@vendor is null)

select 
 case when e.IsIntl = 1 then 'IntlEducation' else 'Education' end as SectionType,   
 a.Addr_Street as Address_Street,  
 a.Middle as Middle,  
 a.First as First,  
 a.Last as Last, 
 a.APNO as Apno,	   
 CONVERT(varchar(10), a.DOB, 101) as Date_Of_Birth,  
 a.City as City,  
 a.State as State,  
 IsNull(a.Alias1_First,'') as Alias1_First,  
 IsNull(a.Alias1_Middle,'') as Alias1_Middle,  
 IsNull(a.Alias1_Last,'') as Alias1_Last,  
 IsNull(a.Alias2_First,'') as Alias2_First,  
 IsNull(a.Alias2_Middle,'') as Alias2_Middle,  
 IsNull(a.Alias3_Last,'') as Alias3_Last,  
 IsNull(a.Alias4_First,'') as Alias4_First,  
 IsNull(a.Alias4_Middle,'') as Alias4_Middle,  
 IsNull(a.Alias4_Last,'') as Alias4_Last,  
 a.SSN as Social_Security_Number,   
 IsNull(a.Generation,'') as Generation,  
 a.Zip as Zip,  
 --IsNull(e.IsIntl,0) as IsIntl,  
 e.School as School_Name,  
 e.city as Education_City,  
 e.State as Education_State,  
 e.Phone as Education_Phone,  
 e.EducatId as ItemId,  
 IsNull(e.From_A,'') as Date_From,  
 IsNull(e.To_A,'') as Date_To,   
 e.Degree_A as Degree,  
 e.Studies_A as Studies,  
 e.CampusName as CampusName,   
 e.OrderId as ItemOrderId,  
 a.Priv_Notes as Comments,
 e.Investigator as Education_Investigator  
from dbo.Educat e with (nolock) inner join dbo.Appl a  with (nolock) on a.APNO = e.APNO  
where 
e.Sectstat in ('9') and web_status = 0 and DateOrdered is null and OrderId is null and a.apstatus in ('p','w')  
and e.Investigator = 'REFPRO'

else

select 
 case when e.IsIntl = 1 then 'IntlEducation' else 'Education' end as SectionType,   
 a.Addr_Street as Address_Street,  
 a.Middle as Middle,  
 a.First as First,  
 a.Last as Last,  
 a.APNO as Apno,	  
 CONVERT(varchar(10), a.DOB, 101) as Date_Of_Birth, 
 a.City as City,  
 a.State as State,  
 IsNull(a.Alias1_First,'') as Alias1_First,  
 IsNull(a.Alias1_Middle,'') as Alias1_Middle,  
 IsNull(a.Alias1_Last,'') as Alias1_Last,  
 IsNull(a.Alias2_First,'') as Alias2_First,  
 IsNull(a.Alias2_Middle,'') as Alias2_Middle,  
 IsNull(a.Alias3_Last,'') as Alias3_Last,  
 IsNull(a.Alias4_First,'') as Alias4_First,  
 IsNull(a.Alias4_Middle,'') as Alias4_Middle,  
 IsNull(a.Alias4_Last,'') as Alias4_Last,  
 a.SSN as Social_Security_Number,   
 IsNull(a.Generation,'') as Generation,  
 a.Zip as Zip,  
 --IsNull(e.IsIntl,0) as IsIntl,  
 e.School as School_Name,  
 e.city as Education_City,  
 e.State as Education_State,  
 e.Phone as Education_Phone,  
 e.EducatId as ItemId,  
 IsNull(e.From_A,'') as Date_From,  
 IsNull(e.To_A,'') as Date_To,   
 e.Degree_A as Degree,  
 e.Studies_A as Studies,  
 e.CampusName as CampusName,   
 e.OrderId as ItemOrderId,  
 a.Priv_Notes as Comments,
 e.Investigator as Education_Investigator  
from dbo.Educat e  with (nolock) inner join dbo.Appl a  with (nolock) on a.APNO = e.APNO  
where 
e.Sectstat in ('9') and web_status = 0 and dateordered is null and orderId is null and a.apstatus in ('p','w')
and e.Investigator = @vendor

--and e.Invstigator = 'REFPRO'
--educatid in (1190647,199386,1196631,1196573,1196604)

