
-------------------------------------------------------------------------------
-- AmsVw_BlockLocation
--
-- Present device hierarchy location along with the blockKey assigned to the
--	location.
--
-- Inputs --
--	none.
--
-- Outputs --
--	Area
--  	Unit
--	Equipment
--	Control
--	TableKey	(ie. blockKey)
--
-- Author --
--	Joe Fisher
--	06/14/01
--
-- Source control keywords --
-- $Date: 2/22/05 3:48p $
-- $Revision: 34 $
--
CREATE VIEW dbo.AmsVw_BlockLocation
AS
SELECT dbo.AmsVw_AreaUnitEquipCntl.Area, 
    dbo.AmsVw_AreaUnitEquipCntl.Unit, 
    dbo.AmsVw_AreaUnitEquipCntl.Equipment, 
    dbo.AmsVw_AreaUnitEquipCntl.Control, 
    dbo.Components.TableKey
FROM dbo.AmsVw_AreaUnitEquipCntl INNER JOIN
    dbo.Components ON 
    dbo.AmsVw_AreaUnitEquipCntl.AreaId = dbo.Components.AreaId
WHERE (dbo.Components.TableName = N'blocks')

GO

