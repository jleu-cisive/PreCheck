
/*
-- =============================================
-- Author:		Joshua Ates
-- Create date: 7/30/2022
-- Description:	Created to fix power BI report, copy pasted from original needs optomization
-- 
-- =============================================	
*/ 


CREATE PROCEDURE [dbo].[PowerBI_ParallelBilling_OriginalBilling]
AS
BEGIN

select a.APNO, a.Billed, a.CLNO, a.PackageID, a.OrigCompDate, a.CompDate, a.State as ApplicantState, c.State as ClientState
into #APNOs
from Appl as a with (nolock)
inner join Client as c with (nolock) on c.CLNO = a.CLNO
left join PackageMain as p  with (nolock) on p.PackageID = a.PackageID
where  a.OrigCompDate >= DATEADD(MONTH,-3,GETDATE())


select * from #APNOs as a with (nolock)
inner join InvDetailsParallel as i with (nolock) on i.APNO = a.APNO and i.IsDeleted = 0
END
