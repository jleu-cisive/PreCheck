CREATE PROCEDURE Bis_statistics
	@AllClients bit,
	@Clients varchar(5000),
	@Detail bit,
	@strStartDate varchar(8),
	@strEndDate varchar(8)
AS
SET NOCOUNT ON
DECLARE @CLNO int
DECLARE @strCLNO varchar(8)
DECLARE @strClientName varchar(25)
DECLARE @c char(1)
DECLARE @i int
IF @AllClients = 0 BEGIN
	-- @Clients contains a comma-delimited list
	-- of client number for which we are going to
	-- print the report.  Create a temporary table.
	CREATE TABLE #tmpClients (
		CLNO int not null primary key,
		Name varchar(25)
	)
	SET @strCLNO = ''
	SET @i = 1
   WHILE @i <= LEN(@Clients) BEGIN
		SET @c = SUBSTRING(@Clients, @i, 1)
		IF @c = ',' BEGIN
			SET @i = @i + 1
			SET @CLNO = CONVERT(int, @strCLNO)
			SET @strClientName = (SELECT Name FROM Client WHERE CLNO = @CLNO)
			INSERT INTO #tmpClients (CLNO, Name) VALUES (@CLNO, @strClientName)
			SET @strCLNO = ''
		END ELSE BEGIN
			SET @strCLNO = @strCLNO + @c
			SET @i = @i + 1
		END
	END
	IF @strCLNO <> '' BEGIN
		SET @CLNO = CONVERT(int, @strCLNO)
		SET @strClientName = (SELECT Name FROM Client WHERE CLNO = @CLNO)
		INSERT INTO #tmpClients (CLNO, Name) VALUES (@CLNO, @strClientName)
		SET @strCLNO = ''
	END
END
IF @AllClients = 1 BEGIN
	-- Report is for all clients. Use the Client table
	IF @Detail = 1 BEGIN
		SELECT c.Clno, C.Name, a.Apno, a.UserID, 1 as ApplCount, CONVERT(numeric(7,2), dbo.ElapsedBusinessDays(a.ApDate, a.CompDate)) as Elapsed
		FROM Client c
		LEFT JOIN Appl a on (c.CLNO = a.CLNO) and (a.ApStatus = 'F')
		WHERE a.CompDate BETWEEN @strStartDate AND @strEndDate
		ORDER BY C.Name
	END ELSE BEGIN
		SELECT c.Clno, C.Name, null, null, COUNT(*) as ApplCount, CONVERT(numeric(7,2), AVG(CONVERT(numeric(7,2), dbo.ElapsedBusinessDays(a.ApDate, a.CompDate)))) as Elapsed
		FROM Client c
		LEFT JOIN Appl a on (c.CLNO = a.CLNO) and (a.ApStatus = 'F')
		WHERE a.CompDate BETWEEN @strStartDate AND @strEndDate
		GROUP BY c.Clno, C.Name
		ORDER BY C.Name
	END
END ELSE BEGIN
	-- Report is for selected clients. Use the temporary table
	IF @Detail = 1 BEGIN
		SELECT c.Clno, C.Name, a.Apno, a.UserID, 1 as ApplCount, CONVERT(numeric(7,2), dbo.ElapsedBusinessDays(a.ApDate, a.CompDate)) as Elapsed
		FROM #tmpClients c
		LEFT JOIN Appl a on (c.CLNO = a.CLNO) and (a.ApStatus = 'F')
		WHERE a.CompDate BETWEEN @strStartDate AND @strEndDate
		ORDER BY C.Name
	END ELSE BEGIN
		SELECT c.Clno, C.Name, null, null, COUNT(*) as ApplCount, CONVERT(numeric(7,2), AVG(CONVERT(numeric(7,2), dbo.ElapsedBusinessDays(a.ApDate, a.CompDate)))) as Elapsed
		FROM #tmpClients c
		LEFT JOIN Appl a on (c.CLNO = a.CLNO) and (a.ApStatus = 'F')
		WHERE a.CompDate BETWEEN @strStartDate AND @strEndDate
		GROUP BY c.Clno, c.Name
		ORDER BY C.Name
	END
END
