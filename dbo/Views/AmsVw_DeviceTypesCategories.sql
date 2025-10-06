-------------------------------------------------------------------------------
-- AmsVw_DeviceTypesCategories
--
-- Get the list of device types and major/minor categories.
-- Note: If Protocol value (ie. NamedConfigs.UniversalId) missing this will return
--	NULL.
--
-- Inputs --
--	none.
--
-- Outputs --
--	Manufacturer - the name.
--  Protocol
--	MfrId
--	DeviceTypeCode
-- 	DeviceTypeName
--	DeviceRevisionCode
--	DeviceRevisionName
--	ProtocolRev
--  AmsDevRevId
--	MajorCategory
--	MinorCategory
--
-- Author --
--	Joe Fisher
--	07/07/19
--
-- Source control keywords --
-- $Date: 2/22/05 3:48p $
-- $Revision: 34 $
--
CREATE VIEW [dbo].[AmsVw_DeviceTypesCategories]
AS
SELECT     dbo.Manufacturers.Name AS Manufacturer, dbo.DeviceProtocols.Name AS Protocol, dbo.MfrProtocols.MfrId, 
                      dbo.DeviceTypes.DeviceType AS DeviceTypeCode, dbo.DeviceTypes.Name AS DeviceTypeName, 
                      dbo.DeviceRevisions.DeviceRevision AS DeviceRevisionCode, dbo.DeviceRevisions.Name AS DeviceRevisionName, 
                      dbo.NamedConfigs.UniversalId AS ProtocolRev, dbo.DeviceRevisions.AmsDevRevId, dbo.MajorDeviceCategories.Name AS MajorCategory, 
                      dbo.MinorDeviceCategories.Name AS MinorCategory
FROM         dbo.Manufacturers INNER JOIN
                      dbo.MfrProtocols ON dbo.Manufacturers.AmsMfrNameId = dbo.MfrProtocols.AmsMfrNameId INNER JOIN
                      dbo.DeviceProtocols ON dbo.MfrProtocols.ProtocolId = dbo.DeviceProtocols.ProtocolId INNER JOIN
                      dbo.DeviceTypes ON dbo.MfrProtocols.MfrProtocolId = dbo.DeviceTypes.MfrProtocolId INNER JOIN
                      dbo.DeviceRevisions ON dbo.DeviceTypes.AmsDevTypeId = dbo.DeviceRevisions.AmsDevTypeId INNER JOIN
                      dbo.DeviceCategories ON dbo.DeviceRevisions.DeviceCategoryId = dbo.DeviceCategories.DeviceCategoryId INNER JOIN
                      dbo.MajorDeviceCategories ON dbo.DeviceCategories.MajorDeviceCategoryId = dbo.MajorDeviceCategories.MajorDeviceCategoryId INNER JOIN
                      dbo.MinorDeviceCategories ON dbo.DeviceCategories.MinorDeviceCategoryId = dbo.MinorDeviceCategories.MinorDeviceCategoryId LEFT OUTER JOIN
                      dbo.NamedConfigs ON dbo.DeviceRevisions.AmsDevRevId = dbo.NamedConfigs.AmsDevRevId

GO

