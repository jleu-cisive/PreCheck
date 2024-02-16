CREATE procedure dbo.qr_GetAIMSLicenseInfo

	@state varchar(5),

	@lictype varchar(10),

	@datefrom datetime = null,

	@dateto datetime = null

--set @state = 'TX'

--set @lictype = 'RN'

--set @datefrom = '12/05/2011'

--set @dateto = '12/06/2011'

--if (@dateTo is null)

--		set @dateTo = DATEADD(dd, 0, DATEDIFF(dd, 0, GETDATE()))		

as	



if (IsNull(@state,'') = '' and IsNull(@lictype,'') = '')

	Select DataXtract_LoggingId,SectionKeyID,Request,Response, ResponseError, ResponseStatus, DateLogRequest,DateLogResponse,LogUser 

	From dbo.DataXtract_Logging (Nolock) 

	Where 
	--lower(section) = 'credentcheck'

	--and SectionKeyID = '' + @state + '-' + @lictype + ''

	--and 
	DateLogRequest between @datefrom and @dateto

	order by DateLogRequest desc

else	

	Select DataXtract_LoggingId,SectionKeyID,Request,Response, ResponseError, ResponseStatus, DateLogRequest,DateLogResponse,LogUser From dbo.DataXtract_Logging (Nolock) 

	Where 
	--lower(section) = 'credentcheck'

	--and
	 SectionKeyID = '' + @state + '-' + @lictype + ''

	and DateLogRequest between @datefrom and @dateto

	order by DateLogRequest desc







	




