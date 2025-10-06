
-------------------------------------------------------------------------------
-- AmsVw_RealAndFutureDeviceTagLocation
--
-- List real and future device information along with where it is assigned.
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
--	SerialNumber	(for future devices defaults to '<future device>')
--	AmsDeviceId	(for future devices defaults to '<future device>')
--	BlockKey	(for future devices NamedConfigs.ConfigKey)
--	BlockIndex	(for future devices defaults to 0)
--	DeviceDisposition	(for future devices defaults to '<future device>')
--	Area
--      Unit
--	Equipment
--	Control
--	AmsTag		(for future devices this is the NamedConfigs.ConfigName)
--	PlantServerId	(ie. plant server machine name.)	(for future devices defaults to '<future device>')
--	PlantServerKey	(for future devices defaults to 0)
--	IsRealDevice	('Yes' for real devices, 'No' for future devices)
--
-- Author --
--	Joe Fisher
--	09/17/01
--
-- Source control keywords --
-- $Date: 2/22/05 3:48p $
-- $Revision: 34 $
--
CREATE VIEW dbo.AmsVw_RealAndFutureDeviceTagLocation
AS
select Manufacturer,
       MfrId,
       Protocol,
       DeviceTypeCode,
       DeviceTypeName,
       DeviceRevisionCode,
       DeviceRevisionName,
       SerialNumber,
       ProtocolRevision,
       AmsDeviceId,
       BlockKey,
       BlockIndex,
       DeviceDisposition,
       Area,
       Unit,
       Equipment,
       Control,
       AmsTag,
       PlantServerId,
       PlantServerKey,
       N'Yes' as IsRealDevice
from AmsVw_DeviceTagLocation
union
select Manufacturer,
       MfrId,
       Protocol,
       DeviceTypeCode,
       DeviceTypeName,
       DeviceRevisionCode,
       DeviceRevisionName,
       SerialNumber,
       ProtocolRevision,
       AmsDeviceId,
       BlockKey,
       BlockIndex,
       DeviceDisposition,
       Area,
       Unit,
       Equipment,
       Control,
       AmsTag,
       PlantServerId,
       PlantServerKey,
       N'No' as IsRealDevice
from AmsVw_FutureDeviceTagLocation

GO

