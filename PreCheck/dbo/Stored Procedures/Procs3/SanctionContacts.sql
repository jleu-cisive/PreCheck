-- =============================================
-- Author:		Prasanna
-- Create date: 05/01/2018
-- Description:	Sanction Contacts - Email Addresses
-- =============================================
CREATE PROCEDURE [dbo].[SanctionContacts]	
AS

	BEGIN
		select cc.CLNO, c.Name, cc.FirstName, cc.MiddleName, cc.LastName, cc.Email, cc.username, cc.UserPassword, cr.RoleID from clientcontacts cc
		inner join client c on cc.CLNO = c.CLNO
		inner join ContactRole cr on cc.ContactID = cr.ContactID where cc.IsActive = 1 and cr.PC_ApplicationID >= 1
	END

