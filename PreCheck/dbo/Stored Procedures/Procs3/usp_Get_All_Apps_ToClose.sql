



-- =============================================
-- Author:		<najma begum>
-- Create date: <06/28/2012>
-- Description:	<Auto close apps with all clear>
-- =============================================
CREATE PROCEDURE [dbo].[usp_Get_All_Apps_ToClose]
	
AS
SET NOCOUNT ON


DECLARE @TblApno AS Table( [APNO] INT );
DECLARE @TblAll AS Table( [APNO] INT );

INSERT INTO @TblApno([APNO])
SELECT A.APNO
		FROM dbo.Appl A with (nolock)  
			INNER JOIN dbo.Client C with (nolock)  ON A.CLNO = C.CLNO
			left join clientconfiguration cc on c.clno = cc.clno and cc.configurationkey = 'OASIS_InProgressStatus'
	WHERE A.ApStatus = 'P'
		AND   Isnull(A.Investigator, '') <> ''
		AND A.userid IS NOT null
		AND   Isnull(A.CAM, '') = ''
		AND IsNull(c.clienttypeid,-1) <> 15
		and cc.value = 'True'
		and A.CLNO not in (2135,3468,3668)
		
insert into @TblAll
		
Select distinct A.Apno FROM dbo.Appl A with (nolock)  
		     LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.Empl with (nolock)   WHERE SectStat NOT IN ('4','5') Group by Apno) Empl on A.APNO = Empl.APNO
		     LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.Educat with (nolock)   WHERE SectStat NOT IN ('4','5') Group by Apno) Educat on A.APNO = Educat.APNO
		     LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.PersRef with (nolock)   WHERE SectStat NOT IN ('4','5') Group by Apno) PersRef on A.APNO = PersRef.APNO
		     LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.ProfLic with (nolock)   WHERE SectStat NOT IN ('4','5') Group by Apno) ProfLic on A.APNO = ProfLic.APNO
		     LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.Credit with (nolock)   WHERE (SectStat NOT IN ('4') and RepType in ('S')) Or (SectStat NOT IN ('3') and RepType in ('C')) Group by Apno) Credit on A.APNO = Credit.APNO
		     LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.MedInteg with (nolock)   WHERE SectStat NOT IN ('3') Group by Apno) MedInteg on A.APNO = MedInteg.APNO
		     LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.DL with (nolock)   WHERE SectStat NOT IN ('5') Group by Apno) DL on A.APNO = DL.APNO
		     LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.Crim with (nolock)   WHERE IsNull(Clear,'')<> 'T'  Group by Apno) Crim1 on A.APNO = Crim1.APNO
		     
		WHERE A.ApStatus IN ('P', 'W')
		AND   A.enteredvia ='StuWeb' and (Empl.apno is null) and (Educat.apno is null) and (PersRef.apno is null)
		and (ProfLic.apno is null) and (Credit.apno is null)and (MedInteg.apno is null)and (DL.apno is null)
		and (Crim1.apno is null)order by A.apno
		
		
		SELECT   distinct  dbo.Appl.APNO, dbo.Appl.ApStatus, dbo.Appl.Investigator, dbo.Appl.UserID as ClientCAM, dbo.Appl.ApDate, Appl.ReopenDate, 
DATEDIFF(day, Appl.ApDate, getdate()) AS ElapseDays,
case when Appl.apstatus = 'W' then 2 else 0 end as Available, (select max(activitydate) from applactivity where apno = Appl.Apno and activitycode  = 2) as SentPending,
dbo.Appl.SSN, dbo.Appl.Last, dbo.Appl.First, dbo.Client.Name as ClientName, 
                      dbo.Appl.CLNO, dbo.Appl.PackageID
FROM         dbo.Appl INNER JOIN
                      dbo.Client ON dbo.Appl.CLNO = dbo.Client.CLNO where Apno in (Select distinct t.Apno from @TblAll t left join Crim on t.Apno = Crim.Apno where Crim.Apno is null or Crim.IsHidden = 0)
AND Isnull(Appl.Investigator, '') <> '' AND Appl.userid IS NOT null AND   Isnull(Appl.CAM, '') = ''  AND Appl.Packageid is not NULL 
AND IsNull(client.clienttypeid,-1) <> 15 AND Appl.Apno not in(select Apno from @TblApno)and client.CLNO not in (2135,3468,3668) 
AND Appl.Apno not in(select Apno from ApplAdditionalData)
And (DATEDIFF(day, Appl.ApDate, getdate()))> 2
order by Appl.Apno



SET NOCOUNT OFF






















