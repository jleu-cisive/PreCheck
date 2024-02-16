 CREATE procedure ClientAccess_LoginActivity_ByClient (@ParentCLNO Int,@User varchar(20) = null,@DateFrom Date,@DateTo Date) AS
SET NOCOUNT ON
-- ClientAccess_LoginActivity_ByClient 12262,'08/01/2017','08/22/2017','dfoyt'
select username,ClientID,LogDate,case LoginSuccess when 1 then 'True' else 'False' end LoginSuccess from ClientAccess_Login_Audit A (nolock) inner join refClientType r (nolock)  on A.ClientType = R.ClientTypeID 
where (A.ClientID in (select clno from client (nolock) where weborderParentClNO = @ParentCLNO ) or clientid =@ParentCLNO)
and cast(LogDate as Date) between @DateFrom and @DateTo
and (Username = @User or isnull(@User,'') = '')
order by LogDate desc,ClientID,Username
SET NOCOUNT OFF


