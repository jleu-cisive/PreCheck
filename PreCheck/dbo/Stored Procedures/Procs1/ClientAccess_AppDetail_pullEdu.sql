
-- =============================================
-- Author:		Kiran Miryala
-- Create date: 07-22-2008
-- Description:	 Pulls Education Details for the client in Check Reports
-- =============================================
CREATE PROCEDURE [dbo].[ClientAccess_AppDetail_pullEdu]
@EDU int 
AS
SET NOCOUNT ON


SELECT School,state,name,degree_a,Degree_V,from_a,to_a,from_V,to_V,studies_a,studies_V,pub_notes
,Contact_Name,Contact_Title,Contact_Date --Added by schapyala on 04/25/2014
FROM dbo.educat (nolock) where educatid =   @EDU

SET NOCOUNT OFF
SET ANSI_NULLS ON

