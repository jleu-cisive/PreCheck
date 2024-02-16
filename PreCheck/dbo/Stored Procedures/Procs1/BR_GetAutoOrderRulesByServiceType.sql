-- =============================================
-- Author:		Najma Begum
-- Create date: 05/31/2012
-- Description:	To get Criminal AutoOrdering Biz Rules.
-- =============================================
CREATE PROCEDURE [dbo].[BR_GetAutoOrderRulesByServiceType]
	@ServiceID int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT     dbo.BRAutoOrderRules.KeyName, dbo.BRAutoOrderRules.Operator, dbo.BRAutoOrderRules.Value, dbo.BRAutoOrderRules.Quantifier, dbo.BRRuleTypes.RuleType, 
                      dbo.BRSources.Source, dbo.refBRSourcePriority.Priority,dbo.BRAutoOrderRules.RuleID
FROM         dbo.BRAutoOrderRules INNER JOIN
                      dbo.BRRuleTypes ON dbo.BRAutoOrderRules.RuleTypeID = dbo.BRRuleTypes.TypeID INNER JOIN
                      dbo.refBRSourceAutoOrderRules ON dbo.BRAutoOrderRules.RuleID = dbo.refBRSourceAutoOrderRules.RuleID INNER JOIN
                      dbo.refBRSourcePriority ON dbo.refBRSourceAutoOrderRules.SourcePriorityID = dbo.refBRSourcePriority.RefID INNER JOIN
                      dbo.BRSources ON dbo.refBRSourcePriority.SourceID = dbo.BRSources.SourceID where dbo.refBRSourcePriority.ServiceTypeID = @ServiceID;
                      
                      SELECT dbo.BRSources.SourceID, dbo.BRSources.Source  
FROM         dbo.BRSources INNER JOIN
                      dbo.refBRSourcePriority ON dbo.BRSources.SourceID = dbo.refBRSourcePriority.SourceID where dbo.refBRSourcePriority.ServiceTypeID = @ServiceID order by dbo.refBRSourcePriority.Priority ;
END
