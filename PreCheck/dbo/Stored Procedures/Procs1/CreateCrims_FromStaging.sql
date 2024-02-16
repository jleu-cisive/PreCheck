-- Alter Procedure CreateCrims_FromStaging

/*
AUTHOR: Schapyala
Date: 02/01/2014
Purpose: This consolidates the logic of creating and updating Public Records (Crims) saved through the Staging table.
This changes the logic from using row based logic (implemented by CreateCrim, which inturn calls testfaxing) to set based logic.
This also removes the unneccessary holes created in the index as the main crim always gets deleted by testfaxing.
This should increase the reliability and also the performance of Pubic Record creation.

Note: We need to modify CreateCrim to use this logic when this has been in production for couple weeks to address the issues mentioned above

04/29/2015: DDegenar & DHE changed name to varchar(100) from varchar(30) and fine varchar(100) from varchar(50)

10/01/2019 - Dhe - Added IN clause to Include Transferred Records and also Pending records.

09/25/2021- DDegenar - Move Intellicorp logic to PrecheckFramework_UpdateFromStaging
*/
CREATE Procedure [dbo].[CreateCrims_FromStaging] (
 @APNO int,@folderId varchar(50), @DateEntered Datetime)
AS
BEGIN  
     SET NOCOUNT ON
	 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED   
      --Dhe Changed on 09/18/2018
  Update [dbo].[PrecheckFramework_PublicRecordsStaging]  
     set County = '*DPS STATEWIDE*, TX'  
	     ,Cnty_No =  2682 
	From [dbo].[PrecheckFramework_PublicRecordsStaging] 
   Where Clear IN ('R', 'I') And CNTY_NO = 1
    
/*04/07/2020 - schapyala - COVID RELATED BLURBS AND SETTING THE STATUS*/
		Declare @IsBusinessContinuityRelated Bit = 0
		If (Select c.affiliateid from dbo.Appl a inner join dbo.client c on a.clno = c.clno 
											 inner join dbo.refAffiliate r on c.AffiliateID = r.AffiliateID
								 Where a.APNO = @APNO) not in (147,149,200,252,253) --exclude CHI, Dignity and Common spirit			
		BEGIN	
			SET @IsBusinessContinuityRelated = 1
		END


