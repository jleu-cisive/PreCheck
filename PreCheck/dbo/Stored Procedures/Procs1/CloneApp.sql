
CREATE PROCEDURE [dbo].[CloneApp]
(
	@APNO int,@username varchar(10), @ret_apno int output
)
AS
SET NOCOUNT ON

--DECLARE @ret_apno int

--INSERT INTO dbo.Appl ( [ApStatus], [UserID], [Billed], [Investigator], [EnteredBy], [EnteredVia], [ApDate], [CompDate], [CLNO], [Attn]
--	, [Last], [First], [Middle], [Alias], [Alias2], [Alias3], [Alias4], [SSN], [DOB], [Sex], [DL_State], [DL_Number], [Addr_Num], [Addr_Dir]
--	, [Addr_Street], [Addr_StType], [Addr_Apt], [City], [State], [Zip], [Pos_Sought], [Update_Billing], [Priv_Notes], [Pub_Notes], [PC_Time_Stamp]
--	, [Pc_Time_Out], [Special_instructions], [Reason], [ReopenDate], [OrigCompDate], [Generation], [Alias1_Last], [Alias1_First], [Alias1_Middle]
--	, [Alias1_Generation], [Alias2_Last], [Alias2_First], [Alias2_Middle], [Alias2_Generation], [Alias3_Last], [Alias3_First], [Alias3_Middle]
--	, [Alias3_Generation], [Alias4_Last], [Alias4_First], [Alias4_Middle], [Alias4_Generation], [PrecheckChallenge], [InUse], [ClientAPNO]
--	, [ClientApplicantNO], [Last_Updated], [DeptCode], [NeedsReview], [StartDate], [RecruiterID], [Phone], [Rush], [IsAutoPrinted], [AutoPrintedDate]
--	, [IsAutoSent], [AutoSentDate], [PackageID], [Rel_Attached], [CreatedDate], [ClientProgramID], [I94])
--SELECT  'P' AS [ApStatus], null As [UserID], 0 As [Billed], NULL AS [Investigator], [EnteredBy], [EnteredVia], getdate(), null As [CompDate], [CLNO], [Attn]
--	, [Last], [First], [Middle], [Alias], [Alias2], [Alias3], [Alias4], [SSN], [DOB], [Sex], [DL_State], [DL_Number], [Addr_Num], [Addr_Dir]
--	, [Addr_Street], [Addr_StType], [Addr_Apt], [City], [State], [Zip], [Pos_Sought], [Update_Billing], [Priv_Notes], [Pub_Notes], [PC_Time_Stamp]
--	, [Pc_Time_Out], [Special_instructions], [Reason], null As [ReopenDate], null As [OrigCompDate], [Generation], [Alias1_Last], [Alias1_First], [Alias1_Middle]
--	, [Alias1_Generation], [Alias2_Last], [Alias2_First], [Alias2_Middle], [Alias2_Generation], [Alias3_Last], [Alias3_First], [Alias3_Middle]
--	, [Alias3_Generation], [Alias4_Last], [Alias4_First], [Alias4_Middle], [Alias4_Generation], [PrecheckChallenge], [InUse], [ClientAPNO]
--	, [ClientApplicantNO], getdate() As [Last_Updated], [DeptCode], 'R1' AS [NeedsReview], [StartDate], [RecruiterID], [Phone], 0 As [Rush], 0 As [IsAutoPrinted]
--	, [AutoPrintedDate], 0 As [IsAutoSent], [AutoSentDate], [PackageID], [Rel_Attached], getdate(), [ClientProgramID], [I94]   
--FROM dbo.Appl 
--WHERE APNO = @APNO

