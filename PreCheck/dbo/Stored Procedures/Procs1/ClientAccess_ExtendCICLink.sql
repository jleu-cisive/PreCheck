
-- =============================================
-- Author:		Arshan Gouri
-- Create date: 01-25-2024
-- Description:	 To extend the CIC link expiration
-- EXEC [ClientAccess_ExtendCICLink] 'C6E3D985-B835-43A1-9B76-00126728F8E8'
-- =============================================
CREATE PROCEDURE [dbo].[ClientAccess_ExtendCICLink]
  @Token uniqueidentifier = NULL
As
 Begin

SET ANSI_NULLS ON


    UPDATE SecureBridge..Token 
    SET ExpireDate = DATEADD(DAY, 10, GETDATE()), IsActive = 1
    WHERE TokenID = @Token;

 END
