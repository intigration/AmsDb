
-------------------------------------------------------------------------------
-- AmsVw_Areas
--
-- Present a top-level (ie. area) view of the device hierarchy.
--
-- Note: this one part in a family of AmsVw_area's type views
--	which provide views into the device hierarchy as if they are
--	tables- albet virtual.
--
-- Inputs --
--	none.
--
-- Outputs --
--	ArealLevel
--  ViewAreaId
--	AreaName
--
-- Author --
--	Joe Fisher
--	06/14/01
--
-- Source control keywords --
-- $Date: 2/22/05 3:48p $
-- $Revision: 34 $
--
CREATE VIEW dbo.AmsVw_Areas
AS
SELECT AreaLevel, ViewAreaId, AreaName
FROM dbo.Hierarchies
WHERE (AreaLevel = 0) AND (AreaName <> N'Manufacturer')

GO

