

CREATE procedure [dbo].[Integration_OrderMgmt_UpdateOrderRequestByRequestId_09082014]    
    
(@requestId int,    
    
 @docRetrieval varchar(30),    
    
 @ApNo int,    
    
 @TrackingNum varchar(30),    
    
 @ClientAppNo varchar(30),                                                   
    
 @requestUserActionId int,    
    
 @orderAck bit ,    
    
 @orderAckDate datetime = null,    
     
 --@request varchar(max) = null    
 @request varchar(max) = null,   
 @xrequest varchar(max) = null   
    
)    
    
     
    
AS    
    
IF @orderAck is null    
 Select @orderAck = Case When isnull(URL_CallBack_Acknowledge,'') = '' then 0 else 1 end    
 From  dbo.Integration_OrderMgmt_Request ord left join ClientConfig_Integration Config     
 ON    Ord.CLNO = Config.CLNO    
 Where RequestID = @requestId    
    
if (@request is not null)    
 update dbo.Integration_OrderMgmt_Request    
 set     
    Partner_Reference = @ClientAppNo,    
  Partner_Tracking_Number = @TrackingNUm,    
  DocRetriever_Reference = @docRetrieval,    
  refUserActionID = @requestUserActionId,    
  APNO = @ApNo,    
  Process_Callback_Acknowledge = @orderAck,    
  Callback_Acknowledge_Date = @orderAckDate,    
  Request = @request,  
  TransformedRequest = @xrequest    
 where    
  RequestID = @requestId    
else    
 update dbo.Integration_OrderMgmt_Request    
 set     
    Partner_Reference = @ClientAppNo,    
  Partner_Tracking_Number = @TrackingNUm,    
  DocRetriever_Reference = @docRetrieval,    
  refUserActionID = @requestUserActionId,    
  APNO = @ApNo,    
  Process_Callback_Acknowledge = @orderAck,    
  Callback_Acknowledge_Date = @orderAckDate
  , 
  TransformedRequest = @xrequest   
  --Request = @request    
 where    
  RequestID = @requestId 

