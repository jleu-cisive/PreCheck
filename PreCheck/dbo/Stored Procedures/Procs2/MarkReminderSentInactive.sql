--====================================================================================================================== 
--Author:        Nazish Rehman
--Create Date:   05-04-2023
--Description:   
--===========================================================================================================================
create proc [dbo].[MarkReminderSentInactive] (@actionid int, @reminderactionid int , @applicantId int, @apno int )
as

 declare @AssociateSubscriptionId int
begin
     select  @AssociateSubscriptionId= AssociateSubscriptionId from enterprise.subscription.associatesubscriptionactionlog with(nolock) where OrderNumber=@apno and DASubscriptionActionTypeID=@actionid
	 if exists(select 1 from  enterprise.subscription.associatesubscriptionactionlog with(nolock) where  DASubscriptionActionTypeID=@reminderactionid and IsActive=0 and IsProcessed=0 and OrderNumber=@apno  )
	           begin

			     update  enterprise.subscription.associatesubscriptionactionlog set ModifyDate= CURRENT_TIMESTAMP where DASubscriptionActionTypeID=@reminderactionid and IsActive=0 and IsProcessed=0 and OrderNumber=@apno
			   end
			   else
			   begin
			     insert into enterprise.subscription.associatesubscriptionactionlog (AssociateSubscriptionId,ApplicantId,DASubscriptionActionTypeID,CreateBy,CreateDate,ModifyBy,ModifyDate,IsActive,IsProcessed,OrderNumber)
				 values (@AssociateSubscriptionId,@applicantId,@reminderactionid,0,CURRENT_TIMESTAMP,0,CURRENT_TIMESTAMP,0,0,@apno)
			   end
  
end
	