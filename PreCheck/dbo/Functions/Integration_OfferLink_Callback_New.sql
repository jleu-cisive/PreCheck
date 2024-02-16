-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
--Select * from  DBO.Integration_OfferLink_Callback('12/08/2021','12/09/2021')
CREATE FUNCTION [dbo].[Integration_OfferLink_Callback_New] 
(
	-- Add the parameters for the function here
	@StartDate Date,
	@EndDate Date
)
RETURNS 
@OfferLink_CallbackLog TABLE 
(
	-- Add the column definitions for the TABLE variable here
	 CLNO INT, 
	 Partner_Reference varchar(10), 
	 CallbackDate DateTime,
	 RequestID INT
)
AS
BEGIN
	-- Fill the table variable with the rows for your result set
	Insert into @OfferLink_CallbackLog
	Select CLNO, Partner_Reference, (CallbackDate),
	case when apno is null and CLNO = 7519 then 
				replace(replace(substring(callbackpostrequest.value('(/Envelope/Packet/PacketInfo/PacketId/node())[1]', 'nvarchar(max)'),1,charindex('_',callbackpostrequest.value('(/Envelope/Packet/PacketInfo/PacketId/node())[1]', 'nvarchar(max)'))),'R',''),'_','') 
	else '' 
	end RequestID
	from Integration_CallbackLogging C
	Where CallbackStatus = 'InProgress' and cast(callbackpostrequest as varchar(8000)) like '%Offer Generated%'
	AND cast(CallbackDate as date) > @StartDate and cast(CallbackDate as date) < Dateadd(d,1,@EndDate)
	--group by CLNO, Partner_Reference
	RETURN 
END 