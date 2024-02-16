


CREATE procedure [dbo].[Integration_GetVerificationXslt](@xslname varchar(30))
as


	Select  XSLTFileData
	From  dbo.XSLFileCache XSLFile 
	Where  XSLName = @xslname


		


