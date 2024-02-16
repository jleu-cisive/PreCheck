
-- =============================================
-- Created By :	Deepak
-- Edited date:	05/18/2017
-- Description:	As part of Alias Logic Re-Write project, alias sent will be added to the private notes. Only AutoOrder records should be selected to send automatically.
-- Edited By :	Deepak Vodethela
-- Edited date:	11/03/2020
-- Description:	Resetting (InUseByIntegration, Ordered) column for the service to pick it up in next run when the records are errored
-- =============================================

--[dbo].[Crim_MarkToSend_AutoOrder] 'WEB SERVICE','AutoOrdr'


CREATE PROCEDURE [dbo].[Crim_MarkToSend_AutoOrder]    
	(@deliverymethod varchar(25), @investigator varchar(8))
AS
BEGIN
    SET NOCOUNT ON
	
	DECLARE @LINKID int;

	INSERT INTO CRIMSENDLOG
	(DeliveryMethod,status,logdate)
	VALUES
	(@deliverymethod,'START',getdate())
	SET @LINKID = @@IDENTITY;
	
	Print '1 - ' + @deliverymethod

--bypass printing for online criminal worksheet clients --10/6/08
	if @deliverymethod In  ('OnlineDB','InHouse','Call_In','Integration')
	Begin
		Print '2 - ' + @deliverymethod
		Declare @BatchPrintNumber  Int
		Declare @CrimControlNumber Int
		Declare @OrderDate varchar(14)
		
		Set @OrderDate = Convert(VARCHAR(14),GetDate(),1)  + ' ' + Convert(VARCHAR(14),GetDate(),108)

		--CREATE TABLE #tmp(crimid int,bnum int,cnum int,vendorid int,cnty_no int) -- VD:  08/14/2017 -- Added the below statement to add Clustered index on tem table
		CREATE TABLE #tmp(tmpID int identity(1,1) primary key not null, crimid int,bnum int,cnum int,vendorid int,cnty_no int)

		--add new records to temp table
	
			If @deliverymethod = 'InHouse' 
					Insert into #tmp
						(crimid,vendorid,cnty_no)
							SELECT C.crimid,c.vendorid,c.cnty_no 
							FROM appl A (NOLOCK)
							INNER JOIN crim C(NOLOCK) ON A.apno = C.apno
							INNER JOIN iris_researchers IR(NOLOCK) ON C.vendorid = IR.r_id
							LEFT OUTER JOIN dbo.ApplAlias_Sections AS S (NOLOCK) ON S.SectionKeyID = C.CrimID AND S.ApplSectionID = 5 AND S.IsActive = 1 AND S.CreatedBy = 'AutoOrdr'
							WHERE (UPPER(A.apstatus) IN ('P','W'))
							  AND ((A.inuse IS NULL) OR (A.inuse = 'ChkAlias'))
							  AND (C.readytosend = 1)
							  AND (UPPER(C.[clear]) IN ('O')
							  AND (UPPER(C.iris_rec) = 'YES')
							  AND (C.batchnumber IS NULL)
							  AND (DATEDIFF(mi, C.crimenteredtime, GETDATE()) >= 1)
							  AND (IR.r_delivery) = @deliverymethod) 
			else
				Insert into #tmp
						(crimid,vendorid,cnty_no)
							SELECT C.crimid,c.vendorid,c.cnty_no 
							FROM appl A (NOLOCK)
							INNER JOIN crim C(NOLOCK) ON A.apno = C.apno
							INNER JOIN iris_researchers IR(NOLOCK) ON C.vendorid = IR.r_id
							INNER JOIN dbo.ApplAlias_Sections AS S (NOLOCK) ON S.SectionKeyID = C.CrimID AND S.ApplSectionID = 5 AND S.IsActive = 1 AND S.CreatedBy = 'AutoOrdr'
							WHERE (UPPER(A.apstatus) IN ('P','W'))
							  AND ((A.inuse IS NULL) OR (A.inuse = 'ChkAlias'))
							  AND (C.readytosend = 1)
							  AND (UPPER(C.[clear]) IN ('R','E')
							  AND (UPPER(C.iris_rec) = 'YES')
							  AND (C.batchnumber IS NULL)
							  AND (DATEDIFF(mi, C.crimenteredtime, GETDATE()) >= 1)
							  AND case when @deliverymethod = 'OnlineDB' then  	(isnull(IR.password,'') ) else 'Dummy' end <> ''
							  AND (IR.r_delivery) = @deliverymethod)

	Print '3 - temp table' 
	Select * from #tmp
 
		--update temp table with new batchnumbers
		DECLARE @vendorid int,@cnty_no int
		DECLARE Batch_Cursor CURSOR FOR
		SELECT distinct vendorid,cnty_no
		FROM #tmp
		OPEN Batch_Cursor;
		FETCH NEXT FROM Batch_Cursor INTO @vendorid,@cnty_no;
		WHILE @@FETCH_STATUS = 0
		   BEGIN
				
				Execute Iris_BatchPrint @BatchPrintNumber out;
				Execute iris_crimnumber @CrimControlNumber out;
				Update #tmp set bnum = @BatchPrintNumber,cnum = @CrimControlNumber WHERE vendorid = @vendorid and cnty_no = @cnty_no;
				Print '44 - select' 
				Select @BatchPrintNumber, @CrimControlNumber , @vendorid , @cnty_no

				FETCH NEXT FROM Batch_Cursor INTO @vendorid,@cnty_no;

		   END
		CLOSE Batch_Cursor;
		DEALLOCATE Batch_Cursor;

	Print '4 - temp table' 
	Select * from #tmp
		
		--update records from temp table
			UPDATE crim 
			SET [clear] = case when deliverymethod = 'Integration'  then 'M' else  'O' end,
				[Ordered] = case when deliverymethod = 'Integration'  then null else @OrderDate end,
				[batchnumber] = tmp.cnum,  --(select cnum from #tmp where crimid = cc.crimid),
				[status]= tmp.bnum,  --(select bnum from #tmp where crimid = cc.crimid),
				[IrisFlag] = 1,
				[IrisOrdered]=getdate()
			from crim cc  
			join #tmp tmp on cc.crimid = tmp.crimid
			--WHERE cc.crimid IN (SELECT crimid FROM #tmp);

	Print '5 - crim table' 
	Select crimid,clear,[batchnumber],[IrisOrdered] from crim (nolock)  WHERE crimid IN (SELECT crimid FROM #tmp);


--Add Sent Aliases to Private notes
		DECLARE @crimid int;
		DECLARE Batch_Cursor CURSOR FOR
		SELECT crimid
		FROM #tmp(nolock)
		OPEN Batch_Cursor;
		FETCH NEXT FROM Batch_Cursor into @crimid;
		WHILE @@FETCH_STATUS = 0
		   BEGIN	
			EXEC [dbo].[Crim_AddSentAliastoPrivNotes]  @crimid, @investigator
			FETCH NEXT FROM Batch_Cursor INTO @crimid;
		   END
		CLOSE Batch_Cursor;
		DEALLOCATE Batch_Cursor;


DROP TABLE #tmp;
	
	END
-- only do this for Email,Fax and Webservice
Else
	
Begin

--below update statements are used to update winservice errors to resend again.
	Print '6 - Crim_ResendLog table' 
	INSERT INTO [dbo].[Crim_ResendLog]
			   ([CrimID]
			   ,[Apno]
			   ,[CreateDate])
	   (SELECT CrimID,apno, GETDATE()
	    FROM Crim as c(NOLOCK)
		INNER JOIN dbo.ApplAlias_Sections AS S (NOLOCK) ON S.SectionKeyID = C.CrimID AND S.ApplSectionID = 5 AND S.IsActive = 1 AND S.CreatedBy = 'AutoOrdr'
	    WHERE (IsHidden = 0) 
		  AND (Clear = 'e'))

   -- Deepak:11/03/2020 --> Resetting (InUseByIntegration, Ordered) column for the service to pick it up in next run.
	update dbo.Crim
		set readytosend = 1,
			batchnumber = Null,
			InUseByIntegration = NULL,
			Ordered = NULL
	WHERE (IsHidden = 0) AND (Clear = 'e')

	CREATE TABLE #tmp2(crimid int)
	Insert into #tmp2(crimid)
	SELECT DISTINCT C.crimid 
	FROM appl A (nolock)
    INNER JOIN crim C(nolock) ON A.apno = C.apno
    INNER JOIN iris_researchers IR(nolock) ON C.vendorid = IR.r_id
	INNER JOIN dbo.ApplAlias_Sections AS S (NOLOCK) ON S.SectionKeyID = C.CrimID AND S.ApplSectionID = 5 AND S.IsActive = 1 AND S.CreatedBy = 'AutoOrdr'
    WHERE (UPPER(A.apstatus) IN ('P','W'))
	  AND ((A.inuse IS NULL) OR (A.inuse = 'ChkAlias'))
	  AND (C.readytosend = 1)
	  AND (UPPER(C.[clear]) IN ('R','E'))
	  AND (UPPER(C.iris_rec) = 'YES')
	  AND (C.batchnumber IS NULL)
	  AND (DATEDIFF(mi, C.crimenteredtime, GETDATE()) >= 1)
	  AND (UPPER(IR.r_delivery) = UPPER(@deliverymethod));

   Print '7 - Crim_AddSentAliastoPrivNotes' 
   --Set Clear = 'M' and update the private notes with the sent aliases
		DECLARE Batch_Cursor CURSOR FOR
		SELECT crimid
		FROM #tmp2(nolock)
		OPEN Batch_Cursor;
		FETCH NEXT FROM Batch_Cursor into @crimid;
		WHILE @@FETCH_STATUS = 0
		   BEGIN	
		    UPDATE crim SET [clear] = 'M' WHERE crimid = @crimid

			IF (@deliverymethod != 'WEB SERVICE')
			BEGIN
				EXEC [dbo].[Crim_AddSentAliastoPrivNotes]  @crimid, @investigator
			END
			FETCH NEXT FROM Batch_Cursor INTO @crimid;
		   END
		CLOSE Batch_Cursor;
		DEALLOCATE Batch_Cursor; 
   
	DROP TABLE #tmp2;

	Print '99 - crim table' 
        SELECT C.crimid,clear,[batchnumber],[IrisOrdered]  
		FROM appl A(nolock) 
        INNER JOIN crim C(nolock) ON A.apno = C.apno
        INNER JOIN iris_researchers IR(nolock) ON C.vendorid = IR.r_id
		INNER JOIN dbo.ApplAlias_Sections AS S (NOLOCK) ON S.SectionKeyID = C.CrimID AND S.ApplSectionID = 5 AND S.IsActive = 1 AND S.CreatedBy = 'AutoOrdr'
		WHERE (UPPER(A.apstatus) IN ('P','W'))
		  AND ((A.inuse IS NULL) OR (A.inuse = 'ChkAlias'))
		  AND (C.readytosend = 1)
		  AND (UPPER(C.[clear]) IN ('R','E'))
		  AND (UPPER(C.iris_rec) = 'YES')
		  AND (C.batchnumber IS NULL)
		  AND (DATEDIFF(mi, C.crimenteredtime, GETDATE()) >= 1)
		  AND (UPPER(IR.r_delivery) = UPPER(@deliverymethod));

end

	--Temp update statement added by schapyala 03/05/2014 - to avoid orders being placed with no names. 
	--Making sure that the base name is sent when no aliases are checked.
	IF (@deliverymethod = 'WEB SERVICE') --added by schapyala on 03/24/17 - handled through ApplAlias_sections table for all other delivery methods except integrations
	BEGIN
		INSERT INTO [dbo].[Crim_NoNameOrder_Log]
				   ([crimID]
				   ,[APNO]
				   ,[txtlast]
				   ,[txtalias]
				   ,[txtalias2]
				   ,[txtalia3]
				   ,[txtalias4]
				   ,[LastUpdate])
		select [crimID]
				   ,[APNO]
				   ,[txtlast]
				   ,[txtalias]
				   ,[txtalias2]
				   ,[txtalias3]
				   ,[txtalias4]
				   ,getdate() 
		from crim  (NOLOCK)
		Where txtalias = 0 and txtalias2= 0 and txtalias3 = 0 and txtalias4= 0 and txtlast=0
		and ishidden =0 
		and [Clear] = 'O'

		Update dbo.Crim 
		Set txtlast = 1
		Where txtalias = 0 and txtalias2= 0 and txtalias3 = 0 and txtalias4= 0 and txtlast=0
		and ishidden =0 
		and [Clear] = 'O'
	END

	INSERT INTO CRIMSENDLOG
	(DeliveryMethod,status,logdate,linkid)
	VALUES
	(@deliverymethod,'END',getdate(),@LINKID)
	
	SET NOCOUNT OFF
End