-- =============================================



-- Author:		Douglas DeGenaro



-- Create date: 07/02/2013



-- Description:	When we want to add to the callback table for the onestep



-- =============================================



CREATE PROCEDURE [dbo].[PrecheckFramework_InsertCallbackRequest] 



	-- Add the parameters for the stored procedure here



	@apno int,
	@CLNO int = null,
	@ClientAPNO varchar(50) = null,
	@FacilityCLNO int = null


AS



BEGIN



	-- SET NOCOUNT ON added to prevent extra result sets from



	-- interfering with SELECT statements.

	

	IF @CLNO IS NULL AND @ClientAPNO IS NULL AND @FacilityCLNO IS NULL
		Select @CLNO = CLNO,@ClientAPNO = ClientAPNO from dbo.Appl where apno = @apno

    -- Insert statements for procedure here



	insert into dbo.Integration_PrecheckCallback(CLNO,[APNO],Partner_Reference,Process_Callback_Acknowledge,Callback_Acknowledge_Date,FacilityCLNO)



	values (@CLNO,@APNO,@ClientAPNO,1,null,@FacilityCLNO)	



END
