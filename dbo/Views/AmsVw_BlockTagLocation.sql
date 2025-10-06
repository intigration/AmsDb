
-------------------------------------------------------------------------------
-- AmsVw_BlockTagLocation
--
-- Present device hierarchy location along with the AmsTag assigned to the
--	location.  If no tag then NULL is returned for that location.
--
-- Inputs --
--	none.
--
-- Outputs --
--	Area
--  Unit
--	Equipment
--	Control
--	ExtBlockTag	(ie. AmsTag)
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
CREATE VIEW dbo.AmsVw_BlockTagLocation
AS
SELECT dbo.AmsVw_BlockLocation.Area, 
    dbo.AmsVw_BlockLocation.Unit, 
    dbo.AmsVw_BlockLocation.Equipment, 
    dbo.AmsVw_BlockLocation.Control, 
    dbo.ExtBlockTags.ExtBlockTag, 
    dbo.BlockAsgms.BlockKey
FROM dbo.ExtBlockTags INNER JOIN
    dbo.BlockAsgms ON 
    dbo.ExtBlockTags.ExtBlockTagKey = dbo.BlockAsgms.ExtBlockTagKey
     LEFT OUTER JOIN
    dbo.AmsVw_BlockLocation ON 
    dbo.BlockAsgms.BlockKey = dbo.AmsVw_BlockLocation.TableKey
WHERE (dbo.BlockAsgms.EventIdDayOut = 49710)

GO

