


CREATE PROCEDURE [dbo].[ApplToBeFinaled_Humera] AS
SET NOCOUNT ON

--The logic doesn't cover if the app has no section attached to it.
SELECT A.Apno, A.ApStatus, A.UserID, A.Investigator,
       A.ApDate, A.ReopenDate,  A.Last, A.First, A.Middle, 
       C.Name AS Client_Name
	FROM Appl A WITH (NOLOCK)
JOIN Client C ON A.Clno = C.Clno
--LEFT OUTER JOIN dbo.ApplAdditionalData AAD WITH(NOLOCK) ON (A.CLNO = AAD.CLNO AND  A.SSN = AAD.SSN AND AAD.SSN IS NOT NULL )
--LEFT OUTER JOIN dbo.ApplAdditionalData AAD2 WITH(NOLOCK) ON (A.APNO = AAD2.APNO AND AAD2.APNO IS NOT NULL)     
--LEFT JOIN clientconfiguration cc WITH(NOLOCK) on c.clno = cc.clno and cc.configurationkey = 'OASIS_InProgressStatus'
WHERE (A.ApStatus IN ('P','W'))
 AND ISNULL(A.Investigator, '') <> ''
  AND A.userid IS NOT null
  AND ISNULL(A.CAM, '') = ''
  AND ISNULL(c.clienttypeid,-1) <> 15
 -- this is unnecessary --> AND(A.ApStatus <> 'M')
	and (SELECT COUNT(*) FROM Crim WITH (NOLOCK)
	  WHERE (Crim.Apno = A.Apno) And Crim.IsHidden =0
	  AND ((Crim.Clear IS NULL) OR (Crim.Clear = 'R') OR (Crim.Clear = 'M') OR (Crim.Clear = 'O')OR (Crim.Clear = 'V')OR (Crim.Clear = 'I') OR (Crim.Clear = 'W') OR (Crim.Clear = 'Z') OR (Crim.Clear = 'D')))=0
       	and (SELECT COUNT(*) FROM Civil WITH (NOLOCK)
	  WHERE (Civil.Apno = A.Apno)
	  AND ((Civil.Clear IS NULL) OR (Civil.Clear = 'O')))=0
	and (SELECT COUNT(*) FROM Credit WITH (NOLOCK)
	  WHERE (Credit.Apno = A.Apno) AND (Credit.SectStat = '0' OR Credit.SectStat = '9'))=0
	and (SELECT COUNT(*) FROM DL WITH (NOLOCK)
	  WHERE (DL.Apno = A.Apno) AND (DL.SectStat = '0' OR DL.SectStat = '9'))=0
	and (SELECT COUNT(*) FROM Empl WITH (NOLOCK)
	  WHERE (Empl.Apno = A.Apno) AND Empl.IsOnReport = 1 AND (Empl.SectStat = '0' OR Empl.SectStat = '9'))=0
	and (SELECT COUNT(*) FROM Educat WITH (NOLOCK)
	  WHERE (Educat.Apno = A.Apno) AND Educat.IsOnReport = 1 AND (Educat.SectStat = '0' OR Educat.SectStat = '9'))=0
	and (SELECT COUNT(*) FROM ProfLic WITH (NOLOCK)
	  WHERE (ProfLic.Apno = A.Apno) AND ProfLic.IsOnReport = 1 AND (ProfLic.SectStat ='0' OR ProfLic.SectStat = '9'))=0
	and (SELECT COUNT(*) FROM PersRef WITH (NOLOCK)
	  WHERE (PersRef.Apno = A.Apno) AND PersRef.IsOnReport = 1 AND (PersRef.SectStat = '0' OR PersRef.SectStat = '9'))=0
	and (SELECT COUNT(*) FROM Medinteg WITH (NOLOCK)							    --added RSK 7/5/2006 How did this go so long without being caught?
	  WHERE (Medinteg.Apno = A.Apno) AND (Medinteg.SectStat = '0' OR Medinteg.SectStat = '9'))=0  --added RSK 7/5/2006
--ORDER BY A.Apno
ORDER BY A.ApDate


