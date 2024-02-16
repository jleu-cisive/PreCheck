-- Alter Procedure iris_VendorCounties





--iris_VendorCounties 97700



CREATE PROCEDURE [dbo].[iris_VendorCounties_backup02102021] 

@Researcher_id int

AS
Set NoCount On


CREATE TABLE #T1(
cnty_no int,
county char(100),
ncount int,
R_Name char(100) )

INSERT INTO #T1 (cnty_no, county,ncount,R_Name)
SELECT iris_Researcher_Charges.cnty_no,
c.A_County + ', ' + c.State  as Researcher_county,
--iris_Researcher_Charges.Researcher_county + ', ' + iris_Researcher_Charges.Researcher_State as Researcher_county,
 (Select count(crimid)From dbo.Crim WITH (NOLOCK) 
--INNER JOIN dbo.Appl WITH (NOLOCK) ON dbo.Appl.APNO = dbo.Crim.APNO 
WHERE crim.ishidden = 0 and (dbo.Crim.VendorID = @Researcher_id) and iris_Researcher_Charges.cnty_no =  dbo.Crim.CNTY_NO  and (dbo.Crim.Clear in('O','W'))
-- and (dbo.Appl.InUse is null) 
group by dbo.Crim.CNTY_NO) as ncount ,
	iris_Researchers.R_Name as R_Name   
  FROM iris_Researcher_Charges WITH (NOLOCK) LEFT OUTER JOIN
 iris_Researchers WITH (NOLOCK) ON iris_Researcher_Charges.Researcher_id = iris_Researchers.R_id 
INNER JOIN dbo.TblCounties c WITH (NOLOCK) ON iris_Researcher_Charges.cnty_no = c.CNTY_NO
where iris_Researcher_Charges.Researcher_id = @Researcher_id
--order by Researcher_county

Select county+'('+ISNULL(CAST([ncount] AS varChar),'0')+')' As Researcher_county ,cnty_no ,R_Name from #T1 order by ncount DESC
--Select dbo.Crim.CNTY_NO, count(*)as Count From dbo.Crim WITH (NOLOCK) INNER JOIN dbo.Appl WITH (NOLOCK) ON dbo.Appl.APNO = dbo.Crim.APNO WHERE (dbo.Crim.VendorID = 87)  and (dbo.Crim.Clear = 'O'or dbo.Crim.Clear is null) and (dbo.Appl.InUse is null) group by dbo.Crim.CNTY_NO
-- 
--
--SELECT CAST([Year] AS varChar) + '-' + RIGHT('0' + CAST([Month] AS varchar), 2) AS Period FROM Performance

--CREATE TABLE #T2(
--cnty_no int,
--ncount int
-- )
--
--
--
--INSERT INTO #T2 (cnty_no,ncount)
--Select dbo.Crim.CNTY_NO,count(crimid)From dbo.Crim WITH (NOLOCK) 
----INNER JOIN iris_Researcher_Charges on iris_Researcher_Charges.cnty_no =  dbo.Crim.CNTY_NO
----dbo.Appl WITH (NOLOCK) ON dbo.Appl.APNO = dbo.Crim.APNO 
--WHERE crim.ishidden = 0 and (dbo.Crim.VendorID = @Researcher_id)  and (dbo.Crim.Clear in('O','W'))
-- group by dbo.Crim.CNTY_NO
--
--CREATE TABLE #T1(
--cnty_no int,
--county char(30),
--ncount int,
--R_Name char(100) )
--
--INSERT INTO #T1 (cnty_no, county,ncount,R_Name)
--SELECT iris_Researcher_Charges.cnty_no,
--c.A_County + ', ' + c.State  as Researcher_county,
--ncount,
--iris_Researchers.R_Name as R_Name   
--  FROM iris_Researcher_Charges WITH (NOLOCK) LEFT  JOIN
-- iris_Researchers WITH (NOLOCK) ON iris_Researcher_Charges.Researcher_id = iris_Researchers.R_id 
--INNER JOIN Counties c WITH (NOLOCK) ON iris_Researcher_Charges.cnty_no = c.CNTY_NO
--inner join #T2 on iris_Researcher_Charges.cnty_no =  #T2.CNTY_NO 
--where iris_Researcher_Charges.Researcher_id = @Researcher_id
--order by Researcher_county
--
--
--Select county+'('+ISNULL(CAST([ncount] AS varChar),'0')+')' As Researcher_county ,cnty_no ,R_Name from #T1 order by ncount DESC
--
--
--drop table #T2
drop table #T1
