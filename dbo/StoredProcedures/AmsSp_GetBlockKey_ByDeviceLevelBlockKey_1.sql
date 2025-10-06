
-----------------------------------------------------------------------
-- AmsSp_GetBlockKey_ByDeviceLevelBlockKey_1
--
-- Gets the blockKey of the deviceLevel blockKey and the blockIndex. 
-- if not found then returns -999.
--
--
-- Inputs -
--	@nDeviceLevelBlockKey int
--		The blockKey of the device.
--	@nBlockIndex int
--		The blockIndex.
--
-- Outputs -
--	@nBlockKey int
--		The BlockKey.
--
-- Returns -
--	0 - successful.
--	-1 - Error
--
-- Joe Fisher, 9/10/2003
--
CREATE PROCEDURE AmsSp_GetBlockKey_ByDeviceLevelBlockKey_1
@nDeviceLevelBlockKey int,
@nBlockIndex int,
@nBlockKey int OUTPUT
AS

declare @iReturnVal int
set @iReturnVal = 0
set @nBlockKey = -999

-- get BlockKey if present.
SELECT  distinct   @nBlockKey = dbo.Blocks.BlockKey
	FROM         dbo.AmsVw_DeviceLevelBlockKey INNER JOIN
                      dbo.Blocks ON dbo.AmsVw_DeviceLevelBlockKey.DeviceKey = dbo.Blocks.DeviceKey
	WHERE     (dbo.AmsVw_DeviceLevelBlockKey.DeviceLevelBlockKey = @nDeviceLevelBlockKey) AND 
			  (dbo.Blocks.BlockIndex = @nBlockIndex)

if (@@ROWCOUNT = 0)
begin
	set @nBlockKey = -999
end

if @@ERROR != 0 
    set @iReturnVal = -1

return @iReturnVal

GO

