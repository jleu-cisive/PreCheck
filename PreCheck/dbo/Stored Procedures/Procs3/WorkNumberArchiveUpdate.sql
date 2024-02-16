-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[WorkNumberArchiveUpdate]
	-- Add the parameters for the stored procedure here
(@SSN varchar(20)           
           ,@EmployerName varchar(255) = null
           ,@EmployerCode varchar(30) = null
           ,@EmployerAddr varchar(100) = null
,@EmployerAddr2 varchar(100) = null
           ,@EmployerState varchar(30) = null
           ,@EmployerCity varchar(30) = null
           ,@EmployerZip varchar(20) = null
           ,@EmployerCountry varchar(30) = null
           ,@EmployeeSSN varchar(20) = null
           ,@EmployeeFirst varchar(30) = null
           ,@EmployeeLast varchar(30) = null
           ,@DateInfo datetime = null
           ,@DateMostRecentHire datetime = null
           ,@DateOriginalHire datetime = null
           ,@MonthsOfService int = null
           ,@DateEndOfEmployment datetime = null
           ,@Position varchar(50) = null
           ,@StatusCode varchar(30) = null
           ,@StatusMessage varchar(150) = null
           ,@UserID varchar(20) = null)

	AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


	Insert Into WorkNumberArchive ([SSN]
           ,[ArchiveDate]
           ,[EmployerName]
           ,[EmployerCode]
           ,[EmployerAddr]
,[EmployerAddr2]
           ,[EmployerState]
           ,[EmployerCity]
           ,[EmployerZip]
           ,[EmployerCountry]
           ,[EmployeeSSN]
           ,[EmployeeFirst]
           ,[EmployeeLast]
           ,[DateInfo]
           ,[DateMostRecentHire]
           ,[DateOriginalHire]
           ,[MonthsOfService]
           ,[DateEndOfEmployment]
           ,[Position]
           ,[StatusCode]
           ,[StatusMessage]
           ,[UserID])
 VALUES(@SSN,getdate()
           ,@EmployerName
           ,@EmployerCode
           ,@EmployerAddr
,@EmployerAddr2
           ,@EmployerState
           ,@EmployerCity
           ,@EmployerZip
           ,@EmployerCountry
           ,@EmployeeSSN
           ,@EmployeeFirst
           ,@EmployeeLast
           ,@DateInfo
           ,@DateMostRecentHire
           ,@DateOriginalHire
           ,@MonthsOfService
           ,@DateEndOfEmployment
           ,@Position
           ,@StatusCode
           ,@StatusMessage
           ,@UserID)
END



