-- =============================================
-- Author:		Doug DeGenaro
-- Create date: 07/23/2012
-- Description:	Once an order is submitted in reference pro, we update the sectionid and orderid field from the acknowledgment
-- =============================================

-- =============================================
-- Author:		Doug DeGenaro

-- Updated date: 08/23/2012
-- Description:	Adding a message parameter to add to the priv_notes, so the investigator can get some clarity on what happened
-- Description:	Changed the getdate() to CURRENT_TIMESTAMP
-- Description:	Removed dynamic sql as it is not needed, and compiled will run faster 

-- Updated date: 02/05/2014
-- Description: set @message to default to null, was causing problems

-- Updated date: 02/05/2014
---Description: Added an IsNull condition for @message, now that it can be null
-- =============================================

--dbo.Verification_UpdateOrderIdBySection_New @tablename = 'Empl',@sectionId = 483941,@orderId = 'RP1234',@messageFlagSet = 1,@web_status = 64,@message = 'Your current order was cancelled.'
CREATE PROCEDURE [dbo].[Verification_UpdateOrderIdBySection](@tablename varchar(100),@sectionId varchar(50),@orderId varchar(50) = null,@messageFlagSet bit,@web_status int = null,@message varchar(max) = null)        
AS         
DECLARE @sql varchar(8000)  
DECLARE @currentdate datetime
Declare @sectstat char

set @sectstat = '9'	
SET @currentdate = CURRENT_TIMESTAMP

IF (@tablename = 'Employment')
BEGIN
	-- if the flag is set, we had a succesful submit, if it is not set we need to update the private notes with that message	
	IF (@messageFlagSet = 0)

	--IF (@orderId is not null) 
		BEGIN												
			UPDATE dbo.Empl 
			SET 
				OrderId = @orderId,
				DateOrdered = @currentdate,
				Web_Status = @web_status,
				SectStat = @sectstat
			WHERE EmplId = @sectionId				
		END    
	ELSE -- we will set the section to a new web_status that will make sure that it wont be picked up again, and will show up with that status in the modules.
		BEGIN
			UPDATE dbo.Empl 
			SET 
				--OrderId = null,
				OrderId = @orderId,
				DateOrdered = @currentdate,
				Web_Status = @web_status,
				Priv_Notes = IsNull(@message,'') + char(10) + char(13) + IsNull(cast(Priv_Notes as varchar(max)),'') 
			WHERE EmplId = @sectionId	
		END
END   


if (@tablename = 'Education')
BEGIN
	set @sectstat = '9'
	set @web_status = 0
	IF (@messageFlagSet = 0)
	--IF (@orderId is not null) 
		BEGIN			
			
			UPDATE dbo.Educat 
			SET 
				OrderId = @orderId,
				DateOrdered = @currentdate,
				Web_Status = @web_status,
				SectStat = @sectstat		
			WHERE EducatId = @sectionId		
		END    
	ELSE -- we will set the section to a new web_status that will make sure that it wont be picked up again, and will show up with that status in the modules.
		BEGIN
			UPDATE dbo.Educat 
			SET 
				OrderId = null,
				DateOrdered = @currentdate,
				--Web_Status = @web_status,
				Priv_Notes = @message + char(10) + char(13) + IsNull(cast(Priv_Notes as varchar(max)),'') 
			WHERE EducatId = @sectionId	
		END
END 

--logging
INSERT into dbo.ReferenceProLog(sectionId,apno,Data,LogDate)
		SELECT 
			@sectionId,
			0,
			'[Updated] Section:' + @tableName + '; message flag set:' + cast(@messageFlagSet as varchar(10)) + '; webstatus:' + cast(@web_status as varchar(20)) + '; dateOrdered:' + cast(@currentdate as varchar(20)) +  '; orderid:' + IsNull(@orderId,'null') + '; Message:' + IsNull(@message,'null') 
			,CURRENT_TIMESTAMP