
-----------------------------------------------------------------------
-- AmsSp_WirelessServices_GetDeviceLocations
--
--	Return the associated Physical Network information, Device Type
--	information and Devices for the specified input filtering.
--
--
-- Inputs --
--	None.
--
-- Recordsets output --  There are four output recordsets.  This is
--				because the calling client is expecting four recordsets.
--				One for Physical Networks, one for Device Type Information,
--				one for plant locations (i.e. plantHierarchy), 
--				and one for Device specific information.
--
--
-- Joe Fisher, 2007/07/18
-- Nghy Hong, 2007/11/20  AOEP00024567 filter out invalid network
-- Nghy Hong, 2008/7/1	  AOEP00026367 filter out IdentStatus = 0
-- James Kramer 2008/9/30  AOEP00027950 - added an isnull check to return ProtocolRev when 
--                                        a device does not have a DD associated with it
-- Nghy Hong 2010/03/03 Added GATEWAY_DEVICE_WIOC filter for DeltaV WIOC
--
CREATE PROCEDURE AmsSp_WirelessServices_GetDeviceLocations 
AS

-- make sure temp tables are cleaned-up just in case.
IF OBJECT_ID(N'tempdb..#AmsSp_WirelessServices_SelectedDevices', N'U') IS NOT NULL 
	DROP TABLE #AmsSp_WirelessServices_SelectedDevices;
IF OBJECT_ID(N'tempdb..#AmsSp_WirelessServices_PlantLocationBlockKeys', N'U') IS NOT NULL 
	DROP TABLE #AmsSp_WirelessServices_PlantLocationBlockKeys;
IF OBJECT_ID(N'tempdb..#AmsSp_WirelessServices_PlantLocations', N'U') IS NOT NULL 
	DROP TABLE #AmsSp_WirelessServices_PlantLocations;

-- select all devices that belong on this set.
Select DeviceLocation.BlockKey,
		NetworkInfoKey,
		AmsDevRevId,
		Identifier as SerialNumber,
		Area, Unit, Equipment, Control
into #AmsSp_WirelessServices_SelectedDevices
from dbo.DeviceLocation
inner join Blocks on Blocks.BlockKey = DeviceLocation.BlockKey
inner join Devices on Devices.DeviceKey = Blocks.DeviceKey
inner join dbo.AmsVw_BlockTagLocation on Blocks.BlockKey = dbo.AmsVw_BlockTagLocation.BlockKey
WHERE	( 
		  (
			(dbo.DeviceLocation.LatencyFactor = 3) 
			or (dbo.DeviceLocation.AmsPath like '%GATEWAY_DEVICE') 
			or (dbo.DeviceLocation.AmsPath like '%GATEWAY_DEVICE_WIOC')
		  )
		  and (dbo.DeviceLocation.NetworkInfoKey <> -1) and (dbo.DeviceLocation.IdentStatus = 1)
		)

update #AmsSp_WirelessServices_SelectedDevices
	set #AmsSp_WirelessServices_SelectedDevices.Area = '__unassigned__',
		#AmsSp_WirelessServices_SelectedDevices.Unit = '__unassigned__',
		#AmsSp_WirelessServices_SelectedDevices.Equipment = '__unassigned__',
		#AmsSp_WirelessServices_SelectedDevices.Control = '__unassigned__'
	from #AmsSp_WirelessServices_SelectedDevices
	where #AmsSp_WirelessServices_SelectedDevices.Area is null

-- build up the plantLocations for the selected devices.
SELECT DISTINCT
		PlantLocationID=IDENTITY(int,1,1),
	    #AmsSp_WirelessServices_SelectedDevices.Area,
		#AmsSp_WirelessServices_SelectedDevices.Unit,
		#AmsSp_WirelessServices_SelectedDevices.Equipment,
		#AmsSp_WirelessServices_SelectedDevices.Control
	into #AmsSp_WirelessServices_PlantLocations
	FROM  #AmsSp_WirelessServices_SelectedDevices

