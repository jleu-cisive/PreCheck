
--[Service_PrintFinalReports] '0'
-- Modified by Radhika Dereddy on 03/05/2020 to include the filter App completion date - 2, so the service always qualifies the reports
-- in the past 2 days(that is 03/05/2020 & 03/04/2020) while sending out the notification to the clients)

CREATE PROCEDURE [dbo].[Service_PrintFinalReports] 
@IsDrugTestRequired varchar(1) = '0'
AS
SET NOCOUNT ON

---************* Updated for Sending Reports Only *********************-------
--Modified by Swetha Rai on 11/5/2007 to add changes for Drug Screen Reports 
--Modified by veena on 11/19/2008 to add changes for Adjudication Process
--add custom flag status override table 1/4/2010
DECLARE @ClientList varchar(8000)
SELECT @CLientList = dbo.fnGetClnofromconfigkeyvalue ('WO_Merge_DrugScreeningRequired','true')

IF @IsDrugTestRequired ='0'

    BEGIN	
		UPDATE dbo.Appl 
		SET Appl.inuse = null
		FROM dbo.Appl
		WHERE Appl.Inuse = 'FilCheck'  -- Unlock any Client Type 13 Appls 

        -- Process all non ClientType 13  applications and only those ClientType 13 applications 
        -- that have a corresponding drug screen report
		UPDATE dbo.Appl
		SET appl.inuse = 'Sending'
		FROM dbo.Appl A 
		INNER JOIN dbo.Client C On (A.CLNO = C.CLNO)
		WHERE A.ApStatus in ('f','w') --OR  A.ApStatus = 'W')3/15/07 removed W status
		--AND A.APNO in (3323613) --uncomment this for testing and specify apps
		AND (A.IsAutoSent = 0)
		AND (A.InUse IS NULL) 
		AND (C.AutoReportDelivery = '1')
		AND (c.DeliveryMethodID is not null) 
		AND (A.IsAutoPrinted = '1')
		AND (A.CompDate >=  DATEADD(day, -10, Getdate())) -- Added by Radhika Dereddy on 03/05/2020
		AND ( (    (ISNULL(C.CLNO,'') NOT IN ( select [value] from dbo.fn_Split(@CLientList,','))) -- To exclude Clients that require Drug Testing.
				OR ((ISNULL(C.CLNO,'') IN  ( select [value] from dbo.fn_Split(@CLientList,',')) AND A.IsDrugTestFileFound = '1'))  -- To exclude Clients that require Drug Testing.
			  )	   
			)

	
	SELECT    dbo.Appl.APNO
		, dbo.Appl.ApStatus
		, dbo.Appl.last
		, dbo.Appl.first
		, dbo.Appl.middle
		, dbo.Appl.CLNO
		, ISNULL(dbo.Users.Name, '') AS AcctMgr
		, dbo.refDeliveryMethod.DeliveryMethod
		, dbo.Appl.Attn
		, dbo.Client.Fax
		, dbo.Client.AutoReportDelivery
		, dbo.Users.EmailAddress
		, dbo.Appl.isautoprinted
		, dbo.Appl.autoprinteddate
		, dbo.Appl.isautosent
		, dbo.Appl.autosentdate
		, dbo.Client.ClientTypeID
		,(case 
			 when cc1.Value='true' and refapplflagstatuscustom.customflagstatus is not null then 
					refapplflagstatuscustom.customflagstatus
			 when cc1.Value='true' and refapplflagstatuscustom.customflagstatus is null then
					refapplflagstatus.flagstatus
			else '' end) as FlagStatus,
			cc2.Value as CustomEmail,
			ISNULL(dbo.Users.Phone, '') as camphone,
			Case When ReopenDate is Null then cast(0 as bit) else cast(1 as bit) end IsReportUpdated --Added by schapyala on 04/23/2014 to indicate if the report was Re-Finaled/updated/Amended
			,Case When ((cc3.Value is not null and cc3.Value = 'true') or (dbo.Client.ClientTypeID = 6)) then cast(1 as bit) else cast(0 as bit) end as ExcludeSummary --Added by schapyala on 04/30/2014 to Flag to exclude summary when configuration is set
		FROM  dbo.Appl WITH (NOLOCK)
		INNER JOIN dbo.Client  WITH (NOLOCK) ON dbo.Appl.CLNO = dbo.Client.CLNO 
		INNER JOIN dbo.refDeliveryMethod  WITH (NOLOCK) ON dbo.Client.DeliveryMethodID = dbo.refDeliveryMethod.DeliveryMethodID 
		LEFT JOIN  dbo.Users  WITH (NOLOCK) ON dbo.Appl.UserID = dbo.Users.UserID
		Left join dbo.clientconfiguration cc1  WITH (NOLOCK) on appl.clno=cc1.clno  and cc1.configurationKey='AdjudicationProcess'
		Left join dbo.clientconfiguration cc2  WITH (NOLOCK) on appl.clno=cc2.clno  and cc2.configurationKey='WS_CustomNotificationEmail'
		Left join dbo.clientconfiguration cc3  WITH (NOLOCK) on appl.clno=cc3.clno  and cc3.configurationKey='WO_ExcludeSummary_NotificationEmail' --Added by schapyala on 04/30/2014 to Flag to exclude summary when configuration is set
		Left join dbo.applFlagstatus  WITH (NOLOCK) on applflagstatus.apno=appl.apno
		Left join dbo.refapplflagstatus  WITH (NOLOCK) on refapplflagstatus.flagstatusid=applflagstatus.flagstatus
		Left join dbo.refapplflagstatuscustom  WITH (NOLOCK) on refapplflagstatuscustom.clno = appl.clno and refapplflagstatuscustom.flagstatusid=applflagstatus.flagstatus
		WHERE (dbo.Appl.InUse = 'Sending') 

	END

