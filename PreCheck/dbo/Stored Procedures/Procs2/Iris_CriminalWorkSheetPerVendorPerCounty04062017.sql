

CREATE PROCEDURE [dbo].[Iris_CriminalWorkSheetPerVendorPerCounty04062017] 
@VendorID int,
@County int

 AS
SELECT 
     

dbo.Crim.CrimID as CrimID, 
    dbo.Crim.APNO as APNO,
	dbo.Appl.CLNO AS CLNO,
    dbo.Crim.County as County,  
    dbo.Crim.Clear as Clear, 
    dbo.Crim.Ordered as Ordered,
    CASE WHEN (dbo.Crim.txtlast = 1) THEN isnull(dbo.Appl.Last,'') + ', ' + isnull(dbo.Appl.First, '') + ' ' + ISNULL(dbo.Appl.Middle, '') ELSE '' END
    + CASE WHEN (LTRIM(RTRIM((isnull(dbo.Appl.Alias1_Last,'') + ', ' + isnull(dbo.Appl.Alias1_First, '') + ' ' + ISNULL(dbo.Appl.Alias1_Middle, '')))) <> ',' and dbo.Crim.txtalias = 1) THEN '/' +  isnull(dbo.Appl.Alias1_Last,'') + ', ' + isnull(dbo.Appl.Alias1_First, '') + ' ' + ISNULL(dbo.Appl.Alias1_Middle, '') ELSE '' END
    + CASE WHEN (LTRIM(RTRIM((isnull(dbo.Appl.Alias2_Last,'') + ', ' + isnull(dbo.Appl.Alias2_First, '') + ' ' + ISNULL(dbo.Appl.Alias2_Middle, '')))) <> ',' and dbo.Crim.txtalias2 = 1) THEN '/' + isnull(dbo.Appl.Alias2_Last,'') + ', ' + isnull(dbo.Appl.Alias2_First, '') + ' ' + ISNULL(dbo.Appl.Alias2_Middle, '') ELSE '' END
    + CASE WHEN (LTRIM(RTRIM((isnull(dbo.Appl.Alias3_Last,'') + ', ' + isnull(dbo.Appl.Alias3_First, '') + ' ' + ISNULL(dbo.Appl.Alias3_Middle, '')))) <> ',' and dbo.Crim.txtalias3 = 1)THEN '/' + isnull(dbo.Appl.Alias3_Last,'') + ', ' + isnull(dbo.Appl.Alias3_First, '') + ' ' + ISNULL(dbo.Appl.Alias3_Middle, '') ELSE '' END
    + CASE WHEN (LTRIM(RTRIM((isnull(dbo.Appl.Alias4_Last,'') + ', ' + isnull(dbo.Appl.Alias4_First, '') + ' ' + ISNULL(dbo.Appl.Alias4_Middle, '')))) <> ',' and dbo.Crim.txtalias4 = 1)THEN '/' + isnull(dbo.Appl.Alias4_Last,'') + ', ' + isnull(dbo.Appl.Alias4_First, '') + ' ' + ISNULL(dbo.Appl.Alias4_Middle, '') ELSE '' END
    as CkName,

    Case when (cast(Isnull(dbo.Crim.txtAlias, 0)as int) + cast(Isnull(dbo.Crim.txtAlias2, 0)as int) + cast(Isnull(dbo.Crim.txtAlias3, 0)as int) + cast(Isnull(dbo.Crim.txtAlias4, 0)as int)) > 0 then 'Y'
         when (cast(Isnull(dbo.Crim.txtAlias, 0)as int) + cast(Isnull(dbo.Crim.txtAlias2, 0)as int) + cast(Isnull(dbo.Crim.txtAlias3, 0)as int) + cast(Isnull(dbo.Crim.txtAlias4, 0)as int)) = 0 then 'N' 
    End as AliasBoolean,
    Isnull(dbo.Crim.txtalias, 0) as txtalias,
    Isnull(dbo.Crim.txtalias2, 0) as txtalias2,
    Isnull(dbo.Crim.txtalias3, 0) as txtalias3,
    Isnull(dbo.Crim.txtalias4, 0) as txtalias4,
    
	dbo.Appl.Alias1_Last as Alias1_Last,
    dbo.Appl.Alias1_First as Alias1_First,  
    dbo.Appl.Alias1_Middle as Alias1_Middle,
    dbo.Appl.Alias1_Generation as Alias1_Generation,

    dbo.Appl.Alias2_Last as Alias2_Last,
    dbo.Appl.Alias2_First as Alias2_First,  
    dbo.Appl.Alias2_Middle as Alias2_Middle,
    dbo.Appl.Alias2_Generation as Alias2_Generation,

    dbo.Appl.Alias3_Last as Alias3_Last,
    dbo.Appl.Alias3_First as Alias3_First,  
    dbo.Appl.Alias3_Middle as Alias3_Middle,
    dbo.Appl.Alias3_Generation as Alias3_Generation,

    dbo.Appl.Alias4_Last as Alias4_Last,
    dbo.Appl.Alias4_First as Alias4_First,  
    dbo.Appl.Alias4_Middle as Alias4_Middle,
    dbo.Appl.Alias4_Generation as Alias4_Generation,

    dbo.Crim.Name as Name,
    dbo.Appl.DOB as ADOB,
    dbo.Crim.DOB as DOB,
    dbo.Appl.SSN as ASSN,
    dbo.Crim.SSN as SSN,
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
    --dbo.Crim.status as status, 
    dbo.Crim.txtalias as txtalias, 
    dbo.Crim.txtalias2 as txtalias2, 
    dbo.Crim.txtalias3 as txtalias3, 
    dbo.Crim.txtalias4 as txtalias4, 
    --dbo.Crim.uniqueid as uniqueid, 
    dbo.Crim.txtlast as txtlast, 
    --dbo.Crim.Crimenteredtime as Crimenteredtime, 
    dbo.Crim.Last_Updated as Last_Updated, 
    dbo.Crim.CNTY_NO as CNTY_NO, 
    dbo.Crim.IRIS_REC as IRIS_REC, 
   -- dbo.Crim.Report as Report, 
   -- dbo.Crim.batchnumber as batchnumber, 
    --dbo.Crim.crim_time as crim_time, 
    --dbo.Crim.deliverymethod as deliverymethod, 
    --dbo.Crim.countydefault as countydefault, 
    dbo.Crim.b_rule as b_rule, 
    --dbo.Crim.tobeworked as tobeworked, 
    --dbo.Crim.readytosend as readytosend, 
    --dbo.Crim.NoteToVendor as NoteToVendor, 
    --dbo.Crim.test as test, 
    --dbo.Crim.InUse as InUse, 
     dbo.Appl.Inuse as  InUse,
    --dbo.Crim.parentCrimID as parentCrimID,
    --dbo.Crim.IrisFlag as IrisFlag, 
    --dbo.Crim.IrisOrdered as IrisOrdered, 
    --dbo.Crim.[Temporary] as [Temporary], 
    --dbo.Crim.CreatedDate as CreatedDate
    '' as ClearChecked,
    '' as HitChecked,
    DateDiff(day, dbo.Appl.ApDate, getdate()) as DaysPassedForApp,
    case when len(dbo.Crim.Ordered) = 0 then 0
    else  DateDiff(day, cast(dbo.Crim.Ordered as DateTime), getdate()) end as DaysPassedForOrderedCrim
