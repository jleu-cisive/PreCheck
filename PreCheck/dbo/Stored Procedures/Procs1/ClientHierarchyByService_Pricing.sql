-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[ClientHierarchyByService_Pricing] 
@ParentClno int
AS
Begin
 select * from ClientHierarchyByService where parentCLNO = @ParentClno and [refHierarchyServiceID]=3;
End