--Humera 8/15/2019
SELECT A.APNO,A.ApStatus,A.UserID,A.Investigator, A.ApDate, A.ReopenDate, --DATEDIFF(day, A.ApDate, getdate()) AS ElapseDays, 
--A.SSN, 
A.Last, A.First, A.Middle, C.Name AS Client_Name--, 
		--case when a.apstatus = 'W' then 2 else 0 end as Available, (select max(activitydate) from applactivity where apno = a.apno and activitycode  = 2) as SentPending
		FROM dbo.Appl A with (nolock)  
			INNER JOIN dbo.Client C with (nolock)  ON A.CLNO = C.CLNO
--			INNER JOIN dbo.SubStatus SS ON ISNULL(A.SubStatusID, 1) = SS.SubStatusID
--				AND SS.MainStatusID = 3	--investigator review
		     LEFT JOIN (SELECT COUNT(*) cnt,APNO FROM dbo.Empl    with (nolock)   WHERE SectStat IN ('0','9') AND IsOnReport = 1 Group by Apno) Empl on A.APNO = Empl.APNO
		     LEFT JOIN (SELECT COUNT(*) cnt,APNO FROM dbo.Educat  with (nolock)   WHERE SectStat IN ('0','9') AND IsOnReport = 1 Group by Apno) Educat on A.APNO = Educat.APNO
		     LEFT JOIN (SELECT COUNT(*) cnt,APNO FROM dbo.PersRef with (nolock)   WHERE SectStat IN ('0','9') AND IsOnReport = 1 Group by Apno) PersRef on A.APNO = PersRef.APNO
		     LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.ProfLic  with (nolock)  WHERE SectStat IN ('0','9') AND IsOnReport = 1 Group by Apno) ProfLic on A.APNO = ProfLic.APNO
		     LEFT JOIN (SELECT COUNT(1) cnt, APNO FROM dbo.Credit  WITH(NOLOCK)   WHERE SectStat IN ('0','9') and reptype ='S' GROUP BY Apno) PID on A.APNO = PID.APNO
			 LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.Credit   WITH(NOLOCK)    WHERE SectStat IN ('0','9') and reptype ='C' GROUP BY Apno) CCredit on A.APNO = CCredit.APNO
		     LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.MedInteg with (nolock)  WHERE SectStat IN ('0','9')  Group by Apno) MedInteg on A.APNO = MedInteg.APNO
		     LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.DL      with (nolock)   WHERE SectStat IN ('0','9')  Group by Apno) DL on A.APNO = DL.APNO
		     LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.Crim	 with (nolock)    WHERE ISNULL(Clear, '') IN ('','R','M','O', 'V','W','X','E','N','I','Q','Z') and ishidden = 0 Group by Apno) Crim on A.APNO = Crim.APNO
			 LEFT OUTER JOIN dbo.ApplAdditionalData AAD WITH(NOLOCK) ON (A.CLNO = AAD.CLNO AND  A.SSN = AAD.SSN AND AAD.SSN IS NOT NULL )
			 LEFT OUTER JOIN dbo.ApplAdditionalData AAD2 WITH(NOLOCK) ON (A.APNO = AAD2.APNO AND AAD2.APNO IS NOT NULL)     
			 LEFT JOIN clientconfiguration cc WITH(NOLOCK) on c.clno = cc.clno and cc.configurationkey = 'OASIS_InProgressStatus'
			 LEFT JOIN ( SELECT MAX(Last_Updated) AS Last_Updated, APNO 
			FROM ((SELECT MAX(Last_Updated) Last_Updated, APNO FROM dbo.Appl WITH(NOLOCK) GROUP BY Apno)
					 UNION ALL
				  (SELECT MAX(Last_Updated) Last_Updated, APNO FROM dbo.Empl WITH(NOLOCK) WHERE SectStat NOT IN ('0','9') AND IsOnReport = 1 GROUP BY Apno)
					 UNION ALL
				  (SELECT MAX(Last_Updated) Last_Updated, APNO FROM dbo.Educat WITH(NOLOCK) WHERE SectStat NOT IN ('0','9') AND IsOnReport = 1 GROUP BY Apno)
					 UNION ALL
				  (SELECT MAX(Last_Updated) Last_Updated, APNO FROM dbo.PersRef WITH(NOLOCK) WHERE SectStat NOT IN ('0','9') AND IsOnReport = 1 GROUP BY Apno) 
					 UNION ALL
				  (SELECT MAX(Last_Updated) Last_Updated, APNO FROM dbo.ProfLic WITH(NOLOCK) WHERE SectStat NOT IN ('0','9') AND IsOnReport = 1 GROUP BY Apno)
					 UNION ALL
				  (SELECT MAX(Last_Updated) Last_Updated, APNO FROM dbo.Credit WITH(NOLOCK) WHERE SectStat NOT IN ('0','9') and reptype ='S' GROUP BY Apno) 
					 UNION ALL
				  (SELECT MAX(Last_Updated) Last_Updated, APNO FROM dbo.Credit WITH(NOLOCK) WHERE SectStat NOT IN ('0','9') and reptype ='C' GROUP BY Apno)
					 UNION ALL
				  (SELECT MAX(Last_Updated) Last_Updated, APNO FROM dbo.MedInteg WITH(NOLOCK) WHERE SectStat NOT IN ('0','9')  GROUP BY Apno)
					 UNION ALL
				  (SELECT MAX(Last_Updated) Last_Updated, APNO FROM dbo.DL WITH(NOLOCK) WHERE SectStat NOT IN ('0','9')  GROUP BY Apno)
					 UNION ALL
				  (SELECT MAX(Last_Updated) Last_Updated, APNO FROM dbo.Crim  WITH(NOLOCK) WHERE ISNULL(Clear, '') NOT IN ('','R','M','O', 'V','W','X','E','N','I','Q','Z') AND ishidden = 0 GROUP BY Apno)
				) AS X GROUP BY X.APNO 
		 ) Y ON Y.APNO = A.APNO
		WHERE 
		A.UserID = 'KHunt'  AND 
		 A.ApStatus IN ('P','W') -- Only "Pending/InProgress OR "SmartStatus"
		AND ISNULL(A.Investigator, '') <> ''
		AND A.userid IS NOT null
		AND ISNULL(A.CAM, '') = ''
	    AND ISNULL(c.clienttypeid,-1) <> 1
		--AND   Isnull(A.CAM, '') = ''
		AND   (Isnull(Empl.Cnt,0) = 0)
		AND   (Isnull(Educat.Cnt,0) = 0)
		AND   (Isnull(PersRef.Cnt,0) = 0)
		AND   (Isnull(ProfLic.Cnt,0) = 0)
		AND   (isnull(CCredit.cnt,0)= 0)
		AND   (Isnull(PID.Cnt,0) = 0)
		AND   (Isnull(MedInteg.Cnt,0) = 0)
		AND   (Isnull(DL.Cnt,0) = 0)
		AND   (Isnull(Crim.Cnt,0) = 0)
		
		
