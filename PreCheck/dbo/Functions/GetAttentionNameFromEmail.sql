



-- =============================================
-- Author:		Dongmei He
-- Create date: 09/03/2019
-- Description:	Convert email to attention name
-- =============================================
CREATE FUNCTION [dbo].[GetAttentionNameFromEmail] 
(
    @Apno AS INT,
    @Email AS VARCHAR(250) 
)
RETURNS varchar(100)
AS
BEGIN

 DECLARE @Attention varchar(100)

 SELECT @Attention = LastName + ', ' +  FirstName 
 FROM ClientContacts CC
 JOIN Appl A
   ON CC.CLNO = A.CLNO
 WHERE LTRIM(RTRIM(CC.Email)) = LTRIM(RTRIM(@Email))
   AND A.APNO = @Apno

 if(@Attention is null) 
   SET @Attention = @Email --'To Be, Determined'

 RETURN @Attention

END



