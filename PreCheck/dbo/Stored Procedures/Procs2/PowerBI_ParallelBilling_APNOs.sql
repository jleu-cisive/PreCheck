


/*
-- =============================================
-- Author:		Joshua Ates
-- Create date: 7/30/2022
-- Description:	Created to fix power BI report, copy pasted from original needs optomization
-- 
-- =============================================	
*/

CREATE PROCEDURE [dbo].[PowerBI_ParallelBilling_APNOs]
AS
BEGIN
select a.APNO, a.Billed, a.CLNO, c.Name, c.State as ClientState, iif(c.CLNO = c.ParentCLNO, NULL, c.ParentCLNO) as ParentClientNumber, iif(c.CLNO = c.ParentCLNO, NULL, cp.Name) as ParentClientName,  a.PackageID, a.OrigCompDate, a.CompDate, a.State as ApplicantState, a.PrecheckChallenge 
from Appl as a with (nolock)
inner join Client as c with (nolock) on c.CLNO = a.CLNO
left join PackageMain as p  with (nolock) on p.PackageID = a.PackageID
left join Client as cp with (nolock) on cp.CLNO = c.ParentCLNO
where a.OrigCompDate >= DATEADD(MONTH,-3,GETDATE())
--and a.ApStatus = 'F' and a.CLNO <> 3468

END
