CREATE PROCEDURE dbo.SetReleaseSharingHierarchy ( @ParentCLNO INT, @ClientList VARCHAR(100)) --include ParentCLNO along with coma seperated list of CLNOs
AS
BEGIN
	--EXEC SetReleaseSharingHierarchy  12969, '12969,12975,12973,12970,12971,12972,12974' --include ParentCLNO along with coma seperated list of CLNOs

	INSERT INTO dbo.ClientHierarchyByService
			( CLNO ,
			  ParentCLNO ,
			  refHierarchyServiceID
			)
	SELECT value,@ParentCLNO,2 --2 is the serviceID to share the online releases
	FROM dbo.fn_Split(@ClientList,',')
END
