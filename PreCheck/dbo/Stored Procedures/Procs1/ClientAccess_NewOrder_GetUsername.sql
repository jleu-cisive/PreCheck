

-- =============================================
-- Author:		Kiran Miryala
-- Create date: 07-23-2008
-- Description:	 Gets users First & LastName, used in New Order
-- =============================================
CREATE PROCEDURE [dbo].[ClientAccess_NewOrder_GetUsername]
@clno int,
@user varchar(14)
AS

Select lastName + ', ' + firstName 
FROM ClientContacts 
WHERE 
CLNO = @clno 
AND 
username = @user

SET ANSI_NULLS ON
