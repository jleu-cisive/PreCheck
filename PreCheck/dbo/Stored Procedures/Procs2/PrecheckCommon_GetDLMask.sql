CREATE procedure [dbo].[PrecheckCommon_GetDLMask](@State varchar(5) = null)  
as   
SET NOCOUNT ON

if (IsNull(@State,'')<> '')  
 select State,RegExMask as mask,DisplayMask as MaskFormat from dbo.DLFormat where State = @State  
else  
 select State,RegExMask as mask,DisplayMask as MaskFormat from dbo.DLFormat 
 
 SET NOCOUNT OFF