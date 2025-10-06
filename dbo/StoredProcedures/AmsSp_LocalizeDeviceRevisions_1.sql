-----------------------------------------------------------------------
-- AmsSp_LocalizeDeviceRevisions_1
--
-- Localize the DeviceRevisions table
--
-- Inputs -
-- @nAmsDevRevId int
-- @sName
--
-- Outputs -
--
-- Returns -
--	0 - successful.
--	-1 - error
--
-- Junilo Pagobo - 06/24/2009
--
CREATE PROCEDURE AmsSp_LocalizeDeviceRevisions_1
@nAmsDevRevId int,
@sName nvarchar(255)
AS
declare @iReturnVal int
set @iReturnVal = 0

BEGIN TRY
	begin
		update DeviceRevisions set Name = @sName
		where AmsDevRevId = @nAmsDevRevId
	end
END TRY
BEGIN CATCH
	set @iReturnVal = -1
END CATCH

return @iReturnVal

GO

