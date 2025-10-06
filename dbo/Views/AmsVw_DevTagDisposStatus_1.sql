

-------------------------------------------------------------------------------
-- AmsVw_DevTagDisposStatus_1
--
-- Get devices' ExtBlockTagKey, DispositionId, and EventIdDayOut for AO project
--
-- Inputs --
--	none.
--
-- Outputs --
--	ExtBlockTagKey	
--	DispositionId
--	EventIdDayOut
--  BlockKey
--  DeviceKey
--
-- Author --
--	Nghy Hong
--	11/08/02
--  12/09/03 Joe Fisher
--

CREATE VIEW dbo.AmsVw_DevTagDisposStatus_1
AS
SELECT BlockAsgms.ExtBlockTagKey,
		Devices.DispositionId,
		BlockAsgms.EventIdDayOut,
		Blocks.BlockKey,
		Devices.DeviceKey
FROM Devices INNER JOIN Blocks 
  ON Devices.DeviceKey = Blocks.DeviceKey
INNER JOIN Blockasgms 
  ON Blocks.BlockKey = BlockAsgms.BlockKey

GO

