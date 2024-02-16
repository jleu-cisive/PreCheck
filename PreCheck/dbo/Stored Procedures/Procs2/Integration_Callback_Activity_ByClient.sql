--****************************************************************************
--Modified by Prasanna on 07/16/2021 - HDT#11614 change to include both Taleo and Infor callbacks. 
--dbo.Integration_Callback_Activity_ByClient '12/27/2018','12/27/2018',1,1
--****************************************************************************


CREATE procedure [dbo].[Integration_Callback_Activity_ByClient] (@CLNO int = 7519,@DateFrom Date = null,@DateTo Date = null,@IncludeFinaledOnly Bit =1,@RemoveDuplicate Bit = 1) AS
BEGIN
	SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	IF @DateFrom is null or @DateFrom ='1/1/1900'
		Set @DateFrom = cast(Current_TImeStamp as Date)

	Set @DateTo = DateAdd(D,1,@DateFrom)

	IF @RemoveDuplicate = 0
		Select distinct  ic.apno [Report Number],callbackdate [Status Update DateTime],apdate [Report Date],compdate [Latest Report Completion],
		origcompdate [Original Report Completion],first [First Name],last [Last Name] ,DeptCode [Process Level],a.ClientApplicantNO [Taleo Candidate ID],--Right(SSN,4) Last4SSN,		
		Case callbackstatus When 'BCA' then 'Received' else callbackstatus end  [Call Back Status],
		case CallbackCompletedStatus when 0 then 'False' else 'True' end [Callback Success]
		from dbo.Integration_CallbackLogging IC left join dbo.appl a on IC.apno = a.apno
		where (ic.clno =@CLNO OR ic.clno = 15163) and callbackdate between @DateFrom and @DateTo
		 and callbackstatus = (case when @IncludeFinaledOnly = 1 then 'Complete' else callbackstatus end)
		 and callbackdate>= (case when @IncludeFinaledOnly = 1 then origcompdate else callbackdate end)
		 and origcompdate>= @DateFrom
		order by 1,2
	else
		Select distinct  ic.apno [Report Number],apdate [Report Date],compdate [Latest Report Completion],
		origcompdate [Original Report Completion],first [First Name],last [Last Name] ,DeptCode [Process Level],a.ClientApplicantNO [Taleo Candidate ID],--Right(SSN,4) Last4SSN,				
		Case callbackstatus When 'BCA' then 'Received' else callbackstatus end  [Call Back Status]
		from dbo.Integration_CallbackLogging IC left join dbo.appl a on IC.apno = a.apno
		where (ic.clno =@CLNO OR ic.clno = 15163) and callbackdate between @DateFrom and @DateTo
		 and callbackstatus = (case when @IncludeFinaledOnly = 1 then 'Complete' else callbackstatus end)
		 and callbackdate>= (case when @IncludeFinaledOnly = 1 then origcompdate else callbackdate end)
		 and origcompdate>= @DateFrom
		order by 1,2

	
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED
	SET NOCOUNT OFF
END