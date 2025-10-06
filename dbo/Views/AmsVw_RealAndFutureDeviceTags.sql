
-------------------------------------------------------------------------------
-- AmsVw_RealAndFutureDeviceTags
--
-- Get real and future device tag information.
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
--	SerialNumber	(defaults to '<future device>' for future devices)
--	ProtocolRevision
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
CREATE VIEW dbo.AmsVw_RealAndFutureDeviceTags
AS
SELECT AmsTag, 
    Manufacturer, 
    Protocol, 
    MfrId, 
    DeviceTypeCode, 
    DeviceTypeName, 
    DeviceRevisionCode, 
    DeviceRevisionName, 
    SerialNumber, 
    ProtocolRevision,
    N'Yes' as IsRealDevice
from AmsVw_DeviceTags
union
SELECT AmsTag, 
    Manufacturer, 
    Protocol, 
    MfrId, 
    DeviceTypeCode, 
    DeviceTypeName, 
    DeviceRevisionCode, 
    DeviceRevisionName, 
    N'<future device>' AS SerialNumber, 
    ProtocolRevision,
    N'No' as IsRealDevice
from AmsVw_FutureDeviceTags

GO

