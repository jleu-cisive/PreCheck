-- =============================================
-- Author:		<Amy Liu>
-- Create date: 06/15/2021
-- Description:	<The report pull out the user access permission change(Add, remove) log from Client Manager>
-- exec [DBO].[QReport_ClientAccessPermissionChangelog] '05/01/2021','06/15/2021'
-- =============================================
CREATE PROCEDURE [dbo].[QReport_ClientAccessPermissionChangelog]
	 @StartDate datetime,
	  @EndDate datetime 
AS
BEGIN
	
	SET NOCOUNT ON;

	 --declare @StartDate datetime ='05/01/2021' 
	 --declare @EndDate datetime ='06/15/2021' 

	  select pw.PrincipalId, cc.FirstName, cc.LastName, cc.username, pw.ResourceId, c.Name ClientName,pw.Status, pw.ChangedDate , pw.ChangedBy, u.Name 
	 -- select pw.*
	  from
	  (
			 select p.PrincipalId, p.ResourceId, 'Active' as Status, p.createdate  ChangedDate, p.CreateBy ChangedBy
			 from Security.Privilege p where  p.CreateDate >=@StartDate  and p.CreateDate<@EndDate +1
			 union 
			 select ph.PrincipalId, ph.ResourceId, 'Removed' as Status, ph.ModifyDate ChangedDate, ph.ModifyBy   ChangedBy
			 from security.PrivilegeHistory ph where  ph.ModifyDate >=@StartDate  and ph.ModifyDate<@EndDate +1
	 )pw 
	 inner join dbo.ClientContacts cc on pw.PrincipalId= cc.ContactID
	left join dbo.Users u on u.ID = pw.ChangedBy
	 inner join dbo.client c on pw.ResourceId= c.CLNO
	 order by pw.ChangedDate

END
