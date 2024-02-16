CREATE procedure [dbo].[HCA_Acquisition_ProfLic_Report]  
as  
BEGIN  
select   
 null as [HR CO],  
 First as [Employee First Name],  
 Last as [Employee Last Name],  
 Middle as [Employee Middle Name],  
 RIGHT(SSN,4) as SSN,  
 DOB,  
 null as [Employee Position Title],  
 null as [Valid Lawson Credential Code],  
 a.APno,  
 lt.[Description] as [License Description],  
 pl.State as [License/Credential State],  
 pl.Lic_No as [License/Credential Number],  
 pl.Year as [Acquired Date],  
 Expire as [Credential Expiration Date],  
 EnteredVia  
  from  
dbo.Appl a (nolock) inner join dbo.ProfLic pl (nolock)  
 on a.APno=pl.APNO  
left join HEVN.dbo.Licensetype lt (nolock) on lt.LIcenseTypeId = pl.LicenseTypeId  
inner join dbo.Client c (nolock) on c.CLNO = a.CLNO  
where a.ApDate >= '05/02/2022' and pl.IsOnReport=1  
and c.clno = 15951  
END  
  
  