--		UNION ALL

--		SELECT A.APNO,A.ApStatus,A.UserID,A.Investigator, A.ApDate, A.ReopenDate, A.Last, A.First, A.Middle, C.Name AS Client_Name--, 
--		--1 As Available, (select max(activitydate) from applactivity where apno = a.apno and activitycode  = 2) as SentPending
--		FROM dbo.Appl A with (nolock)  
--			INNER JOIN dbo.Client C with (nolock)  ON A.CLNO = C.CLNO
--			--left join clientconfiguration cc on c.clno = cc.clno and cc.configurationkey = 'OASIS_InProgressStatus'
----			INNER JOIN dbo.SubStatus SS ON ISNULL(A.SubStatusID, 1) = SS.SubStatusID
----				AND SS.MainStatusID = 3	--investigator review
--		     LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.Empl    with (nolock)   WHERE SectStat IN ('0','9') AND IsOnReport = 1 Group by Apno) Empl on A.APNO = Empl.APNO
--		     LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.Educat  with (nolock)   WHERE SectStat IN ('0','9') AND IsOnReport = 1 Group by Apno) Educat on A.APNO = Educat.APNO
--		     LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.PersRef with (nolock)   WHERE SectStat IN ('0','9') AND IsOnReport = 1 Group by Apno) PersRef on A.APNO = PersRef.APNO
--		     LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.ProfLic  with (nolock)  WHERE SectStat IN ('0','9') AND IsOnReport = 1 Group by Apno) ProfLic on A.APNO = ProfLic.APNO
--		     LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.Credit  with (nolock)   WHERE SectStat IN ('0','9') and reptype ='S' Group by Apno) SCredit on A.APNO = SCredit.APNO
--		     LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.Credit  with (nolock)   WHERE SectStat IN ('0','9') and reptype ='C' Group by Apno) CCredit on A.APNO = CCredit.APNO
--		     LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.MedInteg with (nolock)  WHERE SectStat IN ('0','9')  Group by Apno) MedInteg on A.APNO = MedInteg.APNO
--		     LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.DL      with (nolock)   WHERE SectStat IN ('0','9')  Group by Apno) DL on A.APNO = DL.APNO
--		     LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.Crim	 with (nolock)    WHERE ISNULL(Clear, '') IN ('','R','M','O', 'V','W','X','E','N','I','Q','Z') and ishidden = 0 Group by Apno) Crim on A.APNO = Crim.APNO
--			 LEFT OUTER JOIN dbo.ApplAdditionalData AAD WITH(NOLOCK) ON (A.CLNO = AAD.CLNO AND  A.SSN = AAD.SSN AND AAD.SSN IS NOT NULL )
--			 LEFT OUTER JOIN dbo.ApplAdditionalData AAD2 WITH(NOLOCK) ON (A.APNO = AAD2.APNO AND AAD2.APNO IS NOT NULL)     
--			 LEFT JOIN clientconfiguration cc WITH(NOLOCK) on c.clno = cc.clno and cc.configurationkey = 'OASIS_InProgressStatus'
--			 LEFT JOIN ( SELECT MAX(Last_Updated) AS Last_Updated, APNO 
--			FROM ((SELECT MAX(Last_Updated) Last_Updated, APNO FROM dbo.Appl WITH(NOLOCK) GROUP BY Apno)
--					 UNION ALL
--				  (SELECT MAX(Last_Updated) Last_Updated, APNO FROM dbo.Empl WITH(NOLOCK) WHERE SectStat NOT IN ('0','9') AND IsOnReport = 1 GROUP BY Apno)
--					 UNION ALL
--				  (SELECT MAX(Last_Updated) Last_Updated, APNO FROM dbo.Educat WITH(NOLOCK) WHERE SectStat NOT IN ('0','9') AND IsOnReport = 1 GROUP BY Apno)
--					 UNION ALL
--				  (SELECT MAX(Last_Updated) Last_Updated, APNO FROM dbo.PersRef WITH(NOLOCK) WHERE SectStat NOT IN ('0','9') AND IsOnReport = 1 GROUP BY Apno) 
--					 UNION ALL
--				  (SELECT MAX(Last_Updated) Last_Updated, APNO FROM dbo.ProfLic WITH(NOLOCK) WHERE SectStat NOT IN ('0','9') AND IsOnReport = 1 GROUP BY Apno)
--					 UNION ALL
--				  (SELECT MAX(Last_Updated) Last_Updated, APNO FROM dbo.Credit WITH(NOLOCK) WHERE SectStat NOT IN ('0','9') and reptype ='S' GROUP BY Apno) 
--					 UNION ALL
--				  (SELECT MAX(Last_Updated) Last_Updated, APNO FROM dbo.Credit WITH(NOLOCK) WHERE SectStat NOT IN ('0','9') and reptype ='C' GROUP BY Apno)
--					 UNION ALL
--				  (SELECT MAX(Last_Updated) Last_Updated, APNO FROM dbo.MedInteg WITH(NOLOCK) WHERE SectStat NOT IN ('0','9')  GROUP BY Apno)
--					 UNION ALL
--				  (SELECT MAX(Last_Updated) Last_Updated, APNO FROM dbo.DL WITH(NOLOCK) WHERE SectStat NOT IN ('0','9')  GROUP BY Apno)
--					 UNION ALL
--				  (SELECT MAX(Last_Updated) Last_Updated, APNO FROM dbo.Crim  WITH(NOLOCK) WHERE ISNULL(Clear, '') NOT IN ('','R','M','O', 'V','W','X','E','N','I','Q','Z') AND ishidden = 0 GROUP BY Apno)
--				) AS X GROUP BY X.APNO 
--		 ) Y ON Y.APNO = A.APNO
--		WHERE A.ApStatus = 'P'
--		--AND   A.ApDate IS NOT NULL
--		AND   Isnull(A.Investigator, '') <> ''
--		--AND	  Isnull(A.userid, '') <> ''
--		AND A.userid IS NOT null
--		AND   Isnull(A.CAM, '') = ''
--		AND   (Isnull(Empl.Cnt,0) > 0
--		or   Isnull(Educat.Cnt,0) > 0
--		or   Isnull(PersRef.Cnt,0) > 0
--		or   Isnull(CCredit.Cnt,0) > 0
--		or  Isnull(DL.Cnt,0) > 0)
--		AND   Isnull(ProfLic.Cnt,0) = 0
--		AND   Isnull(SCredit.Cnt,0) = 0
--		AND   Isnull(MedInteg.Cnt,0) = 0
--		AND   Isnull(Crim.Cnt,0) = 0
--		AND IsNull(c.clienttypeid,-1) <> 15
--		and cc.value = 'True'
--		ORDER BY A.apno















 
      
