

-- =============================================
-- Author:		Kiran Miryala
-- Create date: 07-21-2008
-- Description:	 Gets Civil Details for the client in Check Reports
-- =============================================
CREATE PROCEDURE [dbo].[ClientAccess_AppDetail_GetCivil]
@apno int 
AS



SELECT apno,civilid,crimsectstat.crimdescription 
FROM Civil 
left outer join crimsectstat on civil.clear = crimsectstat.crimsect 
where 
apno = @apno



SET ANSI_NULLS ON
