-- Alter Procedure AIMS_GetByJobStatus
-- =============================================
-- Author:		Douglas DeGenaro
-- Create date: 04/22/2014
-- Description:	Show AIMS_Job by Status
-- dbo.AIMS_GetByJobStatus 'Q',null
-- =============================================
CREATE PROCEDURE [dbo].[AIMS_GetByJobStatus] 
	-- Add the parameters for the stored procedure here
	@status varchar(50) = null,
	@section varchar(20) = null	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	select	AIMS_JobID,
			case 
				when j.Section ='Crim' then C.County  
				else j.SectionKeyId end as SectionKeyID,
			AIMS_JobStatus as JobStatus,
			JobStart as StartDate,
			Section,
			va.VendorAccountName as [Source],
			va.VendorAccountId as VendorAccountId,
			JobEnd as EndDate,
			RetryCount,			
			AgentStatus as AgentStatus,
			CreatedDate,
			Last_Updated as [UpdatedDate],
			va.AssemblyFullName as AssemblyName,
			va.AIMSTypeFullName as ClassFullName,
			DataXtract_LoggingId as Id			
	from dbo.AIMS_Jobs j left join dbo.TblCounties c on j.SectionKeyId = cast(c.CNTY_NO as varchar) and j.Section = 'Crim'	
	inner join dbo.VendorAccounts va on j.VendorAccountId = va.VendorAccountId
	where 
		(j.AIMS_JobStatus = coalesce(@status,j.AIMS_JobStatus) and Section = coalesce(@Section,Section))
		order by AIMS_JobStatus,AIMS_JobID desc
END
