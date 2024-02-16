-- =============================================
-- Author:		Kiran Miryala
-- Create date: 07-22-2008
-- Description:	 Pulls Personal Reference Details for the client in Check Reports
-- =============================================
CREATE PROCEDURE [dbo].[ClientAccess_AppDetail_pullPersRef]
@apno int 
AS



SELECT Name, rel_v, Years_v, pub_notes
FROM persref 
where persrefid = @apno

SET ANSI_NULLS ON
