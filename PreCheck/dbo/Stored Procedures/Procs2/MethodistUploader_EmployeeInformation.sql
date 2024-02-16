



-- exec [dbo].[MethodistUploader_EmployeeInformation] '1011866', 2569;



-- =============================================

-- Author:		<Author,,Name>

-- Create date: <Create Date,,>

-- Description:	<Description,,>

-- =============================================

CREATE PROCEDURE [dbo].[MethodistUploader_EmployeeInformation]

	-- Add the parameters for the stored procedure here

	@EmployeeNumber varchar (20),
	@EmployerID int = null,
	@ReportID int = null,
	@Reporttype varchar(20) = null

AS

BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF @EmployeeNumber = '000000000' AND isnull(@ReportID,'') <> '' 
	BEGIN
		IF @Reporttype = 'BackgroundReport'
		BEGIN
			SELECT top 1 '000000000' employeenumber,ssn,last,first,middle,IsNull(CompDate, OrigCompDate) as DateOfHire,
					'' As Company_Code,'' as Department_Code
			FROM Precheck.dbo.Appl a WITH (NOLOCK)
			-- INNER JOIN BackgroundReports.dbo.BackgroundReport br WITH (NOLOCK) on a.apno = br.apno   
			WHERE apno = @ReportID
			  AND (clno = @EmployerID OR clno in (SELECT clno FROM clienthierarchybyservice WITH (NOLOCK) WHERE parentclno = @EmployerID AND refhierarchyserviceid = 1 ))
		END
		ELSE IF @Reporttype = 'BackgroundRelease'
		BEGIN
			SELECT top 1 '000000000' employeenumber,ssn,last,first,'' middle,IsNull(date, '1/1/1900') as DateOfHire,
					'' As Company_Code,'' as Department_Code
			FROM Precheck.dbo.Releaseform WITH (NOLOCK) 
			WHERE Releaseformid = @ReportID
			  AND (clno = @EmployerID OR clno in (SELECT clno FROM clienthierarchybyservice WITH (NOLOCK) WHERE parentclno = @EmployerID AND refhierarchyserviceid = 1 ))
		END
	END
	ELSE
	BEGIN
		-- employeerecord contains duplicates because of multiple facilities so get top 1
		SELECT top 1 er.employeenumber,er.ssn,er.last,er.first,er.middle,ISNULL(IsNull(er.LastStartDate, er.OriginalStartDate),er.RecordDate) as DateOfHire,
				--f.facilitynum 
				case when @EmployerID = 7519 then er.HrCompany else f.facilitynum end As Company_Code,d.departmentnumber as Department_Code
		FROM HEVN.dbo.EmployeeRecord er WITH (NOLOCK) 
		LEFT OUTER JOIN HEVN.dbo.facility f with (nolock) on er.facilityid = f.facilityid 
		LEFT OUTER JOIN HEVN.dbo.department d with (nolock) on er.departmentid = d.departmentid 
		where er.employeenumber = @EmployeeNumber 
		  and (er.employerid = @EmployerID --or @EmployerID is NULL
				OR er.EmployerID in (select parentclno from precheck.dbo.clienthierarchybyservice WITH (NOLOCK) where clno = @EmployerID and refhierarchyserviceid = 1 )
				OR @EmployerID is NULL
			  )
		order by er.endingdate DESC
	END


/* VD - 04/18/2018 - Original Commented because of a change
    -- employeerecord contains duplicates because of multiple facilities so get top 1

SELECT top 1 er.employeenumber,er.ssn,er.last,er.first,er.middle,IsNull(er.LastStartDate, er.OriginalStartDate) as dateofhire,

 f.facilitynum As Company_Code,d.departmentnumber as Department_Code

from HEVN.dbo.EmployeeRecord er WITH (NOLOCK) 

inner join HEVN.dbo.facility f with (nolock) on er.facilityid = f.facilityid 

inner join HEVN.dbo.department d with (nolock) on er.departmentid = d.departmentid 

where er.employeenumber = @EmployeeNumber 

and (er.employerid = @EmployerID or @EmployerID is null)

order by er.endingdate DESC
*/


END