ELSE IF @IsDrugTestRequired ='1'
--  @IsDrugTestRequired = 1 is used to select all finalled Client type 13 applications
--  and the returned list is used to look for Drug Screen reports on the file server.

	BEGIN
	
	
		UPDATE dbo.Appl
		SET appl.inuse = 'FilCheck'
		FROM dbo.Appl A 
		INNER JOIN dbo.Client C On (A.CLNO = C.CLNO)
		WHERE A.ApStatus = 'f' --OR  A.ApStatus = 'W')3/15/07 removed W status
			  AND (A.IsAutoSent = 0) AND (A.InUse IS NULL) AND (C.AutoReportDelivery = '1') 
			  AND  A.IsDrugTestFileFound <> 1 --added by schapyala - 07/22/2013
			  AND (A.IsAutoPrinted = '1') AND (ISNULL(C.CLNO,'') IN  (select [value] from dbo.fn_Split(@CLientList,','))) -- To include only those Clients that require Drug Testing.


--select dbo.Appl.APNO,Appl.PackageID FROM  dbo.Appl inner join 
--        dbo.PackageMain on Appl.PackageID = PackageMain.PackageID
--WHERE     (NOT (PackageDesc LIKE '%Drug%')) and (dbo.Appl.InUse = 'FilCheck')
--order by APNO


		--SELECT    dbo.Appl.APNO,dbo.Appl.SSN,dbo.Appl.[First],dbo.Appl.[Last],dbo.Appl.Clno, IsNull(dbo.ClientConfiguration.Value, 'False') as DrugScreenRequired
		--		 ,dbo.Appl.IsDrugTestFileFound
		--FROM  dbo.Appl left join dbo.ClientConfiguration on dbo.Appl.Clno = dbo.ClientConfiguration.Clno and dbo.ClientConfiguration.ConfigurationKey = 'WO_Merge_DrugScreeningRequired'
		--WHERE (dbo.Appl.InUse = 'FilCheck') 


		SELECT    dbo.Appl.APNO,dbo.Appl.SSN,dbo.Appl.[First],dbo.Appl.[Last],dbo.Appl.Clno, 'True' as DrugScreenRequired,ApDate
				 , 0 IsDrugTestFileFound,EnteredVia into #tempappl
		FROM  dbo.Appl  WITH (NOLOCK)
		WHERE (dbo.Appl.InUse = 'FilCheck')  

		update tmp Set IsDrugTestFileFound = 1
		from 
		#tempappl tmp inner join  dbo.OCHS_CandidateInfo C ON C.APNO = tmp.APNO 
		INNER JOIN OCHS_ResultDetails r ON (cast(C.APNO as varchar) = r.OrderIDOrApno) -- AND (REPLACE(tmp.SSN,'-','') = REPLACE(r.SSNOrOtherID,'-','') OR ApDate > '01/01/2016'))
		inner join 
		OCHS_PDFReports p  on r.TID = p.TID 
		WHERE ((tmp.CLNO = r.clno) OR  tmp.clno in (SELECT facilityclno FROM HEVN..Facility WHERE ParentEmployerID = r.clno) OR tmp.clno IN (SELECT clno FROM client WHERE WebOrderParentCLNO = r.clno))
		AND C.APNO IS NOT null

		---- only for student check apps
		update tmp Set IsDrugTestFileFound = 1
		from 
		#tempappl tmp 
		INNER JOIN OCHS_ResultDetails r ON (cast(tmp.APNO as varchar) = r.OrderIDOrApno) -- AND (REPLACE(tmp.SSN,'-','') = REPLACE(r.SSNOrOtherID,'-','') OR ApDate > '01/01/2016'))
		inner join 
		OCHS_PDFReports p  on r.TID = p.TID 
		WHERE ((tmp.CLNO = r.clno) OR  tmp.clno in (SELECT facilityclno FROM HEVN..Facility WHERE ParentEmployerID = r.clno) OR tmp.clno IN (SELECT clno FROM client WHERE WebOrderParentCLNO = r.clno))
		AND tmp.APNO IS NOT null and EnteredVia = 'StuWeb'

		--For CIC platform applications - schapyala added on 10/10/2017
		update tmp Set IsDrugTestFileFound = 1
		from 
		#tempappl tmp inner join  dbo.OCHS_CandidateInfo C ON C.APNO = tmp.APNO 
		INNER JOIN OCHS_ResultDetails r ON (cast(C.OCHS_CandidateInfoID as varchar) = r.OrderIDOrApno) -- AND (REPLACE(tmp.SSN,'-','') = REPLACE(r.SSNOrOtherID,'-','') OR ApDate > '01/01/2016'))
		inner join 
		OCHS_PDFReports p  on r.TID = p.TID 
		WHERE ((tmp.CLNO = r.clno) OR  tmp.clno in (SELECT facilityclno FROM HEVN..Facility WHERE ParentEmployerID = r.clno) OR tmp.clno IN (SELECT clno FROM client WHERE WebOrderParentCLNO = r.clno))
		AND C.APNO IS NOT null



		Update A Set IsDrugTestFileFound = tmp.IsDrugTestFileFound
		FROM DBO.APPL A inner join #tempappl tmp on A.APNO = tmp.APNO AND tmp.IsDrugTestFileFound = 1

		-- send apno's where Drugscreen resulsts are not found in OCHS tables, so the process can look up in shared folder
		select * from #tempappl Where IsDrugTestFileFound = 0 AND apdate >'1/1/2016'

		DROP TABLE #tempappl

--SELECT    dbo.Appl.APNO
--				 ,dbo.Appl.IsDrugTestFileFound FROM  dbo.Appl inner join 
--        dbo.PackageMain on Appl.PackageID = PackageMain.PackageID
--WHERE     ((PackageDesc LIKE '%Drug%')) and (dbo.Appl.InUse = 'FilCheck')
--order by APNO

---select * from dbo.Appl where 1=2

	END

SET NOCOUNT OFF