





CREATE procedure [dbo].[Integration_OrderMgmt_CreateOrder08102019]

@CLNO int,
@facilityClno int = null,
@partner_tracking varchar(100) = null,
@parnerRef varchar(50),

@Request varchar(max),

@UserName varchar(50) = null,

@needsRelease bit = 1,

@xRequest xml = null

as



declare @RequestID int

declare @SSN varchar(20)

declare @DOB datetime



--Insert into dbo.Integration_OrderMgmt_Request (CLNO,Partner_Reference,Request,UserName)

--values (@CLNO,@parnerRef,@Request,@UserName)

if (@facilityClno is not null)
	Insert into dbo.Integration_OrderMgmt_Request (CLNO,FacilityCLNO,Partner_Reference,Request,TransformedRequest,UserName,Partner_Tracking_Number)
	values (@CLNO,@facilityClno,@parnerRef,@Request,@xRequest,@UserName,@partner_tracking)
else
	Insert into dbo.Integration_OrderMgmt_Request (CLNO,Partner_Reference,Request,TransformedRequest,UserName,Partner_Tracking_Number)
	values (@CLNO,@parnerRef,@Request,@xRequest,@UserName,@partner_tracking)



Select @RequestID = (select top 1 requestid from  dbo.Integration_OrderMgmt_Request where (facilityClno = IsNull(@facilityClno,@CLNO)  or clno = @clno) and partner_reference = @parnerRef order by RequestDate desc)



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






