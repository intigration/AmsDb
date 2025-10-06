
-------------------------------------------------------------------------------
-- AmsVw_CurrentTagBlockAsgms
--
-- Get blockKey currently assigned to tags.
--
-- Inputs --
--	none.
--
-- Outputs --
--	AmsTag
--	BlockKey
--
-- Author --
--	Joe Fisher
--	06/14/01
--
-- Source control keywords --
-- $Date: 2/22/05 3:48p $
-- $Revision: 34 $
--
CREATE VIEW dbo.AmsVw_CurrentTagBlockAsgms
AS
SELECT ExtBlockTags.ExtBlockTag AS AmsTag, BlockAsgms.BlockKey, ExtBlockTags.ExtBlockTagKey
FROM ExtBlockTags INNER JOIN
    BlockAsgms ON 
    ExtBlockTags.ExtBlockTagKey = BlockAsgms.ExtBlockTagKey
WHERE (BlockAsgms.EventIdDayOut = 49710)

GO

