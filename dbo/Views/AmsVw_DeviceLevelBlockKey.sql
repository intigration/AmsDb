
-------------------------------------------------------------------------------
-- AmsVw_DeviceLevelBlockKey
--
-- Get the device level block key for each block key that is not a device level block (block index > 0).
-- Currently only Resource and Transducer blocks have a block index > 0
--
-- Inputs --
--	none.
--
-- Outputs --
--	BlockKey
--	DeviceLevelBlockKey
--	BlockIndex
--
-- Author --
--	Joe Fisher
--	07/31/03
--
-- Source control keywords --
-- $Date: 2/22/05 3:48p $
-- $Revision: 34 $
--
CREATE VIEW dbo.AmsVw_DeviceLevelBlockKey
AS
SELECT     dbo.Blocks.BlockKey, Blocks_1.BlockKey AS DeviceLevelBlockKey, dbo.Blocks.BlockIndex, dbo.Blocks.DeviceKey
FROM         dbo.Blocks INNER JOIN
                      dbo.Blocks Blocks_1 ON dbo.Blocks.DeviceKey = Blocks_1.DeviceKey
WHERE     (Blocks_1.BlockIndex = 0)

GO

