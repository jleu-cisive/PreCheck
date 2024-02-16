
-- =============================================
-- Author:		Kiran Miryala
-- Create date: 07-22-2008
-- Description:	 Pulls Medicare Integrity Verification Details for the client in Check Reports
-- =============================================
CREATE PROCEDURE [dbo].[ClientAccess_AppDetail_pullMedInteg]
@apno int 
AS

SELECT report FROM medinteg where apno =   @apno

SET ANSI_NULLS ON
