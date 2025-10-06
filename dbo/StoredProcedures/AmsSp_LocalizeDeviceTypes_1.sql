-----------------------------------------------------------------------
-- AmsSp_LocalizeDeviceTypes_1
--
-- Localize the DeviceTypes table
--
-- Inputs -
-- @nAmsDevTypeId int
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
CREATE PROCEDURE AmsSp_LocalizeDeviceTypes_1
@nAmsDevTypeId int,
@sName nvarchar(255)
AS
declare @iReturnVal int
set @iReturnVal = 0

BEGIN TRY
	begin
		update DeviceTypes set Name = @sName
		where AmsDevTypeId = @nAmsDevTypeId
	end
END TRY
BEGIN CATCH
	set @iReturnVal = -1
END CATCH

return @iReturnVal

GO

