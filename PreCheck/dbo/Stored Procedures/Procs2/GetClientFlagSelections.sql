



-- ================================================
-- Date: September 9, 2006
-- Author: Santosh Chapyala
--
-- Returns a recordset containing all the Flag Settings for the Client,Section
-- ================================================ 
CREATE PROCEDURE [dbo].[GetClientFlagSelections]
	@CLNO Int,
	@Section Varchar(50) = 'Crim'
AS
SET NOCOUNT ON

IF (Select Count(1) From ClientFlagSelection Where CLNO = @CLNO  And Section = @Section) > 0
	BEGIN
		IF @Section = 'Crim'
			Select CLNO,Section,ClientCrimStatusID,CrimStatusCode StatusCode,CrimStatusDescription StatusDescription,ClientFlag
			 from dbo.ClientFlagSelection CFS inner join clientcrimstatus	CCS on CFS.SectionStatusID = CCS.ClientCrimStatusID
			Where CLNO = @CLNO  And Section = @Section
	END
ELSE
	BEGIN
		IF @Section = 'Crim'
			BEGIN
				Insert Into DBO.ClientFlagSelection (CLNO,Section,SectionStatusID,ClientFlag)
				Select @CLNO,@Section,ClientCrimStatusID,0 
				From clientcrimstatus

				Select @CLNO CLNO,@Section Section,ClientCrimStatusID,CrimStatusCode StatusCode,CrimStatusDescription StatusDescription,0 ClientFlag
				From clientcrimstatus
			END
	END

