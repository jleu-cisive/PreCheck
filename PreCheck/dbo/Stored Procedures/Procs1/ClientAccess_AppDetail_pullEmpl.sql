
-- =============================================
-- Author:		Kiran Miryala
-- Create date: 07-22-2008
-- Description:	 Pulls Employement Details for the client in Check Reports
-- =============================================
CREATE PROCEDURE [dbo].[ClientAccess_AppDetail_pullEmpl]
@emplid int 
AS
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT 
Rel_Cond_Stat.Rel_description AS Reldesc,
 Empl_Type_Stat.emp_description AS Empdesc,
 Employer,location,dept,from_a,to_A,from_v,to_v,position_a,position_v,ver_by, Title,pub_notes,empl_rehire_stat.[Description] Rehire
FROM dbo.Empl 
left join dbo.rel_cond_stat on empl.rel_cond = rel_cond_stat.rel_cond 
left join dbo.empl_type_stat on empl.emp_type = empl_type_stat.emp_type 
left join dbo.empl_rehire_stat on empl.Rehire = empl_rehire_stat.Rehire
where emplid = @emplid



SET TRANSACTION ISOLATION LEVEL READ COMMITTED
SET NOCOUNT OFF

SET ANSI_NULLS ON
