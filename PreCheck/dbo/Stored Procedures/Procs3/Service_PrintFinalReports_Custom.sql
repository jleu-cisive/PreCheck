
--[Service_PrintFinalReports] '0'

CREATE PROCEDURE [dbo].[Service_PrintFinalReports_Custom] 
@IsDrugTestRequired varchar(1) = '0',
@myApp int
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
		WHERE Appl.Inuse = 'FilCheck' and Appl.APNO = @myApp -- Unlock any Client Type 13 Appls 

        -- Process all non ClientType 13  applications and only those ClientType 13 applications 
        -- that have a corresponding drug screen report
		UPDATE dbo.Appl
		SET appl.inuse = 'Sending'
		FROM dbo.Appl A 
		--INNER JOIN dbo.Client C On (A.CLNO = C.CLNO)
		WHERE A.APNO in (@myApp) --uncomment this for testing and specify apps
		/**
			  AND (A.IsAutoSent = 0) AND (A.InUse IS NULL) AND (C.AutoReportDelivery = '1') AND c.DeliveryMethodID is not null and
			  (A.IsAutoPrinted = '1')
			 AND 
			  (((ISNULL(C.CLNO,'') NOT IN ( select [value] from dbo.fn_Split(@CLientList,','))) -- To exclude Clients that require Drug Testing.
			  OR (
					(ISNULL(C.CLNO,'') IN  ( select [value] from dbo.fn_Split(@CLientList,',')) 
					 AND A.IsDrugTestFileFound = '1')-- To exclude Clients that require Drug Testing.
)
))
**/


	

	
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

FROM  dbo.Appl 
INNER JOIN dbo.Client ON dbo.Appl.CLNO = dbo.Client.CLNO 
INNER JOIN dbo.refDeliveryMethod ON dbo.Client.DeliveryMethodID = dbo.refDeliveryMethod.DeliveryMethodID 
LEFT JOIN  dbo.Users ON dbo.Appl.UserID = dbo.Users.UserID
Left join dbo.clientconfiguration cc1 on appl.clno=cc1.clno  and cc1.configurationKey='AdjudicationProcess'
Left join dbo.clientconfiguration cc2 on appl.clno=cc2.clno  and cc2.configurationKey='WS_CustomNotificationEmail'
Left join dbo.clientconfiguration cc3 on appl.clno=cc3.clno  and cc3.configurationKey='WO_ExcludeSummary_NotificationEmail' --Added by schapyala on 04/30/2014 to Flag to exclude summary when configuration is set
Left join dbo.applFlagstatus on applflagstatus.apno=appl.apno
Left join dbo.refapplflagstatus on refapplflagstatus.flagstatusid=applflagstatus.flagstatus
Left join dbo.refapplflagstatuscustom on refapplflagstatuscustom.clno = appl.clno and refapplflagstatuscustom.flagstatusid=applflagstatus.flagstatus
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


		SELECT    dbo.Appl.APNO,dbo.Appl.SSN,dbo.Appl.[First],dbo.Appl.[Last],dbo.Appl.Clno, 'True' as DrugScreenRequired
				 , 0 IsDrugTestFileFound into #tempappl
		FROM  dbo.Appl 
		WHERE (dbo.Appl.InUse = 'FilCheck')  

		update tmp Set IsDrugTestFileFound = 1
		from 
		#tempappl tmp inner join  OCHS_ResultDetails r ON cast(tmp.APNO as varchar) = r.OrderIDOrApno 
		inner join 
		OCHS_PDFReports p  on r.TID = p.TID 

		Update A Set IsDrugTestFileFound = tmp.IsDrugTestFileFound
		FROM DBO.APPL A inner join #tempappl tmp on A.APNO = tmp.APNO --AND tmp.IsDrugTestFileFound = 1


		select * from #tempappl Where IsDrugTestFileFound = 0 

		DROP TABLE #tempappl

--SELECT    dbo.Appl.APNO
--				 ,dbo.Appl.IsDrugTestFileFound FROM  dbo.Appl inner join 
--        dbo.PackageMain on Appl.PackageID = PackageMain.PackageID
--WHERE     ((PackageDesc LIKE '%Drug%')) and (dbo.Appl.InUse = 'FilCheck')
--order by APNO

---select * from dbo.Appl where 1=2

	END

