
-----------------------------------------------------------------------
-- AmsSp_GetDeviceCount_1
--
-- Get device count.
-- Note: this filters out the standard default.
--
-- Inputs -
--	none.
--
-- Outputs -
--	none.
--
-- Returns -
--	returns device count.
--	-1 - Error, unable to get information.
--
-- Joe Fisher, 03/19/2000
--
-- Source control keywords --
-- $Date: 2/17/05 3:47p $
-- $Revision: 121 $
--
CREATE PROCEDURE AmsSp_GetDeviceCount_1
AS

declare @iReturnVal int
set @iReturnVal = 0

SELECT @iReturnVal = COUNT(*)
FROM Devices with (nolock)
WHERE Devices.DeviceKey <> - 1

if (@@ERROR <> 0)
	set @iReturnVal = -1

return @iReturnVal

GO

