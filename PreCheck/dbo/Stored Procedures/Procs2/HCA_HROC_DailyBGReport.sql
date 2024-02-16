-- =============================================

-- Author:		Santosh Chapyala

-- Create date: 03/04/2015

-- Description:	This is a daily report sent to HCA (HROC) for their traceability

-- =============================================

CREATE PROCEDURE DBO.HCA_HROC_DailyBGReport

AS

BEGIN





SET NOCOUNT ON

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED



Select distinct '' FileType,Isnull(DeptCode,'') ProcessLevel,A.CLNO PreCheckCLNO,APNO [PreCheck Report#],First,Last,Middle,Pos_Sought [Position Sought],

Case apstatus when  'F' then 'Completed' When 'W' then 'Available' When 'M' then 'On Hold' When 'P' then 'In Progress' end [Status],StartDate,ApDate [Investigation StartDate],A.CreatedDate [Request Receieved],

Case when apstatus ='F' then dbo.elapsedbusinessdays_2(apdate,OrigCompDate) else dbo.elapsedbusinessdays_2(ApDate,Current_TimeStamp) end Days_Elapsed,OrigCompDate [Request Completion Date],Case when CompDate>OrigCompDate then CompDate else null end [Ammen
ded/Updated Date]

,Case EnteredVia when 'XML' then 'Integration' 

	              when 'web' then 'WebOrder'

				  else 'Data Entry' end Source

 from DBO.APPL A

 --Inner join HEVN..Facility F on Isnull(DEPTCOde,'') = F.FacilityNum and IsOneHR=1 --ideal but cant use this because there could be multiple process levels mapped to a facilityclno (duplicate rows)

Where A.CLNO in (Select distinct FacilityCLNO From HEVN..Facility Where IsOneHR=1 and facilityclno is not null) and

(createddate>cast(current_timestamp as date) or apdate >cast(current_timestamp as date) or OrigCompDate >cast(current_timestamp as date) or CompDate >cast(current_timestamp as date)) 

order by a.clno 





SET TRANSACTION ISOLATION LEVEL READ COMMITTED

SET NOCOUNT OFF









END
