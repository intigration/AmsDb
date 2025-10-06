
-----------------------------------------------------------------------
-- AmsSp_GetDefaultHartAlertDesc_1
--
-- Retrieves the default description based on the supplied alert ID.
--
--
-- Inputs -
--	@sAlertId - default alert.
--
-- Outputs -
--	@sAlertDesc - alert description.
--
-- Returns -
--	0 - successful.
--	-1 - alert not found
--  -2 - db error
--
-- James Kramer 11/4/2008
--
CREATE PROCEDURE AmsSp_GetDefaultHartAlertDesc_1
@sAlertId nvarchar(50),
@sAlertDesc nvarchar(256) output
AS

declare @iReturnVal int
set @iReturnVal = 0

BEGIN TRY
	set @sAlertDesc = "InvalidDescription-" + @sAlertId

	select @sAlertDesc = Description
	from DeviceAlertDesc
	where AmsDevRevId = -1 and AlertId = @sAlertId

	if (@@rowcount = 0)
	begin
		set @iReturnVal = -1
	end
END TRY
BEGIN CATCH
	set @iReturnVal = -2
END CATCH

return @iReturnVal

GO

