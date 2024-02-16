--**********************************************************************************************  
--Update WS_GetStatus changes  
-- SANTOSH/DOUG Added to check if clientappno is null in the facility searching section, because if we dont pass clientappno we dont     
-- want to match on that.    
--[dbo].[WS_GetStatus] 14608,null,null,null,0,0,1,6800279       
-- Modified by Dongmei on 02/16/2022 - - HDT#79890 To fix reclosed before completed by dhe 02/15/2023  
--**********************************************************************************************  
    
CREATE PROCEDURE [dbo].[WS_GetStatus]     
 @CLNO int,    
 @ClientAppNo varchar(50) = NULL,    
 @DateFrom DateTime = NULL,    
 @DateTo   DateTime = NULL,    
 @CompletedOnly BIT = 0,    
 @ReleaseOnly BIT = 0,    
 @IncludeSSNDOB BIT = 0,    
 @ApNo Int = NULL    
     
AS    
BEGIN    

--DECLARE 
-- @CLNO int = 17734,    
-- @ClientAppNo varchar(50) = '230a83',    
-- @DateFrom DateTime = NULL,    
-- @DateTo   DateTime = NULL,    
-- @CompletedOnly BIT = 0,    
-- @ReleaseOnly BIT = 0,    
-- @IncludeSSNDOB BIT = 0,    
-- @ApNo Int = NULL    


 -- SET NOCOUNT ON added to prevent extra result sets from    
 -- interfering with SELECT statements.    
 SET NOCOUNT ON;    
    
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED    
    
   --PR05  
   DROP TABLE IF EXISTS #CLNOTable  
 SELECT CLNO INTO #CLNOTable  
   FROM ClientConfig_Integration  
  WHERE ConfigSettings.value('(ClientConfigSettings/Callback_SendReOpen)[1]','bit') = 1  
    AND ConfigSettings.value('(ClientConfigSettings/Callback_SendReClose)[1]','bit') = 1  
 --PR05  
    
 DECLARE @SSN varchar(11),@DOB DateTime,@ReleaseDate DateTime    
    
 IF @IncludeSSNDOB = 1    
  SELECT @SSN = ISNULL(SSN,i94), @DOB = cast(DOB as Date)    
  FROM   DBO.ReleaseForm with (nolock)    
  WHERE  CLNO = @CLNO     
  AND   ClientAppNo = @ClientAppNo     
 ELSE    
  SELECT @DOB = NULL, @SSN = NULL     
    
