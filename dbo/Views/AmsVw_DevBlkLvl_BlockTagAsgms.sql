
-------------------------------------------------------------------------------
-- AmsVw_DevBlkLvl_BlockTagAsgms
--
-- Combines AmsVw_DeviceLevelBlockKey with BlockAsgms and ExtBlockTags so we get
--	deviceBlock level perspective on block assignments and AmsTags.
--
-- Inputs --
--	none.
--
-- Outputs --
--	ExtBlockTag
--	EventIdDayOut
--	EventIdFractionOut
--	EventIdDayIn
--	EventIdFractionIn
--	BlockKey
--	DeviceLevelBlockKey
--
-- Author --
--	Joe Fisher
--	11/5/2003
--
CREATE  VIEW dbo.AmsVw_DevBlkLvl_BlockTagAsgms
AS
SELECT     dbo.ExtBlockTags.ExtBlockTag,
			dbo.BlockAsgms.EventIdDayOut,
			dbo.BlockAsgms.EventIdFractionOut,
			dbo.BlockAsgms.EventIdDayIn, 
            dbo.BlockAsgms.EventIdFractionIn,
			dbo.AmsVw_DeviceLevelBlockKey.BlockKey,
			dbo.AmsVw_DeviceLevelBlockKey.DeviceLevelBlockKey
FROM dbo.ExtBlockTags INNER JOIN dbo.BlockAsgms ON dbo.ExtBlockTags.ExtBlockTagKey = dbo.BlockAsgms.ExtBlockTagKey
	INNER JOIN dbo.AmsVw_DeviceLevelBlockKey ON dbo.BlockAsgms.BlockKey = dbo.AmsVw_DeviceLevelBlockKey.DeviceLevelBlockKey

GO

