CREATE PROCEDURE [dbo].[MDA_UTPD_Report]
AS
BEGIN
	SELECT a.apno ReportNo,convert(varchar(10), ApDate, 101)  [Report Date],
			a.CLNO [Client ID], replace (c.Name,',',';')	 [Prepared For], 
			DeptCode,REPLACE(REPLACE(REPLACE(replace(Pub_notes,',','-'), CHAR(10), ''), CHAR(13), ''), CHAR(9), '') [Report Comments],
			First, Last,Middle,isnull(First,'') + ' ' + isnull(Middle, '') + ' ' + isnull(Last,'') as [Applicant Name],
			replace(Addr_Street,',',';') Addr_Street, a.city,a.state,a.zip,SSN,
			convert(varchar(10), DOB, 101) DOB,DL_State,DL_Number
		INTO #tmp
	FROM appl a 
	INNER JOIN (SELECT APNO 
				FROM dbo.Crim with (nolock)  
				WHERE IsNull(Clear,'') in ('F') 
				 AND IsHidden = 0 
				Group by Apno) Crim1 on A.APNO = Crim1.APNO
	INNER JOIN client c ON a.clno=c.clno
	--LEFT JOIN dbo.MedInteg m ON a.apno=m.apno
	WHERE a.CLNO IN (2167,2227,2228,2402,3035,8635,3977,16267)
	  AND a.ApStatus='P'

	SELECT COUNT(1) cnt,APNO 
		INTO #tmp2 
	FROM #tmp a 
	INNER JOIN dbo.Crim c WITH (nolock) ON a.ReportNo = c.apno 
	WHERE IsNull(Clear,'') NOT IN ('T','F', 'C', 'A', 'S')  --- addedd new status C, A, S as these are conclusive status as a result of COVID-19
	  AND IsHidden = 0 
	GROUP BY Apno 
	HAVING COUNT(1)>0 

	DELETE #tmp 
	--SELECT apno FROM crim 
	WHERE ReportNo IN (SELECT apno FROM #tmp2)

	SELECT a.*,replace(County,',',';') County,c.SSN [SSN ON Record],
			replace (c.Name,',',';') [Name on Record],
			case when isnull(c.DOB,'')='' then null else convert(varchar(10), c.DOB, 101) end [DOB On Record],
			replace(D.Description,',',';') Degree,
			 case when isnull(c.Date_Filed,'')='' then null else convert(varchar(10), c.Date_Filed, 101) end  [File Date],
			c.CaseNo,
			REPLACE(REPLACE(REPLACE(replace(c.Offense,',',';'), CHAR(10), ''), CHAR(13), ''), CHAR(9), '')  [Charge],
			case when isnull(c.Disp_Date,'')='' then null else convert(varchar(10), c.Disp_Date, 101) end  [Disposition Date],
			REPLACE(REPLACE(REPLACE(replace(c.Disposition,',',';'), CHAR(10), ''), CHAR(13), ''), CHAR(9), '')  Disposition,
			REPLACE(REPLACE(REPLACE(replace(r.Disposition,',',';'), CHAR(10), ''), CHAR(13), ''), CHAR(9), '')  [FinalDisposition],--Added for HDT :84628
			REPLACE(REPLACE(REPLACE(replace(c.Sentence,',',';'), CHAR(10), ''), CHAR(13), ''), CHAR(9), '')  Sentence,
			REPLACE(REPLACE(REPLACE(replace(c.Fine,',',';'), CHAR(10), ''), CHAR(13), ''), CHAR(9), '')  Fine,
			REPLACE(REPLACE(REPLACE(replace(Pub_notes,',',';'), CHAR(10), ''), CHAR(13), ''), CHAR(9), '') [comments]
	 FROM #tmp a 
	 INNER JOIN crim c ON a.ReportNo = c.apno AND clear='F'
	 LEFT JOIN dbo.refCrimDegree D ON c.Degree = D.refCrimDegree
	 left join dbo.RefDisposition r on r. RefDispositionID=c.RefDispositionID--Added for HDT :84628

	-- SELECT * FROM #tmp

	--SELECT * FROM crim WHERE apno IN (SELECT ReportNo FROM #tmp) ORDER BY apno

	--SELECT * FROM #tmp2

	DROP TABLE #tmp2
	DROP TABLE #tmp
END
