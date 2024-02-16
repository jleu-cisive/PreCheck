CREATE PROCEDURE [dbo].[iris_ws_switch_researcher_id]
	@old_R_ID int,
	@new_R_ID int
AS
BEGIN
    SET NOCOUNT ON;    
    
		UPDATE  Iris_ws_Vendor_searches
		SET VENDOR_ID = @new_R_ID
		WHERE VENDOR_ID = @old_R_ID

		UPDATE  Iris_Researcher_Charges
		SET Researcher_ID = @new_R_ID
		WHERE Researcher_ID = @old_R_ID

		UPDATE IRIS_County_Rules
		SET Vendor1 = @new_R_ID
		WHERE Vendor1 = @Old_R_ID

		UPDATE IRIS_County_Rules
		SET Vendor2 = @new_R_ID
		WHERE Vendor2 = @Old_R_ID

		UPDATE IRIS_County_Rules
		SET Vendor3 = @new_R_ID
		WHERE Vendor3 = @Old_R_ID

		UPDATE IRIS_County_Rules
		SET Vendor4 = @new_R_ID
		WHERE Vendor4 = @Old_R_ID

		UPDATE IRIS_County_Rules
		SET Vendor5 = @new_R_ID
		WHERE Vendor5 = @Old_R_ID

		UPDATE IRIS_County_Rules
		SET Vendor6 = @new_R_ID
		WHERE Vendor6 = @Old_R_ID

    SET NOCOUNT OFF;
END
