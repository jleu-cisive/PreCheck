
CREATE FUNCTION [dbo].[ZipCrim_ReportHasAdditionalInstructions]
	(@apno int)
RETURNS bit
WITH EXECUTE AS CALLER
AS
BEGIN

DECLARE @IsAdditionalServicesOrdered bit = 0
DECLARE @AdditionalInstructionExists bit = 0
DECLARE @HasAdditionalInstructions bit = 1
DECLARE @EnteredVia varchar(8)

SELECT @EnteredVia = ENTEREDVIA FROM APPL (NOLOCK) WHERE APNO = @apno

IF(@EnteredVia = 'CIC' OR @EnteredVia = 'StuWeb')
BEGIN

--CIC/StuWeb

		SELECT @IsAdditionalServicesOrdered = CASE WHEN (CASE WHEN max(Componentname) IS NULL 
			                                                  THEN 0 
															  ELSE count(ComponentName) END)>0 
													THEN cast(1 AS bit) ELSE cast(0 AS bit) end ,
			   @AdditionalInstructionExists = CASE WHEN (CASE WHEN max(Instruction) IS NULL 
			                                                  THEN 0 
															  ELSE count(Instruction) END)>0 
													THEN cast(1 AS bit) ELSE cast(0 AS bit) end
		  FROM Enterprise.DBO.[Order] O (NOLOCK)
    INNER JOIN Enterprise.DBO.OrderService OS (NOLOCK)
	        ON O.OrderId = OS.OrderId
	 LEFT JOIN Enterprise.DBO.OrderServiceComponent OSC (NOLOCK)
	        ON OS.OrderServiceId = OSC.OrderServiceId
	 LEFT JOIN Enterprise.DBO.BusinessServiceComponent BSC (NOLOCK)
	        ON OSC.BusinessServiceComponentId = BSC.BusinessServiceComponentId
	  GROUP BY OrderNumber 
	    HAVING OrderNumber IS NOT null AND OrderNumber = @apno
	
		IF(@IsAdditionalServicesOrdered = 0 AND @AdditionalInstructionExists = 0) 
		  SET @HasAdditionalInstructions = 0
		
END


IF(@EnteredVia = 'XML')
BEGIN

--XML

SELECT @AdditionalInstructionExists =  case when priv_notes like '%ADDITIONAL SERVICES%'  then  cast(1 AS bit) ELSE cast(0 AS bit) end
FROM appl(NOLOCK) 
Where APNO = @apno

 SET @HasAdditionalInstructions = @AdditionalInstructionExists

END
RETURN @HasAdditionalInstructions
END
