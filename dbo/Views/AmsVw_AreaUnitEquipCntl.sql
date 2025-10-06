
-------------------------------------------------------------------------------
-- AmsVw_AreaUnitEquipCntl
--
-- Present a 4th-level (ie. control) view of the device hierarchy.
--
-- Note: this one part in a family of AmsVw_area's type views
--	which provide views into the device hierarchy as if they are
--	tables- albet virtual.
--
-- Inputs --
--	none.
--
-- Outputs --
--	AreaId
--	AmsVw_AreaUnitEquip.Area
--  AmsVw_AreaUnitEquip.Unit
--	AmsVw_AreaUnitEquip.Equipment
--	Control  (ie. the AreaName of this level.)
--
-- Author --
--	Joe Fisher
--	06/14/01
--
-- Source control keywords --
-- $Date: 2/22/05 3:48p $
-- $Revision: 34 $
--
CREATE VIEW dbo.AmsVw_AreaUnitEquipCntl
AS
SELECT dbo.Hierarchies.AreaId, dbo.AmsVw_AreaUnitEquip.Area, 
    dbo.AmsVw_AreaUnitEquip.Unit, 
    dbo.AmsVw_AreaUnitEquip.Equipment, 
    dbo.Hierarchies.AreaName AS Control
FROM dbo.AmsVw_AreaUnitEquip LEFT OUTER JOIN
    dbo.Hierarchies ON 
    dbo.AmsVw_AreaUnitEquip.AreaId = dbo.Hierarchies.ParentAreaId

GO

