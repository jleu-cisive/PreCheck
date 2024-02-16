
CREATE PROCEDURE [dbo].[GetNext_APNO]

(

	@Investigator varchar(8)

	, @IsCAM bit = 0

	, @QueueType varchar(20) = 'In Progress'

)

AS

SET NOCOUNT ON



DECLARE @APNO int
DECLARE @APStatus char(1)

SET @APNO = NULL

 if Len(@Investigator) > 8
	set @Investigator = Left(@Investigator,8)

IF @IsCAM = 1	--CAM Module

BEGIN

	--Follow-up items

	--SELECT TOP 1 @APNO = APNO 

	--FROM dbo.Appl 

	--WHERE UserID = @Investigator 

	--	AND ISNULL(GetNextDate, getdate()) <= getdate() 

	--ORDER BY ISNULL(GetNextDate, getdate())





	SELECT TOP 1 @APNO = APNO 

	FROM dbo.Appl 

	WHERE UserID = @Investigator 

		AND GetNextDate is not null AND GetNextDate <= getDate() 

	ORDER BY GetNextDate

	--added 6/13/07

	IF @APNO IS NOT NULL

		update appl set getnextdate = null where apno = @APNO



	--Work bin

	DECLARE @WorkBinID int

	WHILE @APNO IS NULL

	BEGIN

		SELECT TOP 1 @WorkBinID = WorkBinID, @APNO = APNO FROM dbo.WorkBin WHERE UserID = @Investigator AND WorkBinType = @QueueType ORDER BY 



CreatedDate

		IF @APNO IS NOT NULL 

		BEGIN

			DELETE FROM dbo.WorkBin WHERE WorkBinID = @WorkBinID

			--CHECK to make sure status is in Investigator review ie app has been reviewed by investigator

			--If app is not in 3 ie its in followup mode set it to null

			IF (SELECT APNO FROM dbo.Appl A INNER JOIN dbo.SubStatus SS ON A.SubStatusID = SS.SubStatusID 

					AND APNO = @APNO AND SS.MainStatusID = 3 AND InUse IS NULL AND ApStatus = 'P') IS NULL

				SET @APNO = NULL

		END

		ELSE

			SET @APNO = 0

	END



	--General work pool

	IF @APNO = 0 AND @QueueType = 'In Progress'

	BEGIN

		SELECT TOP 1 @APNO = A.APNO

		FROM dbo.Appl A

			INNER JOIN dbo.Client C ON A.CLNO = C.CLNO

			 LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.Empl     WHERE SectStat IN ('0','9') AND IsOnReport = 1 Group by Apno) Empl on A.APNO = Empl.APNO

			 LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.Educat   WHERE SectStat IN ('0','9') AND IsOnReport = 1 Group by Apno) Educat on A.APNO = Educat.APNO

			 LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.PersRef  WHERE SectStat IN ('0','9') AND IsOnReport = 1 Group by Apno) PersRef on A.APNO = PersRef.APNO

			 LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.ProfLic  WHERE SectStat IN ('0','9') AND IsOnReport = 1 Group by Apno) ProfLic on A.APNO = ProfLic.APNO

			 LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.Credit   WHERE SectStat IN ('0','9') Group by Apno) Credit on A.APNO = Credit.APNO

			 LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.MedInteg WHERE SectStat IN ('0','9')  Group by Apno) MedInteg on A.APNO = MedInteg.APNO

			 LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.DL       WHERE SectStat IN ('0','9')  Group by Apno) DL on A.APNO = DL.APNO

			 LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.Crim	   WHERE ISNULL(Clear, '') IN ('','R','M','O', 'V','W','X','E','N','I','Q','Z') Group by Apno) Crim on A.APNO = Crim.APNO

			INNER JOIN dbo.SubStatus SS ON ISNULL(A.SubStatusID, 1) = SS.SubStatusID

				AND SS.MainStatusID = 3	--investigator review

			WHERE  A.ApStatus = 'P'

			--AND A.ApDate IS NOT NULL

			AND ISNULL(A.Investigator, '') <> ''

			AND A.Userid = @Investigator

			--AND C.CAM = @Investigator

			--AND ISNULL(A.UserID, '') = ''

			AND ISNULL(A.InUse, '') = ''

			AND  (Isnull(Empl.Cnt,0) > 0

			OR    Isnull(Educat.Cnt,0) > 0

			OR    Isnull(PersRef.Cnt,0) > 0

			OR    Isnull(ProfLic.Cnt,0) > 0

			OR    Isnull(Credit.Cnt,0) > 0

			OR    Isnull(MedInteg.Cnt,0) > 0

			OR    Isnull(DL.Cnt,0) > 0

			OR    Isnull(Crim.Cnt,0) > 0)

			AND IsNull(c.clienttypeid,-1) <> 15

		/*

			WHERE (SELECT COUNT(*) FROM dbo.Empl		WHERE APNO = A.APNO AND SectStat IN ('0','9') AND IsOnReport = 1) > 0

			OR (SELECT COUNT(*) FROM dbo.Educat		WHERE APNO = A.APNO AND SectStat IN ('0','9') AND IsOnReport = 1) > 0

			OR (SELECT COUNT(*) FROM dbo.PersRef	WHERE APNO = A.APNO AND SectStat IN ('0','9') AND IsOnReport = 1) > 0

			OR (SELECT COUNT(*) FROM dbo.ProfLic	WHERE APNO = A.APNO AND SectStat IN ('0','9') AND IsOnReport = 1) > 0

			OR (SELECT COUNT(*) FROM dbo.Credit		WHERE APNO = A.APNO AND SectStat IN ('0','9')) > 0

			OR (SELECT COUNT(*) FROM dbo.MedInteg	WHERE APNO = A.APNO AND SectStat IN ('0','9')) > 0

			OR (SELECT COUNT(*) FROM dbo.DL			WHERE APNO = A.APNO AND SectStat IN ('0','9')) > 0

			OR (SELECT COUNT(*) FROM dbo.Crim		WHERE APNO = A.APNO AND ISNULL(Clear, '') IN ('','R','M','O')) > 0

		*/

		ORDER BY A.Rush DESC, A.PreCheckChallenge DESC, A.APNO

	END

	ELSE IF @APNO = 0 AND @QueueType = 'To Be Final'

	BEGIN

		SELECT TOP 1 @APNO = A.APNO

		FROM dbo.Appl A

			INNER JOIN dbo.Client C ON A.CLNO = C.CLNO

