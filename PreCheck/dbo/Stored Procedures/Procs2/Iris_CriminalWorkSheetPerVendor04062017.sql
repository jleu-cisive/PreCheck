-- Alter Procedure Iris_CriminalWorkSheetPerVendor04062017






--[Iris_CriminalWorkSheetPerVendor] 513806









CREATE PROCEDURE [dbo].[Iris_CriminalWorkSheetPerVendor04062017] 
@VendorID int
AS





SELECT CrimID, APNO, County,clear,  Ordered, Name,DOB,  SSN, CaseNo, Date_Filed,  Degree,Offense,  Disposition,  Sentence, 
  Fine,  Disp_Date,  Pub_Notes, Priv_Notes,  CRIM_SpecialInstr,  vendorid,  status, txtalias, txtalias2,  txtalias3,  txtalias4,  uniqueid, 
     txtlast, Crimenteredtime, Last_Updated,  CNTY_NO, IRIS_REC,  Report,  batchnumber,  crim_time,  deliverymethod, countydefault, 
    b_rule,  tobeworked, readytosend,  NoteToVendor, test,  InUse,  parentCrimID,IrisFlag,  IrisOrdered,  [Temporary],  CreatedDate, KnownHits
from
((
SELECT dbo.Crim.CrimID as CrimID, 
    dbo.Crim.APNO as APNO,
   c.County as County, 
    (CASE dbo.Crim.Clear
    WHEN 'O' THEN 'Ordered'
    END) as clear, 
    dbo.Crim.Ordered as Ordered,
    isnull(dbo.Appl.Last,'') + ',  ' + isnull(dbo.Appl.First,'') + ',  ' +  isnull(dbo.Appl.Middle,'') as Name,
    dbo.Appl.DOB as DOB, 
    dbo.Appl.SSN as SSN,
    dbo.Crim.CaseNo as CaseNo, 
    dbo.Crim.Date_Filed as Date_Filed, 
    dbo.Crim.Degree as Degree, 
    dbo.Crim.Offense as Offense, 
    dbo.Crim.Disposition as Disposition, 
    dbo.Crim.Sentence as Sentence, 
    dbo.Crim.Fine as Fine, 
    dbo.Crim.Disp_Date as Disp_Date, 
    dbo.Crim.Pub_Notes as Pub_Notes,
    dbo.Crim.Priv_Notes as Priv_Notes, 
    dbo.Crim.CRIM_SpecialInstr as CRIM_SpecialInstr, 
    dbo.Crim.vendorid as vendorid, 
    dbo.Crim.status as status, 
    dbo.Crim.txtalias as txtalias, 
    dbo.Crim.txtalias2 as txtalias2, 
    dbo.Crim.txtalias3 as txtalias3, 
    dbo.Crim.txtalias4 as txtalias4, 
    dbo.Crim.uniqueid as uniqueid, 
    dbo.Crim.txtlast as txtlast, 
    dbo.Crim.Crimenteredtime as Crimenteredtime, 
    dbo.Crim.Last_Updated as Last_Updated, 
    dbo.Crim.CNTY_NO as CNTY_NO, 
    dbo.Crim.IRIS_REC as IRIS_REC, 
    dbo.Crim.Report as Report, 
    dbo.Crim.batchnumber as batchnumber, 
    dbo.Crim.crim_time as crim_time, 
    dbo.Crim.deliverymethod as deliverymethod, 
    dbo.Crim.countydefault as countydefault, 
    dbo.Crim.b_rule as b_rule, 
    dbo.Crim.tobeworked as tobeworked, 
    dbo.Crim.readytosend as readytosend, 
    dbo.Crim.NoteToVendor as NoteToVendor, 
    dbo.Crim.test as test, 
    dbo.Crim.InUse as InUse, 
    dbo.Crim.parentCrimID as parentCrimID,
    dbo.Crim.IrisFlag as IrisFlag, 
    dbo.Crim.IrisOrdered as IrisOrdered, 
    dbo.Crim.[Temporary] as [Temporary], 
    dbo.Crim.CreatedDate as CreatedDate,
ISNULL(dbo.Crim.CRIM_SpecialInstr,'') AS KnownHits
From dbo.Crim WITH (NOLOCK) INNER JOIN
                      dbo.Appl WITH (NOLOCK) ON dbo.Appl.APNO = dbo.Crim.APNO 
					  inner join dbo.TblCounties c on dbo.Crim.CNTY_NO = c.CNTY_NO

WHERE     (dbo.Crim.VendorID = @VendorID) and 
(dbo.Crim.Clear in('O','W')) --and (dbo.Appl.InUse is null) 
and (dbo.Crim.txtlast = 1)
and crim.ishidden = 0 --order by dbo.Crim.Apno
)
union all
(Select dbo.Crim.CrimID as CrimID, 
    dbo.Crim.APNO as APNO,
    c.County as County, 
    (CASE dbo.Crim.Clear
    WHEN 'O' THEN 'Ordered'
 WHEN 'W' THEN 'Ordered'
    END) as clear, 
    dbo.Crim.Ordered as Ordered,
    'Alias: ' +
    CASE WHEN (LTRIM(RTRIM((isnull(Alias1_Last,'') + ', ' + isnull(Alias1_First, '') + ' ' + ISNULL(Alias1_Middle, '')))) <> ',' and dbo.Crim.txtalias = 1) THEN isnull(Alias1_Last,'') + ', ' + isnull(Alias1_First, '') + ' ' + ISNULL(Alias1_Middle, '') ELSE '' END
    + CASE WHEN (LTRIM(RTRIM((isnull(Alias2_Last,'') + ', ' + isnull(Alias2_First, '') + ' ' + ISNULL(Alias2_Middle, '')))) <> ',' and dbo.Crim.txtalias2 = 1) THEN '/' + isnull(Alias2_Last,'') + ', ' + isnull(Alias2_First, '') + ' ' + ISNULL(Alias2_Middle, '') ELSE '' END
    + CASE WHEN (LTRIM(RTRIM((isnull(Alias3_Last,'') + ', ' + isnull(Alias3_First, '') + ' ' + ISNULL(Alias3_Middle, '')))) <> ',' and dbo.Crim.txtalias3 = 1)THEN '/' + isnull(Alias3_Last,'') + ', ' + isnull(Alias3_First, '') + ' ' + ISNULL(Alias3_Middle, '') ELSE '' END
    + CASE WHEN (LTRIM(RTRIM((isnull(Alias4_Last,'') + ', ' + isnull(Alias4_First, '') + ' ' + ISNULL(Alias4_Middle, '')))) <> ',' and dbo.Crim.txtalias4 = 1)THEN '/' + isnull(Alias4_Last,'') + ', ' + isnull(Alias4_First, '') + ' ' + ISNULL(Alias4_Middle, '') ELSE '' END
    as Name,
   -- 'Alias: ' + isnull(dbo.Appl.Alias1_Last,'') + '   ' + isnull(dbo.Appl.Alias1_First,'') + '   ' +  isnull(dbo.Appl.Alias1_Middle,'') + '   ' +
    --isnull(dbo.Appl.Alias2_Last,'') + '   ' + isnull(dbo.Appl.Alias2_First,'') + '   ' +  isnull(dbo.Appl.Alias2_Middle,'') + '   ' +
   -- isnull(dbo.Appl.Alias3_Last,'') + '   ' + isnull(dbo.Appl.Alias3_First,'') + '   ' +  isnull(dbo.Appl.Alias3_Middle,'') + '   ' +
   -- isnull(dbo.Appl.Alias4_Last,'') + '   ' + isnull(dbo.Appl.Alias4_First,'') + '   ' +  isnull(dbo.Appl.Alias4_Middle,'') as Name,
   
    dbo.Appl.DOB as DOB, 
    dbo.Appl.SSN as SSN,
    dbo.Crim.CaseNo as CaseNo, 
    dbo.Crim.Date_Filed as Date_Filed, 
    dbo.Crim.Degree as Degree, 
    dbo.Crim.Offense as Offense, 
    dbo.Crim.Disposition as Disposition, 
    dbo.Crim.Sentence as Sentence, 
    dbo.Crim.Fine as Fine, 
    dbo.Crim.Disp_Date as Disp_Date, 
    dbo.Crim.Pub_Notes as Pub_Notes,
    dbo.Crim.Priv_Notes as Priv_Notes, 
    dbo.Crim.CRIM_SpecialInstr as CRIM_SpecialInstr, 
    dbo.Crim.vendorid as vendorid, 
    dbo.Crim.status as status, 
    dbo.Crim.txtalias as txtalias, 
    dbo.Crim.txtalias2 as txtalias2, 
    dbo.Crim.txtalias3 as txtalias3, 
    dbo.Crim.txtalias4 as txtalias4, 
    dbo.Crim.uniqueid as uniqueid, 
    dbo.Crim.txtlast as txtlast, 
    dbo.Crim.Crimenteredtime as Crimenteredtime, 
    dbo.Crim.Last_Updated as Last_Updated, 
    dbo.Crim.CNTY_NO as CNTY_NO, 
    dbo.Crim.IRIS_REC as IRIS_REC, 
    dbo.Crim.Report as Report, 
    dbo.Crim.batchnumber as batchnumber, 
    dbo.Crim.crim_time as crim_time, 
    dbo.Crim.deliverymethod as deliverymethod, 
    dbo.Crim.countydefault as countydefault, 
    dbo.Crim.b_rule as b_rule, 
    dbo.Crim.tobeworked as tobeworked, 
    dbo.Crim.readytosend as readytosend, 
    dbo.Crim.NoteToVendor as NoteToVendor, 
    dbo.Crim.test as test, 
    dbo.Crim.InUse as InUse, 
    dbo.Crim.parentCrimID as parentCrimID,
    dbo.Crim.IrisFlag as IrisFlag, 
    dbo.Crim.IrisOrdered as IrisOrdered, 
    dbo.Crim.[Temporary] as [Temporary], 
    dbo.Crim.CreatedDate as CreatedDate,
ISNULL(dbo.Crim.CRIM_SpecialInstr,'') AS KnownHits
From dbo.Crim WITH (NOLOCK) INNER JOIN
                      dbo.Appl WITH (NOLOCK) ON dbo.Appl.APNO = dbo.Crim.APNO 
					   inner join dbo.TblCounties c on dbo.Crim.CNTY_NO = c.CNTY_NO
WHERE     (dbo.Crim.VendorID = @VendorID) and 
(dbo.Crim.Clear in( 'O','W')) --and (dbo.Appl.InUse is null) 
and crim.ishidden = 0 and
(isnull(dbo.Appl.Alias1_Last, '') <> '' or
isnull(dbo.Appl.Alias1_First, '') <> '' or
isnull(dbo.Appl.Alias1_Middle, '') <> '' or
isnull(dbo.Appl.Alias2_Last, '') <> '' or
isnull(dbo.Appl.Alias2_First, '') <> '' or
isnull(dbo.Appl.Alias2_Middle, '') <> '' or
isnull(dbo.Appl.Alias3_Last, '') <> '' or
isnull(dbo.Appl.Alias3_First, '') <> '' or
isnull(dbo.Appl.Alias3_Middle, '') <> '' or
isnull(dbo.Appl.Alias4_Last, '') <> '' or
isnull(dbo.Appl.Alias4_First, '') <> '' or
isnull(dbo.Appl.Alias4_Middle, '') <> '' )
and 
(
dbo.Crim.txtalias = 1 or
dbo.Crim.txtalias2 = 1 or
dbo.Crim.txtalias3 = 1 or
dbo.Crim.txtalias4 = 1 
)
)) K
order by County, Name desc