--
--SELECT A.APNO,A.ApStatus,A.UserID,A.Investigator, A.ApDate, A.ReopenDate, --DATEDIFF(day, A.ApDate, getdate()) AS ElapseDays, 
----A.SSN, 
--A.Last, A.First, A.Middle, C.Name AS Client_Name--, 
--		--case when a.apstatus = 'W' then 2 else 0 end as Available, (select max(activitydate) from applactivity where apno = a.apno and activitycode  = 2) as SentPending
--		FROM dbo.Appl A with (nolock)  
--			INNER JOIN dbo.Client C with (nolock)  ON A.CLNO = C.CLNO
----			INNER JOIN dbo.SubStatus SS ON ISNULL(A.SubStatusID, 1) = SS.SubStatusID
----				AND SS.MainStatusID = 3	--investigator review
--		     LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.Empl    with (nolock)   WHERE SectStat IN ('0','9') AND IsOnReport = 1 Group by Apno) Empl on A.APNO = Empl.APNO
--		     LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.Educat  with (nolock)   WHERE SectStat IN ('0','9') AND IsOnReport = 1 Group by Apno) Educat on A.APNO = Educat.APNO
--		     LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.PersRef with (nolock)   WHERE SectStat IN ('0','9') AND IsOnReport = 1 Group by Apno) PersRef on A.APNO = PersRef.APNO
--		     LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.ProfLic  with (nolock)  WHERE SectStat IN ('0','9') AND IsOnReport = 1 Group by Apno) ProfLic on A.APNO = ProfLic.APNO
--		     LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.Credit  with (nolock)   WHERE SectStat IN ('0','9') Group by Apno) Credit on A.APNO = Credit.APNO
--		     LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.MedInteg with (nolock)  WHERE SectStat IN ('0','9')  Group by Apno) MedInteg on A.APNO = MedInteg.APNO
--		     LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.DL      with (nolock)   WHERE SectStat IN ('0','9')  Group by Apno) DL on A.APNO = DL.APNO
--		     LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.Crim	 with (nolock)    WHERE ISNULL(Clear, '') IN ('','R','M','O', 'V','W','X','E','N','I','Q') and ishidden = 0 Group by Apno) Crim on A.APNO = Crim.APNO
--		WHERE A.ApStatus in ('P','W')
--		--AND   A.ApDate IS NOT NULL
--		AND   Isnull(A.Investigator, '') <> ''
--		--AND	  Isnull(A.userid, '') <> ''
--		AND A.userid IS NOT null
--		AND   Isnull(A.CAM, '') = ''
--		AND   Isnull(Empl.Cnt,0) = 0
--		AND   Isnull(Educat.Cnt,0) = 0
--		AND   Isnull(PersRef.Cnt,0) = 0
--		AND   Isnull(ProfLic.Cnt,0) = 0
--		AND   Isnull(Credit.Cnt,0) = 0
--		AND   Isnull(MedInteg.Cnt,0) = 0
--		AND   Isnull(DL.Cnt,0) = 0
--		AND   Isnull(Crim.Cnt,0) = 0
--		AND IsNull(c.clienttypeid,-1) <> 15
--		and a.apno not in (SELECT A.APNO
--		FROM dbo.Appl A with (nolock)  
--			INNER JOIN dbo.Client C with (nolock)  ON A.CLNO = C.CLNO
--			left join clientconfiguration cc on c.clno = cc.clno and cc.configurationkey = 'OASIS_InProgressStatus'
----			INNER JOIN dbo.SubStatus SS ON ISNULL(A.SubStatusID, 1) = SS.SubStatusID
----				AND SS.MainStatusID = 3	--investigator review
--		     LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.Empl    with (nolock)   WHERE SectStat IN ('0','9') AND IsOnReport = 1 Group by Apno) Empl on A.APNO = Empl.APNO
--		     LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.Educat  with (nolock)   WHERE SectStat IN ('0','9') AND IsOnReport = 1 Group by Apno) Educat on A.APNO = Educat.APNO
--		     LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.PersRef with (nolock)   WHERE SectStat IN ('0','9') AND IsOnReport = 1 Group by Apno) PersRef on A.APNO = PersRef.APNO
--		     LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.ProfLic  with (nolock)  WHERE SectStat IN ('0','9') AND IsOnReport = 1 Group by Apno) ProfLic on A.APNO = ProfLic.APNO
--		     LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.Credit  with (nolock)   WHERE SectStat IN ('0','9') and reptype ='S' Group by Apno) SCredit on A.APNO = SCredit.APNO
--		     LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.Credit  with (nolock)   WHERE SectStat IN ('0','9') and reptype ='C' Group by Apno) CCredit on A.APNO = CCredit.APNO
--		     LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.MedInteg with (nolock)  WHERE SectStat IN ('0','9')  Group by Apno) MedInteg on A.APNO = MedInteg.APNO
--		     LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.DL      with (nolock)   WHERE SectStat IN ('0','9')  Group by Apno) DL on A.APNO = DL.APNO
--		     LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.Crim	 with (nolock)    WHERE ISNULL(Clear, '') IN ('','R','M','O', 'V','W','X','E','N','I','Q') and ishidden = 0 Group by Apno) Crim on A.APNO = Crim.APNO
--		WHERE A.ApStatus = 'P'
--		--AND   A.ApDate IS NOT NULL
--		AND   Isnull(A.Investigator, '') <> ''
--		--AND	  Isnull(A.userid, '') <> ''
--		AND A.userid IS NOT null
--		AND   Isnull(A.CAM, '') = ''
--		AND   (Isnull(Empl.Cnt,0) > 0
--		or   Isnull(Educat.Cnt,0) > 0
--		or   Isnull(PersRef.Cnt,0) > 0
--		or   Isnull(CCredit.Cnt,0) > 0
--		or  Isnull(DL.Cnt,0) > 0)
--		AND   Isnull(ProfLic.Cnt,0) = 0
--		AND   Isnull(SCredit.Cnt,0) = 0
--		AND   Isnull(MedInteg.Cnt,0) = 0
--		AND   Isnull(Crim.Cnt,0) = 0
--		AND IsNull(c.clienttypeid,-1) <> 15
--		and cc.value = 'True')
--		UNION ALL
--		SELECT A.APNO,A.ApStatus,A.UserID,A.Investigator, A.ApDate, A.ReopenDate, A.Last, A.First, A.Middle, C.Name AS Client_Name--, 
--		--1 As Available, (select max(activitydate) from applactivity where apno = a.apno and activitycode  = 2) as SentPending
--		FROM dbo.Appl A with (nolock)  
--			INNER JOIN dbo.Client C with (nolock)  ON A.CLNO = C.CLNO
--			left join clientconfiguration cc on c.clno = cc.clno and cc.configurationkey = 'OASIS_InProgressStatus'
----			INNER JOIN dbo.SubStatus SS ON ISNULL(A.SubStatusID, 1) = SS.SubStatusID
----				AND SS.MainStatusID = 3	--investigator review
--		     LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.Empl    with (nolock)   WHERE SectStat IN ('0','9') AND IsOnReport = 1 Group by Apno) Empl on A.APNO = Empl.APNO
--		     LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.Educat  with (nolock)   WHERE SectStat IN ('0','9') AND IsOnReport = 1 Group by Apno) Educat on A.APNO = Educat.APNO
--		     LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.PersRef with (nolock)   WHERE SectStat IN ('0','9') AND IsOnReport = 1 Group by Apno) PersRef on A.APNO = PersRef.APNO
--		     LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.ProfLic  with (nolock)  WHERE SectStat IN ('0','9') AND IsOnReport = 1 Group by Apno) ProfLic on A.APNO = ProfLic.APNO
--		     LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.Credit  with (nolock)   WHERE SectStat IN ('0','9') and reptype ='S' Group by Apno) SCredit on A.APNO = SCredit.APNO
--		     LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.Credit  with (nolock)   WHERE SectStat IN ('0','9') and reptype ='C' Group by Apno) CCredit on A.APNO = CCredit.APNO
--		     LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.MedInteg with (nolock)  WHERE SectStat IN ('0','9')  Group by Apno) MedInteg on A.APNO = MedInteg.APNO
--		     LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.DL      with (nolock)   WHERE SectStat IN ('0','9')  Group by Apno) DL on A.APNO = DL.APNO
--		     LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.Crim	 with (nolock)    WHERE ISNULL(Clear, '') IN ('','R','M','O', 'V','W','X','E','N','I','Q') and ishidden = 0 Group by Apno) Crim on A.APNO = Crim.APNO
--		WHERE A.ApStatus = 'P'
--		--AND   A.ApDate IS NOT NULL
--		AND   Isnull(A.Investigator, '') <> ''
--		--AND	  Isnull(A.userid, '') <> ''
--		AND A.userid IS NOT null
--		AND   Isnull(A.CAM, '') = ''
--		AND   (Isnull(Empl.Cnt,0) > 0
--		or   Isnull(Educat.Cnt,0) > 0
--		or   Isnull(PersRef.Cnt,0) > 0
--		or   Isnull(CCredit.Cnt,0) > 0
--		or  Isnull(DL.Cnt,0) > 0)
--		AND   Isnull(ProfLic.Cnt,0) = 0
--		AND   Isnull(SCredit.Cnt,0) = 0
--		AND   Isnull(MedInteg.Cnt,0) = 0
--		AND   Isnull(Crim.Cnt,0) = 0
--		AND IsNull(c.clienttypeid,-1) <> 15
--		and cc.value = 'True'
--		ORDER BY A.apno



