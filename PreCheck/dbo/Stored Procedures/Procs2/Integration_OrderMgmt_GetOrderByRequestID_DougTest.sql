	  

	  

	  

	  

	-- =============================================  

	-- Author:  Name  

	-- Create date: January 3,2011  

	-- Description: Get Request by clientid and clientappno  
	--[dbo].[Integration_OrderMgmt_GetOrderByRequestID_DougTest] 727393
	-- =============================================  

	CREATE PROCEDURE [dbo].[Integration_OrderMgmt_GetOrderByRequestID_DougTest]   

	 -- Add the parameters for the stored procedure here  

	 @RequestID int,   

	 @ClientReferenceNumber varchar(50) = null  

	AS  

	BEGIN  

	 --declare @req  varchar(max)  

	 declare @req1 varchar(max)  

	 declare @req2 xml  

	 set @req1 = null  

	 set @req2 = null   

	 -- SET NOCOUNT ON added to prevent extra result sets from  

	 -- interfering with SELECT statements.  

	 SET NOCOUNT ON;  

	 select @req1 = Request,@req2 = TransformedRequest from Integration_OrderMgmt_Request where RequestID = @RequestID order by RequestDate DESC   

	 if (@req2 is null)  

		select top 1 CLNO,@req1 as RawRequest,@req2 as Request,FacilityClno,refUserActionID,1 as NeedsTransform,case when apno = 0 then '' else CONVERT(varchar(20),apno) end as apno  from dbo.Integration_OrderMgmt_Request where RequestID = @RequestID 

	 -- select top 1 CLNO,@req1 as Request,refUserActionID,1 as NeedsTransform,IsNull(Apno,'') as Apno from dbo.Integration_OrderMgmt_Request where RequestID = @RequestID  

	 else  

		select top 1 CLNO,@req1 as RawRequest,@req2 as Request,FacilityClno,refUserActionID,0 as NeedsTransform,case when apno = 0 then '' else CONVERT(varchar(20),apno) end as apno  from dbo.Integration_OrderMgmt_Request where RequestID = @RequestID 

	 -- select top 1 CLNO,@req2 as Request,refUserActionID,0 as NeedsTransform,IsNull(Apno,'') as Apno from dbo.Integration_OrderMgmt_Request where RequestID = @RequestID  	 

		-- Insert statements for procedure here   

		--select top 1 CLNO,@req1 as RawRequest,@req2 as Request,refUserActionID,IsNull(Apno,'') as Apno from dbo.Integration_OrderMgmt_Request where RequestID = @RequestID 

	END  

	  

	  

	  

	 