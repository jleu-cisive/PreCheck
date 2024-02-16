
--[CreateStudentCheckReceipt] 2972069
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CreateStudentCheckReceipt] 

@Apno int,
@Email varchar(200),
@Username varchar(50),
@HostIpAddress varchar(50),
@HostDatetime datetime

AS
BEGIN


--Added logging into StudentcheckReceiptLog table for more understanding. Radhika Dereddy on 07/12/2017

INSERT INTO StudentCheck_Receipt_Log(Apno, EmailAddress, UserName, HostIPAddress, HostDateTime, CreatedDate,CreatedBy)
VALUES(@Apno, @Email, @Username, @HostIpAddress, @HostDatetime, CURRENT_TIMESTAMP, 'StudentCheck' )
	
	 -- Added by Radhika Dereddy on 08/06/2015
	Declare @ConfigKey varchar(50)
	SET @ConfigKey = 'Notification_ImmunizationTracking_Initiate'

	SET NOCOUNT ON;

--  select A.APNO,(First+ ' ' + Middle + ' ' +  Last) as Name, ApStatus,A.CreatedDate,A.CLNO,C.Name as school,A.ClientProgramID,CP.Name as program,C.SchoolWillPay,(P.Amount + P.TaxAmount) as TotalAmount
-- 
--
--
--from Appl A
--inner Join Client C on A.CLNO=C.CLNO
--inner Join ClientProgram CP on A.ClientProgramID = CP.ClientProgramID
--inner Join PrecheckServices.dbo.Payment P on A.APNO = P.AppNo
--where APNO = @Apno



	if ((select SchoolWillPay from Client where Clno = (Select Clno from Appl where APNO = @Apno)) =1)
	Begin
			  select A.APNO,(First+ ' ' + isnull(Middle,'') + ' ' +  Last) as Name,
			 ApStatus,A.CreatedDate,
			A.CLNO,
			C.Name as school,
			A.ClientProgramID,CP.Name as program,C.SchoolWillPay, '0' as TotalAmount,isnull(PackageID,0) as PackageID,
			isnull(CC.Value,'False') as 'ImmunizationKey'  -- Added by Radhika Dereddy on 08/06/2015
			from Appl A
			inner Join Client C on A.CLNO=C.CLNO
			inner Join ClientProgram CP on A.ClientProgramID = CP.ClientProgramID
			left join ClientConfiguration CC on A.CLNO = CC.CLNO and CC.ConfigurationKey = @ConfigKey -- Added by Radhika Dereddy on 08/06/2015
			Where APNO = @Apno and a.CLNO <> 3468
			
	End

	else
	Begin
			select A.APNO,(First+ ' ' + isnull(Middle,'') + ' ' +  Last) as Name,
			 ApStatus,A.CreatedDate,
			A.CLNO,
			C.Name as school,
			A.ClientProgramID,CP.Name as program,C.SchoolWillPay,(P.Amount + P.TaxAmount) as TotalAmount,isnull(PackageID,0) as PackageID,
			isnull(CC.Value,'False') as 'ImmunizationKey'  -- Added by Radhika Dereddy on 08/06/2015
			from Appl A
			inner Join Client C on A.CLNO=C.CLNO
			inner Join ClientProgram CP on A.ClientProgramID = CP.ClientProgramID
			inner Join PrecheckServices.dbo.Payment P on A.APNO = P.AppNo
			left join ClientConfiguration CC on A.CLNO = CC.CLNO and CC.ConfigurationKey = @ConfigKey -- Added by Radhika Dereddy on 08/06/2015
			where APNO = @Apno and ApStatus in ('P','F')
			and a.CLNO <> 3468
			
	End


 

END


