
-- =============================================
-- Author:		Kiran Miryala
-- Create date: 07-22-2008
-- Description:	 Pulls MVR Details for the client in Check Reports
--***************************************************************************
-- Edited by:		Kiran Miryala
-- Update date: 3/29/2012
-- Description:	 addaed the webstatus lookup so any MVR in reasearch status should not be seen by client
-- =============================================
CREATE PROCEDURE [dbo].[ClientAccess_AppDetail_pullMVR]
@apno int 
AS

SELECT report FROM dl where apno = @apno and isnull(web_status,0)  <> 44 -- web status is in research status