select BlockKey, PlantLocationID
into #AmsSp_WirelessServices_PlantLocationBlockKeys
from #AmsSp_WirelessServices_PlantLocations p1 inner join #AmsSp_WirelessServices_SelectedDevices p2
on (p1.Area = p2.Area)
and (p1.Unit = p2.Unit)
and (p1.Equipment = p2.Equipment)
and (p1.Control = p2.Control)


-- output the expected recordsets.
-- network info
SELECT DISTINCT
			dbo.NetworkInfo.NetworkInfoKey, 
			dbo.PlantServer.PlantServerId, 
			dbo.NetworkInfo.NetworkId, 
			dbo.NetworkInfo.NetworkName, 
			dbo.NetworkInfo.NetworkKindAsString
FROM	dbo.DeviceLocation INNER JOIN
			#AmsSp_WirelessServices_SelectedDevices on #AmsSp_WirelessServices_SelectedDevices.NetworkInfoKey = dbo.DeviceLocation.NetworkInfoKey
			inner join dbo.NetworkInfo ON dbo.NetworkInfo.NetworkInfoKey = dbo.DeviceLocation.NetworkInfoKey INNER JOIN
			dbo.PlantServer ON dbo.NetworkInfo.PlantServerKey = dbo.PlantServer.PlantServerKey

select * from #AmsSp_WirelessServices_PlantLocations

-- send device types that are involved
select distinct
	AmsVw_DeviceTypesCategories.AmsDevRevId as AmsDevRevId,
	Manufacturer,
	MfrId,
	Protocol,
	isnull(AmsVw_DeviceTypesCategories.ProtocolRev,Devices.ProtocolRevision) as ProtocolRev,
	DeviceTypeName,
	DeviceTypeCode,
	DeviceRevisionName,
	DeviceRevisionCode,
	MajorCategory,
	MinorCategory
from AmsVw_DeviceTypesCategories inner join Devices on Devices.AmsDevRevId = AmsVw_DeviceTypesCategories.AmsDevRevId
	inner join Blocks on Blocks.DeviceKey = Devices.DeviceKey
	inner join #AmsSp_WirelessServices_SelectedDevices on #AmsSp_WirelessServices_SelectedDevices.BlockKey = Blocks.BlockKey

-- now go ahead and send the device specific information.
select
	AmsTag,
	DeviceLocation.NetworkInfoKey,
	PlantLocationID,
	AmsDevRevId,
	AmsPath,
	SerialNumber
from #AmsSp_WirelessServices_SelectedDevices
	inner join AmsVw_CurrentTagBlockAsgms on AmsVw_CurrentTagBlockAsgms.BlockKey = #AmsSp_WirelessServices_SelectedDevices.BlockKey
	inner join DeviceLocation on DeviceLocation.BlockKey = #AmsSp_WirelessServices_SelectedDevices.BlockKey
	inner join #AmsSp_WirelessServices_PlantLocationBlockKeys on #AmsSp_WirelessServices_PlantLocationBlockKeys.BlockKey = #AmsSp_WirelessServices_SelectedDevices.BlockKey

-- cleanup.
IF OBJECT_ID(N'tempdb..#AmsSp_WirelessServices_SelectedDevices', N'U') IS NOT NULL 
	DROP TABLE #AmsSp_WirelessServices_SelectedDevices;
IF OBJECT_ID(N'tempdb..#AmsSp_WirelessServices_PlantLocationBlockKeys', N'U') IS NOT NULL 
	DROP TABLE #AmsSp_WirelessServices_PlantLocationBlockKeys;
IF OBJECT_ID(N'tempdb..#AmsSp_WirelessServices_PlantLocations', N'U') IS NOT NULL 
	DROP TABLE #AmsSp_WirelessServices_PlantLocations;

GO

