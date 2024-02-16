-- =============================================
-- Author:		<Amy Qing Liu>
-- Create date: <05/26/2020>
-- Description:	<Search for EmplIDs from apno.for project: IntranetModule-Status-SubStatus phase2 UAT test >
-- parameters: '0' for all apnos; apnos are seperated by '|'.
-- exec [dbo].[QReport_GetSJVEmploymentIDListFromAPNOs] @APNOList='5119200|5119199|5119192',@StartDate='05/01/2020',@EndDate= '05/26/2020'
-- exec [dbo].[QReport_GetSJVEmploymentIDListFromAPNOs] @APNOList='0',@StartDate='05/01/2020',@EndDate= '05/26/2020'
-- Modified by Humera Ahmed on 6/20/2022 because report's data was not getting exported to Excel. The Public notes column exceeded 32,000 character limit so we are not including Public notes column in line #31
-- =============================================
CREATE PROCEDURE [dbo].[QReport_GetSJVEmploymentIDListFromAPNOs]
@APNOList varchar(max) =null,
@StartDate datetime =null,
@EndDate datetime =null
AS
BEGIN

	SET NOCOUNT ON;

	--declare @APNOList varchar(max) =null
	
	--declare	@StartDate datetime ='05/25/2020'
	--declare	@EndDate datetime ='05/26/2020'
		select distinct e.Investigator,a.clno,a.apno,e.EmplID,e.OrderId, a.ApStatus,e.SectStat,ss.Description, e.SectSubStatusID,sss.SectSubStatus,  e.CreatedDate, e.DateOrdered, e.Employer,e.Priv_Notes,
		--, e.Pub_Notes,
		 RFL, ver_By, Web_status, web_updated,e.Last_Updated,e.IsOnReport, e.IsHidden, e.IsOKtoContact
		from Empl e with(nolock)
		inner join appl a with(nolock) on a.apno= e.apno
		inner join SectStat ss with(nolock) on ss.Code = e.SectStat
		left join SectSubStatus sss with(nolock) on e.SectSubStatusID= sss.SectSubStatusID
		where 
		--e.Investigator='SJV'
		--and 
		(isnull(@APNOList,'0')='0' or  a.apno in (select value from [dbo].[fn_Split](@APNOList,'|')) )  
		and (isnull(@StartDate,'')='' or e.CreatedDate>=@StartDate)
		and (isnull(@EndDate,'')='' or (e.CreatedDate<=@EndDate +1))
		order by a.apno asc

END

