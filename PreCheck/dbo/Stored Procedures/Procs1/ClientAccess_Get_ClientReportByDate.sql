

/****** Object:  StoredProcedure [dbo].[EZVerify_GetEmplVerificationInfo]    Script Date: 06/22/2011 11:03:41 ******/

-- =============================================
-- Author:		Kiran Miryala
-- Create date: 07-16-2008
-- Description:	 Gets app info for the client when search by Dates
-- =============================================
CREATE PROCEDURE [dbo].[ClientAccess_Get_ClientReportByDate]
	@CLNO  INT,
 @StartDate	  DateTime,
 @EndDate      DateTime

As

SELECT 
	a.apno
	,a.last
	,a.first
	,a.ssn
	,a.apdate
	,a.attn
	,apstatus = case  when a.apstatus = 'F' then 'Completed' when a.apstatus = 'P' then 'In Progress' when a.apstatus = 'W' and a.apno > 1200000 then 'In Progress (A)' else 'On Hold' end
	,c.Name AS expr1 
	,af.flagstatus
	,a.Pos_Sought
	,Convert(varchar(10),a.DOB,101) as DOB
	,a.Phone
	FROM appl a WITH (NOLOCK)
	Inner Join  client c WITH (NOLOCK) ON a.CLNO = c.CLNO 
	LEFT OUTER JOIN applflagstatus af WITH (NOLOCK) ON a.apno=af.apno
	where 
		(a.CLNO = @CLNO or c.WebOrderParentCLNO = @CLNO)
	 AND 
a.apdate between @StartDate and @EndDate
--		a.apdate >= @StartDate 
--	AND 
--		a.apdate < DateAdd(d,1,@EndDate)
	
		--a.apdate <= @EndDate
	order by a.apno DESC


