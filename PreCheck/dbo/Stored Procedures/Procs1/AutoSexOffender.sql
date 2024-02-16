-- Create Procedure AutoSexOffender

CREATE PROCEDURE [dbo].[AutoSexOffender] AS
BEGIN
	declare @id int
	declare @apno int
	declare @state varchar(2)
	declare @crimid int
	create table #a (apno int, [state] varchar(2),CLNO int,AutoOrderClient varchar(6),SkipSexOffender varchar(6), id int identity)
	create table #c (CNTY_NO int,  id int identity)

	/*
	-- VD-11/03/2016 - For Special Instructions update in Appl table
	create table #GetSI (NoteText text, CLNO int)
	create table #InsertSI (NoteText text, Special_instructions varchar(max), Apno int)
	create table #ConcatSI (Special_instructions varchar(max), Apno int)
	*/

	-- Below statement is used to update appl table when there is no SSN. need to skip PID and other county automation.

	UPDATE Appl
		SET NeedsReview = SUBSTRING(NeedsReview,1,1) + '7',
			InUse = null  
		--select * from Appl
		WHERE InUse = 'SexOff_S'
		  --(InUse IS NULL) AND (NeedsReview Like '%1')
		  --and Clno > 0
		  AND ApStatus = 'P' 
	      AND ((SSN IS NULL) OR (LEN(LTRIM(RTRIM(SSN))) < 11 ))

	-- START: Insert primary name into ApplAlias when SSN is not provided.-- VD:05/23/2017
		SELECT ROW_NUMBER() OVER(ORDER BY A.APNO DESC) AS NoSSNRow, InUse,NeedsReview, EnteredVia,  ApStatus, ApDate, A.Apno, A.SSN, DOB, A.CLNO, A.First, A.Last, A.Middle, A.Generation, AA.APNO AS AliasAPNO
			INTO #tmpNoSSNRecords
		FROM Appl AS A(NOLOCK) 
		LEFT OUTER JOIN ApplAlias AS AA(NOLOCK) ON A.APNO = AA.APNO 
		WHERE NeedsReview = LEFT(NeedsReview,1) + '7' 
		  AND ApStatus = 'P'
		  AND (AA.APNO IS NULL)

		--SELECT * FROM #tmpNoSSNRecords

		DECLARE @TotalNumberOfNoSSNRecords int = (SELECT MAX(NoSSNRow)FROM #tmpNoSSNRecords);
		DECLARE @NoSSNRecordRow int;
		DECLARE @FirstName VARCHAR(20)
		DECLARE @MiddleName VARCHAR(20)
		DECLARE @LastName VARCHAR(20)
		DECLARE @Generation VARCHAR(3)

		--SELECT @TotalNumberOfNoSSNRecords

		WHILE (@TotalNumberOfNoSSNRecords != 0)
		BEGIN	
			SELECT @NoSSNRecordRow = NoSSNRow, @Apno = Apno, @FirstName = REPLACE([First], '''', ''), @MiddleName = REPLACE(Middle, '''', ''), @LastName = REPLACE([Last], '''', '') , @Generation = REPLACE(Generation, '''', '') 
			FROM #tmpNoSSNRecords
			WHERE NoSSNRow = @TotalNumberOfNoSSNRecords
			ORDER BY NoSSNRow DESC

			--SELECT @NoSSNRecordRow NoSSNRecordRow, @Apno Apno, @FirstName FirstName, @MiddleName MiddleName, @LastName LastName, @Generation Generation

			IF ((SELECT COUNT(*) FROM ApplAlias(NOLOCK) WHERE APNO = @Apno) = 0)
			BEGIN			
				INSERT INTO [dbo].[ApplAlias]
					([APNO] ,[First] ,[Middle] ,[Last], [IsMaiden], [CreatedDate], [Generation], [AddedBy], [CLNO], [SSN], [IsPrimaryName], [IsActive], [CreatedBy], [LastUpdateDate], [LastUpdatedBy], [IsPublicRecordQualified])
				VALUES
					(@Apno, @FirstName, @MiddleName, @LastName, 0, CURRENT_TIMESTAMP, @Generation, 'AliasAutomation', NULL, NULL, 1, 1, 'AliasAutomation', CURRENT_TIMESTAMP, 'AliasAutomation', 1)

				--PRINT @Apno
			END

			-- SET your counter to -1
			SET @TotalNumberOfNoSSNRecords = @NoSSNRecordRow - 1
		END
	-- END: Insert primary name into ApplAlias when SSN is not provided.

	 insert	#a (apno, [state],CLNO,AutoOrderClient,SkipSexOffender) 
	select a.apno, a.state
	,a.CLNO ,IsNull(AutoOrderConfig.[value], 'False'),IsNull(SexOffenderConfig.[value], 'False') --added by Schapyala on 07/02/14
	from dbo.appl a left join dbo.clientconfiguration SexOffenderConfig on a.clno = SexOffenderConfig.clno and SexOffenderConfig.configurationkey = 'SkipSexOffender' 
					left join dbo.clientconfiguration AutoOrderConfig on a.clno = AutoOrderConfig.clno and AutoOrderConfig.configurationkey = 'AutoOrder' --added by Schapyala on 07/02/14
	where  a.InUse = 'SexOff_S' 
	AND APNO NOT IN 
		(SELECT APNO FROM  Crim WHERE CNTY_NO=2480 AND APNO IN (SELECT APNO FROM Appl WHERE InUse = 'SexOff_S' ))

			declare @CLNO int
			declare @AutoOrderClient varchar(6)
			declare @SkipSexOffender varchar(6)

			select @id = 0

			WHILE @id < (select max(id) from #a)
				BEGIN
					select @id = @id + 1

					select 	@apno = apno,
						--  @state = state -- commented the state to be a null value for Auto ordering Sex offender searches using AMIS Agents
							@state = NULL,
							@CLNO = clno,  --added by Schapyala on 07/02/14
							@AutoOrderClient = AutoOrderClient,
							@SkipSexOffender = SkipSexOffender  --end added by Schapyala on 07/02/14
					from	#a
					where	#a.id = @id

					if @SkipSexOffender = 'False'
						exec  dbo.createcrimsexoffender @state, @apno, 2480, @crimid
							 
					--if @AutoOrderClient = 'True'
					--Begin
						--Create crim records based on client rules configuration
						insert	#c (CNTY_NO) 
						select CNTY_NO from  dbo.StateWideCountyRules s inner join  dbo.refRequirementText r on s.StatewideID = r.CivilID  where r.clno = @clno -- Civil
						union
						select CNTY_NO from  dbo.StateWideCountyRules s inner join  dbo.refRequirementText r on s.StatewideID = r.FederalID  where r.clno = @clno -- Federal
						union
						select CNTY_NO from  dbo.StateWideCountyRules s inner join  dbo.refRequirementText r on s.StatewideID = r.SpecialRegID  where r.clno = @clno -- SpecialReg


						/* START : Update Special Instructions from Client Notes to Appl's Special_Instructions field*/ -- VD-11/03/2016
							/*
							INSERT #GetSI (CLNO, NoteText)
							SELECT CLNO, NoteText 
							FROM ClientNotes(NOLOCK)
							WHERE CLNO = @CLNO
							  AND NoteText LIKE '%SPECIAL INSTRUCTION%'

							IF (SELECT COUNT(*) FROM #GetSI) > 0
								BEGIN
									INSERT #InsertSI (NoteText, Apno, Special_instructions)
										SELECT C.NoteText, A.APNO, A.Special_instructions
										FROM Appl(NOLOCK) AS A
										INNER JOIN #GetSI AS C ON A.CLNO = C.CLNO
										WHERE C.CLNO = @CLNO
  										  AND A.Apno = @apno																	

									INSERT #ConcatSI (Apno, Special_instructions)
									SELECT  APNO, 
											Special_instructions = REPLACE(STUFF((SELECT ', ' + CAST(NoteText AS VARCHAR(MAX))
																					FROM #InsertSI b
																					WHERE b.APNO = a.APNO 
																					FOR XML PATH('')), 1, 1, ''),',', char(13) + char(10))
									FROM #InsertSI a
									GROUP BY APNO

									IF (SELECT COUNT(*) AS Special_instructions FROM Appl(NOLOCK) WHERE Special_instructions LIKE '%SPECIAL INSTRUCTION%' AND APNO = @apno) = 0
									BEGIN
										UPDATE Appl
											SET Special_instructions =  RTRIM(LTRIM(REPLACE(T.Special_instructions,'''',''))) --+ isnull(a.Special_instructions,'')
										FROM Appl(NOLOCK) AS A
										INNER JOIN #ConcatSI AS T ON A.APNO = T.APNO
									END
							END
							*/
						/* END : Update Special Instructions from Client Notes to Appl's Special_Instructions field*/



						insert into dbo.Crim (Apno, CNTY_NO, County,CreatedDate,[Clear],vendorid,deliverymethod,b_rule,iris_rec,readytosend )
						Select @apno, c.CNTY_NO, County,getdate(),
						case when @AutoOrderClient = 'True' then 'R' else null end, --IF Autoorder client, then set it to pending 
						R_id,R_Delivery,'Yes','Yes','0'
						From #C c inner join dbo.TblCounties cnty on c.cnty_no = cnty.cnty_no
						inner join dbo.Iris_Researcher_Charges IRC on c.cnty_no = IRC.cnty_no AND (Researcher_Default = 'Yes')
						inner join  dbo.Iris_Researchers IR on Researcher_id = R_id
						where C.CNTY_NO not in (select distinct CNTY_NO from crim where APNO = @apno)
						
						declare @MvrID int
						select @MvrID = MvrID from    dbo.Client   where clno = @clno 

						if @MvrID = 418
						begin
							if ((Select count(apno) from Dl where Apno = @apno) =0)
								Begin
									INSERT INTO DBO.[DL] ([APNO],[SectStat],[CreatedDate])
									Select Apno,0,getdate()	From DBO.Appl Where Apno = @apno
								end

								--Update Appl 	set inuse = Null, NeedsReview = substring(NeedsReview,1,1) + '5'	where Apno = @apno
	
						End
						else if @MvrID = 420
						Begin
								if ((Select count(apno) from Dl where Apno = @apno) =0)
								Begin
									INSERT INTO DBO.[DL] ([APNO],[SectStat],[CreatedDate])
									Select Apno,0,getdate()	From DBO.Appl Where Apno = @apno
								end
						end

						-- below was commented by kiran on 7/10/2014, to get active vendor and delivery method for each county.

						----Select @apno, c.CNTY_NO, County,getdate(),
						----case when @AutoOrderClient = 'True' then 'R' else null end, --IF Autoorder client, then set it to pending 
						----86419,'Call_In','Yes','Yes','0'
						----From #C c inner join dbo.counties cnty on c.cnty_no = cnty.cnty_no
						--Where c.CNTY_NO not in (Select CNTY_NO	From dbo.crim where APNO = @apno)  -- uncomment if they complain about duplicate orders -- added by schapyala on 07/2/14 to prevent duplicates	

						Truncate table #c
					--End
               
					END
		
	drop table #a 
	drop table #c
	DROP TABLE #tmpNoSSNRecords
	/*
	drop table #GetSI
	drop table #InsertSI
	drop table #ConcatSI
	*/
	Update Appl
	set inuse = 'SexOff_E'
	where inuse = 'SexOff_S'
END
