-- =============================================
-- Author:		<Amy Liu>
-- Create date: <05/27/2021>
-- Description:	this is for granting a user access permission to a client 
-- or revoke a permission from a client for the user in Client Manager windows forms application
-- =============================================
create PROCEDURE [dbo].[usp_SavePrivilege]
(
	@ContactID int,
	@CLNO int,
	@IsActive bit=1,
	@UserID varchar(20)
)

AS
BEGIN
	declare @PrincipalTypeId_User int = 1
	declare @ResourceTypeId_User int = 2
	declare  @PrivilegeIds  table (PrivilegeID int)

	declare @ID int =0
	select @ID = isnull(ID,0) from dbo.Users where UserID= left(ltrim(rtrim(@UserID)),8) 


	SET NOCOUNT ON;
	declare @PrivilegeId int =0

			BEGIN TRY
            BEGIN TRANSACTION;
				IF (@IsActive=1)
				BEGIN
					INSERT INTO Security.Privilege
										(PrincipalTypeId, PrincipalId, ResourceTypeId, ResourceId, AccessTypeId, AccessId, IsActive, CreateDate, CreateBy, ModifyDate, ModifyBy)
							VALUES        (@PrincipalTypeId_User,@ContactID, @ResourceTypeId_User,@CLNO, NULL, NULL, @IsActive, GETDATE(), @ID , GETDATE(), @ID )
				END
				ELSE
				BEGIN
					
					insert into @PrivilegeIds( PrivilegeID)
					select privilegeID 
					from Security.Privilege pv 
					where pv.ResourceId= @CLNO and pv.PrincipalId=@ContactID and PrincipalTypeId=@PrincipalTypeId_User and ResourceTypeId= @ResourceTypeId_User

						insert into Security.PrivilegeHistory(PrivilegeId, PrincipalTypeId, PrincipalId, ResourceTypeId, ResourceId, IsActive, CreateBy, CreateDate,ModifyBy, ModifyDate)						
									select PrivilegeId, PrincipalTypeId, PrincipalId, ResourceTypeId, ResourceId, IsActive, CreateBy, CreateDate, @ID , GETDATE()
									from Security.Privilege pv 
									where pv.PrivilegeId in (select PrivilegeId from @PrivilegeIds)

			
						delete FROM Security.Privilege  where PrivilegeId in (select PrivilegeId from @PrivilegeIds)

				END

				IF @@TRANCOUNT > 0
					COMMIT;
			END TRY
			BEGIN CATCH
				IF @@TRANCOUNT > 0
					ROLLBACK;
				Throw;
			END CATCH;




END
