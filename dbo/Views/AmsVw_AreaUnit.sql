
-------------------------------------------------------------------------------
-- AmsVw_AreaUnit
--
-- Present a 2nd-level (ie. unit) view of the device hierarchy.
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
--	ParentAreaId
--  ViewAreaId
--	ArealLevel
--	Area (ie. AmsVw_Areas.AreaName)
--	Unit (ie. Hierarchies.AreaName at this level)
--
-- Author --
--	Joe Fisher
--	06/14/01
--
-- Source control keywords --
-- $Date: 2/22/05 3:48p $
-- $Revision: 34 $
--
CREATE VIEW dbo.AmsVw_AreaUnit
AS
SELECT dbo.Hierarchies.AreaId, dbo.Hierarchies.ParentAreaId, 
    dbo.Hierarchies.ViewAreaId, dbo.Hierarchies.AreaLevel, 
    dbo.AmsVw_Areas.AreaName AS Area, 
    dbo.Hierarchies.AreaName AS Unit
FROM dbo.Hierarchies RIGHT OUTER JOIN
    dbo.AmsVw_Areas ON 
    dbo.Hierarchies.ParentAreaId = dbo.AmsVw_Areas.ViewAreaId

GO

