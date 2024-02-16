


------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------
CREATE PROCEDURE [dbo].[sp_StudentCheck_CreditCardTransaction_WithAPNO]
(
@AppNum Int = null,
@CCNO nvarchar(50),
@CCTYPE varchar(20)= '',
@Name varchar(50)= '',
@TransuserIP varchar(50)= null,
@TransType char(1)= '',
@TransRef varchar(50)= '',
@AuthCode varchar(50)= '',
@TransResponseCode INT = null,
@TransResponse  varchar(100)= null,
@TransAmount money,
@ZipAuth  char(1),
@CVVAuth  char(1),
@Comment1 varchar(128),
@Comment2 varchar(128), 
@CCTransID INT output)
AS
BEGIN
/*
Unit Name: sp_Log_CreditCardTransaction
Author Name:Santosh
Date of Creation: 04/23/04
Brief Description:This Procedure logs the Credit Card Authorization into the "CCTransactionLog" Table.
OUTPUT values :
Date Modified:
Details of Modification:
*/
	insert into PreCheck_CCTransactionLog
	 	(APPNUMBER,CCNO,Name,TransactionType,TransREF,TransResponseCode,TransResponseDesc,TransDate,TransAmount,AuthCode,AVSAuth,CSCAuth,CCTYPE,Comment1,Comment2,TransuserIP) 
	values   (@AppNum,@CCNO,@Name,@TransType,@TransRef,@TransResponseCode,@TransResponse,getdate(),@TransAmount,@AuthCode,@ZipAuth,@CVVAuth,@CCTYPE,@Comment1,@Comment2,@TransuserIP)
	SET @CCTransID = @@identity

END



