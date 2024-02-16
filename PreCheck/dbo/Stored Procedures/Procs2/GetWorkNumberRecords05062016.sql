CREATE proc [dbo].[GetWorkNumberRecords05062016] 
 as
declare @ErrorCode int

Begin Transaction
Set @ErrorCode=@@Error



CREATE TABLE #WorkNumber  (APNO int, ApStatus char(1), SSN varchar(11), Priv_Notes nvarchar(4000), 
Pub_Notes nvarchar(4000), [First] varchar(20), [Last] varchar(20), EmplID int, EmplVerifyID int, 
Employer varchar(30), Location varchar(250), [state] varchar(2), city varchar(50), zipcode char(5), 
Position_A varchar(50), Position_V varchar(50), From_A varchar(30), IsFrom_AYear bit, From_V varchar(30), To_A varchar(30), IsTo_AYear bit,
To_V varchar(30), RFL varchar(30), Salary_V varchar(50), SectStat char(1), Title varchar(25), 
ver_by varchar(50), web_status int, name varchar(100), CodeCount int, NoPassThroughCharges  bit, ApprovedPassThroughCharges bit, VerifyType varchar(20))

Insert into #WorkNumber(APNO, ApStatus, SSN, Priv_Notes, 
						Pub_Notes, [First], [Last], EmplID, EmplVerifyID, 
						Employer, Location, [state], city, zipcode, 
						Position_A, Position_V, From_A, IsFrom_AYear, From_V, To_A, IsTo_AYear,
						To_V, RFL, Salary_V, SectStat, Title, 
						ver_by, web_status, name, CodeCount, NoPassThroughCharges, ApprovedPassThroughCharges, VerifyType)
SELECT   a.APNO, 
		 a.ApStatus, 
		 a.SSN, 
		 '' as Priv_Notes, 
		 '' as Pub_Notes, 
		 a.First, a.Last, 
		 e.EmplID, 
		 i.VerificationSourceCode as EmplVerifyID, 
		 e.Employer, e.Location, 
		 e.state, 
		 e.city, 
		 e.zipcode, 
		 e.Position_A, 
		 e.Position_V,
		case when Lower(e.From_A) = 'current' or  Lower(e.From_A) = 'present' or Lower(e.From_A) = 'n/a' then convert(varchar(10),getdate(),103) else e.From_A end as From_A, 
		0, 
		e.From_V, 
		case when Lower(e.To_A) = 'current' or  Lower(e.To_A) = 'present' or Lower(e.To_A) = 'n/a' then convert(varchar(10),getdate(),103) else e.To_A end as To_A, 
		0,
		case when Lower(e.To_V) = 'current' or  Lower(e.To_V) = 'present' then convert(varchar(10),getdate(),103) else e.To_V end as To_V, 
		--e.To_V,
		e.RFL, e.Salary_V, e.SectStat, e.Title, 'The WorkNumber WinService' as ver_by, e.web_status, c.name, i.codeCount, 
		--Isnull(g.NoPassThroughCharges, 0) as NoPassThroughCharges, isnull(g.ApprovedPassThroughCharges, 1) as ApprovedPassThroughCharges, 'Employment
		--' as VerifyType
		case when isnull(cc.value,'')='' then 0 else  (case when cc.value = 'True' then 1 else 0 end) end  as NoPassThroughCharges,
		case when isnull(cc1.value,'')='' then 1 else (case when cc1.value = 'True' then 1 else 0 end)  end ApprovedPassThroughCharges,
		 'Employment' as VerifyType
FROM dbo.Empl e with (nolock) 
INNER JOIN dbo.Appl a with (nolock) ON e.apno = a.apno 
INNER JOIN dbo.client c with (nolock) ON a.clno = c.clno
INNER JOIN 
(SELECT  a.VerificationSourceCode, a.SectionKeyID, 
--a.refVerificationSource, a.IsChecked, 
b.codeCount  FROM dbo.Integration_Verification_SourceCode  A  with (nolock) 
INNER JOIN
(select min(VerificationSourceCodeID) as VerificationSourceCodeID, SectionKeyID, refVerificationSource, IsChecked, count(*) as codeCount from dbo.Integration_Verification_SourceCode  with (nolock) 
group by SectionKeyID, refVerificationSource, IsChecked having refVerificationSource is not null and IsChecked = 0 and refVerificationSource = 'WorkNumber' ) B  on  A.VerificationSourceCodeID = B.VerificationSourceCodeID) i ON i.SectionKeyID = e.EmplID

LEFT JOIN dbo.clientconfiguration cc on c.clno = cc.clno and cc.ConfigurationKey = 'NoEmplPassThroughCharges'
LEFT JOIN dbo.clientconfiguration cc1 on c.clno = cc1.clno and cc1.ConfigurationKey = 'ApprovedEmplPassThroughCharges'
WHERE 
e.web_status = 69 and 
--(e.Inuse is null or e.Inuse = '') and (i.VerificationSourceCode <> '' or i.VerificationSourceCode is not null)
(isnull(e.Inuse,'') = '') and (isnull(i.VerificationSourceCode,'') <> '')



UPDATE dbo.Empl
        SET Inuse = 'WNWinSrv'
            WHERE EmplID IN( select Emplid from #WorkNumber where web_status = 69)

UPDATE i
        SET IsChecked = 1
		from dbo.Integration_Verification_SourceCode i
		inner join #WorkNumber w
		on i.SectionKeyID = w.Emplid
		and i.VerificationSourceCode = cast(w.EmplVerifyID as varchar(10))
		where w.web_status = 69
           

SELECT distinct w.APNO, w.ApStatus, w.SSN, w.Priv_Notes, w.Pub_Notes, w.[First], w.[Last], w.EmplID, w.EmplVerifyID, 
           w.Employer, w.Location, w.[state], w.city, w.zipcode, w.Position_A, w.Position_V, w.From_A, w.IsFrom_AYear, w.From_V, w.To_A, w.IsTo_AYear,
           w.To_V, w.RFL, w.Salary_V, w.SectStat, w.Title, w.ver_by, w.web_status, w.name, w.CodeCount, w.NoPassThroughCharges, w.ApprovedPassThroughCharges, w.VerifyType,
	       case when i.SubKeyChar is NULL or i.SubKeyChar = '' then 0 else 1 end as Isbilled
	       FROM #WorkNumber w left join dbo.invdetail (nolock) i on w.apno = i.apno and cast(w.EmplVerifyID as varchar(10)) = i.subkeychar where web_status = 69

    --SELECT * FROM #WorkNumber where web_status = 69
      

If (@ErrorCode<>0)
  Begin
  RollBack Transaction
  Return (-@ErrorCode)
  End
Else
  Commit Transaction