/*

				AND A.ApStatus = 'P'

				AND A.ApDate IS NOT NULL

				AND ISNULL(A.Investigator, '') <> ''

				AND A.Userid = @Investigator

				--AND C.CAM = @Investigator

				--AND ISNULL(A.UserID, '') = ''

				AND ISNULL(A.InUse, '') = ''

*/

			INNER JOIN dbo.SubStatus SS ON ISNULL(A.SubStatusID, 1) = SS.SubStatusID

				AND SS.MainStatusID = 3	--investigator review

		     LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.Empl     WHERE SectStat IN ('0','9') AND IsOnReport = 1 Group by Apno) Empl on A.APNO = Empl.APNO

		     LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.Educat   WHERE SectStat IN ('0','9') AND IsOnReport = 1 Group by Apno) Educat on A.APNO = Educat.APNO

		     LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.PersRef  WHERE SectStat IN ('0','9') AND IsOnReport = 1 Group by Apno) PersRef on A.APNO = PersRef.APNO

		     LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.ProfLic  WHERE SectStat IN ('0','9') AND IsOnReport = 1 Group by Apno) ProfLic on A.APNO = ProfLic.APNO

		     LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.Credit   WHERE SectStat IN ('0','9') Group by Apno) Credit on A.APNO = Credit.APNO

		     LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.MedInteg WHERE SectStat IN ('0','9')  Group by Apno) MedInteg on A.APNO = MedInteg.APNO

		     LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.DL       WHERE SectStat IN ('0','9')  Group by Apno) DL on A.APNO = DL.APNO

		     LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.Crim	   WHERE ISNULL(Clear, '') IN ('','R','M','O', 'V','W','X','E','N','I','Q') and ishidden = 0 Group by Apno) Crim on A.APNO = Crim.APNO

			WHERE A.ApStatus = 'P'

			--AND A.ApDate IS NOT NULL

			AND ISNULL(A.Investigator, '') <> ''

			AND A.Userid = @Investigator

			--AND C.CAM = @Investigator

			--AND ISNULL(A.UserID, '') = ''

			AND ISNULL(A.InUse, '') = ''

			AND   Isnull(Empl.Cnt,0) = 0

			AND   Isnull(Educat.Cnt,0) = 0

			AND   Isnull(PersRef.Cnt,0) = 0

			AND   Isnull(ProfLic.Cnt,0) = 0

			AND   Isnull(Credit.Cnt,0) = 0

			AND   Isnull(MedInteg.Cnt,0) = 0

			AND   Isnull(DL.Cnt,0) = 0

			AND   Isnull(Crim.Cnt,0) = 0

			AND IsNull(c.clienttypeid,-1) <> 15

