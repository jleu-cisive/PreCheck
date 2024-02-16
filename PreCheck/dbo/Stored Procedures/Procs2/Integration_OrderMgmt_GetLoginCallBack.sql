
-- =============================================
-- Author:		Ddegenaro
-- Create date: 11/05/2010
-- Description:	Returns a RequestID, SSN and DOB )
-- =============================================
CREATE procedure [dbo].[Integration_OrderMgmt_GetLoginCallBack]
@CLNO int,
@parnerRef varchar(50),
@Request varchar(max)
as

declare @RequestID int
declare @SSN varchar(20)
declare @DOB datetime

Insert into dbo.Integration_OrderMgmt_Request (CLNO,Partner_Reference,Request)
values (@CLNO,@parnerRef,@Request)

Select @RequestID = SCOPE_IDENTITY() 

SELECT TOP 1 @SSN = IsNull(SSN,''),@DOB = IsNull(DOB,'')
	FROM   DBO.ReleaseForm
	WHERE  CLNO = @CLNO and
	ClientAppNo = @parnerRef
	ORDER BY [Date] desc

select @RequestID as RequestID,@SSN as SSN,@DOB as DOB

