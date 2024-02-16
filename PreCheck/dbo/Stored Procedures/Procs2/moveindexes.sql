CREATE procedure moveindexes   
as  
  set nocount on;
 declare @objid int,   -- the object id of the table    
   @indid smallint, -- the index id of an index    
   @groupid smallint,  -- the filegroup id of an index    
   @indname sysname,    
   @groupname sysname,    
   @status int,    
   @keys nvarchar(2126), --Length (16*max_identifierLength)+(15*2)+(16*3)    
   @dbname sysname  ,  
   @objname nvarchar(776),  
   @FILLFACT TINYINT,  
   @ISQL VARCHAR(5000),  
   @kill int,  
   @counter int  
     

CREATE TABLE #Idx (Comment varchar(max))

DECLARE TCURSOR CURSOR FOR SELECT NAME FROM SYSOBJECTS WHERE TYPE = 'U' ORDER BY NAME ASC  
OPEN TCURSOR  
FETCH NEXT FROM TCURSOR INTO @OBJNAME  
WHILE @@FETCH_STATUS = 0  
BEGIN  
  
   
   select @objid = object_id(@objname)    
   create table #spindtab    
     (    
     index_name   sysname collate database_default NOT NULL,    
     stats    int,    
     groupname   sysname collate database_default NOT NULL,    
     index_keys   nvarchar(2126) collate database_default   NULL, -- see @keys above for length descr    
     FILLFACT TINYINT  
     )    
  

  declare ms_crs_ind cursor local static for    
  select indid, groupid, name, status, ORIGFILLFACTOR from sysindexes    
     where name LIKE 'IX%' OR name LIKE 'PK%' AND  id = object_id(@OBJNAME)
		order by indid    
 open ms_crs_ind    
 fetch ms_crs_ind into @indid, @groupid, @indname, @status, @FILLFACT  
    
 while @@fetch_status >= 0    
 begin    
  declare @i int, @thiskey nvarchar(131) -- 128+3    
    
  select @keys = index_col(@objname, @indid, 1), @i = 2    
  if (indexkey_property(@objid, @indid, 1, 'isdescending') = 1)    
   select @keys = @keys  + '(-)'    
    
  select @thiskey = index_col(@objname, @indid, @i)    
  if ((@thiskey is not null) and (indexkey_property(@objid, @indid, @i, 'isdescending') = 1))    
   select @thiskey = @thiskey + '(-)'    
    
  while (@thiskey is not null )    
  begin    
   select @keys = @keys + ', ' + @thiskey, @i = @i + 1    
   select @thiskey = index_col(@objname, @indid, @i)    
   if ((@thiskey is not null) and (indexkey_property(@objid, @indid, @i, 'isdescending') = 1))    
    select @thiskey = @thiskey + '(-)'    
  end    
    
  select @groupname = groupname from sysfilegroups where groupid = @groupid    
    
  insert into #spindtab values (@indname, @status, @groupname, @keys, @FILLFACT)    
    
  -- Next index    
  fetch ms_crs_ind into @indid, @groupid, @indname, @status, @FILLFACT    
 end    
 deallocate ms_crs_ind    
    
 -- SET UP SOME CONSTANT VALUES FOR OUTPUT QUERY    
 declare @empty varchar(1) select @empty = ''    
 declare @des1   varchar(35), -- 35 matches spt_values    
   @des2   varchar(35),    
   @des4   varchar(35),    
   @des32   varchar(35),    
   @des64   varchar(35),    
   @des2048  varchar(35),    
   @des4096  varchar(35),    
   @des8388608  varchar(35),    
   @des16777216 varchar(35)    
 select @des1 = name from master.dbo.spt_values where type = 'I' and number = 1    
 select @des2 = name from master.dbo.spt_values where type = 'I' and number = 2    
 select @des4 = name from master.dbo.spt_values where type = 'I' and number = 4    
 select @des32 = name from master.dbo.spt_values where type = 'I' and number = 32    
 select @des64 = name from master.dbo.spt_values where type = 'I' and number = 64    
 select @des2048 = name from master.dbo.spt_values where type = 'I' and number = 2048    
 select @des4096 = name from master.dbo.spt_values where type = 'I' and number = 4096    
 select @des8388608 = name from master.dbo.spt_values where type = 'I' and number = 8388608    
 select @des16777216 = name from master.dbo.spt_values where type = 'I' and number = 16777216    
    
 -- DISPLAY THE RESULTS    
declare @tcount int  
set @tcount = (select count(*) from sysobjects where type = 'U' and name > @objname)  
print 'Recreating Indexes for Table ' + @objname + '.  ' + convert(varchar(5),@tcount) + ' Tables Remaining!'  
DECLARE @INAME VARCHAR(100)  
DECLARE ICURSOR CURSOR FOR SELECT INDEX_NAME FROM #SPINDTAB ORDER BY INDEX_NAME   
OPEN ICURSOR  
FETCH NEXT FROM ICURSOR INTO @INAME  
WHILE @@FETCH_STATUS = 0   
BEGIN  
 SET @ISQL = ( select  'Create  '  + case when (stats & 2)<>0 then @des2 + '  ' else @empty end +   
 case when (stats & 16)<>0 then 'CLUSTERED  INDEX ' else ' INDEX ' end +  
 index_name + ' ON ' + @objname + ' ('+index_keys +') WITH '+  
   CASE WHEN FILLFACT = 0 THEN ' DROP_EXISTING' ELSE ' FILLFACTOR = '+CONVERT(CHAR(2),FILLFACT)+', DROP_EXISTING' END +  
 ' ON ' + case when (stats & 16)<>0 then ' [FG_DATA]' else ' [FG_INDEX]' end  
 from #spindtab  WHERE INDEX_NAME = @INAME)  

INSERT INTO #Idx   
SELECT (@ISQL)  

FETCH NEXT FROM ICURSOR INTO @INAME  
END  
CLOSE ICURSOR  
DEALLOCATE ICURSOR  
  
drop table #spindtab  
FETCH NEXT FROM TCURSOR INTO @OBJNAME  
END  
CLOSE TCURSOR  
DEALLOCATE TCURSOR  
SELECT * FROM #Idx WHERE comment is NOT NULL
