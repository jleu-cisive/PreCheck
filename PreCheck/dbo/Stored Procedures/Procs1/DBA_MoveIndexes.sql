CREATE Procedure DBA_MoveIndexes
AS  
  SET NOCOUNT ON;

 declare @objid int,   -- the object id of the table    
   @indid smallint, -- the index id of an index    
   @groupid smallint,  -- the filegroup id of an index    
   @indname sysname,    
   @groupname sysname,    
   @status int,    
   @keys nvarchar(2126), --Length (16*max_identifierLength)+(15x2)+(16x3)    
   @OBJNAME nvarchar(776),  
   @FILLFACT TINYINT,  
   @ISQL VARCHAR(5000),  
   @kill int,  
   @counter int  
     
set @counter = 1  

CREATE TABLE #Ind(comment varchar(max))

--LOOP TO GO THROUGH TABLES AND GRAB THEIR INDEXES
DECLARE TCURSOR CURSOR FOR SELECT NAME FROM SYSOBJECTS WHERE TYPE = 'U' ORDER BY NAME ASC  
OPEN TCURSOR  
FETCH NEXT FROM TCURSOR INTO @OBJNAME  
WHILE @@FETCH_STATUS = 0  
BEGIN  
   
   select @objid = object_id(@OBJNAME)    
   

	create table #spindtab    
     (    
     index_name   sysname collate database_default NOT NULL,    
     stats    int,    
     groupname   sysname collate database_default NOT NULL,    
     index_keys   nvarchar(2126) collate database_default NOT NULL, -- see @keys above for length descr    
     FILLFACT TINYINT  
     )    
  

declare ms_crs_ind cursor local static for (select indid, groupid, name, status, ORIGFILLFACTOR 
		from sysindexes where id = object_id(@OBJNAME) and indid > 0 and indid < 255 and (status & 64)= 0)


 
	open ms_crs_ind    
		fetch ms_crs_ind into @indid, @groupid, @indname, @status, @FILLFACT  
    
				 while @@fetch_status >= 0    
				 begin    
				  declare @i int, 
						  @thiskey nvarchar(131) -- 128+3    
				    
							select @keys = index_col(@OBJNAME, @indid, 1), @i = 2    
							  if (indexkey_property(@objid, @indid, 1, 'isdescending') = 1)    
								   select @keys = @keys  + '(-)'    
				    
							select @thiskey = index_col(@OBJNAME, @indid, @i)    
								if ((@thiskey is not null) and (indexkey_property(@objid, @indid, @i, 'isdescending') = 1))    
									select @thiskey = @thiskey + '(-)'    
				    
								  while (@thiskey is not null )    
										begin    
										   select @keys = @keys + ', ' + @thiskey, @i = @i + 1    
										   select @thiskey = index_col(@OBJNAME, @indid, @i)    
										   if ((@thiskey is not null) and (indexkey_property(@objid, @indid, @i, 'isdescending') = 1))    
											select @thiskey = @thiskey + '(-)'    
										end    
    
					
		select @groupname = groupname 
		from sysfilegroups 
		where groupid = @groupid    
    
		insert into #spindtab 
		values (@indname, @status, @groupname, @keys, @FILLFACT)    

    
  -- Next index    
		fetch ms_crs_ind into @indid, @groupid, @indname, @status, @FILLFACT    
 end    
CLOSE ms_crs_ind 
deallocate ms_crs_ind    

    
 -- SET UP SOME CONSTANT VALUES FOR OUTPUT QUERY    
 declare @empty varchar(1) select @empty = ''    
-- 35 matches spt_values     
declare 
@des1   varchar(35), 
@des2   varchar(35),
@des4   varchar(35), 
@des32 varchar(35),
@des64   varchar(35),
@des2048  varchar(35),
@des4096  varchar(35),
@des8388608  varchar(35),
@des16777216 varchar(35)    

	select @des1 = name from master.dbo.spt_values 
			where type = 'I' 
			and number = 1    
	 select @des2 = name from master.dbo.spt_values 
			where type = 'I' 
			and number = 2    
	 select @des4 = name from master.dbo.spt_values 
			where type = 'I' 
			and number = 4    
	 select @des32 = name from master.dbo.spt_values 
			where type = 'I' 
			and number = 32    
	 select @des64 = name from master.dbo.spt_values 
			where type = 'I' 
			and number = 64    
	 select @des2048 = name from master.dbo.spt_values 
			where type = 'I' 
			and number = 2048    
	 select @des4096 = name from master.dbo.spt_values 
			where type = 'I' 
			and number = 4096    
	 select @des8388608 = name from master.dbo.spt_values 
			where type = 'I' 
			and number = 8388608    
	 select @des16777216 = name from master.dbo.spt_values 
			where type = 'I' 
			and number = 16777216    
    
 -- DISPLAY THE RESULTS    
declare @tcount int  
	set @tcount = (select count(name) from sysobjects where type = 'U' and name > @OBJNAME)  


--GET DOWN TO BUSINESS
	Set @ISQL = ''	
	PRINT 'Recreating Indexes for Table ' + @OBJNAME + '.  ' + convert(varchar(5),@tcount) + ' Tables Remaining!'  


--ISSUE CREATE INDEX STATEMENTS WITH DROP EXISTING
DECLARE @INAME VARCHAR(100)  
DECLARE ICURSOR CURSOR FOR SELECT INDEX_NAME FROM #SPINDTAB ORDER BY INDEX_NAME   
		OPEN ICURSOR  
				FETCH NEXT FROM ICURSOR INTO @INAME  
						WHILE @@FETCH_STATUS = 0   

							BEGIN  
							( select @ISQL= 'Create  ' + case when (stats & 2)<>0 
													then @des2 + '  ' 
													else @empty 
													END +  
								
												 case when (stats & 16)=0 	
													then ' INDEX ' 	
													end 

							+ index_name + ' ON ' + @OBJNAME + ' ('+index_keys +') WITH '+  

												CASE WHEN FILLFACT = 0 
													THEN ' DROP_EXISTING' 
													ELSE ' FILLFACTOR = '+CONVERT(CHAR(2),FILLFACT)+',DROP_EXISTING' 
													END 
							+' ON '+ 	
												case when (stats & 16)=0	
													then ' [NCINDEX]' 
													end

							 from #spindtab  WHERE INDEX_NAME = @INAME)  



				INSERT INTO #Ind  
				SELECT  (@ISQL)  
			FETCH NEXT FROM ICURSOR INTO @INAME  
		END  
		CLOSE ICURSOR  
DEALLOCATE ICURSOR  


DROP TABLE #spindtab  
FETCH NEXT FROM TCURSOR INTO @OBJNAME  
END  
CLOSE TCURSOR  
DEALLOCATE TCURSOR  

SELECT * FROM #Ind WHERE Comment IS NOT NULL;
