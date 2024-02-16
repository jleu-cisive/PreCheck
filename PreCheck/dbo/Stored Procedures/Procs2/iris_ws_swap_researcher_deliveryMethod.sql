CREATE PROCEDURE [dbo].[iris_ws_swap_researcher_deliveryMethod]
	@Vendor_Name varchar(50),
    @IsSwitchToWebServiceMethod bit
AS
BEGIN
    SET NOCOUNT ON;  

SET @Vendor_Name = '%'+@Vendor_Name+'%'

DECLARE cc_switch_R_ID CURSOR
FOR 
	SELECT R_ID, Temp_R_ID
	FROM IRiS_Researchers 
	WHERE R_Name LIKE @Vendor_Name AND Temp_R_ID IS NOT NULL AND Temp_R_ID <> R_ID

DECLARE @R_id INT , 
		@temp_R_ID INT
OPEN cc_switch_R_ID
FETCH cc_switch_R_ID INTO @R_id,
						  @Temp_R_ID	
WHILE @@FETCH_STATUS=0
begin
if @IsSwitchToWebServiceMethod = 1
BEGIN
	exec iris_ws_switch_researcher_id @old_R_ID = @Temp_R_ID, @NEW_R_ID = @R_ID
END
ELSE
BEGIN
	exec iris_ws_switch_researcher_id @old_R_ID = @R_ID, @NEW_R_ID = @Temp_R_ID
END
fetch cc_switch_R_ID into @R_id,
						  @Temp_R_ID	
end
close cc_switch_R_ID
deallocate cc_switch_R_ID


    SET NOCOUNT OFF;
END
