
-------------------------------------------------------------------------------
-- AmsVw_AlertMonitorStartup
--
-- Get BlockKey's alert monitor information along with device hierarchy location
--	info.
--
-- Inputs --
--	none.
--
-- Outputs --
--	BlockKey
--	ExtBlockTag	(ie. AmsTag)
--	Area
--  Unit
--	Equipment
--	Control
--	MonitorGroup
--	Frequency
--	PlantServerKey
--  Protocol
--  MfrId
--  ProtocolRev
--  DeviceTypeCode
--  DeviceRevisionCode
--  SerialNumber
--
-- Author --
--	Joe Fisher
--	06/14/01
--  09/29/04
--	10/14/04
--	James Kramer 11/26/2007
--
-- Source control keywords --
-- $Date: 2/22/05 3:48p $
-- $Revision: 34 $
--
CREATE  VIEW dbo.AmsVw_AlertMonitorStartup
AS
SELECT AmsVw_DeviceTagLocation.BlockKey,
    AmsVw_DeviceTagLocation.AmsTag, 
    AmsVw_DeviceTagLocation.Area, 
    AmsVw_DeviceTagLocation.Unit, 
    AmsVw_DeviceTagLocation.Equipment, 
    AmsVw_DeviceTagLocation.Control,
    DeviceMonitorList.MonitorGroup AS MonitorGroup,
    DeviceMonitorList.Frequency, 
    PlantServer.PlantServerKey,
    DeviceMonitorList.DVMEnabled,
	AmsVw_DeviceTagLocation.MfrId,
	AmsVw_DeviceTagLocation.Manufacturer,
	AmsVw_DeviceTagLocation.Protocol,
	cast(AmsVw_DeviceTagLocation.ProtocolRevision as nvarchar(10)) as ProtocolRev,
	AmsVw_DeviceTagLocation.DeviceTypeCode,
	AmsVw_DeviceTagLocation.DeviceRevisionCode,
	AmsVw_DeviceTagLocation.SerialNumber,
	AmsVw_DeviceTagLocation.DeviceTypeName
FROM DeviceMonitorList LEFT OUTER JOIN
    AmsVw_DeviceTagLocation ON DeviceMonitorList.BlockKey = AmsVw_DeviceTagLocation.BlockKey INNER JOIN
	DeviceLocation ON DeviceLocation.BlockKey = DeviceMonitorList.BlockKey INNER JOIN
	NetworkInfo ON NetworkInfo.NetworkInfoKey = DeviceLocation.NetworkInfoKey INNER JOIN	
	PlantServer ON PlantServer.PlantServerKey = NetworkInfo.PlantServerKey

GO

