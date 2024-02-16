-- Alter Procedure ADD_Countries_TO_Counties

--This procedure sets values to country column.  If State is US, adds USA.  Else moves county value to country
--4/30/2003
CREATE PROCEDURE dbo.ADD_Countries_TO_Counties AS

--be sure they are clear
Update dbo.TblCounties set country=''

--move county to county (for foriegn)
Update dbo.TblCounties set country=a_county

--for USA, overwrite country as 'USA'
Update dbo.TblCounties set country='USA' Where 
		--States
		state='AK' or state='AL' or state='AR' or state='AZ' or
		state='CA' or state = 'CO' or state = 'CT' or
		state='DE' or state = 'FL' or state = 'GA' or 
		state='HI' or
		state='IA' or state = 'ID' or state = 'IL' or state = 'IN' or
		state='KS' or state = 'KY' or state = 'LA' or
		state='MA' or state = 'MD' or state = 'ME' or state = 'MI' or state = 'MO' or state='MN' or state = 'MS' or state = 'MT' or
		state='NC' or state = 'ND' or state = 'NE' or state = 'NH' or state = 'NJ' or state = 'NM' or state = 'NV' or state = 'NY' or
		state='OK' or state = 'OH' or state = 'OR' or state = 'PA' or
		state='RI' or state='SC' or state = 'SD' or
		state='TN' or state = 'TX' or state='UT' or 
		state='VA' or state = 'VT' or 
		state='WA' or state = 'WI' or state = 'WV' or state = 'WY' or
		--Territories
		state='AS' or --American Samoa
		state='GU' or --Guam
		state='PR' or --Puerto Rico
		state='VI' or   --Virgin Islands
		state='MP' or   --Northern Mariana Islands
		--Other
		state='DC' or -- District of Co.lumbia
		state='US' -- US courts
--Fix up US counties
Update dbo.TblCounties set a_county='**STATEWIDE**' Where a_county='STATEWIDE'
Update dbo.TblCounties set a_county='*DPS STATEWIDE*' Where a_county='DPS'
Update dbo.TblCounties set a_county='**STATEWIDE**' Where a_county='No County Indicated' and Country='USA'
--Mislabeled counties
Update dbo.TblCounties set a_county='Randall', state='TX', country='USA' Where county='Randall'
Update dbo.TblCounties set a_county='Fayette', state='TX', country='USA' Where county='Fayette'
Update dbo.TblCounties set a_county='Harris', state='TX', country='USA' Where county='Class C Harris, TX'
Update dbo.TblCounties set a_county='Caddo Parish', state='LA', country='USA' Where county='Shreveport, LA'
Update dbo.TblCounties set a_county='Orleans Parish', state='LA', country='USA' Where county='New Orleans, LA'
Update dbo.TblCounties set a_county='Van Buren', state='TX', country='USA' Where county='Paw Paw, MI'
Update dbo.TblCounties set a_county='Miller', state='AR', country='USA' Where county='Bowie, AR'
--More Mislabeled counties
Update dbo.TblCounties set a_county='Montegomery', state='VA', country='USA' Where county='Blacksburg, VA'
Update dbo.TblCounties set a_county='Mississippi', state='AR', country='USA' Where county='Blytheville, AR'
Update dbo.TblCounties set a_county='Mahoning', state='OH', country='USA' Where county='Campbell, OH'
Update dbo.TblCounties set a_county='Richland', state='SC', country='USA' Where county='Columbia, SC'
Update dbo.TblCounties set a_county='U.S. DISTRICT COURT FED', state='US', country='USA' Where county='CT US DISTRICT/FED COURT'
Update dbo.TblCounties set a_county='Payne', state='OK', country='USA' Where county='Cushing, OK'
Update dbo.TblCounties set a_county='Mifflin', state='PA', country='USA' Where county='Muffin, PA'
Update dbo.TblCounties set a_county='U.S. DISTRICT COURT FED', state='US', country='USA' Where county='EASTERN DISTRICT OF TEXAS'
Update dbo.TblCounties set a_county='Allen', state='IA', country='USA' Where county='Ft. Wayne, IN'
Update dbo.TblCounties set a_county='Harris', state='TX', country='USA' Where county='HOUSTON METRO AREA'
Update dbo.TblCounties set a_county='Saline', state='AR', country='USA' Where county='Haskell, AR'
Update dbo.TblCounties set a_county='Broward', state='FL', country='USA' Where county='Hollywood, FL'
Update dbo.TblCounties set a_county='Sevier', state='TN', country='USA' Where county='Howard, TN'
Update dbo.TblCounties set a_county='Hardin', state='OH', country='USA' Where county='Kenton, OH'
Update dbo.TblCounties set a_county='Gwinnett', state='GA', country='USA' Where county='Lilburn, GA'
Update dbo.TblCounties set a_county='Dunn', state='ND', country='USA' Where county='Marshall, ND'
Update dbo.TblCounties set a_county='U.S. DISTRICT COURT FED', state='US', country='USA' Where county='MIDDLE DIST. FL'
Update dbo.TblCounties set a_county='Clayton', state='GA', country='USA' Where county='Morrow City, GA'
Update dbo.TblCounties set a_county='U.S. DISTRICT COURT FED', state='US', country='USA' Where county='NORTHERN DISTRICT'
Update dbo.TblCounties set a_county='Utah', state='UT', country='USA' Where county='Provo, UT'
Update dbo.TblCounties set a_county='Ouachita', state='AR', country='USA' Where county='Quatchita, AR'
Update dbo.TblCounties set a_county='Warren', state='NY', country='USA' Where county='Queensbury, NY'
Update dbo.TblCounties set a_county='Utah', state='UT', country='USA' Where county='Sandy, UT'
Update dbo.TblCounties set a_county='U.S. DISTRICT COURT FED', state='US', country='USA' Where county='SOUTHERN DIST., MS'
Update dbo.TblCounties set a_county='U.S. DISTRICT COURT FED', state='US', country='USA' Where county='SOUTHERN DIST., TX'
Update dbo.TblCounties set a_county='Navarro', state='FL', country='USA' Where county='Springhill, FL'
Update dbo.TblCounties set a_county='Concordia', state='LA', country='USA' Where county='St. Shaw, LA'
Update dbo.TblCounties set a_county='U.S. DISTRICT COURT FED', state='US', country='USA' Where county='WESTERN FEDERAL DISTRICT'
Update dbo.TblCounties set a_county='Midland', state='MI', country='USA' Where county='Wise, MI'
Update dbo.TblCounties set a_county='Canadian', state='OK', country='USA' Where county='Yukon, OK'
Update dbo.TblCounties set a_county='Matanuska-Susitna Borough', state='AK', country='USA' Where county='Palmer, AK'
Update dbo.TblCounties set a_county='Mercer', state='WV', country='USA' Where county='Bluefield, WV'
--Louisiana Fix ups 
Update dbo.TblCounties set a_county='Orleans Parish' Where a_county='Orleans' and state='LA'
Update dbo.TblCounties set a_county='Caddo Parish'  Where a_county='Caddo' and state='LA'

