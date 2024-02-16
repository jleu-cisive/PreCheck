
--====================================================================================================================== 
--Author:        Lalit Kumar
--Create Date:   3-February-2023
--Description:   get invoce information from InvDetail_Reconciliation table and invdetail table
-- updated by Lalit Kumar on 21 feb 2023 to include license info
-- updated by Lalit on 24 April 2023 for category
--====================================================================================================================== 


CREATE PROCEDURE [dbo].[sp_getinvDetail]
	@apno int = 0
AS
begin
set NOCOUNT ON
  drop table if exists #tempinvoice
  --declare @apno int = 6887855
  select distinct id.InvDetID,idr.SectionKeyId,id.APNO,case when ase.ApplSectionID=6 then 'MVR' else case when ase.ApplSectionId=4 then 'License' else case WHEN ase.ApplSectionID=8 THEN '' ELSE ase.[Description] END END end as Category
  ,case when id.[type]=1 then 'Manual' else 'Auto'end as Method,id.Subkey,id.Billed,id.InvoiceNumber,id.CreateDate,
  id.[Description],id.Amount into #tempinvoice
  from InvDetail id WITH(NOLOCK) left join InvDetail_Reconciliation idr WITH(NOLOCK) on idr.InvDetID=id.InvDetID and idr.Isactive=1 and  idr.APNO=@apno
  left join ApplSections ase WITH(NOLOCK) on ase.ApplSectionID=idr.SectionId
  where id.apno=@apno
  
  select * from #tempinvoice order by InvDetID desc
  drop table if exists #tempinvoice
SET NOCOUNT OFF
end
