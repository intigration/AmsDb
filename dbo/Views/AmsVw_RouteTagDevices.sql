
-------------------------------------------------------------------------------
-- AmsVw_RouteTagDevices
--
-- Get routes information along with tag and devices currently assigned to them.
--
-- Inputs --
--	none.
--
-- Outputs --
--	FolderName
--	RouteName
--	RouteDescription
--	AmsTag
--	Manufacturer
--	Protocol
--  	MfrId
--	DeviceTypeCode
--	DeviceTypeName
--	DeviceRevisionCode
--	DeviceRevisionName
--	SerialNumber
--	ProtocolRevision
--	DL_Status -- tag download status.
--	RouteStatus
--
-- Author --
--	Joe Fisher
--	08/29/01
--
-- Source control keywords --
-- $Date: 2/22/05 3:48p $
-- $Revision: 34 $
--
CREATE VIEW dbo.AmsVw_RouteTagDevices
AS
SELECT dbo.RouteFolders.FolderName,
    dbo.Routes.RouteName, 
    dbo.Routes.RouteDescription, 
    dbo.AmsVw_DeviceTags.AmsTag, 
    dbo.AmsVw_DeviceTags.Manufacturer, 
    dbo.AmsVw_DeviceTags.Protocol, 
    dbo.AmsVw_DeviceTags.MfrId, 
    dbo.AmsVw_DeviceTags.DeviceTypeCode, 
    dbo.AmsVw_DeviceTags.DeviceTypeName, 
    dbo.AmsVw_DeviceTags.DeviceRevisionCode, 
    dbo.AmsVw_DeviceTags.DeviceRevisionName, 
    dbo.AmsVw_DeviceTags.SerialNumber, 
    dbo.AmsVw_DeviceTags.ProtocolRevision, 
    dbo.RouteTags.DL_Status,
    dbo.Routes.RouteStatus
FROM dbo.AmsVw_DeviceTags INNER JOIN
    dbo.ExtBlockTags ON 
    dbo.AmsVw_DeviceTags.AmsTag = dbo.ExtBlockTags.ExtBlockTag
     INNER JOIN
    dbo.RouteTags ON 
    dbo.ExtBlockTags.ExtBlockTagKey = dbo.RouteTags.ExtBlockTagKey
     INNER JOIN
    dbo.Routes ON 
    dbo.RouteTags.RouteId = dbo.Routes.RouteId INNER JOIN
    dbo.RouteFolders ON 
    dbo.Routes.FolderId = dbo.RouteFolders.FolderId

GO

