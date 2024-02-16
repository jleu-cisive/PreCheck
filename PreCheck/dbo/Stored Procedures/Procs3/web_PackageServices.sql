
-- =============================================  
-- Author:  <Author,,Lalit>  
-- Create date: <Create Date,,8 sep 2022>  
-- Description: <Description,,to get services included in packages>
-- updated on 17 jan 2023 for #79095
-- =============================================  
CREATE PROCEDURE [dbo].[web_PackageServices] @CLNO INT
AS
BEGIN
set nocount on
--declare @CLNO int=7519
select pm.PackageID
	 , dr.RateType as [Services]
	 , pm.PackageDesc
	 , case
				 when ps3.IncludedCount <> 0 then
					 1
				 else
					 0
	   end		   as IsIncluded
from ClientPackages cp with (nolock)
	inner join (
		select distinct ps.PackageID
					  , ps.ServiceType
					  , IncludedCount = (
						case
								  when ServiceType = 8 then
									  case
												when isnull(ps2.PackageID, '') <> ''
													and
													pgm.PackageDesc not like '%only%'
													and
													(   pgm.DefaultPrice > 30
														or pgm.PackageDesc like '%precheck%') then
													case
															  when c.[Medicaid/Medicare] <> 0 then
																  1
															  else
																  isnull(ps.IncludedCount, 0)
													end
												else
													isnull(ps.IncludedCount, 0)
									  end
								  when ServiceType = 1 then
									  case
												when isnull(ps2.PackageID, '') <> ''
													and
													pgm.PackageDesc not like '%only%'
													and
													(   pgm.DefaultPrice > 30
														or pgm.PackageDesc like '%precheck%') then
													case
															  when c.Social <> 0 then
																  1
															  else
																  isnull(ps.IncludedCount, 0)
													end
												else
													isnull(ps.IncludedCount, 0)
									  end
								  else
									  isnull(ps.IncludedCount, 0)
						end
						)
					  , ps.ServiceID
					  , pgm.DefaultPrice
		from ClientPackages cp with (nolock)
		inner join PackageService ps with (nolock)
			on cp.PackageID = ps.PackageID
		inner join Client c with (nolock)
			on c.CLNO = cp.CLNO
		left join (
			select PackageID
				 , count(*) _count
			from PackageService with (nolock)
			where IncludedCount <> 0
			group by PackageID
			having count(*) > 1) ps2
			on ps.PackageID = ps2.PackageID
		left join PackageMain pgm
			on ps2.PackageID = pgm.PackageID
		where c.CLNO = @CLNO) ps3
		on cp.PackageID = ps3.PackageID
	inner join DefaultRates dr with (nolock)
		on dr.ServiceID = ps3.ServiceID
	inner join PackageMain pm with (nolock)
		on pm.PackageID = cp.PackageID
	left outer join ClientRates cr
		on cr.ServiceID = dr.ServiceID
			and cr.CLNO = cp.CLNO
where cp.CLNO = @CLNO
	  and cp.IsActive <> 0
	  and pm.refPackageTypeID is null--and (ps3.IncludedCount <> 0 OR (pm.PackageDesc LIKE '%line%' and pm.PackageDesc LIKE '%item%') )  
group by pm.PackageDesc
	   , dr.RateType
	   , ps3.IncludedCount
	   , pm.PackageID
order by pm.PackageDesc
	   , dr.RateType

set nocount off
END