--Canada provinces
Update dbo.TblCounties set country='Canada' Where state='AA'
Update dbo.TblCounties set state=a_county Where country='Canada'
--Update COUNTIES set state='AB' Where state='Alberta'
--Update COUNTIES set state='BC' Where state='British Columbia'
--Update COUNTIES set state='MB' Where state='Manitoba'
--Update COUNTIES set state='NB' Where state='New Brunswick'
--Update COUNTIES set state='NF' Where state='Newfoundland and Labrador'
--Update COUNTIES set state='NT' Where state='Northwest Territories'
--Update COUNTIES set state='NU' Where state='Nunavut'
--Update COUNTIES set state='NS' Where state='Nova Scotia'
--Update COUNTIES set state='ON' Where state='Ontario'
--Update COUNTIES set state='PE' Where state='Prince Edward Island'
--Update COUNTIES set state='QU' Where state='Quebec'
--Update COUNTIES set state='SS' Where state='Saskatchewan'
--Update COUNTIES set state='YU' Where state='Yukon Territory'
Update dbo.TblCounties set a_county='**Out of Country**' Where country='Canada'
Update dbo.TblCounties set a_county='no county',state='**Nationwide**' Where country='Canada' and State='Canada'  -- IRIS correction

--Australia
Update dbo.TblCounties set country='Australia' Where state='AU'
Update dbo.TblCounties set state=a_county Where country='Australia'
Update dbo.TblCounties set a_county='**Out of Country**' Where country='Australia'
Update dbo.TblCounties set state='***Nationwide***', a_county='no county' Where country='Australia' and State='Australia'

--UK has counties but not states, so leave state='UK'
Update dbo.TblCounties set country='UK' Where state='UK'
Update dbo.TblCounties set a_county='Dorset' Where country='UK' and a_county LIKE '%Dorset%'

--Bermuda has counties but not states, call state Bermuda
Update dbo.TblCounties set state='Bermuda', country='Bermuda' Where state='BM'

--Phillipines provinces
Update dbo.TblCounties set country='Phillipines' Where state='PI'
Update dbo.TblCounties set state=a_county Where country='Phillipines'
Update dbo.TblCounties set state='***NATIONWIDE***' Where a_county='All Counties' and Country='Phillipines'
Update dbo.TblCounties set a_county='**Out of Country**' Where country='Phillipines'
Update dbo.TblCounties set a_county='no county' Where state='***Nationwide***' and Country='Phillipines'

--Marshall Islands
Update dbo.TblCounties set country='Marshall Islands' Where state='MH'
Update dbo.TblCounties set A_County='no county', State='***Nationwide***' WHERE country='Marshall Islands'

--Micronesia
Update dbo.TblCounties set country='Micronesia' Where state='FM'
Update dbo.TblCounties set A_County='no county', State='***Nationwide***' WHERE country='Micronesia'

--Palau
Update dbo.TblCounties set country='Palau' Where state='PW'
Update dbo.TblCounties set A_County='no county', State='***Nationwide***' WHERE country='Palau'

--Fix up other counties
Update dbo.TblCounties set state='***Nationwide***', a_county='' Where country='Antigua'
Update dbo.TblCounties set state='***Nationwide***', a_county='' Where country='Argentina'
Update dbo.TblCounties set state='***Nationwide***', a_county='' Where country='Trinidad'