--SELECT @@IDENTITY

	INSERT INTO dbo.Appl ( [ApStatus], [UserID], [Billed], [Investigator], [EnteredBy], [EnteredVia], [ApDate], [CompDate], [CLNO], [Attn]
		, [Last], [First], [Middle], [Alias], [Alias2], [Alias3], [Alias4], [SSN], [DOB], [Sex], [DL_State], [DL_Number], [Addr_Num], [Addr_Dir]
		, [Addr_Street], [Addr_StType], [Addr_Apt], [City], [State], [Zip], [Pos_Sought], [Update_Billing], [Priv_Notes], [Pub_Notes], [PC_Time_Stamp]
		, [Pc_Time_Out], [Special_instructions], [Reason], [ReopenDate], [OrigCompDate], [Generation], [Alias1_Last], [Alias1_First], [Alias1_Middle]
		, [Alias1_Generation], [Alias2_Last], [Alias2_First], [Alias2_Middle], [Alias2_Generation], [Alias3_Last], [Alias3_First], [Alias3_Middle]
		, [Alias3_Generation], [Alias4_Last], [Alias4_First], [Alias4_Middle], [Alias4_Generation], [PrecheckChallenge], [InUse], [ClientAPNO]
		, [ClientApplicantNO], [Last_Updated], [DeptCode], [NeedsReview], [StartDate], [RecruiterID], [Phone], [Rush], [IsAutoPrinted], [AutoPrintedDate]
		, [IsAutoSent], [AutoSentDate], [PackageID], [Rel_Attached], [CreatedDate], [ClientProgramID], [I94])
	SELECT  'P' AS [ApStatus], null As [UserID], 0 As [Billed], NULL AS [Investigator], [EnteredBy], [EnteredVia], getdate(), null As [CompDate], [CLNO], [Attn]
		, [Last], [First], [Middle], [Alias], [Alias2], [Alias3], [Alias4], [SSN], [DOB], [Sex], [DL_State], [DL_Number], [Addr_Num], [Addr_Dir]
		, [Addr_Street], [Addr_StType], [Addr_Apt], [City], [State], [Zip], [Pos_Sought], [Update_Billing], [Priv_Notes], [Pub_Notes], [PC_Time_Stamp]
		, [Pc_Time_Out], [Special_instructions], [Reason], null As [ReopenDate], null As [OrigCompDate], [Generation], [Alias1_Last], [Alias1_First], [Alias1_Middle]
		, [Alias1_Generation], [Alias2_Last], [Alias2_First], [Alias2_Middle], [Alias2_Generation], [Alias3_Last], [Alias3_First], [Alias3_Middle]
		, [Alias3_Generation], [Alias4_Last], [Alias4_First], [Alias4_Middle], [Alias4_Generation], [PrecheckChallenge], [InUse], [ClientAPNO]
		, [ClientApplicantNO], getdate() As [Last_Updated], [DeptCode], 'R1' AS [NeedsReview], [StartDate], [RecruiterID], [Phone], 0 As [Rush], 0 As [IsAutoPrinted]
		, [AutoPrintedDate], 0 As [IsAutoSent], [AutoSentDate], [PackageID], [Rel_Attached], getdate(), [ClientProgramID], [I94]   
	FROM dbo.Appl 
	WHERE APNO = @APNO


	set @ret_apno = (SELECT @@IDENTITY)

	-- BEGIN INSERT INTO ApplAlias Table
	-- Deepak Vodethela: 09/18/2019 - Insert Primary Name into ApplAlias Table from the cloned report.

	DECLARE @CLNO INT

	SELECT @CLNO = CLNO FROM dbo.Appl a	WHERE A.APNO = @ret_apno

	-- Joe Monforti - This test account is strictly for QA of our vendors.  
	-- The idea is for the vendor to receive a criminal search as if it was a client requesting. I compare two separate reports data for my evaluation. 
	IF (@CLNO = 12453) 
	BEGIN
		IF ((SELECT COUNT(*) FROM ApplAlias aa(NOLOCK) WHERE aa.APNO = @ret_apno AND aa.IsPrimaryName = 1) = 0)
		BEGIN
			DECLARE @FirstName VARCHAR(20)
			DECLARE @MiddleName VARCHAR(20)	
			DECLARE @LastName VARCHAR(20)
			DECLARE @Generation VARCHAR(3)

			SELECT @FirstName = REPLACE([First], '''', ''), @MiddleName = REPLACE(Middle, '''', ''), @LastName = REPLACE([Last], '''', '') , @Generation = REPLACE(Generation, '''', '') FROM Appl(NOLOCK) WHERE APNO = @ret_apno
			--SELECT @FirstName AS FirstName, @MiddleName AS MiddleName, @LastName AS LastName, @Generation AS Generation

			INSERT INTO [dbo].[ApplAlias]
				([APNO] ,[First] ,[Middle] ,[Last], [IsMaiden], [CreatedDate], [Generation], [AddedBy], [CLNO], [SSN], [IsPrimaryName], [IsActive], [CreatedBy], [LastUpdateDate], [LastUpdatedBy], [IsPublicRecordQualified])
			VALUES
				(@ret_apno, @FirstName, @MiddleName, @LastName, 0, CURRENT_TIMESTAMP, @Generation, 'AliasAutomation', NULL, NULL, 1, 1, 'AliasAutomation', CURRENT_TIMESTAMP, 'AliasAutomation', 1)
		END
	END 
	-- END INSERT INTO ApplAlias Table


	insert into changelog(TableName,ID,oldValue,NewValue,ChangeDate,UserID) values('Appl.CloneApp',@apno,@apno,@ret_apno,getDate(),@username);

	return @ret_apno


SET NOCOUNT OFF
