
/*
[dbo].[IRIS_PendingOrders_Integrations] 2480, 0,0
[dbo].[IRIS_PendingOrders_Integrations] null,1,1
[dbo].[IRIS_PendingOrders_Intellicorp] 6,null
--Modified by Humera Ahmed on 11/2/2022 to include IsActive = 1 when joining ApplAlias table on line #118
--Modified by Humera Ahmed on 11/17/2022 to seperate the logic for Autoclears(partnerid=5) and Cisive Criminal database(partnerid=8)
--Modified by sindhura to send the super in increments of 30 searches 01-11-2023
--Modified by Humera Ahmed to remove the top 10 in line #148
--Modified by Lalit for #111372 on 27 sept 2023
*/

CREATE   procedure [dbo].[IRIS_PendingOrders_Intellicorp] ( @retries int = null,@County int = null, @PartnerId int = null)   
AS  
SET NOCOUNT ON

	BEGIN

		DECLARE @CrimPendingSearches TABLE
        (
			Section VARCHAR(20),
			SectionID INT,
			Apno INT,
			Cnty_No INT,	
			County VARCHAR(50),
			State varchar(10),
			Ordered VARCHAR(20),
			Last  VARCHAR(50),
			First VARCHAR(50), 
			Middle VARCHAR(50), 
			DOB DATETIME,
			DOB_MM VARCHAR(2),
			DOB_DD VARCHAR(2),
			DOB_YYYY INT,
			SSN VARCHAR(11),
			SSN1 VARCHAR(3),
			SSN2 VARCHAR(3),
			SSN3 VARCHAR(4),
			KnownHits VARCHAR(MAX),
			InUse Bit,
			InUseByIntegration VARCHAR(50),
			IsPrimaryName bit,
			ApplAliasID INT,
			Address_num varchar (10),
			Address_street Varchar(100),
			City    Varchar(50),
			A_State Varchar(10),
			Zip Varchar(10),
			Gender  Varchar(1),
			email varchar(100)
		)




			BEGIN
			if (@retries is null) set @retries = 6
	
				declare @defaultOrderedDate datetime
				declare @varcharOrderDate varchar(20)
				--Lear Year Fix
--if (year(CURRENT_TIMESTAMP)%4 = 0)
--       set @defaultOrderedDate = DATEADD(DAY,-1,CURRENT_TIMESTAMP)
--else
       set @defaultOrderedDate = CURRENT_TIMESTAMP     
       set @defaultOrderedDate = replace(@defaultOrderedDate,year(@defaultOrderedDate),'1900')

-- added to removed bad date format in ordered column 4/26/2021
select distinct crimid ,cast(ordered as datetime) as orderedDate   into #temp1 
 FROM dbo.Crim c with (NOLOCK)    inner join dbo.Partner_LogStatus pl   on c.CrimID= pl.SectionID 
 and pl.partnerid = @PartnerId and pl.section = 'Crim' and pl.crimstatus is null   
 WHERE
