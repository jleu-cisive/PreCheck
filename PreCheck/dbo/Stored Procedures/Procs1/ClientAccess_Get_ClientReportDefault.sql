--[ClientAccess_Get_ClientReportDefault] 2331


-- =============================================
-- Author:		Kiran Miryala
-- Create date: 07-16-2008
-- Description:	 Gets app info for the client on Load of ClientReports page
-- =============================================
CREATE PROCEDURE [dbo].[ClientAccess_Get_ClientReportDefault]
	@CLNO  INT

As

Declare @date as datetime
Set @date = CAST(CAST(YEAR(getdate()) AS VARCHAR(4)) + '/' +
                CAST(MONTH(getdate()) AS VARCHAR(2)) + '/' +
                CAST(DAY(getdate()) AS VARCHAR(2)) AS DATETIME)


	SELECT --Top 150 
a.apno
,a.last,a.first,
case when Rtrim(Ltrim(a.ssn)) = '-  -' then '' else a.ssn end ssn
,convert(char(10),a.ApDate,101)as apdate 
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
where(
(a.CLNO = @CLNO or c.WebOrderParentCLNO = @CLNO) 
and 
a.compdate between (@date - 7) and DateAdd(d,1,@date) 
--a.compdate between getdate()- 7 and getdate() + 1 
and
a.apstatus = 'f')
union
SELECT 
a.apno
,a.last,a.first,case when Rtrim(Ltrim(a.ssn)) = '--' then '' else a.ssn end ssn
,convert(char(10),a.ApDate,101)as apdate  
,a.attn
,apstatus = case  when a.apstatus = 'F' then 'Completed' when a.apstatus = 'P' then 'In Progress' when a.apstatus = 'W' and a.apno > 1200000 then 'In Progress (A)' else 'On Hold' end
,c.Name AS expr1
,af.flagstatus
,a.Pos_Sought
	,Convert(varchar(10),a.DOB,101) as DOB
	,a.Phone
	FROM appl a WITH (NOLOCK)
	Inner Join  client c WITH (NOLOCK) ON a.CLNO = c.CLNO 
	LEFT OUTER JOIN applflagstatus af  WITH (NOLOCK) ON a.apno=af.apno
where(
(a.CLNO = @CLNO or c.WebOrderParentCLNO = @CLNO) 
and 
a.apstatus = 'p')
union
SELECT 
a.apno
,a.last,a.first,case when Rtrim(Ltrim(a.ssn)) = '--' then '' else a.ssn end ssn,convert(char(10),a.ApDate,101)as apdate  
,a.attn
,apstatus = case  when a.apstatus = 'F' then 'Completed' when a.apstatus = 'P' then 'In Progress' when a.apstatus = 'W' and a.apno > 1200000 then 'In Progress (A)' else 'On Hold' end
,c.Name AS expr1
,af.flagstatus
,a.Pos_Sought
	,Convert(varchar(10),a.DOB,101) as DOB
	,a.Phone
	FROM appl a WITH (NOLOCK)
	Inner Join  client c WITH (NOLOCK) ON a.CLNO = c.CLNO 
	LEFT OUTER JOIN applflagstatus af WITH (NOLOCK)  ON a.apno=af.apno
where
(a.CLNO = @CLNO or c.WebOrderParentCLNO = @CLNO) 
and 
a.apstatus = 'w'
order by a.apno DESC

SET ANSI_NULLS ON

