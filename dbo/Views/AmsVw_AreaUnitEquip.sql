
-------------------------------------------------------------------------------
-- AmsVw_AreaUnitEquip
--
-- Present a 3rd-level (ie. equipment) view of the device hierarchy.
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
--	AmsVw_AreaUnit.Area
--  AmsVw_AreaUnit.Unit
--	Equipment  (ie. Hierarchies.AreaName at this level)
--
-- Author --
--	Joe Fisher
--	06/14/01
--
-- Source control keywords --
-- $Date: 2/22/05 3:48p $
-- $Revision: 34 $
--
CREATE VIEW dbo.AmsVw_AreaUnitEquip
AS
SELECT dbo.Hierarchies.AreaId, dbo.AmsVw_AreaUnit.Area, 
    dbo.AmsVw_AreaUnit.Unit, 
    dbo.Hierarchies.AreaName AS Equipment
FROM dbo.AmsVw_AreaUnit LEFT OUTER JOIN
    dbo.Hierarchies ON 
    dbo.AmsVw_AreaUnit.AreaId = dbo.Hierarchies.ParentAreaId

GO

