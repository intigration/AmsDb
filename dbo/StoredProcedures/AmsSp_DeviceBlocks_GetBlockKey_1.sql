
-----------------------------------------------------------------------
-- AmsSp_DeviceBlocks_GetBlockKey_1
--
-- Get the BlockKey identifier.
--
-- Inputs -
--	@strDeviceID nvarchar(256)
--		This is the device identifier.
--	@iBlockIndex integer
--		This is the block index.
-- Outputs -
--	none
--
-- Returns -
--	BlockKey if found else -1.
--
-- Joe Fisher, 06/24/2003
--
CREATE PROCEDURE AmsSp_DeviceBlocks_GetBlockKey_1
@strDeviceID nvarchar(256),
@iBlockIndex int
AS
declare @iReturnVal int

select @iReturnVal = BlockKey
from dbo.Devices INNER JOIN dbo.Blocks ON dbo.Devices.DeviceKey = dbo.Blocks.DeviceKey
where (Devices.Identifier = @strDeviceID) and
      (Blocks.BlockIndex = @iBlockIndex)

if (@@ROWCOUNT <> 1)
begin
	set @iReturnVal = -1
end

return @iReturnVal

GO