/*

		WHERE (SELECT COUNT(*) FROM dbo.Empl		WHERE APNO = A.APNO AND SectStat IN ('0','9') AND IsOnReport = 1) = 0

			AND (SELECT COUNT(*) FROM dbo.Educat	WHERE APNO = A.APNO AND SectStat IN ('0','9') AND IsOnReport = 1) = 0

			AND (SELECT COUNT(*) FROM dbo.PersRef	WHERE APNO = A.APNO AND SectStat IN ('0','9') AND IsOnReport = 1) = 0

			AND (SELECT COUNT(*) FROM dbo.ProfLic	WHERE APNO = A.APNO AND SectStat IN ('0','9') AND IsOnReport = 1) = 0

			AND (SELECT COUNT(*) FROM dbo.Credit	WHERE APNO = A.APNO AND SectStat IN ('0','9')) = 0

			AND (SELECT COUNT(*) FROM dbo.MedInteg	WHERE APNO = A.APNO AND SectStat IN ('0','9')) = 0

			AND (SELECT COUNT(*) FROM dbo.DL		WHERE APNO = A.APNO AND SectStat IN ('0','9')) = 0

			AND (SELECT COUNT(*) FROM dbo.Crim		WHERE APNO = A.APNO AND ISNULL(Clear, '') IN ('','R','M','O')) = 0

*/

		ORDER BY A.Rush DESC, A.PreCheckChallenge DESC, A.APNO

	END

END

ELSE	--Investigator Module

