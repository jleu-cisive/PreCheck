CREATE FUNCTION GetInvoiceDate (@FirstOfMonth datetime)  
RETURNS datetime AS  
BEGIN 
Declare @StartDate datetime
Declare @EndDate datetime
Declare @InvDate datetime

Set @StartDate =  DATEADD(day, -15, @FirstOfMonth)
Set @EndDate =  DATEADD(day, 15, @FirstOfMonth)

Select @InvDate = InvMaster.InvDate FROM InvMaster WHERE InvDate > @StartDate and InvDate < @EndDate

return @InvDate

END