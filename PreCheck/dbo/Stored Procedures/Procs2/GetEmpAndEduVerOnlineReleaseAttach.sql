-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[GetEmpAndEduVerOnlineReleaseAttach]
	-- Add the parameters for the stored procedure here
	@StartDate datetime,
	@EndDate datetime
	
AS
BEGIN

DECLARE @via VarChar(1000) = 'Online Release'
DECLARE @via2 VarChar(1000) = 'StuWeb'
DECLARE @webstat Int = 5
DECLARE @norel NVarChar(1000) = 'N'
DECLARE @yrel NVarChar(1000) = 'Y'

DECLARE @emptable TABLE 
( 
    ApDate datetime, 
    APNO int,
	Name varchar(300),
	Employer_School varchar(300),
	ReleaseAttached varchar(10) 
)

DECLARE @edutable TABLE 
( 
    ApDate datetime, 
    APNO int,
	Name varchar(300),
	Employer_School varchar(300),
	ReleaseAttached varchar(10) 
)

if @StartDate = '1/1/1900'
begin
set @StartDate = '01/01/1976'
end

if @EndDate = '1/1/1900'
begin
set @EndDate = '01/01/2090'
end

insert into @emptable (apdate, apno, name, Employer_School, releaseattached)
values (null, null, 'Employer Verification', null, null)

--add spacing
insert into @edutable (apdate, apno, name, Employer_School, releaseattached)
values (null, null, null, null, null)
insert into @edutable (apdate, apno, name, Employer_School, releaseattached)
values (null, null, null, null, null)
insert into @edutable (apdate, apno, name, Employer_School, releaseattached)
values (null, null, 'Education Verification', null, null)



insert into @emptable (apdate, apno, name, Employer_School, releaseattached)
SELECT [t0].[ApDate], [t0].[APNO], [t1].[Name], [t2].[Employer], 
    (CASE 
        WHEN [t4].[test] IS NULL THEN @norel
        ELSE @yrel
     END) AS [ReleaseAttached]
FROM [Appl] AS [t0] with (nolock)
CROSS JOIN [Client] AS [t1] with (nolock)
CROSS JOIN [Empl] AS [t2] with (nolock)
LEFT OUTER JOIN (
    SELECT 1 AS [test], [t3].[ClientAPPNO], [t3].[EnteredVia]
    FROM [ReleaseForm] AS [t3] with (nolock)
    ) AS [t4] ON ([t4].[ClientAPPNO] = (CONVERT(NVarChar,[t2].[Apno]))) AND (([t4].[EnteredVia] = @via) OR ([t4].[EnteredVia] = @via2))
WHERE (Convert(date, t0.apdate)>= CONVERT(date, @StartDate)) AND (Convert(date, t0.apdate)<= CONVERT(date, @EndDate)) 
AND ([t1].[CLNO] = [t0].[CLNO]) AND (NOT ([t2].[IsHidden] = 1)) AND ([t2].[Apno] = [t0].[APNO]) AND ([t2].[web_status] = @webstat)


insert into  @edutable (apdate, apno, name, Employer_School, releaseattached)
SELECT [t0].[ApDate], [t0].[APNO], [t1].[Name], [t2].[School], 
    (CASE 
        WHEN [t4].[test] IS NULL THEN @norel
        ELSE @yrel
     END) AS [ReleaseAttached]
FROM [Appl] AS [t0] with (nolock)
CROSS JOIN [Client] AS [t1] with (nolock)
CROSS JOIN [Educat] AS [t2] with (nolock)
LEFT OUTER JOIN (
    SELECT 1 AS [test], [t3].[ClientAPPNO], [t3].[EnteredVia]
    FROM [ReleaseForm] AS [t3] with (nolock)
    ) AS [t4] ON ([t4].[ClientAPPNO] = (CONVERT(NVarChar,[t2].[APNO]))) AND (([t4].[EnteredVia] = @via) OR ([t4].[EnteredVia] = @via2))
WHERE (Convert(date, t0.apdate)>= CONVERT(date, @StartDate)) AND (Convert(date, t0.apdate)<= CONVERT(date, @EndDate)) 
AND ([t1].[CLNO] = [t0].[CLNO]) AND (NOT ([t2].[IsHidden] = 1)) AND ([t2].[APNO] = [t0].[APNO]) AND ([t2].[web_status] = @webstat)



--select 'Employments: ' as 'Employment Verification:'
select * from @emptable union all select * from @edutable
--select 'Education' as 'Education Verification:'
--select * from @edutable
END
