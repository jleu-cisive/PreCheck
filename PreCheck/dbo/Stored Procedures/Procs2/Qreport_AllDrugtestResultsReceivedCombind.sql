
-- =============================================
-- Author:		Sunil Mandal
-- Create date: 23/06/2022
-- #50770 Create new Qreport for finance 

-- EXEC [dbo].[Qreport_AllDrugtestResultsReceivedCombind] 11625,0,'06/1/2020','06/15/2020',0
-- =============================================
CREATE PROCEDURE [dbo].[Qreport_AllDrugtestResultsReceivedCombind]
	-- Add the parameters for the stored procedure here
	@CLNO int,
	@ParentCLNO int,
	@StartDate DateTime,
	@EndDate DateTime,
	@AffiliateId int
AS
BEGIN
--declare @StartDate Date,@EndDate Date, @CLNO Int,@AffiliateId Int,@ParentCLNO Varchar(max)
	--SET @StartDate = '06/1/2020';
	--SET @EndDate = '06/15/2020';
	--SET @CLNO = '11625';
	--SET @AffiliateId = 0;
	--SET @ParentCLNO = 0;

	IF OBJECT_ID('tempdb..#HCAPS_TAT') IS NOT NULL
	BEGIN
		DROP Table #HCAPS_TAT
	END

					Create Table #HCAPS_TAT
					(
					ClientID Int,
					[Client Name] Varchar(Max),
					AffiliateID	Int,
					Affiliate Varchar(Max),	
					[First Name] Varchar(Max),	
					[Last Name]	Varchar(Max),
					[Report Number]	Bigint,
					[Online Release Date]	Date,
					[Created Date]	Date,
					[TAT Days]	Int,
					[Completed Date] Date,	
					[Report Status]	Varchar(Max),
					[Process Level] Varchar(Max)
					)

	Insert Into #HCAPS_TAT exec dbo.HCAPS_TAT @CLNO,@StartDate,@EndDate,@AffiliateId;

	IF OBJECT_ID('tempdb..#DrugTestDetails_DateRange') IS NOT NULL
	BEGIN
		DROP Table #DrugTestDetails_DateRange
	END

					Create Table #DrugTestDetails_DateRange
					(
					OCHS_CandidateInfoID Int,
					[Client ID] Int,
					[Client Name] Varchar(Max),
					Affiliate Varchar(Max),
					OCHS_TransactionID Int,
					LastName Varchar(Max),
					FirstName Varchar(Max),
					Middle Varchar(Max),
					Email NVarchar(Max),
					TestReason Varchar(Max),
					CostCenter Varchar(Max),
					ClientIdent Varchar(Max),
					CreatedDate	Date,
					Location Varchar(Max),
					ProdCat Varchar(Max),
					ProdClass Varchar(Max),
					SpecType Varchar(Max),
					Customer bigint,
					[Requested By] Varchar(Max),
					)


	Insert Into #DrugTestDetails_DateRange exec dbo.[DrugTestDetails_DateRange_Doug] @StartDate,@EndDate,@CLNO,@ParentCLNO

IF OBJECT_ID('tempdb..#Qreport_AllDrugtestResultsReceived') IS NOT NULL
	BEGIN
		DROP Table #Qreport_AllDrugtestResultsReceived
	END

					Create Table #Qreport_AllDrugtestResultsReceived
					(
					CLNO Int,
					OrderNumber	nVarchar(Max),
					[Client Name] Varchar(Max),
					ParentCLNO Varchar(Max),
					[Transaction ID] nVarchar(Max),
					[Chain of Custody] nVarchar(Max),
					[First Name] Varchar(Max),
					[Last Name] Varchar(Max),
					[Order Status] Varchar(Max),
					[Test Result] Varchar(Max),	
					[Last Update Date] date
					)


	Insert Into #Qreport_AllDrugtestResultsReceived EXEC [Qreport_AllDrugtestResultsReceived] @CLNO,@ParentCLNO,@StartDate,@EndDate

		Select QADRR.CLNO,QADRR.OrderNumber,QADRR.[Client Name],QADRR.ParentCLNO,QADRR.[Transaction ID],QADRR.[Chain of Custody],QADRR.[First Name],QADRR.[Last Name],QADRR.[Order Status],QADRR.[Test Result],QADRR.[Last Update Date],
		       HCAPS.ClientID,HCAPS.AffiliateID,HCAPS.Affiliate,HCAPS.[First Name],HCAPS.[Last Name],HCAPS.[Report Number],HCAPS.[Online Release Date],HCAPS.[Created Date],HCAPS.[TAT Days],HCAPS.[Completed Date],HCAPS.[Report Status],HCAPS.[Process Level],
		       DTDDR.OCHS_CandidateInfoID,DTDDR.OCHS_TransactionID,DTDDR.LastName,DTDDR.FirstName,DTDDR.Middle,DTDDR.Email,DTDDR.TestReason,DTDDR.CostCenter,DTDDR.ClientIdent,DTDDR.CreatedDate,DTDDR.[Location],DTDDR.ProdCat,DTDDR.ProdClass,DTDDR.SpecType,DTDDR.Customer,DTDDR.[Requested By]
		from #Qreport_AllDrugtestResultsReceived QADRR
		Left Join #HCAPS_TAT HCAPS On HCAPS.ClientID = QADRR.CLNO
		Left Join #DrugTestDetails_DateRange DTDDR On QADRR.CLNO = DTDDR.[Client ID]

End

Drop table #Qreport_AllDrugtestResultsReceived
Drop Table #HCAPS_TAT 
Drop Table #DrugTestDetails_DateRange



