
CREATE PROCEDURE [dbo].[Win_Service_AddApplAddress]
	@apno int, @address varchar(100), @city varchar(100), @state varchar(100), @zipCode varchar(10),@county varchar(100), @country varchar(100),
	@dateStart varchar(22), @dateEnd varchar(22), @source varchar(100)
AS
	DECLARE @clno int, @ssn varchar(12)

	SELECT @clno = a.CLNO, @ssn = a.SSN FROM dbo.Appl a WHERE a.APNO = @apno

	IF NOT EXISTS (
		SELECT * FROM dbo.ApplAddress aa 
		WHERE aa.APNO = @apno AND aa.Address = @address AND city = @city AND state = @state AND zip = @zipCode AND @county = County
		AND cast(aa.DateStart AS date) = cast(@dateStart AS date) AND cast(aa.DateEnd AS date) = cast(@dateEnd AS date) AND aa.Source = @source
	)
	BEGIN
		INSERT INTO dbo.ApplAddress
		(
			--ApplAddressID - column value is auto-generated
			APNO,
			Address,
			City,
			[State],
			Zip,
			County,
			Country,
			DateStart,
			DateEnd,
			Source,
			CLNO,
			SSN
		)
		VALUES
		(
			-- ApplAddressID - int
			@apno, -- APNO - int
			@address, -- Address - varchar
			@city, -- City - varchar
			@state, -- State - varchar
			@zipCode, -- Zip - varchar
			@county,
			@country, -- Country - varchar
			cast(@dateStart AS date), -- DateStart - datetime
			cast(@dateEnd  AS date), -- DateEnd - datetime
			@source, -- Source - varchar
			@clno, -- CLNO - int
			@ssn -- SSN - varchar
		)
	END
