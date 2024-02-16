-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================

--[ClientContactsBasedOnCLNO] '3668'

CREATE PROCEDURE [dbo].[ClientContactsBasedOnCLNO]
	 @CLNO int

AS
BEGIN	
	If @CLNO <> ''
	 --select CLNO, FirstName, LastName, Phone, Email from clientContacts where CLNO in(@CLNO)
	 select CLNO, FirstName, LastName, Phone, Email from clientContacts where CLNO in(@CLNO)
                                                                                            
END
