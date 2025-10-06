
-------------------------------------------------------------------------------
-- AmsVw_BlockTagLocation_2
--
-- This view is an extension of AmsVw_BlockTagLocation to include device protocol
-- Refer to AmsVw_BlockTagLocation of its detail explaination
--
-- Inputs --
--	none.
--
-- Outputs --
--	Area
--  	Unit
--	Equipment
--	Control
--	ExtBlockTag	(ie. AmsTag)
--	BlockKey
--	Protocol
--
-- Author --
--	Nghy Hong
--	07/22/04
--
-- Source control keywords --
-- $Date: 2/22/05 3:48p $
-- $Revision: 34 $
--
CREATE VIEW dbo.AmsVw_BlockTagLocation_2
AS
SELECT dbo.AmsVw_BlockLocation.Area, 
    dbo.AmsVw_BlockLocation.Unit, 
    dbo.AmsVw_BlockLocation.Equipment, 
    dbo.AmsVw_BlockLocation.Control, 
    dbo.ExtBlockTags.ExtBlockTag, 
    dbo.BlockAsgms.BlockKey,
    dbo.AmsVw_BlockTags.Protocol
FROM dbo.ExtBlockTags INNER JOIN
    dbo.BlockAsgms ON 
    dbo.ExtBlockTags.ExtBlockTagKey = dbo.BlockAsgms.ExtBlockTagKey
     LEFT OUTER JOIN
    dbo.AmsVw_BlockLocation ON 
    dbo.BlockAsgms.BlockKey = dbo.AmsVw_BlockLocation.TableKey
     LEFT OUTER JOIN
    dbo.AmsVw_BlockTags ON
    dbo.BlockAsgms.BlockKey = dbo.AmsVw_BlockTags.BlockKey
WHERE (dbo.BlockAsgms.EventIdDayOut = 49710)

GO

