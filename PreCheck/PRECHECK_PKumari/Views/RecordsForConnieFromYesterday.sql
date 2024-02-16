create view  [PRECHECK\PKumari].RecordsForConnieFromYesterday as
select Apno,County,Clear,Last_Updated from RecordsForConnie where Last_Updated>='5/8/2013' and Last_Updated<'5/9/2013'