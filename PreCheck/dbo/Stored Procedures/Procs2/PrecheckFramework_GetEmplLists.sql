
-- =============================================  
-- Author:  Douglas DeGenaro  
-- Create date: 10/18/2012  
-- Description:   
-- =============================================  
CREATE PROCEDURE [dbo].[PrecheckFramework_GetEmplLists]   
 -- Add the parameters for the stored procedure here  
   
AS  
BEGIN  
 -- SET NOCOUNT ON added to prevent extra result sets from  
 -- interfering with SELECT statements.  
 SET NOCOUNT ON;  
  
      
  
 select Type,[Key],[Value] from  
(SELECT 'EmplType' as Type,cast(Emp_Type as Varchar) as [Key], Emp_Description as [Value] FROM dbo.Empl_Type_Stat --WHERE IsActive = 1 --ORDER BY EmplType  
Union ALL  
SELECT 'EmplRehire' as Type,cast(Rehire as varchar) as [Key], [Description] as [Value] FROM dbo.Empl_Rehire_stat --WHERE IsActive = 1 --ORDER BY EmplRehire  
Union ALL  
SELECT 'EmplRelCond' as Type,cast(Rel_cond as varchar) as [Key], Rel_Description as [Value] FROM dbo.Rel_Cond_Stat-- WHERE IsActive = 1 --ORDER BY EmplRelCond  
Union All  
SELECT 'WebStatus' as Type,cast(code as varchar) as [Key], Description as [Value] FROM dbo.webSectStat  
Union All  
SELECT 'AppStatuses' as Type,cast(code as varchar) as [Key], Description as [Value] FROM dbo.SectStat Where IsActive = 1  
Union All
Select 'CrimStatuses' as Type,crimsect as [Key], crimdescription as [Value] from dbo.CrimSectStat 
Union All
Select 'CrimDegreeType' as Type,refCrimDegree as [Key], Description as [Value] from dbo.refCrimDegree 
)  as ComboLists  
where [Key] is not null  
--Union All  
--SELECT 'VerifyMethod' as ComboBox,VerifyMethodID as [Key], VerifyMethod as [Value] FROM dbo.refVerifyMethod WHERE IsActive = 1 AND (IsAll = 1 OR IsEmpl = 1) --ORDER BY VerifyMethod  
END  
