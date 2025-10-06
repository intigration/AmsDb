
-------------------------------------------------------------------------------
-- AmsVw_AlertMonitorBlockInfo
--
-- Get information on blocks that are in the DeviceMonitorList.
--
-- Inputs --
--	none.
--
-- Outputs --
--	AmsTag		(tag currently assigned to block.)
--	Manufacturer
--	Protocol
--  	MfrId
--	DeviceTypeCode
--	DeviceTypeName
--	DeviceRevisionCode
--	DeviceRevisionName
--	ProtocolRevision
--	SerialNumber
--	PlantServerId	(ie. name)
--	PlantServerKey
--	MonitorGroup
--	Frequency
--  DVMEnable
--
-- Author --
--	Joe Fisher
--	04/12/02
--  10/12/04
--	James Kramer
--	11/26/2007
--
-- Source control keywords --
-- $Date: 2/22/05 3:48p $
-- $Revision: 34 $
--
CREATE VIEW dbo.AmsVw_AlertMonitorBlockInfo
AS
SELECT  dbo.AmsVw_BlockTags.AmsTag,
	dbo.AmsVw_BlockTags.Manufacturer,
	dbo.AmsVw_BlockTags.Protocol,
	dbo.AmsVw_BlockTags.MfrId, 
    dbo.AmsVw_BlockTags.DeviceTypeCode,
	dbo.AmsVw_BlockTags.DeviceTypeName,
	dbo.AmsVw_BlockTags.DeviceRevisionCode, 
    dbo.AmsVw_BlockTags.DeviceRevisionName,
	dbo.AmsVw_BlockTags.BlockKey,
	dbo.AmsVw_BlockTags.ProtocolRevision, 
    dbo.AmsVw_BlockTags.SerialNumber,
	dbo.PlantServer.PlantServerId,
	dbo.PlantServer.PlantServerKey,
	dbo.DeviceMonitorList.MonitorGroup, 
    dbo.DeviceMonitorList.Frequency,
	dbo.DeviceMonitorList.DVMEnabled
FROM  dbo.DeviceMonitorList INNER JOIN
	  dbo.DeviceLocation ON dbo.DeviceLocation.BlockKey = dbo.DeviceMonitorList.BlockKey INNER JOIN
	  dbo.NetworkInfo ON dbo.NetworkInfo.NetworkInfoKey = dbo.DeviceLocation.NetworkInfoKey INNER JOIN	
      dbo.PlantServer ON dbo.PlantServer.PlantServerKey = dbo.NetworkInfo.PlantServerKey INNER JOIN
      dbo.AmsVw_BlockTags ON dbo.DeviceMonitorList.BlockKey = dbo.AmsVw_BlockTags.BlockKey

GO

