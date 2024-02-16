

--  [Billing_CreateInvoices] '1/31/2014'
-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 01/10/2014
-- Description:	/* Stored procedure Billing_CreateInvoices Copies all the Staging Table (Staging_InvMaster,Staging_InvRegistrar,Staging_InvRegistrarToTal) 
  --             * Data into Original tables and Updates InvDetail, Appl Table and Client Table 
 --              * all these queries are inside a transaction. If an error occurs it will rollback to the original table
 --              * this stored procedure uses a User defined Table valued function named "CSVToTable" */
-- =============================================

CREATE PROCEDURE [dbo].[Billing_CreateInvoices]
	@LastInvDate datetime
	
AS
SET NOCOUNT ON

	BEGIN TRANSACTION tran1

      BEGIN TRY

		SET @LastInvDate = (SELECT DISTINCT InvDate FROM Staging_InvMaster)

	    --STEP 1: Copy the Data from Staging_InvMaster to InvMaster
		INSERT INTO InvMaster(CLNO, InvDate, Printed, Sale, Tax) (SELECT CLNO, InvDate, Printed, Sale, Tax FROM Staging_InvMaster)

		--STEP 2: Update the Staging_InvMaster with the InvoiceNumber from InvMaster as it the Identity column
		UPDATE Staging_InvMaster SET Staging_InvMaster.InvoiceNumber = InvMaster.InvoiceNumber FROM InvMaster WHERE InvMaster.CLNO = Staging_InvMaster.CLNO AND InvMaster.InvDate = Staging_InvMaster.InvDate

		--STEP 3: Update the Staging_InvRegistrar with invoiceNumber from staging_invmaster 
		UPDATE Staging_InvRegistrar SET Staging_InvRegistrar.InvoiceNumber = Staging_InvMaster.InvoiceNumber FROM Staging_InvMaster WHERE Staging_InvMaster.CLNO = Staging_InvRegistrar.CLNO  AND Staging_InvMaster.InvDate = Staging_InvRegistrar.CutOffDate

		--STEP 4: Update InvDetail InvoiceNumber from InvMaster InvoiceNumber
		UPDATE InvDetail SET InvDetail.Billed = 1, InvDetail.InvoiceNumber = Inv.InvoiceNumber FROM Staging_InvMaster Inv Inner JOIN Appl a ON a.CLNO = Inv.CLNO Inner Join InvDetail ON InvDetail.APNO = a.Apno WHERE InvDetID IN (SELECT InvDetID FROM Staging_CreateInvoiceMainPull) AND Inv.InvDate = @LastInvDate

		--STEP 5: Update Appl Billed =1 for all the Apno's provided
	    UPDATE Appl SET Billed = 1 WHERE Apno IN (SELECT DISTINCT APNO FROM Staging_CreateInvoiceMainPull)

		--   UPDATE Appl SET Billed = 1 WHERE Apno IN (select apno from invdetail where type = 0 and apno in (SELECT DISTINCT APNO FROM Staging_CreateInvoiceMainPull) )  -- kiran 7/17/2019  -- make sure to not mark app as billed with out packagebilled


		--STEP 6: Update Client  with CutoffDate and Amounts for all the CLNO's
		UPDATE Client SET LastInvDate = @LastInvDate, Client.LastInvAmount = (Inv.Sale + Inv.Tax) FROM InvMaster Inv WHERE Inv.CLNo = Client.CLNO AND Inv.InvDate = @LastInvDate

		--STEP 7: Insert into InvRegistrar from Staging_InvRegistrar
		INSERT INTO InvRegistrar (RunNumber,InvoiceNumber,CLNO,ClientName,CutOffDate,BillingCycle,Sale,Tax,Locality,Total,CreatedDate)
        (SELECT RunNumber, InvoiceNumber, CLNO, ClientName, CutOffDate, BillingCycle, Sale, Tax, Locality, Total, CreatedDate FROM Staging_InvRegistrar)

		--STEP 8: Insert into InvRegistrarTotal from Staging_InvRegistrarTotal
		INSERT INTO InvRegistrarTotal (RunNumber,InvCount,CutOffDate,BillingCycle,TotalSale,TotalTax,CreatedDate)
        (SELECT RunNumber, InvCount, CutOffDate, BillingCycle, TotalSale, TotalTax, CreatedDate FROM Staging_InvRegistrarTotal)


	--Commit if all steps are successful

    COMMIT TRANSACTION tran1

	  END TRY

   BEGIN CATCH

	--Rollback on error
   ROLLBACK TRANSACTION tran1

   END CATCH
