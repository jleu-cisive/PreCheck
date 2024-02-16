

CREATE procedure [dbo].[Integration_OrderMgmt_UpdateOrderRequestByRequestId]    
    
(@requestId int,        
 @docRetrieval varchar(30),        
 @ApNo int,        
 @TrackingNum varchar(30),        
 @ClientAppNo varchar(30) = null,                                                       
 @requestUserActionId int,        
 @orderAck bit ,        
 @orderAckDate datetime = null,         
  @request varchar(max) = null,   
 @xrequest xml = null,   
 @parentRequestId int = null ,
 @recruiterEmail varchar(100) = null
)    
    
     
    
AS    
    
IF @orderAck is null    
 Select @orderAck = Case When isnull(URL_CallBack_Acknowledge,'') = '' then 0 else 1 end    
 From  dbo.Integration_OrderMgmt_Request ord left join ClientConfig_Integration Config     
 ON    Ord.CLNO = Config.CLNO    
 Where RequestID = @requestId    
    


 update dbo.Integration_OrderMgmt_Request    
 set     
  Partner_Reference = COALESCE(@ClientAppNo,Partner_Reference),    
  Partner_Tracking_Number = COALESCE(@TrackingNUm,Partner_Tracking_Number),    
  DocRetriever_Reference = COALESCE(@docRetrieval,DocRetriever_Reference),    
  refUserActionID = COALESCE(@requestUserActionId,refUserActionID),    
  APNO = COALESCE(@ApNo,Apno),    
  Process_Callback_Acknowledge = COALESCE(@orderAck,Process_Callback_Acknowledge),    
  Callback_Acknowledge_Date = COALESCE(@orderAckDate,Callback_Acknowledge_Date),    
  Request = COALESCE(@request,request),
  TransformedRequest = COALESCE(@xrequest,TransformedRequest),
  ParentRequestID = COALESCE(@parentRequestid,ParentRequestID),  
  UserName =  COALESCE(@recruiterEmail,UserName)  ,
  FacilityCLNO=case when clno=7519 then NULL ELSE FacilityCLNO end
 where    
  RequestID = @requestId    


