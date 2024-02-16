
--select * from dbo.Appl where apno = 2324190
--[dbo].[WS_GetStatus] 2179,'481377',null,null,0,1,0,null
--WS_GetStatus @Clno=1937,@Apno=2544553




CREATE PROCEDURE [dbo].[WS_GetStatus_04232015] 
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
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	DECLARE @SSN varchar(11),@DOB DateTime

	IF @IncludeSSNDOB = 1
		SELECT @SSN = ISNULL(SSN,i94), @DOB = cast(DOB as Date)
		FROM   DBO.ReleaseForm with (nolock)
		WHERE  CLNO = @CLNO 
		AND   ClientAppNo = @ClientAppNo 
	ELSE
		SELECT @DOB = NULL, @SSN = NULL	

IF (@releaseOnly = 1)
	 BEGIN
	  IF (select count(1) from dbo.ReleaseForm where CLNO = @CLNO and ClientAPPNO = @ClientAppNo) > 0
			Select cast(1 as bit) 'ReleaseCaptured',@SSN SSN,@DOB DOB
		ELSE
			select cast(0 as bit) as 'ReleaseCaptured',@SSN SSN,@DOB DOB
	 END

 Else
	BEGIN
		Declare @AdjReview varchar(10),@AdjCutOff DateTime

		SET @AdjReview = (select value from clientconfiguration with (nolock) where configurationkey = 'AdjudicationProcess' and clno = @CLNO)
		SET @AdjReview = Isnull(@AdjReview,'False')

		SET @AdjCutOff = (select cast(value as Datetime)  from clientconfiguration with (nolock) where configurationkey = 'Adjudication_CutOffDate' and clno = @CLNO and isdate(value)=1)
		SET @AdjCutOff = Isnull(@AdjCutOff,Current_TimeStamp)
	
		-- Added by Doug DeGenaro
		-- We determine if clientappno is filled that we are searching by clno and clientappno, for any dates
		IF (@ClientAppNo IS NOT NULL or @ApNo IS NOT NULL)
			BEGIN


	--			IF @ClientAppNo IS NULL
	--				SELECT @ClientAppNo = Partner_Reference 
	--				FROM   DBO.Integration_OrderMgmt_Request	
	--				WHERE  APNO = @ApNo		
	--			

				--schapyala - 12/21/2011 -  to check if the app has been created for a sub-facility. If yes, reassign the CLNO to retrieve the correct status.
				Declare @FacilityCLNO int,@AppCLNO INT,@AppClientApNo varchar(50)

				Select @FacilityCLNO = FacilityCLNO
				From dbo.Integration_OrderMgmt_Request 
				Where CLNO = @CLNO 	AND    (Partner_Reference = isnull(@ClientAppNo,'') or APNO = isnull(@APNO,''))

				IF 	@FacilityCLNO IS NULL 		
					Select @FacilityCLNO = FacilityCLNO
					From dbo.Integration_PrecheckCallback 
					Where CLNO = @CLNO 	AND    (Partner_Reference = isnull(@ClientAppNo,'') or APNO = isnull(@APNO,''))


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
						IF @AppCLNO in (SELECT FacilityCLNO FROM HEVN..Facility Where ParentEmployerID = @CLNO AND FacilityCLNO IS NOT NULL) or @AppCLNO in (SELECT CLNO 	FROM DBO.[ClientHierarchyByService] WHERE ParentCLNO = @CLNO and  refHierarchyServiceID in (1,2))
								IF @AppClientApNo = @clientappno
									SET @FacilityCLNO = @AppCLNO
								ELSe
									--Doug Change to set the FacilityClno the same as the ApplClno if it is null
									SET @FacilityCLNO = IsNull(@FacilityCLNO,@AppCLNO)
									--SET @FacilityCLNO = @FacilityCLNO
					END
				END
				--SELECT @CLNO,@FacilityCLNO,@AppCLNO
		   
	--select @FacilityCLNO
				-- Assumption is the clno we are getting from the config table is unique per client.
				Set @CLNO = ISNULL(@FacilityCLNO,@CLNO)
				--schapyala 12/21/2011

			   --schapyala 12/6/2011
				IF (Select count(1) from DBO.APPL A With (nolock) Where (A.CLNO = @CLNO or A.CLNO = @FacilityCLNO )	AND  (CLIENTAPNO = coalesce(@clientappno,clientapno) and A.APNO = coalesce(@apno,apno))) > 0
						SELECT A.APNO,IsNull(A.Last,'') as LAST,IsNull(A.First,'') as FIRST,IsNull(A.Middle,'') as MIDDLE,COMPDATE,APDATE,ISNULL(@ClientAppNo,CLIENTAPNO) CLIENTAPNO,LAST_UPDATED,
							   ISNULL(STAT.APPSTATUSVALUE,'InProgress') APSTATUS,
							   CASE WHEN @IncludeSSNDOB = 1 THEN ISNULL(DOB,@DOB) ELSE NULL END DOB,
							   CASE WHEN @IncludeSSNDOB = 1 THEN ISNULL(SSN,@SSN) ELSE NULL END SSN,
							   CASE WHEN @AdjReview = 'True' AND A.APDATE > @AdjCutOff THEN (CASE WHEN A.APSTATUS ='F' THEN ISNULL(CustomStatus.CustomFlagStatus,RefApplFlagStatus.FlagStatus) ELSE NULL END) ELSE 'N/A' END AdjStatus,A.CLNO as FacilityCLNO 
						FROM  DBO.APPL A 
						LEFT JOIN DBO.APPSTATUSDETAIL STAT  ON A.APSTATUS = STAT.APPSTATUSITEM
						LEFT JOIN DBO.ApplFlagStatus FlagStatus  ON A.APNO =  FlagStatus.APNO
						LEFT JOIN DBO.RefApplFlagStatus  ON FlagStatus.FLAGSTATUS=RefApplFlagStatus.FLAGSTATUSID
						LEFT JOIN DBO.RefApplFlagStatusCustom  CustomStatus  ON CustomStatus.CLNO = @CLNO AND FlagStatus.FLAGSTATUS = CustomStatus.FLAGSTATUSID 
						WHERE A.CLNO = @CLNO
						--AND   CLIENTAPNO = @ClientAppNo 
						--AND    (CLIENTAPNO = isnull(@ClientAppNo,'') or A.APNO = isnull(@APNO,''))
						AND    (CLIENTAPNO = coalesce(@clientappno,clientapno) and A.APNO = coalesce(@apno,a.apno))  
						ORDER BY APDATE Desc
				ELSE
						--If an app has been cancelled (moved to bad apps because of a duplicate submission), pull the info from the bad apps client with a CANCELLED status
						SELECT A.APNO,IsNull(A.Last,'') as LAST,IsNull(A.First,'') as FIRST,IsNull(A.Middle,'') as MIDDLE,COMPDATE,APDATE,ISNULL(@ClientAppNo,CLIENTAPNO) CLIENTAPNO,LAST_UPDATED,
							   'Cancelled' APSTATUS,
							   DOB,SSN, 'N/A'  AdjStatus , A.CLNO as FacilityCLNO
						FROM  DBO.APPL A 
						WHERE A.CLNO = 3468 --Bad Apps Client
						AND    (CLIENTAPNO = coalesce(@clientappno,clientapno) and A.APNO = coalesce(@apno,apno))  
						ORDER BY APDATE Desc					
							
			END
		ELSE
		-- Added by Doug DeGenaro
		-- otherwise we are searching by date range for the specified clno
			SELECT A.APNO,COMPDATE,APDATE,CLIENTAPNO,LAST_UPDATED,ISNULL(STAT.APPSTATUSVALUE,'InProgress') APSTATUS,
				   CASE WHEN @IncludeSSNDOB = 1 THEN DOB ELSE NULL END DOB,
				   CASE WHEN @IncludeSSNDOB = 1 THEN SSN ELSE NULL END SSN,
				   CASE WHEN @AdjReview = 'True' AND A.APDATE > @AdjCutOff   AND A.APSTATUS ='F' THEN ISNULL(CustomStatus.CustomFlagStatus,RefApplFlagStatus.FlagStatus) ELSE NULL END AdjStatus  , A.CLNO as FacilityCLNO 
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