--SELECT distinct A.Investigator,a.CLNO,A.ApStatus,A.APNO, A.ApDate, A.ReopenDate, DATEDIFF(day, A.ApDate, getdate()) AS ElapseDays, A.SSN, A.Last, A.First, A.Middle, C.Name AS ClientName, A.UserID AS ClientCAM, 
--		(select max(activitydate) from applactivity where apno = a.apno and activitycode  = 2)  SentPending,isnull(AAD2.Crim_SelfDisclosed,isnull(AAD.Crim_SelfDisclosed,0)) Crim_SelfDisclosed,isnull(cc.value,'False') SmartStatusClient,
--		isnull(empl.cnt,0) emplPendingCount,isnull(Educat.cnt,0)  EducatPendingCount,isnull(PersRef.cnt,0)  PersRefPendingCount,isnull(ProfLic.cnt,0)  ProfLicPendingCount,
--		isnull(PID.cnt,0)  PIDPendingCount,isnull(MedInteg.cnt,0)  MedIntegPendingCount,isnull(Crim.cnt,0)  CrimPendingCount,
--		isnull(CCredit.cnt,0)  CCreditPendingCount,isnull(DL.cnt,0)  DLPendingCount, isnull(A.InProgressReviewed,0) InProgressReviewed
--		into #tmpAppl
--		FROM dbo.Appl A with (nolock)  
--			INNER JOIN dbo.Client C with (nolock)  ON A.CLNO = C.CLNO
--		    LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.Empl    with (nolock)   WHERE SectStat IN ('0','9') AND IsOnReport = 1 AND Ishidden = 0 Group by Apno) Empl on A.APNO = Empl.APNO
--		    LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.Educat  with (nolock)   WHERE SectStat IN ('0','9') AND IsOnReport = 1 AND Ishidden = 0 Group by Apno) Educat on A.APNO = Educat.APNO
--		    LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.PersRef with (nolock)   WHERE SectStat IN ('0','9') AND IsOnReport = 1 AND Ishidden = 0 Group by Apno) PersRef on A.APNO = PersRef.APNO
--		    LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.ProfLic  with (nolock)  WHERE SectStat IN ('0','9') AND IsOnReport = 1 AND Ishidden = 0 Group by Apno) ProfLic on A.APNO = ProfLic.APNO
--		    LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.Credit  with (nolock)   WHERE SectStat IN ('0','9') AND reptype ='S' AND Ishidden = 0 Group by Apno) PID on A.APNO = PID.APNO
--		    LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.Credit  with (nolock)   WHERE SectStat IN ('0','9') AND reptype ='C' AND Ishidden = 0 Group by Apno) CCredit on A.APNO = CCredit.APNO
--		    LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.MedInteg with (nolock)  WHERE SectStat IN ('0','9') AND Ishidden = 0 Group by Apno) MedInteg on A.APNO = MedInteg.APNO
--		    LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.DL      with (nolock)   WHERE SectStat IN ('0','9') AND Ishidden = 0 Group by Apno) DL on A.APNO = DL.APNO
--		    LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.Crim	 with (nolock)   WHERE ISNULL(Clear, '') IN ('','R','M','O', 'V','W','X','E','N','I','Q','Z') AND ishidden = 0 Group by Apno) Crim on A.APNO = Crim.APNO
--			LEFT OUTER JOIN dbo.ApplAdditionalData AAD with (Nolock) ON ( (A.CLNO = AAD.CLNO AND  A.SSN = AAD.SSN AND AAD.SSN IS NOT NULL ))
--			LEFT OUTER JOIN dbo.ApplAdditionalData AAD2 with (Nolock) ON (A.APNO = AAD2.APNO AND  AAD2.APNO IS NOT NULL)	
--			left join clientconfiguration cc with (Nolock) on c.clno = cc.clno and cc.configurationkey = 'OASIS_InProgressStatus'	
--		WHERE A.ApStatus in ('P','W')
--		AND   Isnull(A.Investigator, '') <> ''
--		AND A.userid IS NOT null
--		AND   Isnull(A.CAM, '') = ''
--		AND IsNull(c.clienttypeid,-1) <> 15

