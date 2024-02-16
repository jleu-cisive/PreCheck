


CREATE PROCEDURE [dbo].[iris_CrimWorkSheetLogin] 

@UserID varchar(30),
@Password varchar(15),
@VendorID int
AS
Set NoCount On

select R_Name from Iris_researchers where R_id=@VendorID and UserID=@USerID 
      and Password = @Password
