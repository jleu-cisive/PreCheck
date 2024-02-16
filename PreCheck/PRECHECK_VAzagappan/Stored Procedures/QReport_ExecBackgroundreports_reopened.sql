--Use Precheck

--Go

---- =======================================================================================================

---- Created by  : Vairavan A

---- Create date : 07/03/2023

---- Ticket no   : 99523 

---- Description : This Sp is used to execute Qreport stored procedure [Precheck].[dbo].[Backgroundreports_reopened] 

----                on ala-db-01. This is required to remotely call the Sp on ala-db-01 where the necessary 

----                BackgroundReports database resides as this SP itself wil be called by Qreports app via

----                ala-bi-01 Sql server. 

--/*---Testing

--EXEC [dbo].[QReport_ExecBackgroundreports_reopened] '1629:1934';

--EXEC [dbo].[QReport_ExecBackgroundreports_reopened] NULL;

--EXECute [dbo].[QReport_ExecBackgroundreports_reopened] '';

--*/

---- =======================================================================================================

 



CREATE proc  [PRECHECK\VAzagappan].QReport_ExecBackgroundreports_reopened
@ClNo varchar(1024) =''

As

Begin
    Declare @ClNo1 varchar(1024) = @ClNo

    exec sp_executesql N'exec [ala-db-01].[Precheck].[dbo].[Backgroundreports_reopened] @clNo', N'@clNo Varchar(1024)' , @ClNo1

End

