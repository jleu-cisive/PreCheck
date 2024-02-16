


CREATE PROCEDURE [dbo].[DeleteSection] 
	-- Add the parameters for the stored procedure here
	(@tablename varchar(25),@id int,@username varchar(8),@reptype char(1) = 'Z')
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF @tablename = 'Crim'
		BEGIN
			Insert into Precheck_Archive.dbo.Crim_Deleted 
		  select CRIMID,[APNO]
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
		  ,[tobeworked]
		  ,[readytosend]
		  ,[NoteToVendor]
		  ,[test]
		  ,[InUse]
		  ,[parentCrimID]
		  ,[IrisFlag]
		  ,[IrisOrdered]
		  ,[Temporary]
		  ,[CreatedDate]
		  ,[IsCAMReview]
		  ,[IsHidden]
		  ,[IsHistoryRecord]
		  ,[AliasParentCrimID]
		  ,[InUseByIntegration]
		  ,[ClientAdjudicationStatus]
		  ,@username,getdate() from Crim where crimid = @id;
			DELETE from Iris_ws_screening where crim_Id =@id;
			DELETE from iris_ws_order where applicant_id = (select apno from crim where crimid = @id);
			DELETE FROM ApplAdjudicationAuditTrail where applsectionid = (select applsectionid from applsections where section = 'Crim')
			and sectionid = @id;
			Delete from Crim where crimid = @id;
		END
	ELSE IF @tablename = 'Empl'
		BEGIN
			--Insert into Precheck_Archive.dbo.Empl_Deleted select *,@username,getdate() from Empl where emplid = @id;
			--Delete from Empl where emplid = @id;
             Update Empl set IsOnReport = 0 where emplid = @id;
		END
	ELSE IF @tablename = 'Educat'
		BEGIN
			--Insert into Precheck_Archive.dbo.Educat_Deleted select *,@username,getdate() from Educat where educatid = @id;
			--Delete from Educat where educatid = @id;
             Update Educat set IsOnReport = 0 where educatid = @id;
		END
	ELSE IF @tablename = 'PersRef'
		BEGIN
			--Insert into Precheck_Archive.dbo.PersRef_Deleted select *,@username,getdate() from PersRef where PersRefid = @id;
			--Delete from PersRef where PersRefid = @id;
            Update PersRef set IsOnReport = 0 where PersRefid = @id;
		END
	ELSE IF @tablename = 'ProfLic'
		BEGIN
			--Insert into Precheck_Archive.dbo.ProfLic_Deleted select *,@username,getdate() from ProfLic where ProfLicid = @id;
			--Delete from ProfLic where ProfLicid = @id;
            Update ProfLic set IsOnReport = 0 where ProfLicid = @id;
		END
	ELSE IF @tablename = 'Credit'
		BEGIN
			Insert into Precheck_Archive.dbo.Credit_Deleted 
			select [APNO]
			  ,[Vendor]
			  ,[RepType]
			  ,[Qued]
			  ,[Pulled]
			  ,[SectStat]
			  ,[Report]
			  ,[Last_Updated]
			  ,[InUse]
			  ,[CreatedDate]
			  ,[IsHidden]
			  ,[IsCAMReview]
			  ,[ClientAdjudicationStatus],@username,getdate() from Credit where apno = @id and reptype = @reptype;
			DELETE FROM ApplAdjudicationAuditTrail where applsectionid = (select applsectionid from applsections where section = 'Credit')
			and sectionid = @id and apno = @id;
			Delete from Credit where apno = @id and reptype = @reptype;
		END

	ELSE IF @tablename = 'MedInteg'
		BEGIN
			Insert into Precheck_Archive.dbo.MedInteg_Deleted 
			select [APNO]
			  ,[SectStat]
			  ,[Report]
			  ,[Last_Updated]
			  ,[InUse]
			  ,[CreatedDate]
			  ,[IsHidden]
			  ,[IsCAMReview]
			  ,[ClientAdjudicationStatus],@username,getdate() from MedInteg where apno = @id;

			DELETE FROM ApplAdjudicationAuditTrail where applsectionid = (select applsectionid from applsections where section = 'MedInteg')
			and sectionid = @id and apno = @id;			
			Delete from MedInteg where apno = @id;
		END
	ELSE IF @tablename = 'DL'
		BEGIN
			Insert into Precheck_Archive.dbo.DL_Deleted 
			--select *,@username,getdate() from DL where apno = @id;
			Select [APNO]
			  ,[Ordered]
			  ,[SectStat]
			  ,[Report]
			  ,[Web_status]
			  ,[Time_in]
			  ,[Last_Updated]
			  ,[InUse]
			  ,[CreatedDate]
			  ,[IsHidden]
			  ,[IsCAMReview]
			  ,[ClientAdjudicationStatus]
			  ,@username,getdate()
			from DL where apno = @id;
			DELETE FROM ApplAdjudicationAuditTrail where applsectionid = (select applsectionid from applsections where section = 'DL')
			and sectionid = @id and apno = @id;	
			Delete from DL where apno = @id;
		END
END