--		CREATE NONCLUSTERED INDEX IX_tmpAppl_ApStatus_SmartStatusClient
--		ON [dbo].[#tmpAppl] ([ApStatus],[SmartStatusClient],[ProfLicPendingCount],[PIDPendingCount],[MedIntegPendingCount],[CrimPendingCount])
--		INCLUDE ([Investigator],[APNO],[ApDate],[ReopenDate],[ElapseDays],[SSN],[Last],[First],[ClientName],[ClientCAM],[SentPending],[Crim_SelfDisclosed],[emplPendingCount],[EducatPendingCount],[PersRefPendingCount],[CCreditPendingCount],[DLPendingCount],[InProgressReviewed])
		
		
--		--Select distinct A.Investigator,A.ApStatus,A.APNO, A.ApDate, A.ReopenDate, A.ElapseDays, A.SSN, A.Last, A.First, A.ClientName, A.ClientCAM,
--		--		case when a.apstatus = 'W' then 2 else 0 end as Available, A.SentPending,A.Crim_SelfDisclosed, isnull(A.InProgressReviewed,0) InProgressReviewed
--		Select A.Apno, A.ApStatus,A.ClientCAM AS 'UserID', A.Investigator,
--       A.ApDate, A.ReopenDate,  A.Last, A.First, A.Middle, A.ClientName AS 'Client_Name'
--		From #tmpAppl A
--		Where A.ApStatus in ('P','W')
--		AND   A.emplPendingCount = 0
--		AND   A.EducatPendingCount = 0
--		AND   A.PersRefPendingCount=0
--		AND   A.CCreditPendingCount = 0
--		AND   A.DLPendingCount = 0
--		AND   A.ProfLicPendingCount = 0
--		AND   A.PIDPendingCount = 0
--		AND   A.MedIntegPendingCount = 0
--		AND   A.CrimPendingCount = 0
--		UNION ALL
--		--Select distinct A.Investigator,A.ApStatus,A.APNO, A.ApDate, A.ReopenDate, A.ElapseDays, A.SSN, A.Last, A.First, A.ClientName, A.ClientCAM,
--		--		1 as Available, A.SentPending,A.Crim_SelfDisclosed, isnull(A.InProgressReviewed,0) InProgressReviewed
--		Select A.Apno, A.ApStatus, A.ClientCAM  AS 'UserID', A.Investigator,
--       A.ApDate, A.ReopenDate,  A.Last, A.First, A.Middle, A.ClientName AS 'Client_Name'
--		From #tmpAppl A
--		Where A.ApStatus = 'P'
--		--Where A.ApStatus in ('P','W')
--		AND   A.SmartStatusClient = 'True'
--		AND	  (A.emplPendingCount > 0
--		   OR   A.EducatPendingCount > 0
--		   OR   A.PersRefPendingCount>0
--		   OR   A.CCreditPendingCount > 0
--		   OR   A.DLPendingCount > 0)
--		AND   A.ProfLicPendingCount = 0
--		AND   A.PIDPendingCount = 0
--		AND   A.MedIntegPendingCount = 0
--		AND   A.CrimPendingCount = 0
--		ORDER BY A.apno

--		drop table #tmpAppl

set ANSI_NULLS OFF
set QUOTED_IDENTIFIER OFF


