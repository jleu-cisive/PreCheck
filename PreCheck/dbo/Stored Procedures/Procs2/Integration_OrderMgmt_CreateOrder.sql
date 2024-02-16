CREATE procedure [dbo].[Integration_OrderMgmt_CreateOrder]

@CLNO int,
@facilityClno int = null,
@partner_tracking varchar(100) = null,
@parnerRef varchar(50),
@Request varchar(max),
--@UserName varchar(50) = null,
@UserName varchar(100) = null,
@needsRelease bit = 1,
@xRequest xml = null,
@ClientCandidateId varchar(100) = null,
@RequestCounter int = null  

as



declare @RequestID int

declare @SSN varchar(20)

declare @DOB datetime


declare @sendOrderInitiate bit
 select @sendOrderInitiate =  ConfigSettings.value('(//SendOrderInitiateFirst)[1]','bit') from dbo.ClientConfig_Integration where CLNO = @CLNO

--Insert into dbo.Integration_OrderMgmt_Request (CLNO,Partner_Reference,Request,UserName)

--values (@CLNO,@parnerRef,@Request,@UserName)

if (@facilityClno is not null)  
 Insert into dbo.Integration_OrderMgmt_Request (CLNO,FacilityCLNO,Partner_Reference,Request,refUserActionID,TransformedRequest,UserName,Partner_Tracking_Number,ClientCandidateId,RequestCounter)  
 values (@CLNO,@facilityClno,@parnerRef,@Request,case when IsNull(@sendOrderInitiate,0) = 1 then 4 else 1 end,@xRequest,@UserName,@partner_tracking,@ClientCandidateId,@RequestCounter)  
else  
 Insert into dbo.Integration_OrderMgmt_Request (CLNO,Partner_Reference,Request,refUserActionID,TransformedRequest,UserName,Partner_Tracking_Number,ClientCandidateId,RequestCounter)  
 values (@CLNO,@parnerRef,@Request,case when IsNull(@sendOrderInitiate,0) = 1 then 4 else 1 end,@xRequest,@UserName,@partner_tracking,@ClientCandidateId,@RequestCounter)



Select @RequestID = SCOPE_IDENTITY()--(select top 1 requestid from  dbo.Integration_OrderMgmt_Request where (facilityClno = IsNull(@facilityClno,@CLNO)  or clno = @clno) and partner_reference = @parnerRef order by RequestDate desc)



if (@needsRelease = 1)

begin

	SELECT TOP 1 @SSN = IsNull(SSN,''),@DOB = IsNull(DOB,'')

		FROM   DBO.ReleaseForm

		WHERE  (CLNO = @CLNO or CLNO = @facilityClno) and

		ClientAppNo = @parnerRef

		ORDER BY [Date] desc

		select @RequestID as RequestID,@SSN as SSN,@DOB as DOB

end

else

	select @RequestID