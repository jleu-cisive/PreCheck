-- Alter Procedure PrecheckFramework_GetCrimCountiesWithSourceByApno



--[PrecheckFramework_GetCrimCountiesWithSourceByApno] 2188058
--Exec dbo.[PrecheckFramework_GetCrimCountiesWithSourceByApno] 5324919
CREATE procedure [dbo].[PrecheckFramework_GetCrimCountiesWithSourceByApno]
@apno int

as
--SET @APNO = 2188000
--2188000,2188025,2188031,2188058,2188061
--select 'Source' as SectionName,ac.sourceId,ac.apno,source,ac.county,AC.[State],AC.[IsStatewide],[CNTY_NUM],[CNTY_NUMToOrder],isnull([CountyCount],1)[CountyCount],[AddedOn],[SourceIdntyColValue],[Priority],(A_County + ', ' + C.State) CNTY_ToOrder
--FROM [dbo].[ApplCounties] AC 
--INNER JOIN [dbo].[refBRSourcePriority] P on AC.SourceID = P.SourceID 
--INNER JOIN [dbo].[BRSources] S on AC.SourceID = S.SourceID -- Not needed. Just for display now.
--INNER JOIN dbo.counties C on AC.[CNTY_NUMToOrder] = C.CNTY_NO
--WHERE APNO = @APNO AND AC.IsActive = 1
--order by [Priority]

--schapyala added group by to eliminate duplicates in the ApplCounties table on 09/15/2020
select 'Source' as SectionName,ac.sourceId,ac.apno,source,ac.county,AC.[State],AC.[IsStatewide],[CNTY_NUM],[CNTY_NUMToOrder],isnull([CountyCount],1)[CountyCount],
max([AddedOn]) [AddedOn],[SourceIdntyColValue],[Priority],(A_County + ', ' + C.State) CNTY_ToOrder
FROM [dbo].[ApplCounties] AC 
INNER JOIN [dbo].[refBRSourcePriority] P on AC.SourceID = P.SourceID 
INNER JOIN [dbo].[BRSources] S on AC.SourceID = S.SourceID -- Not needed. Just for display now.
INNER JOIN dbo.counties C on AC.[CNTY_NUMToOrder] = C.CNTY_NO
WHERE APNO = @APNO AND AC.IsActive = 1
Group By ac.sourceId,ac.apno,source,ac.county,AC.[State],
AC.[IsStatewide],[CNTY_NUM],[CNTY_NUMToOrder],isnull([CountyCount],1),
[SourceIdntyColValue],[Priority],A_County ,C.State
order by [Priority]

