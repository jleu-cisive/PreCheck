
--



CREATE   PROCEDURE [dbo].[FormTaskStatusChange]
(
	@statusID int,
	@devID int,
	@myCase int
) AS

	

	if(@myCase=1) --selected dev ==6 & status <> 14 & sta<>1
	begin
	UPDATE    dbo.Task
	SET       IsHidden = 1

	UPDATE    dbo.Task
	SET       IsHidden = 0
	WHERE    ( StatusID!=14 and StatusID=@statusID)
	end
	else if(@myCase=2)--dev<>6 and status<>1
	begin
	UPDATE    dbo.Task
	SET       IsHidden = 1

	UPDATE    dbo.Task
	SET       IsHidden = 0
	WHERE    (StatusID!=14 and ( developerID=@devID and statusID=@statusID ))
	end
	else if(@myCase=3)--selected both combobox in All, dev==6 & sta==1
	begin
	UPDATE    dbo.Task
	SET       IsHidden = 0

	UPDATE    dbo.Task
	SET       IsHidden = 1
	WHERE    (StatusID = 14)
	
	UPDATE    dbo.Task
	SET       ExpandCollapse = '-'
	WHERE     (ExpandCollapse = '+' and ishidden = 0 )

	end
	else if(@myCase=4)--selected cmbStatus==1 & dev <>6
	begin
	UPDATE    dbo.Task
	SET       IsHidden = 1

	UPDATE    dbo.Task
	SET       IsHidden = 0
	WHERE    (StatusID!=14 and developerID=@devID )

	end
	else if(@myCase=5)--status=14 & dev<>6
	begin
		if(@devID!=6)
		begin
		UPDATE    dbo.Task
		SET       IsHidden = 1

		UPDATE    dbo.Task
		SET       IsHidden = 0
		WHERE    (StatusID = 14 and developerID=@devID )

		end
	--end
		else if(@devID=6)
		begin
		UPDATE    dbo.Task
		SET       IsHidden = 1
	
		UPDATE    dbo.Task
		SET       IsHidden = 0
		WHERE    (StatusID = 14 )
		end
	end
