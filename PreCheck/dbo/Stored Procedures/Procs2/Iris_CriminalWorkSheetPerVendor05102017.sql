-- Alter Procedure Iris_CriminalWorkSheetPerVendor05102017

/*
[Iris_CriminalWorkSheetPerVendor] 1278446
exec Iris_CriminalWorkSheetPerVendor04062017 1819258
*/

/*
Edited By	:	Deepak Vodethela	
Edited date	:	02/13/2017
Description	:	As part of Alias Logic Re-Write project all the Aliases will be from dbo.ApplAlias (Overflow table). Modified the conditions at Aliases section.
Execution : 
	EXEC [dbo].[Iris_CriminalWorkSheetPerVendor] 175
*/

CREATE PROCEDURE [dbo].[Iris_CriminalWorkSheetPerVendor05102017]
@VendorID int
AS

SELECT	CrimID, APNO, County,clear,  Ordered, Name, DOB,  SSN, CaseNo, Date_Filed,  Degree,Offense,  Disposition,  Sentence, 
		Fine,  Disp_Date,  Pub_Notes, Priv_Notes,  CRIM_SpecialInstr,  vendorid,  status,
		uniqueid, Crimenteredtime, Last_Updated,  CNTY_NO, IRIS_REC,  Report,  batchnumber,  crim_time,  deliverymethod, countydefault, 
		b_rule,  tobeworked, readytosend,  NoteToVendor, test,  InUse,  parentCrimID,IrisFlag,  IrisOrdered,  [Temporary],  CreatedDate, KnownHits
		INTO #tmp
