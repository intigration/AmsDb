
/****** Object:  View dbo.AmsVw_DeviceTagLocationRoutes    Script Date: 9/6/01 10:32:43 AM ******/
--
-- Source control keywords --
-- $Date: 2/22/05 3:48p $
-- $Revision: 34 $
CREATE VIEW dbo.AmsVw_DeviceTagLocationRoutes
AS
SELECT dbo.Manufacturers.Name AS Manufacturer, 
    dbo.MfrProtocols.MfrId, 
    dbo.DeviceProtocols.Name AS Protocol, 
    dbo.DeviceTypes.DeviceType AS DeviceTypeCode, 
    dbo.DeviceTypes.Name AS DeviceTypeName, 
    dbo.DeviceRevisions.DeviceRevision AS DeviceRevisionCode, 
    dbo.DeviceRevisions.Name AS DeviceRevisionName, 
    dbo.Devices.Identifier AS SerialNumber, 
    dbo.Devices.ProtocolRevision, dbo.Devices.AmsDeviceId, 
    dbo.Blocks.BlockKey, dbo.Blocks.BlockIndex, 
    dbo.Dispositions.Name AS DeviceDisposition, 
    dbo.AmsVw_BlockLocation.Area, 
    dbo.AmsVw_BlockLocation.Unit, 
    dbo.AmsVw_BlockLocation.Equipment, 
    dbo.AmsVw_BlockLocation.Control, 
    dbo.ExtBlockTags.ExtBlockTag AS AmsTag, 
    dbo.PlantServer.PlantServerId, 
    dbo.PlantServer.PlantServerKey, 
    dbo.RouteFolders.FolderName, dbo.Routes.RouteName
FROM dbo.RouteTags INNER JOIN
    dbo.Routes ON 
    dbo.RouteTags.RouteId = dbo.Routes.RouteId INNER JOIN
    dbo.RouteFolders ON 
    dbo.Routes.FolderId = dbo.RouteFolders.FolderId RIGHT OUTER
     JOIN
    dbo.DeviceRevisions INNER JOIN
    dbo.Devices ON 
    dbo.DeviceRevisions.AmsDevRevId = dbo.Devices.AmsDevRevId
     INNER JOIN
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
    dbo.Blocks ON 
    dbo.Devices.DeviceKey = dbo.Blocks.DeviceKey INNER JOIN
    dbo.Dispositions ON 
    dbo.Devices.DispositionId = dbo.Dispositions.DispositionId INNER
     JOIN
    dbo.BlockAsgms ON 
    dbo.Blocks.BlockKey = dbo.BlockAsgms.BlockKey INNER JOIN
    dbo.ExtBlockTags ON 
    dbo.BlockAsgms.ExtBlockTagKey = dbo.ExtBlockTags.ExtBlockTagKey
     ON 
    dbo.RouteTags.ExtBlockTagKey = dbo.ExtBlockTags.ExtBlockTagKey
     LEFT OUTER JOIN
    dbo.PlantServer INNER JOIN
    dbo.DeviceLocation ON 
    dbo.PlantServer.PlantServerKey = dbo.DeviceLocation.PlantServerKey
     ON 
    dbo.Blocks.BlockKey = dbo.DeviceLocation.BlockKey LEFT OUTER
     JOIN
    dbo.AmsVw_BlockLocation ON 
    dbo.Blocks.BlockKey = dbo.AmsVw_BlockLocation.TableKey
WHERE (dbo.BlockAsgms.EventIdDayOut = 49710)

GO

