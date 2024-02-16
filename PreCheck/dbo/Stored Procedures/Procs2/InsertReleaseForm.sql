CREATE PROCEDURE DBO.InsertReleaseForm
    @pdf AS IMAGE,
    @ssn AS VARCHAR (11),
    @first AS VARCHAR (50),
    @last AS VARCHAR (50)
AS
INSERT INTO ReleaseForm (PDF,ssn,first,last)
VALUES ( @PDF,@SSN,@first,@last)