From dbo.Crim WITH (NOLOCK) INNER JOIN
                      dbo.Appl WITH (NOLOCK) ON dbo.Appl.APNO = dbo.Crim.APNO 
WHERE     (dbo.Crim.VendorID = @VendorID) and (dbo.Crim.Cnty_no = @County) and 
(dbo.Crim.Clear in('O','W'))
--and (dbo.Appl.InUse is null) 
and crim.ishidden = 0 order by Ordered,CkName


select clno,

SUBSTRING(value,0,CHARINDEX('|',value)) as cnty_no,

SUBSTRING(value,CHARINDEX('|',value) + 1,LEN(value) - 1) as vendorid

 from clientconfiguration (NOLOCK)

where clno = 3115 and configurationkey = 'Criminal_DPS_Stamp'

--Update Appl set InUse = 'Vendor' where apno in (SELECT dbo.Crim.APNO as APNO    
--From dbo.Crim WITH (NOLOCK) INNER JOIN
                      --dbo.Appl WITH (NOLOCK) ON dbo.Appl.APNO = dbo.Crim.APNO 
--WHERE     (dbo.Crim.VendorID = @VendorID) and (dbo.Crim.Cnty_no = @County) and 
--(dbo.Crim.Clear = 'O'or dbo.Crim.Clear is null) and (dbo.Appl.InUse is null))














