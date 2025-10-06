
-----------------------------------------------------------------------
-- AmsSp_DeviceBlocks_HasBaseline_1
--
-- Note: for FF Server.
--
-- Check to see if the device-block as been 'baselined'.
--
-- Inputs -
--	@strDeviceID nvarchar(256)
--		This is the device identifier.
--	@iBlockIndex smallint
--		This is the block index.
--
-- Outputs -
--	@iBaselineStatus smallint
--		non-zero if device-block has been baselined else zero.
--
--
-- Returns -
--	returns 0 if successful execution else non-zero.
--
-- Joe Fisher, 06/24/2003
--
CREATE PROCEDURE AmsSp_DeviceBlocks_HasBaseline_1
@strDeviceID nvarchar(256),
@iBlockIndex smallint,
@iBaselineStatus smallint OUT
AS
declare @strErrorMsg nvarchar(256)

set @iBaselineStatus = 1

return 0

errorHandler:
print 'AmsSp_DeviceBlocks_HasBaseline_1: ' + @strErrorMsg
return 1

GO

