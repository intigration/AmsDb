-----------------------------------------------------------------------
-- AmsSp_GetLiveAmsFFDeviceId_1
-- Get AMS FF device identifier from the given FF device identifier for the FF device  
-- that is currently identified in the AMS Device Manager system.
--
-- Inputs -
--	@sFFDeviceId  -- FF  physical device identifier.
--
-- Outputs 
--	@sLiveAmsFFDeviceId  -- AMS FF device identifier that is currently 
--							identified in the AMS Device Manager system (i.e. live device). 
--
-- Returns -
--	0 - successful.
--  -1 - Device not found
--	-2 - General Error.
--
-- Nghy Hong - 12/17/2010
CREATE PROCEDURE AmsSp_GetLiveAmsFFDeviceId_1
@sFFDeviceId nvarchar(256),
@sLiveAmsFFDeviceId nvarchar(256) out
AS
declare @nReturn int;
set @nReturn = 0;

BEGIN TRY
	set @sLiveAmsFFDeviceId = '';
	SELECT @sLiveAmsFFDeviceId = Devices.Identifier
	FROM  Devices INNER JOIN
				   Blocks ON Devices.DeviceKey = Blocks.DeviceKey INNER JOIN
				   DeviceLocation ON Blocks.BlockKey = DeviceLocation.BlockKey
	WHERE (Devices.Identifier LIKE @sFFDeviceId + '%') AND (DeviceLocation.IdentStatus = 1)

	if (@@ROWCOUNT <> 1)
	begin
		set @nReturn = -1 --live device not found
	end

END TRY
BEGIN CATCH
	set @nReturn = -2;  --General error
END CATCH

return @nReturn;

GO

