
-------------------------------------------------------------------------------
-- AmsVw_NamedConfigsLocation
--
-- Present namedConfig device (ie. 'future' device) hierarchy location along
-- with the ConfigKey assigned to the location.
--
-- Inputs --
--	none.
--
-- Outputs --
--	Area
--  	Unit
--	Equipment
--	Control
--	TableKey	(ie. ConfigKey)
--
-- Author --
--	Joe Fisher
--	09/17/01
--
-- Source control keywords --
-- $Date: 2/22/05 3:48p $
-- $Revision: 34 $
--
CREATE VIEW dbo.AmsVw_NamedConfigsLocation
AS
SELECT AmsVw_AreaUnitEquipCntl.Area, 
    AmsVw_AreaUnitEquipCntl.Unit, 
    AmsVw_AreaUnitEquipCntl.Equipment, 
    AmsVw_AreaUnitEquipCntl.Control, 
    Components.TableKey
FROM dbo.AmsVw_AreaUnitEquipCntl INNER JOIN
    dbo.Components ON 
    dbo.AmsVw_AreaUnitEquipCntl.AreaId = dbo.Components.AreaId
WHERE (dbo.Components.TableName = N'namedconfigs')

GO

