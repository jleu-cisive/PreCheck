

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_get_usersDetails]
 @ContactID	int

	
AS

Select ContactID,FirstName,LastName,MiddleName,Phone,Ext,Email,username,UserPassword,IsActive,ISNULL(ClientRoleID,0) AS ClientRoleID
From ClientContacts
where 
ContactID = @ContactID 
SET ANSI_NULLS ON

