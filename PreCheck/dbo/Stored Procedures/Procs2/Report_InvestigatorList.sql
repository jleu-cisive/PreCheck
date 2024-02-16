


CREATE PROCEDURE [dbo].[Report_InvestigatorList]  @empl int, @persref int, @educat int, @proflic int, @csr int,
@startdate datetime, @enddate datetime

AS
-- Coded for online reporting  JS
SET NOCOUNT ON
if @empl <> '' 
SELECT     UserID
FROM         Users
WHERE     (Disabled = 0) AND (empl = @empl) 
union
select distinct empl.investigator as userid from appl join empl on appl.apno=empl.apno where 
apdate between @startdate and @enddate

if @educat <> '' 
SELECT     UserID
FROM         Users
WHERE     (Disabled = 0) AND (educat = @educat) 
union
select distinct educat.investigator as userid from appl join educat on appl.apno=educat.apno where 
apdate between @startdate and @enddate

if @proflic <> '' 
SELECT     UserID
FROM         Users
WHERE     (Disabled = 0) AND (proflic = @proflic) 
union
select distinct proflic.investigator as userid from appl join proflic on appl.apno=proflic.apno where 
apdate between @startdate and @enddate

if @persref <> '' 
SELECT     UserID
FROM         Users
WHERE     (Disabled = 0) AND (persref = @persref) 
union
select distinct persref.investigator as userid from appl join persref on appl.apno=persref.apno where 
apdate between @startdate and @enddate

if @csr <> '' 
SELECT     UserID
FROM         Users
WHERE     (Disabled = 0) AND (csr = @csr) 
union
select distinct investigator as userid from appl where 
apdate between @startdate and @enddate
