-- =============================================
-- Author:		Dongmei He
-- Create date: 07/21/2017
-- Description:	List Client Migrate To New StudentCheck
-- Modified by Radhika Dereddy on 12/27/2017 to take the configuration key value
-- from Enterprise for StudentCheck phase-2 rollout
-- =============================================

-- [dbo].[ListClientMigrateToNewStudentCheck]
CREATE PROCEDURE [dbo].[ListClientMigrateToNewStudentCheck]
AS

BEGIN
Declare @SchoolList varchar(max)
Declare @MigrateToNewStudentCheck bit

Select @MigrateToNewStudentCheck = KeyValue From [Enterprise].Config.Configuration Where KeyName = 'MigrateToNewStudentCheck'
Select @SchoolList = KeyValue From [Enterprise].Config.Configuration Where KeyName = 'MigrateStudentCheckClientCSV'

--commented by radhika on 12/27/2017
--Select @MigrateToNewStudentCheck = value From ClientConfiguration Where ConfigurationKey = 'MigrateToNewStudentCheck'
--Select @SchoolList = value From ClientConfiguration Where ConfigurationKey = 'MigrateStudentCheckClientCSV'

--Select @MigrateToNewStudentCheck
--Set @SchoolList = ''
--Set @MigrateToNewStudentCheck = 0

If(@MigrateToNewStudentCheck = 1 and isnull(@SchoolList, '')  <> '')
Begin 

Select value into #SchoolList  From dbo.fn_Split(@SchoolList, ',')
Select value as Clno From #SchoolList 
Union
Select CLNO_Hospital as Clno from Client Join ClientSchoolHospital on Clno = CLNO_School Where Clno in (Select value From #SchoolList) AND CLNO_Hospital IS NOT NULL

End

Else If(@MigrateToNewStudentCheck = 1 and isnull(@SchoolList, '')  = '')
Begin
Select Clno from Client 
End
END