/*COVID RELATED BLURBS AND SETTING THE STATUS*/

  --Insert New Crims...Records with no SectionID in the Staging table    
      create table #tmpCrim 
	  ( id int  NOT NULL identity(1,1)  PRIMARY KEY CLUSTERED ,
	  CNTY_NO int, County varchar(75),CountyState varchar(25),refCountyTypeID int,vendor int,DeliveryMethod varchar(50), bRule varchar(3)  DEFAULT ('No'),
	  Ordered varchar(14),Name varchar(100),DOB datetime,SSN varchar(11),CaseNo varchar(50),Date_Filed Datetime,Degree varchar(1),Offense varchar(1000),Disposition varchar(500),Sentence varchar(1000),Fine varchar(100),Disp_Date Datetime,
	  [Clear] varchar(1),AdmittedRecord Bit,IsHistoryRecord Bit,IsHidden Bit,InUse Bit,Priv_Notes nvarchar(max),Pub_Notes nvarchar(max),[CRIM_SpecialInstr]  nvarchar(max),Report nvarchar(max),CreatedDate Datetime)  


      --Populate the temp table with record information for counties/jurisdictions that needs to be inserted -- no sectionID/CrimID in staging  
      insert into #tmpCrim	(CNTY_NO,County,CountyState,refCountyTypeID,Ordered,Name,DOB,SSN,CaseNo,Date_Filed,Degree,Offense,Disposition,Sentence,Fine,Disp_Date,[Clear],AdmittedRecord,IsHistoryRecord,IsHidden,InUse,Priv_Notes,Pub_Notes,[CRIM_SpecialInstr],Report,CreatedDate)	
      Select  P.CNTY_NO, case when isnull(C.County,'')='' then  isnull(c.A_County,'') else C.County end ,C.[State],refCountyTypeID,P.Ordered,P.Name,P.DOB,P.SSN,P.CaseNo,P.Date_Filed,P.Degree,P.Offense,P.Disposition,P.Sentence,P.Fine,P.Disp_Date,[Clear],IsNull(P.AdmittedRecord,0),IsHistoryRecord,IsHidden,InUse,Priv_Notes,IsNull(Pub_Notes,''),[CRIM_SpecialInstr],Report,CreatedDate 
      From dbo.PrecheckFramework_PublicRecordsStaging P Inner Join  dbo.TblCounties C on P.CNTY_NO = C.CNTY_NO
      Where FolderId = @FolderId and apno = @apno and IsNull(SectionId,'') = ''
	  AND   CreatedDate >= @DateEntered   

	--  /*Auto-Clear Lead Step Start - schapyala on 05/19/2020 */

	--	Declare @SkipAutoClear Bit = 0 

	--	--Skip AutoClear if Admitted Record
	--	Select @SkipAutoClear = Case When IsNull(AdmittedRecord,0) = 1 or IsHistoryRecord = 1 then cast(1 as bit) else cast(0 as bit) end
	--	From #tmpCrim D 

	--	--Skip AutoClear if ZipCrim clients
	--	Select @SkipAutoClear = Case When AffiliateID IN (249) --249 (everifile/zipcrim)
	--										  Then cast(1 as bit) else cast(0 as bit) End
	--	From DBO.APPL A inner Join dbo.CLient C on A.CLNO = C.CLNO
	--	Where APNO = @Apno
	
	----Qualify for AutoClears only when there is [no Self-Disclosure or Past COnvictions] and for NON-ZipCrim Clients
	--	IF @SkipAutoClear = 0
	--		--Logic for setting Clear status to Y - "Auto Clear - Intellicorp" for qualified counties by partner (5 - Intellicorp) table configuration
	--		UPDATE C Set [Clear] = Case When PJ.County IS NULL then [Clear] else 'Y' end,
	--		Priv_Notes = Case When PJ.County IS NULL then Priv_Notes else (CAST( CURRENT_TIMESTAMP as varchar) + ' - Jurisdiction Qualified after AI Review Process for Intellicorp AutoClear service;  ' + isnull(Priv_Notes,'')) End
	--		FROM #tmpCrim C LEFT JOIN dbo.County_PartnerJurisdiction PJ on C.CNTY_NO = PJ.CNTY_NO
	--		WHERE PartnerID = 4 -- Intellicorp
	--		AND isnull([Clear],'') in ('','R','H')

	--	--exclude those pre-existing records and only consider those created after @dateEntered
	--	--Delete #tmpCrim Where CreatedDate < @DateEntered 

	--  /*Auto-Clear Lead Step END - schapyala on 05/19/2020 */
	  
	 
	  
	  --Add Blurbs 
	  --specific county
      Update t Set Pub_Notes = Pub_Notes + '; ' + char(9) + char(13)+  CONVERT (VARCHAR(10), current_timestamp, 103) + ' - ' + CountyBlurb
	  ,[Clear] = case when (C.IsBusinessContinuityRelated = 1 and @IsBusinessContinuityRelated = 1)  then 'S' else [Clear] end
	  From  #tmpCrim t inner join dbo.refCountyBlurb C on t.CNTY_NO = C.CNTY_NO 
	  Where  C.CNTY_NO IS NOT NULL

	  --international
      Update t Set Pub_Notes = Pub_Notes + '; ' + char(9) + char(13)+ CONVERT (VARCHAR(10), current_timestamp, 103) + ' - ' +  CountyBlurb
	  ,[Clear] = case when (C.IsBusinessContinuityRelated = 1 and @IsBusinessContinuityRelated = 1)  then 'S' else [Clear] end
	  From  #tmpCrim t inner join dbo.refCountyBlurb C on t.refCountyTypeID = C.refCountyTypeID 
	  Where  C.refCountyTypeID IS NOT NULL

	  --State level counties excluding statewide for some
      Update t Set Pub_Notes = Pub_Notes + '; ' + char(9) + char(13) + CONVERT (VARCHAR(10),current_timestamp, 103) + ' - ' +  CountyBlurb
	  ,[Clear] = case when (C.IsBusinessContinuityRelated = 1 and @IsBusinessContinuityRelated = 1) then 'S' else [Clear] end
	  From  #tmpCrim t inner join dbo.refCountyBlurb C on t.CountyState = C.CountyState  
	  Where  C.CountyState IS NOT NULL 
	  AND    t.refCountyTypeID <> (Case When ExcludeStateWide =1 then 2 else 0 end) --2 is statewide
 

	 SELECT cntyno,Vendor,beg_date, end_date into #tmpCountyRules
	FROM 
	   (SELECT CountyState cntyno, beg_date, end_date, Vendor1,Vendor2,Vendor3,Vendor4,Vendor5,Vendor6
	   FROM Iris_County_Rules WHERE     Iris_County_Rules.Active = 1) p
	UNPIVOT
	   (vendor FOR countystate IN 
		  (vendor1, vendor2, vendor3, vendor4, vendor5,vendor6)
	)AS unpvt;

    SELECT cntyno,vendor,beg_date,end_date,
    Row_Number() Over(Partition by  cntyno order by vendor ) AS RowNo INTO #tmpCountyRules_2
    FROM #tmpCountyRules 
    WHERE vendor <> 0

	--handy query
	--select t.cntyno,c.county,R_Name vendorname,vendor,beg_date,end_date from #tmpCountyRules_2 t inner join counties c on t.cntyno = c.cnty_no
	--inner join iris_researchers r on t.vendor = r.r_id

	drop table #tmpCountyRules

    --Update the first vendor
    Update t Set vendor = cr.vendor,DeliveryMethod = R.R_Delivery,bRule ='Yes'
    --select t.cnty_no, cr.vendor , R.R_Delivery  DeliveryMethod 
    from #tmpcrim t left join #tmpCountyRules_2 cr on t.Cnty_no = cr.Cntyno 
    LEFT JOIN Iris_Researchers R ON cr.vendor = R.R_id
    Where current_timestamp between beg_date and end_date and (cr.vendor>0)
    AND RowNo  = 1

    --Insert the remaining vendors 
    INSERT INTO #tmpcrim   (CNTY_NO,County,CountyState,refCountyTypeID,vendor,DeliveryMethod,bRule,Ordered,Name,DOB,SSN,CaseNo,Date_Filed,Degree,Offense,Disposition,Sentence,Fine,Disp_Date,[Clear],AdmittedRecord,IsHistoryRecord,IsHidden,InUse,Priv_Notes,Pub_Notes,[CRIM_SpecialInstr],Report)
    select t.cnty_no, t.County, t.CountyState, t.refCountyTypeID,cr.vendor , R.R_Delivery, bRule,Ordered,Name,DOB,SSN,CaseNo,Date_Filed,Degree,Offense,Disposition,Sentence,Fine,Disp_Date,[Clear],AdmittedRecord,IsHistoryRecord,IsHidden,InUse,Priv_Notes,Pub_Notes,[CRIM_SpecialInstr],Report
    from #tmpcrim t left join #tmpCountyRules_2 cr on t.Cnty_no = cr.Cntyno 
    LEFT JOIN Iris_Researchers R ON cr.vendor = R.R_id
    Where current_timestamp between beg_date and end_date and (cr.vendor>0)
    AND RowNo  > 1

	 drop table #tmpCountyRules_2

	 --When there is a active vendor rule, I want to get the alternate vendor and also the alternate vendors delivery method...This is not done correctly at this time. It returns only the main vendors delivery method. Please cross check the additional join to see if I am missing something
	  Update t Set vendor = Case When (R.vendorruleactive = 1 and (current_timestamp between R.vendorrulestartdate and R.vendorruleenddate) ) then R.vendorruleid else R.R_ID end,
				   DeliveryMethod = Case When (R.vendorruleactive = 1 and (current_timestamp between R.vendorrulestartdate and R.vendorruleenddate) ) then V.R_Delivery else R.R_Delivery end,
				   bRule = Case When (R.vendorruleactive = 1 and (current_timestamp between R.vendorrulestartdate and R.vendorruleenddate) ) then 'Yes' else 'No' end
	 --select t.cntyno, Case When (R.vendorruleactive = 1 and (current_timestamp between R.vendorrulestartdate and R.vendorruleenddate) ) then R.vendorruleid else R.R_ID end vendor,
	 --Case When (R.vendorruleactive = 1 and (current_timestamp between R.vendorrulestartdate and R.vendorruleenddate) ) then V.R_Delivery else R.R_Delivery end DeliveryMethod --cross check this logic please
	 from #tmpcrim t
	 left join Iris_Researcher_Charges RC ON t.CNTY_NO = RC.cnty_no 
	 LEFT JOIN Iris_Researchers R ON RC.Researcher_id = R.R_id
	 LEFT JOIN Iris_Researchers V ON R.vendorruleid = V.R_id  --Cross check this logic please
	 where  (RC.Researcher_Default = 'yes') and vendor is null 

    --Create new Crims with all the data from staging and data derived based on above logic
	insert into DBO.Crim (Apno, CNTY_NO, County,CreatedDate,vendorid,deliverymethod,b_rule,iris_rec,readytosend,Ordered,Name,DOB,SSN,CaseNo,Date_Filed,Degree,Offense,Disposition,Sentence,Fine,Disp_Date,[Clear],AdmittedRecord,IsHistoryRecord,IsHidden,InUse,Priv_Notes,Pub_Notes,[CRIM_SpecialInstr],Report) 
	Select @APNO,CNTY_NO, County,@DateEntered,vendor,Deliverymethod,bRule,'yes',
	case DeliveryMethod when 'Mail' then 0
						when 'OnlineDB' then 0
						when 'Call_In' then 0
						when 'InHouse' then 0
						else Null
	end,
	Ordered,Name,DOB,SSN,CaseNo,Date_Filed,Degree,Offense,Disposition,Sentence,Fine,Disp_Date,
	[Clear],AdmittedRecord,IsHistoryRecord,IsHidden,InUse,Priv_Notes,Pub_Notes,[CRIM_SpecialInstr],Report
	From #tmpCrim
	Order By CNTY_NO

	drop table #tmpcrim
 --End Insert New Crims...Records with no SectionID in the Staging table 
   
  --Update Crims...Records with SectionID in the Staging table     
      UPDATE   
       pubrec  
      SET   
       County = prstg.County  
       ,[Clear] = case when pubrec.[Clear] = 'S' then pubrec.[Clear] else prstg.[Clear]  end
       ,Ordered = prstg.Ordered  
       ,Name = prstg.Name  
       ,DOB = prstg.DOB  
       ,SSN = prstg.SSN  
       ,CaseNo = prstg.CaseNo  
       ,Date_Filed = prstg.Date_Filed  
       ,Degree = Case When prstg.Clear = 'R' Then NULL Else prstg.Degree  END
       ,Offense = prstg.Offense  
       ,Disposition = prstg.Disposition  
       ,Sentence = prstg.Sentence  
       ,Fine = prstg.Fine  
       ,Disp_Date = prstg.Disp_Date  
       ,Priv_Notes = cast(prstg.Priv_Notes as varchar(max))  
       ,Pub_Notes = cast(prstg.Pub_Notes as varchar(max))  
       ,IsHistoryRecord = prstg.IsHistoryRecord  
       ,IsHidden = IsNull(prstg.IsHidden,0)  
       ,InUse = null --prstg.InUse  
       ,Report = cast(prstg.Report as varchar(max))  
       ,[CRIM_SpecialInstr] = cast(prstg.[CRIM_SpecialInstr] as varchar(max))    
	   ,AdmittedRecord = IsNull(prstg.AdmittedRecord,0)
	    FROM  
       [dbo].[Crim] pubrec INNER JOIN [dbo].[PrecheckFramework_PublicRecordsStaging] prstg  ON prstg.Apno = pubrec.Apno and prstg.SectionId = pubrec.CrimId   
      where IsNull(prstg.SectionID,'') <> ''  
	  and prstg.FolderId = @folderId 
	  and prstg.CreatedDate >= @DateEntered 
        
	 DELETE FROM   
		[dbo].[PrecheckFramework_PublicRecordsStaging]  
	 WHERE  FolderId = @FolderId and apno = @apno 
	 AND    CreatedDate >= @DateEntered


	 SET TRANSACTION ISOLATION LEVEL READ COMMITTED   	 
	 SET NOCOUNT OFF	  
END
