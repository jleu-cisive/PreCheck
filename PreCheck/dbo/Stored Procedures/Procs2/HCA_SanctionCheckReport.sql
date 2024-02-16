  
--=============================================  
-- Author:  Prasanna  
-- Create date: 03/08/2017  
-- Description: HCA SanctionCheck Report  
-- Exec [HCA_SanctionCheckReport] 1616,'01/10/2016','01/10/2017',0  
--Modified by Arindam Mitra on 03/01/2023 to add AffiliateId 4 and 294 (HCA and HCA Velocity) for ticket# 84621 PART 3
-- Exec [HCA_SanctionCheckReport] 2273,'01/10/2018','01/10/2019',0  
-- =============================================  
CREATE PROCEDURE [dbo].[HCA_SanctionCheckReport]  
 @Clno int, @startDate date,@endDate date,@IsOneHR bit  
AS  
BEGIN  
   
 SET NOCOUNT ON;  
  
 select appl.CLNO,facility.FacilityName,facility.FacilityName, (appl.First+''+appl.middle+''+appl.Last) as [Emaployee Name],facility.IsOneHR as IsOneHR,  
 (CASE WHEN medInteg.SectStat = '3' THEN 'CLEARED/POSSIBLE CLEARED'  
    WHEN medInteg.SectStat = '7' THEN 'POSITIVE/POSSIBLE'  
    ELSE 'Other Status' END) as  [SanctionCheck results], medInteg.CreatedDate from MedInteg medInteg   
 inner join Appl appl on medInteg.ApNo = appl.apno  
 inner join [HEVN].[dbo].Facility facility on facility.[FacilityCLNO] = appl.CLNO  
 inner join dbo.Client C  with (nolock) ON appl.Clno = C.Clno --Code added by Arindam for ticket# -84621 PART 3
 where c.AffiliateID IN (4, 294) --Code added by Arindam for ticket# -84621 PART 3
 AND appl.clno = isnull(@clno,'') and (convert(varchar(10),medInteg.CreatedDate,111) between @startDate and @endDate) and facility.IsOneHR = @IsOneHR  
  
END  