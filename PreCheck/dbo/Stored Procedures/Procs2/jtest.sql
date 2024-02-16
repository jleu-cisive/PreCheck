CREATE PROCEDURE jtest AS
select apno,county,clear from crim
union all
select apno,first, last from appl