FROM
(	(
	SELECT C.CrimID as CrimID, 
		C.APNO as APNO,
		X.County as County, 
		(CASE C.Clear
		WHEN 'O' THEN 'Ordered' END) as clear, 
		C.Ordered as Ordered,
		ISNULL(A.Last,'') + ', ' + ISNULL(A.First,'') + ' ' +  ISNULL(A.Middle,'') as Name,
		A.DOB as DOB, 
		A.SSN as SSN,
		C.CaseNo as CaseNo, 
		C.Date_Filed as Date_Filed, 
		C.Degree as Degree, 
		C.Offense as Offense, 
		C.Disposition as Disposition, 
		C.Sentence as Sentence, 
		C.Fine as Fine, 
		C.Disp_Date as Disp_Date, 
		C.Pub_Notes as Pub_Notes,
		C.Priv_Notes as Priv_Notes, 
		C.CRIM_SpecialInstr as CRIM_SpecialInstr, 
		C.vendorid as vendorid, 
		C.status as status, 
		C.uniqueid as uniqueid, 
		C.Crimenteredtime as Crimenteredtime, 
		C.Last_Updated as Last_Updated, 
		C.CNTY_NO as CNTY_NO, 
		C.IRIS_REC as IRIS_REC, 
		C.Report as Report, 
		C.batchnumber as batchnumber, 
		C.crim_time as crim_time, 
		C.deliverymethod as deliverymethod, 
		C.countydefault as countydefault, 
		C.b_rule as b_rule, 
		C.tobeworked as tobeworked, 
		C.readytosend as readytosend, 
		C.NoteToVendor as NoteToVendor, 
		C.test as test, 
		C.InUse as InUse, 
		C.parentCrimID as parentCrimID,
		C.IrisFlag as IrisFlag, 
		C.IrisOrdered as IrisOrdered, 
		C.[Temporary] as [Temporary], 
		C.CreatedDate as CreatedDate,
		ISNULL(C.CRIM_SpecialInstr,'') AS KnownHits
	FROM dbo.Crim AS C WITH (NOLOCK) 
	INNER JOIN dbo.Appl AS A WITH (NOLOCK) ON A.APNO = C.APNO 
	INNER JOIN dbo.TblCounties AS X on C.CNTY_NO = X.CNTY_NO
	WHERE (C.VendorID = @VendorID) 
	  AND (C.Clear in('O','W'))
	  AND C.ishidden = 0
	)
UNION ALL
	(Select C.CrimID as CrimID, 
		C.APNO as APNO,
		X.County as County, 
		(CASE C.Clear
			WHEN 'O' THEN 'Ordered'
			WHEN 'W' THEN 'Ordered'
		END) as clear, 
		C.Ordered as Ordered,
	   'Alias: ' + isnull(AA.AliasName,'') as Name,
		--isnull(AA.AliasName,'') as Name,
		A.DOB as DOB, 
		A.SSN as SSN,
		C.CaseNo as CaseNo, 
		C.Date_Filed as Date_Filed, 
		C.Degree as Degree, 
		C.Offense as Offense, 
		C.Disposition as Disposition, 
		C.Sentence as Sentence, 
		C.Fine as Fine, 
		C.Disp_Date as Disp_Date, 
		C.Pub_Notes as Pub_Notes,
		C.Priv_Notes as Priv_Notes, 
		C.CRIM_SpecialInstr as CRIM_SpecialInstr, 
		C.vendorid as vendorid, 
		C.status as status, 
		C.uniqueid as uniqueid, 
		C.Crimenteredtime as Crimenteredtime, 
		C.Last_Updated as Last_Updated, 
		C.CNTY_NO as CNTY_NO, 
		C.IRIS_REC as IRIS_REC, 
		C.Report as Report, 
		C.batchnumber as batchnumber, 
		C.crim_time as crim_time, 
		C.deliverymethod as deliverymethod, 
		C.countydefault as countydefault, 
		C.b_rule as b_rule, 
		C.tobeworked as tobeworked, 
		C.readytosend as readytosend, 
		C.NoteToVendor as NoteToVendor, 
		C.test as test, 
		C.InUse as InUse, 
		C.parentCrimID as parentCrimID,
		C.IrisFlag as IrisFlag, 
		C.IrisOrdered as IrisOrdered, 
		C.[Temporary] as [Temporary], 
		C.CreatedDate as CreatedDate,
		ISNULL(C.CRIM_SpecialInstr,'') AS KnownHits
	From dbo.Crim AS C WITH (NOLOCK) 
	INNER JOIN dbo.Appl AS A WITH (NOLOCK) ON A.APNO = C.APNO
LEFT JOIN 
	(SELECT t.SectionKeyID
			,STUFF((SELECT DISTINCT ' / ' + isnull(A.Last, '') + ', ' +  isnull(A.First, '') + ' ' + isnull(A.Middle, '')
					FROM ApplAlias AS A
					INNER JOIN dbo.ApplAlias_Sections AS S 
			        ON A.ApplAliasId = S.ApplAliasId
                    WHERE s.SectionKeyID = t.SectionKeyID AND S.IsActive = 1 AND S.ApplSectionID = 5 and IsPrimaryName=0
					FOR XML PATH(''),TYPE).value('.','VARCHAR(MAX)'),1,2,'') AS AliasName
 FROM ApplAlias_Sections t 
GROUP BY t.SectionKeyID
	) AA
	ON AA.SectionKeyID = C.CrimID
	INNER JOIN dbo.TblCounties AS X(NOLOCK) on C.CNTY_NO = X.CNTY_NO
	WHERE (C.VendorID = @VendorID) and isnull(AliasName,'')<>''
	  AND (C.Clear in( 'O','W'))
	  AND C.ishidden = 0 
	)
	) K

	--SELECT * FROM #tmp ORDER BY COUNTY, NAME DESC

	SELECT	DISTINCT CrimID, APNO, County,clear,  Ordered, Name,
			--Name = STUFF((SELECT ', ' + isnull(Name, '')
			--				FROM #tmp b 
			--				WHERE b.CrimID = a.CrimID 
			--				FOR XML PATH('')), 1, 2, '') ,
			DOB,  SSN, CaseNo, Date_Filed,  Degree,Offense,  Disposition,  Sentence, 
			Fine,  Disp_Date,  Pub_Notes, Priv_Notes,  CRIM_SpecialInstr,  vendorid,  status, 
			uniqueid, Crimenteredtime, Last_Updated,  CNTY_NO, IRIS_REC,  Report,  batchnumber,  crim_time,  deliverymethod, countydefault, 
			b_rule,  tobeworked, readytosend,  NoteToVendor, test,  InUse,  parentCrimID,IrisFlag,  IrisOrdered,  [Temporary],  CreatedDate, KnownHits
	FROM #tmp AS A
	ORDER BY COUNTY, NAME DESC

	DROP TABLE #tmp
