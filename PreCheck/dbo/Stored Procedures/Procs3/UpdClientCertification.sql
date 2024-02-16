
CREATE PROCEDURE [dbo].[UpdClientCertification]
-- =============================================
-- Author:		Dongmei He
-- Create date: 09/06/2016
-- Modified Date: 5/4/2017 (Gaurav Bangia)
-- Description:	Update Client Certificate table
-- Modified reason: To handle issue where certification does not exist
-- EXEC UpdClientCertification 168404 , 'Gaurav Bangia', '172.16.16.27', '9/20/2016'
-- =============================================
	@OrderNumber int,
	@RecruiterEmail varchar(250),
	@UserIPAddress varchar(25),
	@CertifyDate	datetime
AS

IF((SELECT COUNT(*) FROM dbo.Appl WHERE APNO=@OrderNumber)=1)
BEGIN
	UPDATE  [dbo].[ClientCertification] 
	SET [ClientCertReceived] = 'Yes', 
	[ClientCertBy] = @RecruiterEmail, 
	[ClientICertByPAddress] = @UserIPAddress,
	ClientCertUpdated = @CertifyDate
	WHERE APNO = @OrderNumber
END
ELSE
BEGIN
	INSERT INTO dbo.ClientCertification
	        ( APNO ,
	          ClientCertReceived ,
	          ClientCertBy ,
	          ClientCertUpdated ,
	          ClientICertByPAddress
	        )
	VALUES  ( @OrderNumber , -- APNO - int
	          'Yes' , -- ClientCertReceived - varchar(5)
	          @RecruiterEmail , -- ClientCertBy - varchar(500)
	          @CertifyDate , -- ClientCertUpdated - datetime
	          @UserIPAddress  -- ClientICertByPAddress - varchar(50)
	        )
END