isnull(pl.Retries,0)<@retries

				
				
				update C 

                set Ordered= null
                FROM dbo.Crim c with (NOLOCK)
				where  c.crimid in (select crimid from #temp1 --  inner join dbo.Partner_LogStatus pl   on c.CrimID= pl.SectionID  and pl.partnerid = 4 and pl.section = 'Crim' and pl.crimstatus is null   
                WHERE DATEDIFF( MINUTE,orderedDate,@defaultOrderedDate)>60
                --AND pl.CreatedDate > Dateadd(MONTH,-3,current_timestamp)
                AND Year(orderedDate) = '1900'
				)
				drop table #temp1


			--	set @defaultOrderedDate = getdate()	
			--	set @defaultOrderedDate = replace(@defaultOrderedDate,year(getdate()),'1900')
				set @varcharOrderDate = convert(varchar(10),@defaultOrderedDate,101) + ' ' + CONVERT(VARCHAR(10), @defaultOrderedDate, 108)		
				
				
				if (@PartnerId = 4) --Intellicorp Auto clear 
				Begin
					INSERT INTO @CrimPendingSearches
					SELECT  Distinct  'Crim' Section,SectionID,Apno,Cnty_No , County, state,  @varcharOrderDate Ordered, Last, First, Middle, DOB,
							RIGHT('00' + CONVERT(VARCHAR(2),MONTH(DOB)),2)  DOB_MM,  right('00' + CONVERT(VARCHAR(2),Day(DOB)),2) DOB_DD,YEAR(DOB) DOB_YYYY,SSN,left(SSN,3) SSN1, 
							CASE WHEN CHARINDEX('-',SSN)>0 THEN SUBSTRING(SSN,5,2) ELSE SUBSTRING(SSN,4,2) END SSN2,right(SSN,4) SSN3,CAST(KnownHits AS VARCHAR(max)) KnownHits,		
							InUse,InUseByIntegration,IsPrimaryName,ApplAliasID, Addr_Num, Addr_Street, City, A_State, Zip, sex, email
					FROM  
					(  
					SELECT 	DISTINCT  C.CrimID SectionID,C.APNO , C.Cnty_no, CNTY.County, Cnty.State State,--C.Ordered,
							ISNULL(AA.Last,A.Last) Last, 
							ISNULL(AA.First,A.First) First,
							--Null AS Middle,
							ISNULL(AA.Middle, A.Middle) Middle,
							A.DOB AS DOB,  
							CASE WHEN c.Cnty_no = 3906 then  REPLACE(A.SSN,'-','') else A.SSN end AS SSN,  
							ISNULL(C.CRIM_SpecialInstr,'') AS KnownHits,c.InUse,InUseByIntegration ,IsPrimaryName ,AA.ApplAliasID,
							a.Addr_Num, a.Addr_Street, a.City, a.[State] A_state , a.Zip, a.sex, a.email
					FROM Crim C WITH (NOLOCK) 
					INNER JOIN Appl A WITH (NOLOCK) ON A.APNO = C.APNO 		
					--INNER JOIN dbo.ApplAlias_Sections AS S (NOLOCK) ON S.SectionKeyID = C.CrimID AND S.ApplSectionID = 5 AND S.IsActive=1-- crim
					INNER JOIN ApplAlias AS AA(NOLOCK) ON A.APNO = AA.APNO and AA.IsPublicRecordQualified = 1 AND AA.IsActive=1 --schapyala on 05/19/20 Qualify all publicrecord qualified aliases
					-- INNER JOIN [Counties] as cnty on cnty.cnty_no = c.CNTY_NO
					INNER JOIN [dbo].[County_PartnerJurisdiction] CNTY on CNTY.partnerid = @PartnerId and cnty.cnty_no = c.CNTY_NO
					LEFT OUTER JOIN dbo.Partner_LogStatus as pl  on  pl.partnerid = @PartnerId and pl.section = 'Crim' and c.CrimID= pl.SectionID and pl.ApplAliasID =AA.ApplAliasID 
					WHERE (C.Cnty_no = @County OR @County IS NULL) 
					  AND (C.Clear IN( 'Y'))  
					  AND (A.InUse IS NULL) 
					  AND A.ApStatus in ('p','w')
					  AND c.ishidden = 0   
					  AND Isnull(Ordered,'')=''
					  AND A.CLNO NOT IN (3468,2135) -- Added this by Santosh on 06/24/13 to exclude BAD APPS 

					  --AND IsNull(c.InUseByIntegration,'') = ''	
					  AND pl.crimstatus is null 			 		
					) Qry 
				--ORDER BY CAST(ISNULL(Ordered,'1/1/1900') AS DateTime)
				End

				ELSE IF (@PartnerId = 11) -- Crim DB
					BEGIN
						INSERT INTO @CrimPendingSearches
						SELECT  Distinct  'Crim' Section,SectionID,Apno,Cnty_No , County, state,  @varcharOrderDate Ordered, Last, First, Middle, DOB,
							RIGHT('00' + CONVERT(VARCHAR(2),MONTH(DOB)),2)  DOB_MM,  right('00' + CONVERT(VARCHAR(2),Day(DOB)),2) DOB_DD,YEAR(DOB) DOB_YYYY,SSN,left(SSN,3) SSN1, 
							CASE WHEN CHARINDEX('-',SSN)>0 THEN SUBSTRING(SSN,5,2) ELSE SUBSTRING(SSN,4,2) END SSN2,right(SSN,4) SSN3,CAST(KnownHits AS VARCHAR(max)) KnownHits,		
							InUse,InUseByIntegration,IsPrimaryName,ApplAliasID, Addr_Num, Addr_Street, City, A_State, Zip, sex, email
						FROM  
						(  
							SELECT	Distinct C.CrimID SectionID
								,C.APNO , C.Cnty_no, CNTY.County, Cnty.State State,
								ISNULL(AA.Last,A.Last) Last, 
								ISNULL(AA.First,A.First) First,
								ISNULL(AA.Middle, A.Middle) Middle,
								A.DOB AS DOB,  
								CASE WHEN c.Cnty_no = 3906 then  REPLACE(A.SSN,'-','') else A.SSN end AS SSN,  
								ISNULL(C.CRIM_SpecialInstr,'') AS KnownHits,c.InUse,InUseByIntegration ,IsPrimaryName ,AA.ApplAliasID,
								a.Addr_Num, a.Addr_Street, a.City, a.[State] A_state , a.Zip, a.sex, a.email
						FROM Crim C WITH (NOLOCK) 
						INNER JOIN Appl A WITH (NOLOCK) ON A.APNO = C.APNO 		
						INNER JOIN dbo.ApplAlias_Sections AS S (NOLOCK) ON S.SectionKeyID = C.CrimID AND S.ApplSectionID = 5 AND S.IsActive=1
						INNER JOIN ApplAlias AS AA(NOLOCK) ON AA.ApplAliasID = S.ApplAliasID 
						INNER JOIN [dbo].[County_PartnerJurisdiction] CNTY on CNTY.partnerid = @PartnerId and cnty.cnty_no = c.CNTY_NO
						LEFT OUTER JOIN dbo.Partner_LogStatus as pl  on  pl.partnerid = @PartnerId and pl.section = 'Crim' and c.CrimID= pl.SectionID and pl.ApplAliasID =AA.ApplAliasID 
						WHERE 
						(C.Cnty_no = @County OR @County IS NULL) 
						  AND (C.Clear IN( 'M')) 
						  AND (A.InUse IS NULL) 
						  AND A.ApStatus in ('p','w')
						  AND c.ishidden = 0   
						  AND Isnull(Ordered,'')=''
						  AND A.CLNO NOT IN (3468,2135)
						  and c.vendorid = 13235906 --Cisive Criminal database vendor id
						  AND pl.crimstatus is null	 		
						) Qry 
					--ORDER BY CAST(ISNULL(Ordered,'1/1/1900') AS DateTime)
						
					END

					ELSE IF (@PartnerId = 13) -- Crim DB, SOR to Mid-Market,  added by Lalit for #111372
					BEGIN
						INSERT INTO @CrimPendingSearches
						SELECT  Distinct  'Crim' Section,SectionID,Apno,Cnty_No , County, state,  @varcharOrderDate Ordered, Last, First, Middle, DOB,
							RIGHT('00' + CONVERT(VARCHAR(2),MONTH(DOB)),2)  DOB_MM,  right('00' + CONVERT(VARCHAR(2),Day(DOB)),2) DOB_DD,YEAR(DOB) DOB_YYYY,SSN,left(SSN,3) SSN1, 
							CASE WHEN CHARINDEX('-',SSN)>0 THEN SUBSTRING(SSN,5,2) ELSE SUBSTRING(SSN,4,2) END SSN2,right(SSN,4) SSN3,CAST(KnownHits AS VARCHAR(max)) KnownHits,		
							InUse,InUseByIntegration,IsPrimaryName,ApplAliasID, Addr_Num, Addr_Street, City, A_State, Zip, sex, email
						FROM  
						(  
							SELECT	Distinct C.CrimID SectionID
								,C.APNO , C.Cnty_no, CNTY.County, Cnty.State State,
								ISNULL(AA.Last,A.Last) Last, 
								ISNULL(AA.First,A.First) First,
								ISNULL(AA.Middle, A.Middle) Middle,
								A.DOB AS DOB,  
								CASE WHEN c.Cnty_no = 3906 then  REPLACE(A.SSN,'-','') else A.SSN end AS SSN,  
								ISNULL(C.CRIM_SpecialInstr,'') AS KnownHits,c.InUse,InUseByIntegration ,IsPrimaryName ,AA.ApplAliasID,
								a.Addr_Num, a.Addr_Street, a.City, a.[State] A_state , a.Zip, a.sex, a.email
						FROM Crim C WITH (NOLOCK) 
						INNER JOIN Appl A WITH (NOLOCK) ON A.APNO = C.APNO 		
						INNER JOIN dbo.ApplAlias_Sections AS S (NOLOCK) ON S.SectionKeyID = C.CrimID AND S.ApplSectionID = 5 AND S.IsActive=1
						INNER JOIN ApplAlias AS AA(NOLOCK) ON AA.ApplAliasID = S.ApplAliasID and AA.IsPublicRecordQualified = 1 AND AA.IsActive=1
						INNER JOIN [dbo].[County_PartnerJurisdiction] CNTY on CNTY.partnerid = @PartnerId and cnty.cnty_no = c.CNTY_NO
						LEFT OUTER JOIN dbo.Partner_LogStatus as pl  on  pl.partnerid = @PartnerId and pl.section = 'Crim' and c.CrimID= pl.SectionID and pl.ApplAliasID =AA.ApplAliasID 
						WHERE 
						(C.Cnty_no = @County OR @County IS NULL) 
						  AND (C.Clear IN( 'M')) 
						  AND (A.InUse IS NULL) 
						  AND A.ApStatus in ('p','w')
						  AND c.ishidden = 0   
						  AND Isnull(Ordered,'')=''
						  AND A.CLNO NOT IN (3468,2135)
						  and c.vendorid = 13235906 
						  AND pl.crimstatus is null	 		
						) Qry 
						
					END

				-- Set Block
				Update C Set Ordered = CP.Ordered
				From Crim C inner join @CrimPendingSearches CP on C.CrimID = CP.SectionID
				
				--The below logic is to handle any bad Date of Birth scenarios that need to be handled
				BEGIN TRY
					Declare @DOBCutoff Date = cast(Dateadd(YEAR,-12,current_timestamp) as Date)
					Declare @DOBCutoffHigh Date = cast(Dateadd(YEAR,20,'1/1/1900') as Date)
					If (Select count(1) From @CrimPendingSearches where DOB >= @DOBCutoff or ISDATE(DOB) = 0) >0
					BEGIN
						
						Declare @msg varchar(5500)
						
						--compile a list of APNO's with bad DOB along with instructions
						SELECT distinct @msg =  COALESCE(@msg + ', ', '') + cast(Apno as varchar) + '[' + IsNull([First],'') + ' ' + IsNull([Last],'') + ']'  + char(9) + char(13)  
						FROM @CrimPendingSearches
						WHERE DOB >= @DOBCutoff or ISDATE(DOB) = 0
						
						Select @msg = 'Please find the list of Apps where the DOB is ' + cast(@DOBCutoff as varchar) +' or higher (less than 12 years of age). These orders will be rejected by the integration vendors and hence need to be fixed or handled outside integration.' + char(9) + char(13) 
						+ 'Reports/Apps updated with a correct DOB will be re-tried to be sent in an hour or so. ' + char(9) + char(13) +  char(9) + char(13) 
						+ @msg +  char(9) + char(13) + ' You will continue to receive this notification for the above Reports about every hour (till fixed or handled). Thank you.' 
						
						--Delete the bad DOB records from the temp to prevent sending to the vendor
						Delete @CrimPendingSearches where DOB >= @DOBCutoff or ISDATE(DOB) = 0

						--send the compiled email to recepients
						EXEC msdb.dbo.sp_send_dbmail   @from_address = 'Integration Vendor Service <DoNotReply@PreCheck.com>',@subject=N'Date Of Birth Corrections Needed', @recipients=N'santoshchapyala@Precheck.com;DouglasDegenaro@precheck.com;JoeMonforti@precheck.com; MatthewCeloria@precheck.com',    @body=@msg ;
						
					END
				END TRY
				BEGIN CATCH  
				--	--Error handling
				END CATCH
				

				SELECT	DISTINCT 'Crim' Section,
						SectionID,ApplAliasID, Apno, Cnty_No,County,State,CAST(ISNULL(Ordered,'1/1/1900') AS DATETIME) Ordered,
						Coalesce([Last],'') [last] ,
						coalesce([First],'') [first] ,
						Coalesce(Middle,'') Middle,   
						CONVERT(varchar, DOB, 101) DOB,
						RIGHT('00' + convert(VARCHAR(2),MONTH(DOB)),2)  DOB_MM,
						RIGHT('00' + convert(VARCHAR(2),DAY(DOB)),2) DOB_DD,
						YEAR(DOB) DOB_YYYY,SSN,LEFT(SSN,3) SSN1,
						CASE WHEN CHARINDEX('-',SSN)>0 THEN SUBSTRING(SSN,5,2) ELSE SUBSTRING(SSN,4,2) END SSN2,
						RIGHT(SSN,4) SSN3,
						CAST(KnownHits AS VARCHAR(max)) KnownHits,InUse, InUseByIntegration ,
						coalesce(Address_num,'') Address_num, 
						coalesce(Address_street,'') Address_street, 
						coalesce(City,'') City, 
						coalesce(A_State,'') A_State,
						coalesce(Zip,'') Zip, 
						Coalesce(Gender,'') Gender,
						coalesce( email, '') as email
				from @CrimPendingSearches
				
			END
		

	END
SET NOCOUNT OFF	


