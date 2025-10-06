
-------------------------------------------------------------------------------
-- AmsVw_FutureDeviceTagLocation
--
-- Present future device information along with where it is assigned.
-- Note: this does not include 'real' devices.
-- Future devices and their data is stored in the NamedConfigs and NamedConfigData
-- tables.
--
-- Inputs --
--	none.
--
-- Outputs --
--	Manufacturer
--	MfrId
--	Protocol
--	DeviceTypeCode
--	DeviceTypeName
--	DeviceRevisionCode
--	DeviceRevisionName
--	SerialNumber	(defaults to '<future device>')
--	AmsDeviceId	(defaults to '<future device>')
--	BlockKey	(NamedConfigs.ConfigKey)
--	BlockIndex	(defaults to 0)
--	DeviceDisposition	(defaults to '<future device>')
--	Area
--      Unit
--	Equipment
--	Control
--	AmsTag		(this is the NamedConfigs.ConfigName)
--	PlantServerId	(ie. plant server machine name.)	(defaults to '<future device>')
--	PlantServerKey	(defaults to 0)
--
-- Author --
--	Joe Fisher
--	09/17/01
--
-- Source control keywords --
-- $Date: 2/22/05 3:48p $
-- $Revision: 34 $
--
CREATE VIEW dbo.AmsVw_FutureDeviceTagLocation
AS
SELECT dbo.Manufacturers.Name AS Manufacturer, 
    dbo.MfrProtocols.MfrId, 
    dbo.DeviceProtocols.Name AS Protocol, 
    dbo.DeviceTypes.DeviceType AS DeviceTypeCode, 
    dbo.DeviceTypes.Name AS DeviceTypeName, 
    dbo.DeviceRevisions.DeviceRevision AS DeviceRevisionCode, 
    dbo.DeviceRevisions.Name AS DeviceRevisionName, 
    N'<future device>' AS SerialNumber, 
    ProtocolRevision = 
	case
	    when NamedConfigs.UniversalId is NULL then N'0'
	    else NamedConfigs.UniversalId
	end,
    N'<future device>' AS AmsDeviceId,
    dbo.NamedConfigs.ConfigKey as BlockKey,
    0 AS BlockIndex, 
    N'<future device>' AS DeviceDisposition, 
    dbo.AmsVw_NamedConfigsLocation.Area, 
    dbo.AmsVw_NamedConfigsLocation.Unit, 
    dbo.AmsVw_NamedConfigsLocation.Equipment, 
    dbo.AmsVw_NamedConfigsLocation.Control,
    dbo.NamedConfigs.ConfigName AS AmsTag, 
    N'<future device>' as PlantServerId,
    0 as PlantServerKey
FROM dbo.DeviceRevisions INNER JOIN
    dbo.DeviceTypes ON 
    dbo.DeviceRevisions.AmsDevTypeId = dbo.DeviceTypes.AmsDevTypeId
     INNER JOIN
    dbo.MfrProtocols ON 
    dbo.DeviceTypes.MfrProtocolId = dbo.MfrProtocols.MfrProtocolId
     INNER JOIN
    dbo.Manufacturers ON 
    dbo.MfrProtocols.AmsMfrNameId = dbo.Manufacturers.AmsMfrNameId
     INNER JOIN
    dbo.DeviceProtocols ON 
    dbo.MfrProtocols.ProtocolId = dbo.DeviceProtocols.ProtocolId INNER
     JOIN
    dbo.NamedConfigs ON 
    dbo.DeviceRevisions.AmsDevRevId = dbo.NamedConfigs.AmsDevRevId
     LEFT OUTER JOIN
    dbo.AmsVw_NamedConfigsLocation ON 
    dbo.NamedConfigs.ConfigKey = dbo.AmsVw_NamedConfigsLocation.TableKey
WHERE (dbo.NamedConfigs.ConfigType = N'F')

GO