BEGIN

	--Follow-up items

	SELECT TOP 1 @APNO = A.APNO

	FROM dbo.Appl A

		INNER JOIN dbo.SubStatus SS ON ISNULL(A.SubStatusID, 2) = SS.SubStatusID

			AND SS.MainStatusID = 1

			AND (A.NeedsReview LIKE '%2' or A.NeedsReview LIKE '%5' or A.NeedsReview LIKE '%3' or A.NeedsReview LIKE '%6' or A.NeedsReview LIKE '%7')

			AND A.ApStatus = 'P'
			AND ISNULL(A.InUse, '') = ''

			AND A.GetNextDate is not null AND A.GetNextDate <= getDate() 

			--AND ISNULL(A.GetNextDate, getdate()) <= getdate()

			AND A.Investigator = @Investigator

		--INNER JOIN dbo.Empl Em ON A.APNO = Em.APNO AND Em.SectStat = '0'

		--INNER JOIN dbo.Educat Ed ON A.APNO = Ed.APNO AND Ed.SectStat = '0'

		--INNER JOIN dbo.PersRef PR ON A.APNO = PR.APNO AND PR.SectStat = '0'

		--INNER JOIN dbo.ProfLic PL ON A.APNO = PL.APNO AND PL.SectStat = '0'

		--INNER JOIN dbo.Crim C ON A.APNO = C.APNO AND ISNULL(C.Clear, '') = ''

		--INNER JOIN dbo.DL DL ON A.APNO = DL.APNO AND DL.SectStat = '0'

		--INNER JOIN dbo.MedInteg MI ON A.APNO = MI.APNO AND MI.SectStat = '0'

		--INNER JOIN dbo.Credit C2 ON A.APNO = C2.APNO AND C2.SectStat = '0'

	ORDER BY A.GetNextDate --ISNULL(A.GetNextDate, getdate())

	--clear out getnextdate
	
	IF @APNO IS NOT NULL
			BEGIN
			
			INSERT INTO [dbo].[ApplGetNextLog]

           ([APNO]

           ,[username]

           ,[QueueType]

           ,[CreatedDate])

		VALUES

           (@APNO

           ,@Investigator

           ,'getnextdate'

           ,getdate())
           END


	IF @APNO IS NOT NULL

		update appl set getnextdate = null where apno = @APNO



	--General work pool

	IF @APNO IS NULL

	BEGIN

		DECLARE @ClientSum float, @ClientCount int, @ClientAvg float

		SELECT @ClientSum = SUM(ISNULL(W.Weight, 50)) 

		FROM dbo.Client C LEFT OUTER JOIN dbo.ClientWeight W ON C.CLNO = W.CLNO AND W.WeightType = 'Investigator'



		SELECT @ClientCount = COUNT(*) FROM dbo.Client

		SET @ClientAvg = @ClientSum / @ClientCount



		DECLARE @CLNOWeight float, @ApDateWeight float, @PriorityAvg float, @Normalized_CLNO float, @Normalized_ApDate float

		SELECT TOP 1 @CLNOWeight = Weight FROM dbo.PriorityLevel WHERE PriorityType = 'Investigator' AND FieldName = 'CLNO'

		SELECT TOP 1 @ApDateWeight = Weight FROM dbo.PriorityLevel WHERE PriorityType = 'Investigator' AND FieldName = 'ApDate'

		SET @PriorityAvg = (@CLNOWeight + @ApDateWeight) / 2

		SET	@Normalized_CLNO = @CLNOWeight / @PriorityAvg

		SET @Normalized_ApDate = @ApDateWeight / @PriorityAvg



		SELECT TOP 1 @APNO = A.APNO,@APStatus = A.ApStatus

		FROM dbo.Appl A

			INNER JOIN dbo.Client C ON A.CLNO = C.CLNO

				AND A.ApStatus = 'P'

				AND ISNULL(A.Investigator, '') = ''

				--AND A.ApDate IS NOT NULL

				AND ISNULL(A.InUse, '') = ''

				AND (A.NeedsReview LIKE '%2' or A.NeedsReview LIKE '%5' or A.NeedsReview LIKE '%3' or A.NeedsReview LIKE '%6' or A.NeedsReview LIKE '%7')

			LEFT JOIN dbo.ClientWeight W ON A.CLNO = W.CLNO

			LEFT JOIN dbo.ApplInvestigators AI ON A.CLNO = AI.CLNO

		WHERE (C.Investigator1 = @Investigator 
		    OR C.Investigator2 = @Investigator 
			OR (AI.Investigator = @Investigator 
		        AND (cast(current_timestamp as date) between  AI.Effective_ActivationDate AND Isnull(AI.Effective_InActivationDate,current_timestamp)
		            )
		       )
		--) modified by dhe 05/28/2019

			OR (ISNULL(C.Investigator1, '') = '' AND ISNULL(C.Investigator2, '') = '')
			) --modified by dhe 05/28/2019

			AND IsNull(c.clienttypeid,-1) <> 15

		ORDER BY (DATEDIFF(hour, A.ApDate, getdate()) * @Normalized_ApDate) + ((ISNULL(W.Weight, 50) / @ClientAvg) * @Normalized_CLNO) DESC

			, A.APNO ASC
			
			IF @APNO IS NOT NULL
			BEGIN
			
			INSERT INTO [dbo].[ApplGetNextLog]

           ([APNO]

           ,[username]

           ,[QueueType]

           ,[CreatedDate])

		VALUES

           (@APNO

           ,@Investigator

           ,@ApStatus

           ,getdate())
           END

	END

END



IF @APNO IS NOT NULL

BEGIN

	IF @IsCAM = 0

		BEGIN

		UPDATE dbo.Appl SET InUse = @Investigator, Investigator = @Investigator WHERE APNO = @APNO

		--INSERT INTO [dbo].[ApplGetNextLog]

  --         ([APNO]

  --         ,[username]

  --         ,[QueueType]

  --         ,[CreatedDate])

		--VALUES

  --         (@APNO

  --         ,@Investigator

  --         ,@QueueType

  --         ,getdate())

		END

	ELSE

		BEGIN

		UPDATE dbo.Appl SET InUse = @Investigator WHERE APNO = @APNO

		INSERT INTO [dbo].[ApplGetNextLog]

           ([APNO]

           ,[username]

           ,[QueueType]

           ,[CreatedDate])

		VALUES

           (@APNO

           ,@Investigator

           ,@QueueType

           ,getdate())

		END

	SELECT @APNO AS APNO

END

ELSE

	SELECT 0 AS APNO



SET NOCOUNT OFF






















