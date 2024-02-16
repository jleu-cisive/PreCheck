-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 08/04/2016
-- Description:	 Q-Report that allows me to pull accounts that are set to "True" for auto-order. 
-- Modified By Radhika Dereddy on 10/02/2017 to include all clients and exclude  Client Type of Medical-StudentCheck 
-- =============================================
CREATE PROCEDURE [dbo].[Clients_AutoOrder_SetToTrue]
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
select distinct c.CLNO, c.Name as ClientName, rf.Description, (case when rf.refPackageTypeID in (4,5,6) then 'True' else 'False' end) as 'AutoOrder'
from Client c 
left join ClientPackages cp on cp.clno = c.clno
left join PackageMain pm on pm.PackageID = cp.PackageID
left join refPackageType rf on rf.refPackageTypeID = pm.refPackageTypeID
where c.IsInactive = 0
and ClientTypeID <> 4 and c.CLNO NOT IN (3468, 3668, 2135)
order by c.CLNO asc

END