select 'SourceDetail' as SectionName,* from
(
--employment details
select ac.sourceId,[SourceIdntyColValue],
empl.Employer as NameOfSource, empl.Position_A,
null as Studies_A,null as NameOnRecord,
null as Degree,null as DOB, null as SSN, null as Caseno,null as Offense,null as Disposition,null as Sentence,null as Fine, null [Date_filed],null [CrimDate],null as Priv_Notes,@apno APNO,
empl.From_A as FromDate,empl.To_A as ToDate,empl.City as City,empl.[State] as [State]
FROM [dbo].[ApplCounties] AC 
INNER JOIN [dbo].[refBRSourcePriority] P on AC.SourceID = P.SourceID 
INNER JOIN [dbo].[BRSources] S on AC.SourceID = S.SourceID 
INNER JOIN [dbo].Empl empl on empl.emplid = ac.[SourceIdntyColValue]
where ac.sourceid = 7 and ac.apno = @apno and ac.isactive = 1

UNION ALL

--education details
select ac.sourceId,[SourceIdntyColValue],
educat.school as NameOfSource,null as Position_A,
Educat.Studies_A,educat.Name NameOnRecord,
educat.Degree_A Degree,null as DOB, null as SSN, null as Caseno,null as Offense,null as Disposition,null as Sentence,null as Fine,  null [Date_filed],null [CrimDate],null as Priv_Notes, @apno APNO,
educat.From_A as FromDate,educat.To_A as ToDate,educat.City as City,educat.[State] as [State]
FROM [dbo].[ApplCounties] AC 
INNER JOIN [dbo].[refBRSourcePriority] P on AC.SourceID = P.SourceID 
INNER JOIN [dbo].[BRSources] S on AC.SourceID = S.SourceID 
INNER JOIN [dbo].Educat educat on educat.educatID = ac.[SourceIdntyColValue]
where ac.sourceid = 8 and ac.apno = @apno and ac.isactive = 1

UNION ALL

--Past crim details
select ac.sourceId,[SourceIdntyColValue],
null as NameOfSource,null as Position_A,
null as Studies_A,
Crim.Name as NameOnRecord,Crim.Degree,  Crim.DOB, Crim.SSN, Crim.Caseno,Crim.Offense,Crim.Disposition,Crim.Sentence,Crim.Fine,  cast(convert(date,Crim.Date_Filed,101) as varchar(12)) [Date_filed],
cast(convert(date,Crim.Disp_Date,101) as varchar(12)) [CrimDate],'Public Notes: ' + cast(Crim.Pub_Notes as varchar(max))  + CHAR(13) + CHAR(10)  +  'Private Notes: ' + cast(crim.Priv_notes as varchar(max)) as Priv_notes,crim.APNO,
NULL as FromDate,NULL as ToDate,NULL as City,NULL as [State]
FROM [dbo].[ApplCounties] AC 
INNER JOIN [dbo].[refBRSourcePriority] P on AC.SourceID = P.SourceID 
INNER JOIN [dbo].[BRSources] S on AC.SourceID = S.SourceID 
INNER JOIN [dbo].Crim crim on crim.CrimID = ac.[SourceIdntyColValue]
where ac.sourceid = 4 and ac.apno = @apno and ac.isactive = 1

UNION ALL

--Self Disclosed details
select ac.sourceId,[SourceIdntyColValue],
null as NameOfSource,null as Position_A,
null as Studies_A,
null as NameOnRecord,Null Degree,  Null DOB, SD.SSN, Null Caseno,SD.Offense,Null Disposition,Null Sentence,Null Fine, null [Date_filed],SD.[CrimDate],null as Priv_Notes,@apno APNO,
NULL as FromDate,NULL as ToDate,SD.City,SD.[State]
FROM [dbo].[ApplCounties] AC 
INNER JOIN [dbo].[refBRSourcePriority] P on AC.SourceID = P.SourceID 
INNER JOIN [dbo].[BRSources] S on AC.SourceID = S.SourceID 
INNER JOIN [dbo].[ApplicantCrim] SD on SD.ApplicantCrimID = ac.[SourceIdntyColValue]
where ac.sourceid = 3 and ac.apno = @apno and ac.isactive = 1

UNION ALL

--Past Address History details
select ac.sourceId,[SourceIdntyColValue],
null as NameOfSource,null as Position_A, 
null as Studies_A,
null as NameOnRecord,Null Degree,  Null DOB, PAH.SSN, Null Caseno,Null Offense,Null Disposition,Null Sentence,Null Fine, null [Date_filed], NULL [CrimDate],null as Priv_Notes,@apno APNO,
cast(PAH.DateStart as varchar(12)) as FromDate,cast(PAH.DateEnd as varchar(12)) as ToDate,PAH.City,PAH.[State]
FROM [dbo].[ApplCounties] AC 
INNER JOIN [dbo].[refBRSourcePriority] P on AC.SourceID = P.SourceID 
INNER JOIN [dbo].[BRSources] S on AC.SourceID = S.SourceID 
INNER JOIN [dbo].[ApplAddress] PAH on PAH.[ApplAddressID] = ac.[SourceIdntyColValue]
where ac.sourceid = 5 and ac.apno = @apno and ac.isactive = 1
) tbl


SELECT 'CrimDetail' as SectionName
	   ,[CrimID]
      ,[APNO]
      ,[County]
      ,[Clear]
      ,[Ordered]
      ,[Name]
      ,[DOB]
      ,[SSN]
      ,[CaseNo]
      ,[Date_Filed]
      ,[Degree]
      ,[Offense]
      ,[Disposition]
      ,[Sentence]
      ,[Fine]
      ,[Disp_Date]
      ,[Pub_Notes]
      ,[Priv_Notes]
      ,[txtalias]
      ,[txtalias2]
      ,[txtalias3]
      ,[txtalias4]
      ,[uniqueid]
      ,[txtlast]
      ,[Crimenteredtime]
      ,[Last_Updated]
      ,[CNTY_NO]
      ,[IRIS_REC]
      ,[CRIM_SpecialInstr]
      ,[Report]
      ,[batchnumber]
      ,[crim_time]
      ,[vendorid]
      ,[deliverymethod]
      ,[countydefault]
      ,[status]
      ,[b_rule]
      ,IsNull([tobeworked],0) as [tobeworked]
      ,IsNull([readytosend],0) as [readytosend]
      ,[NoteToVendor]
      ,[test]
      ,IsNull([InUse],0) as InUse
      ,[parentCrimID]
      ,[IrisFlag]
      ,[IrisOrdered]
      ,[Temporary]
      ,[CreatedDate]
      ,IsNull([IsCAMReview],0) as [IsCAMReview]
      ,IsNull([IsHidden],0) as IsHidden
      ,[IsHistoryRecord]
      ,[AliasParentCrimID]
      ,[InUseByIntegration]
      ,[ClientAdjudicationStatus]
	  ,IsNull(AdmittedRecord,0) as SelfDisclosed
	   ,case when IsNull([crimdescription],'') = '' then 'NOT CHECKED' else [crimdescription]  end as  CrimStatus
  FROM [dbo].[Crim] C left join Crimsectstat Stat on IsNull(C.Clear,'') = Stat.crimsect
	 -- ,[crimdescription] CrimStatus
  --FROM [dbo].[Crim] C inner join Crimsectstat Stat on C.Clear = Stat.crimsect
  --FROM [dbo].[Crim] C 
  WHERE apno = @apno and IsNull(IsHidden,0) = 0
