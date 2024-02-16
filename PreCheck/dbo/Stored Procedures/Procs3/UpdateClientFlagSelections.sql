




-- ================================================
-- Date: September 9, 2006
-- Author: Santosh Chapyala
--
-- Returns a recordset containing all the Flag Settings for the Client,Section
-- ================================================ 
CREATE PROCEDURE [dbo].[UpdateClientFlagSelections]
	@CLNO Int,
	@Section Varchar(50) = 'Crim',
	@SectionStatusID Int ,
	@ClientFlag Bit 
AS
SET NOCOUNT ON

Update ClientFlagSelection Set ClientFlag = @ClientFlag
Where  CLNO = @CLNO and
	   Section = @Section and
	   SectionStatusID = @SectionStatusID


