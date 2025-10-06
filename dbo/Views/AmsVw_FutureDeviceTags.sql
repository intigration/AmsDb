
-------------------------------------------------------------------------------
-- AmsVw_FutureDeviceTags
--
-- Get future device information.
-- Note: for future devices only.
--
-- Inputs --
--	none.
--
-- Outputs --
--	AmsTag
--	Manufacturer
--	Protocol
--  	MfrId
--	DeviceTypeCode
--	DeviceTypeName
--	DeviceRevisionCode
--	DeviceRevisionName
--	SerialNumber	(defaults to '<future device>')
--	ProtocolRevision
--
-- Author --
--	Joe Fisher
--	09/17/01
--
-- Source control keywords --
-- $Date: 2/22/05 3:48p $
-- $Revision: 34 $
--
CREATE VIEW dbo.AmsVw_FutureDeviceTags
AS
SELECT dbo.NamedConfigs.ConfigName AS AmsTag, 
    dbo.Manufacturers.Name AS Manufacturer, 
    dbo.DeviceProtocols.Name AS Protocol, 
    dbo.MfrProtocols.MfrId, 
    dbo.DeviceTypes.DeviceType AS DeviceTypeCode, 
    dbo.DeviceTypes.Name AS DeviceTypeName, 
    dbo.DeviceRevisions.DeviceRevision AS DeviceRevisionCode, 
    dbo.DeviceRevisions.Name AS DeviceRevisionName, 
    N'<future device>' AS SerialNumber, 
    ProtocolRevision = 
	case
	    when NamedConfigs.UniversalId is NULL then N'0'
	    else NamedConfigs.UniversalId
	end
FROM dbo.Manufacturers INNER JOIN
    dbo.MfrProtocols ON 
    dbo.Manufacturers.AmsMfrNameId = dbo.MfrProtocols.AmsMfrNameId
     INNER JOIN
    dbo.DeviceProtocols ON 
    dbo.MfrProtocols.ProtocolId = dbo.DeviceProtocols.ProtocolId INNER
     JOIN
    dbo.DeviceTypes ON 
    dbo.MfrProtocols.MfrProtocolId = dbo.DeviceTypes.MfrProtocolId
     INNER JOIN
    dbo.DeviceRevisions ON 
    dbo.DeviceTypes.AmsDevTypeId = dbo.DeviceRevisions.AmsDevTypeId
     INNER JOIN
    dbo.NamedConfigs ON 
    dbo.DeviceRevisions.AmsDevRevId = dbo.NamedConfigs.AmsDevRevId
WHERE (dbo.NamedConfigs.ConfigType = N'F')

GO