IF (@releaseOnly = 1)    
  BEGIN    
  CREATE TABLE dbo.#tmpRelease    
  (SSN Varchar(50),    
  DOB Date,    
  Report Image,    
  RecruiterEmail varchar(100),    
  ReleaseDate DateTime      
  )    
    
  Insert into dbo.#tmpRelease    
  Exec [dbo].[Release_CheckIfExists] @CLNO,@ClientAppNo,@SSN    
    
  if (Select count(1) from dbo.#tmpRelease)>0    
   Select cast(1 as bit) 'ReleaseCaptured',SSN,DOB,ReleaseDate    
   From dbo.#tmpRelease    
  else    
   select cast(0 as bit) as 'ReleaseCaptured',@SSN SSN,@DOB DOB,null as ReleaseDate    
  Drop Table dbo.#tmpRelease    
  END    
 Else    
 BEGIN    
  Declare @AdjReview varchar(10),@AdjCutOff DateTime,@DefaultAdjReviewOnly varchar(10)    
    
  SET @AdjReview = (select value from clientconfiguration with (nolock) where configurationkey = 'AdjudicationProcess' and clno = @CLNO)    
  SET @AdjReview = Isnull(@AdjReview,'False')    
    
  --added by schapyala on 02/11/2022 for HCA PR11 without having to enable adjudication service    
  SET @DefaultAdjReviewOnly = (select value from clientconfiguration with (nolock) where configurationkey = 'EnableDefaultAdjudicationStatusOnly' and clno = @CLNO)    
  SET @DefaultAdjReviewOnly = Isnull(@DefaultAdjReviewOnly,'False')    
    
  SET @AdjCutOff = (select cast(value as Datetime)  from clientconfiguration with (nolock) where configurationkey = 'Adjudication_CutOffDate' and clno = @CLNO and isdate(value)=1)    
  SET @AdjCutOff = Isnull(@AdjCutOff,Current_TimeStamp)    
     
  -- Added by Doug DeGenaro    
  -- We determine if clientappno is filled that we are searching by clno and clientappno, for any dates    
  IF (@ClientAppNo IS NOT NULL or @ApNo IS NOT NULL)    
   BEGIN    
    
    
 --   IF @ClientAppNo IS NULL    
 --    SELECT @ClientAppNo = Partner_Reference     
 --    FROM   DBO.Integration_OrderMgmt_Request     
 --    WHERE  APNO = @ApNo      
 --       
    
    --schapyala - 12/21/2011 -  to check if the app has been created for a sub-facility. If yes, reassign the CLNO to retrieve the correct status.    
    Declare @FacilityCLNO int,@AppCLNO INT,@AppClientApNo varchar(50)    
    
	 if (Isnull(@apno,0) > 0)  
 begin  
  Select @FacilityCLNO = FacilityCLNO      
  From dbo.Integration_OrderMgmt_Request       
  Where (CLNO = @CLNO  and IsNull(Apno,'') = @apno) or APNO = isnull(@APNO,'')   
 end  
 else  
 begin  
  Select @FacilityCLNO = FacilityCLNO      
  From dbo.Integration_OrderMgmt_Request       
  Where (CLNO = @CLNO  AND    (Partner_Reference = isnull(@ClientAppNo,'')))   
   
 end  

    --Select @FacilityCLNO = FacilityCLNO    
    --From dbo.Integration_OrderMgmt_Request     
    --Where (CLNO = @CLNO  AND    (Partner_Reference = isnull(@ClientAppNo,'') and IsNull(Apno,'') = @apno) or APNO = isnull(@APNO,''))    
    
    IF  @FacilityCLNO IS NULL       
     Select @FacilityCLNO = FacilityCLNO    
     From dbo.Integration_PrecheckCallback     
     Where (CLNO = @CLNO  AND    (Partner_Reference = isnull(@ClientAppNo,'') and IsNull(Apno,'') = @apno) or APNO = isnull(@APNO,''))    
    
    
      --schapyala - Added this logic to find the status for all child accounts.    
      IF @ApNo IS NOT NULL    
     Select @AppCLNO = CLNO ,@AppClientApNo = ClientApNo    
     FROM DBO.APPL     
     WHERE APNO = @APNO    
    
    IF (@AppCLNO = @CLNO )     
    BEGIN    
     SET @CLNO = @CLNO    
     SET @FacilityCLNO = @AppCLNO    
    END    
    ELSE IF (@AppCLNO = ISNULL(@FacilityCLNO,'') )    
     SET @FacilityCLNO = @FacilityCLNO    
    ELSE    
    BEGIN    
     IF @FacilityCLNO IS NULL OR @FacilityCLNO <> @AppCLNO     
     BEGIN    
      IF @AppCLNO in (SELECT FacilityCLNO FROM HEVN.dbo.Facility Where ParentEmployerID = @CLNO AND FacilityCLNO IS NOT NULL)    
   or @AppCLNO in (Select CLNO From dbo.Client Where WebOrderParentCLNO = @CLNO)   
   or @AppCLNO in (SELECT CLNO  FROM DBO.[ClientHierarchyByService] WHERE ParentCLNO = @CLNO and  refHierarchyServiceID in (1,2))    
        IF (@AppClientApNo = @clientappno  or @clientappno is null)    
         SET @FacilityCLNO = @AppCLNO    
        ELSe    
         SET @FacilityCLNO = @FacilityCLNO    
     END    
    END    
    
 --Added by schapyala and Doug on 08/28/2020    
 --Christus Orders come in as 16180 but created under 14608    
 --Doug to change the hard coding to use config setting to reset with the correct clno    
 IF (@CLNO = 16180 and @FacilityCLNO IS NULL)      
  SET @FacilityCLNO = 14608    
    
   --Commented below by schapyala on 07/25/14. Cross check    
    -- Assumption is the clno we are getting from the config table is unique per client.    
    --Set @CLNO = ISNULL(@FacilityCLNO,@CLNO)    
   --Commented above by schapyala on 07/25/14. Cross check    
    
      --schapyala 12/6/2011    
    --IF (Select count(1) from DBO.APPL A With (nolock) Where (A.CLNO = @CLNO or A.CLNO = @FacilityCLNO ) AND  (CLIENTAPNO = coalesce(@clientappno,clientapno) OR A.APNO = coalesce(@apno,apno))) > 0    
    --  SELECT A.APNO,IsNull(A.Last,'') as LAST,IsNull(A.First,'') as FIRST,IsNull(A.Middle,'') as MIDDLE,COMPDATE,APDATE,ISNULL(@ClientAppNo,CLIENTAPNO) CLIENTAPNO,LAST_UPDATED,    
    --      ISNULL(STAT.APPSTATUSVALUE,'InProgress') APSTATUS,    
    --      CASE WHEN @IncludeSSNDOB = 1 THEN ISNULL(DOB,@DOB) ELSE NULL END DOB,    
    --      CASE WHEN @IncludeSSNDOB = 1 THEN ISNULL(SSN,@SSN) ELSE NULL END SSN,    
    --      CASE WHEN @AdjReview = 'True' AND A.APDATE > @AdjCutOff THEN (CASE WHEN A.APSTATUS ='F' THEN ISNULL(CustomStatus.CustomFlagStatus,RefApplFlagStatus.FlagStatus) ELSE NULL END) ELSE 'N/A' END AdjStatus,A.CLNO as FacilityCLNO ,    
    --      A.Pub_Notes PreCheckComments    
    --  FROM  DBO.APPL A     
    --  LEFT JOIN DBO.APPSTATUSDETAIL STAT  ON A.APSTATUS = STAT.APPSTATUSITEM    
    --  LEFT JOIN DBO.ApplFlagStatus FlagStatus  ON A.APNO =  FlagStatus.APNO    
    --  LEFT JOIN DBO.RefApplFlagStatus  ON FlagStatus.FLAGSTATUS=RefApplFlagStatus.FLAGSTATUSID    
    --  LEFT JOIN DBO.RefApplFlagStatusCustom  CustomStatus  ON CustomStatus.CLNO = @CLNO AND FlagStatus.FLAGSTATUS = CustomStatus.FLAGSTATUSID     
    --  WHERE A.CLNO = @CLNO     
    --  --AND   CLIENTAPNO = @ClientAppNo     
    --  --AND    (CLIENTAPNO = isnull(@ClientAppNo,'') or A.APNO = isnull(@APNO,''))    
    --  AND    (A.APNO = coalesce(@apno,a.apno) OR CLIENTAPNO = coalesce(@clientappno,clientapno)  )      
    --  ORDER BY APDATE Desc    
        
    --If the specific app has been cancelled (moved to bad apps because of a duplicate submission), pull the info from the bad apps client with a CANCELLED status    
    IF (Select count(1) from DBO.APPL A With (nolock) Where (A.CLNO = 3468 ) AND  A.APNO = @apno AND @apno IS NOT NULL) > 0    
      SELECT A.APNO,IsNull(A.Last,'') as LAST,IsNull(A.First,'') as FIRST,IsNull(A.Middle,'') as MIDDLE,COMPDATE,APDATE,ISNULL(@ClientAppNo,CLIENTAPNO) CLIENTAPNO,IsNull(LAST_UPDATED,r.RequestDate) AS LAST_UPDATED,    
          'Cancelled' APSTATUS,    
          DOB,SSN, 'N/A'  AdjStatus , isnull(r.CLNO,@CLNO) as FacilityCLNO,    
          '' PreCheckComments    
      FROM  DBO.APPL A left join dbo.Integration_OrderMgmt_Request r on r.APNO = a.APNO    
      WHERE A.CLNO = 3468 --Bad Apps Client    
      AND     A.APNO = @apno     
    
    ELSE IF (Select count(1) from DBO.APPL A With (nolock) Where (A.CLNO = @CLNO or A.CLNO = @FacilityCLNO or A.CLNO=@APPCLNO ) AND  A.APNO = @apno AND @apno IS NOT NULL) > 0    
     SELECT A.APNO,IsNull(A.Last,'') as LAST,IsNull(A.First,'') as FIRST,IsNull(A.Middle,'') as MIDDLE,COMPDATE,APDATE, CLIENTAPNO,IsNull(LAST_UPDATED,r.RequestDate) AS LAST_UPDATED,    
       --ISNULL(STAT.APPSTATUSVALUE,'InProgress') APSTATUS,    
     --PR05  
  CASE WHEN STAT.APPSTATUSVALUE = 'InProgress'   
    AND R.CLNO IN (SELECT CLNO FROM #CLNOTable)  
    AND A.ReopenDate IS Not NULL   
    AND DATEDIFF( MINUTE,A.CompDate ,A.ReopenDate)> 0  
    AND A.OrigCompDate IS Not NULL  
    THEN 'Re-Opened'  
    WHEN STAT.APPSTATUSVALUE = 'Completed'   
    AND R.CLNO IN (SELECT CLNO FROM #CLNOTable)   
    AND A.ReopenDate IS Not NULL   
    AND DATEDIFF( MINUTE,A.ReopenDate ,A.CompDate)> 0  
    AND A.OrigCompDate IS Not NULL  
    -- To fix reclosed before completed by dhe 02/15/2023  
    AND (SELECT top 1 1 from Integration_CallbackLogging  
                        where CallbackPostRequest.value('(//Status)[1]','varchar(100)') = 'Completed' and apno = A.APNO  
                        and CallbackPostRequest is not null) = 1  
    THEN 'Re-Closed'  
    ELSE ISNULL(STAT.APPSTATUSVALUE,'InProgress') END AS APSTATUS,   
        -- PR05   
       CASE WHEN @IncludeSSNDOB = 1 THEN ISNULL(DOB,@DOB) ELSE NULL END DOB,    
       CASE WHEN @IncludeSSNDOB = 1 THEN ISNULL(SSN,@SSN) ELSE NULL END SSN,    
       CASE WHEN ((@AdjReview = 'True' AND A.APDATE > @AdjCutOff) OR @DefaultAdjReviewOnly = 'True')  THEN (CASE WHEN A.APSTATUS ='F' THEN ISNULL(CustomStatus.CustomFlagStatus,RefApplFlagStatus.FlagStatus) ELSE NULL END) ELSE 'N/A' END AdjStatus,    
       CASE WHEN R.clno in (13489,12444,12721,13126) then R.CLNO ELSE A.CLNO END FacilityCLNO ,    
       A.Pub_Notes PreCheckComments    
     FROM  DBO.APPL A     
     LEFT JOIN DBO.APPSTATUSDETAIL STAT  ON A.APSTATUS = STAT.APPSTATUSITEM    
     LEFT JOIN DBO.ApplFlagStatus FlagStatus  ON A.APNO =  FlagStatus.APNO    
     LEFT JOIN DBO.RefApplFlagStatus  ON FlagStatus.FLAGSTATUS=RefApplFlagStatus.FLAGSTATUSID    
     LEFT JOIN DBO.RefApplFlagStatusCustom  CustomStatus  ON CustomStatus.CLNO = @CLNO AND FlagStatus.FLAGSTATUS = CustomStatus.FLAGSTATUSID     
     LEFT JOIN dbo.Integration_OrderMgmt_Request r on r.APNO = a.APNO    
     WHERE (A.APNO = @apno )  
  --AND (A.CLNO = @CLNO or A.CLNO = @FacilityCLNO )   
     ORDER BY APDATE Desc        
    ELSE IF (Select count(1) from DBO.APPL A With (nolock) Where (A.CLNO = @CLNO or A.CLNO = @FacilityCLNO ) AND  A.CLIENTAPNO = @clientappno AND @clientappno IS NOT NULL) > 0    
     SELECT A.APNO,IsNull(A.Last,'') as LAST,IsNull(A.First,'') as FIRST,IsNull(A.Middle,'') as MIDDLE,COMPDATE,APDATE, CLIENTAPNO,IsNull(LAST_UPDATED,r.RequestDate) AS LAST_UPDATED,    
       --ISNULL(STAT.APPSTATUSVALUE,'InProgress') APSTATUS,   
     --PR05  
   CASE WHEN STAT.APPSTATUSVALUE = 'InProgress'   
     AND R.CLNO IN (SELECT CLNO FROM #CLNOTable)  
     AND A.ReopenDate IS Not NULL   
     AND DATEDIFF( MINUTE,A.CompDate ,A.ReopenDate)> 0  
     AND A.OrigCompDate IS Not NULL  
     THEN 'Re-Opened'  
     WHEN STAT.APPSTATUSVALUE = 'Completed'   
     AND R.CLNO IN (SELECT CLNO FROM #CLNOTable)   
     AND A.ReopenDate IS Not NULL   
     AND DATEDIFF( MINUTE,A.ReopenDate ,A.CompDate)> 0  
     AND A.OrigCompDate IS Not NULL  
     -- To fix reclosed before completed by dhe 02/15/2023  
     AND (SELECT top 1 1 from Integration_CallbackLogging  
                        where CallbackPostRequest.value('(//Status)[1]','varchar(100)') = 'Completed' and apno = A.APNO  
                        and CallbackPostRequest is not null) = 1  
     THEN 'Re-Closed'  
     ELSE ISNULL(STAT.APPSTATUSVALUE,'InProgress') END AS APSTATUS,   
                -- PR05   
       CASE WHEN @IncludeSSNDOB = 1 THEN ISNULL(DOB,@DOB) ELSE NULL END DOB,    
       CASE WHEN @IncludeSSNDOB = 1 THEN ISNULL(SSN,@SSN) ELSE NULL END SSN,    
       CASE WHEN ((@AdjReview = 'True' AND A.APDATE > @AdjCutOff) OR @DefaultAdjReviewOnly = 'True')  THEN (CASE WHEN A.APSTATUS ='F' THEN ISNULL(CustomStatus.CustomFlagStatus,RefApplFlagStatus.FlagStatus) ELSE NULL END) ELSE 'N/A' END AdjStatus,    
       CASE WHEN R.clno in (13489,12444,12721,13126) then R.CLNO ELSE A.CLNO END FacilityCLNO ,    
       A.Pub_Notes PreCheckComments    
     FROM  DBO.APPL A     
     LEFT JOIN DBO.APPSTATUSDETAIL STAT  ON A.APSTATUS = STAT.APPSTATUSITEM    
     LEFT JOIN DBO.ApplFlagStatus FlagStatus  ON A.APNO =  FlagStatus.APNO    
     LEFT JOIN DBO.RefApplFlagStatus  ON FlagStatus.FLAGSTATUS=RefApplFlagStatus.FLAGSTATUSID    
     LEFT JOIN DBO.RefApplFlagStatusCustom  CustomStatus  ON CustomStatus.CLNO = @CLNO AND FlagStatus.FLAGSTATUS = CustomStatus.FLAGSTATUSID     
     LEFT JOIN dbo.Integration_OrderMgmt_Request r on r.APNO = a.APNO    
     WHERE (A.CLNO = @CLNO or A.CLNO = @FacilityCLNO )    
     AND    (CLIENTAPNO = @ClientAppNo )      
     ORDER BY APDATE Desc        
        
    ELSE    
      --If an app has been cancelled (moved to bad apps because of a duplicate submission), pull the info from the bad apps client with a CANCELLED status    
      SELECT A.APNO,IsNull(A.Last,'') as LAST,IsNull(A.First,'') as FIRST,IsNull(A.Middle,'') as MIDDLE,COMPDATE,APDATE,ISNULL(@ClientAppNo,CLIENTAPNO) CLIENTAPNO,IsNull(LAST_UPDATED,r.RequestDate) AS LAST_UPDATED,    
          'Cancelled' APSTATUS,    
          DOB,SSN, 'N/A'  AdjStatus , isnull(r.CLNO,@CLNO) as FacilityCLNO,    
          '' PreCheckComments    
      FROM  DBO.APPL A left join dbo.Integration_OrderMgmt_Request r on r.APNO = a.APNO    
      WHERE A.CLNO = 3468 --Bad Apps Client    
      AND    (CLIENTAPNO = @ClientAppNo)      
      ORDER BY APDATE Desc         
           
   END    
  ELSE    
  -- Added by Doug DeGenaro    
  -- otherwise we are searching by date range for the specified clno    
   SELECT A.APNO,COMPDATE,APDATE,CLIENTAPNO,LAST_UPDATED,ISNULL(STAT.APPSTATUSVALUE,'InProgress') APSTATUS,    
       CASE WHEN @IncludeSSNDOB = 1 THEN DOB ELSE NULL END DOB,    
       CASE WHEN @IncludeSSNDOB = 1 THEN SSN ELSE NULL END SSN,    
       CASE WHEN ((@AdjReview = 'True' AND A.APDATE > @AdjCutOff) OR @DefaultAdjReviewOnly = 'True')    AND A.APSTATUS ='F' THEN ISNULL(CustomStatus.CustomFlagStatus,RefApplFlagStatus.FlagStatus) ELSE NULL END AdjStatus  , A.CLNO as FacilityCLNO     
   FROM  DBO.APPL A    
   LEFT JOIN DBO.APPSTATUSDETAIL STAT ON A.APSTATUS = STAT.APPSTATUSITEM    
   LEFT JOIN DBO.ApplFlagStatus FlagStatus ON A.APNO =  FlagStatus.APNO    
   LEFT JOIN DBO.RefApplFlagStatus ON FlagStatus.FLAGSTATUS=RefApplFlagStatus.FLAGSTATUSID    
   LEFT JOIN DBO.RefApplFlagStatusCustom CustomStatus ON CustomStatus.CLNO = @CLNO AND FlagStatus.FLAGSTATUS = CustomStatus.FLAGSTATUSID     
   LEFT JOIN BACKGROUNDREPORTS.DBO.BackgroundReport Report ON A.Apno = Report.Apno    
   WHERE A.CLNO = @CLNO    
   AND  ApDate Between @DateFrom    
      AND  DateAdd(d,1,@DateTo) --To include all the apps on the specified date (since timestamp is not being considered, only the apps through 12 AM are included by default)    
   AND  (CASE WHEN @CompletedOnly = 1 THEN Report.APNO ELSE A.APNO END) IS NOT NULL    
 END    
    
SET TRANSACTION ISOLATION LEVEL READ COMMITTED    
    
SET NOCOUNT OFF     
    
END    
  
  