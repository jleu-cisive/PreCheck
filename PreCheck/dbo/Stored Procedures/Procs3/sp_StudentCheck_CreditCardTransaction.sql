






------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------
CREATE PROCEDURE [dbo].[sp_StudentCheck_CreditCardTransaction]
(	--@AppNum Int,
	@CCNO nvarchar(50)
	, @CCTYPE varchar(20) = ''
	, @Name varchar(50) = ''
	, @TransuserIP varchar(50) = null
	, @TransType char(1) = ''
	, @TransRef varchar(50) = ''
	, @AuthCode varchar(50) = ''
	, @TransResponseCode INT = null
	, @TransResponse  varchar(100) = null
	, @TransAmount money = 0
	, @ZipAuth  char(1)
	, @CVVAuth  char(1)
	, @Comment1 varchar(128)
	, @Comment2 varchar(128)
	, @CCTransID INT output
)
AS
BEGIN
SET NOCOUNT ON
/*
Unit Name: sp_Log_CreditCardTransaction
Author Name:Santosh
Date of Creation: 04/23/04
Brief Description:This Procedure logs the Credit Card Authorization into the "CCTransactionLog" Table.
OUTPUT values :
Date Modified: 09/06/06
Details of Modification: Added SET NOCOUNT ON and added the DBO. tablespace identifier - Schapyala
Date Modified: 11/15/06
Details of Modification: Changed the format of stored procedure to meet guidelines - Trong
Date Modified: 11/27/06
Details of Modification: Added default value for the parameter: @TransRef - Trong
*/

INSERT INTO dbo.Precheck_CCTransactionLog
	(APPNUMBER, CCNO, Name, TransactionType, TransREF, TransResponseCode, TransResponseDesc, TransDate,
	 TransAmount, AuthCode, AVSAuth, CSCAuth, CCTYPE, Comment1, Comment2, TransuserIP)
VALUES 
	(NULL, @CCNO, @Name, @TransType, @TransRef, @TransResponseCode, @TransResponse, getdate(),
	 @TransAmount, @AuthCode, @ZipAuth, @CVVAuth, @CCTYPE, @Comment1, @Comment2, @TransuserIP)

SET @CCTransID = @@IDENTITY

END

SET NOCOUNT OFF





