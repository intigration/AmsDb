
-----------------------------------------------------------------------
-- AmsSp_VLServices_GetDeviceLocations
--
--	Return the associated Physical Network information, Device Type
--	information and Devices for the specified input filtering.
--
--
-- Inputs --
--	@iMfrID - Manufacturer ID of the Manufacturer to return information
--				for.  This can either be base 10 (e.g. 38) or it can
--				be hexidecimal (e.g. 0x26).  
--			NOTE: When a Manufacturer ID is specified, all Mux Devies
--				shall also be returned.
--	@sProtocol - The protocol of devices to return information for.
--	@iConnectionState - Connection state of the devices to filter on to
--				return information for.
--
-- Recordsets output --  There are three output recordsets.  This is
--				because the calling client is expecting three recordsets.
--				One for Physical Networks, one for Device Type Information 
--				and one for Device specific information.
--
--
-- Corey Middendorf, 11/01/04
-- Joe Fisher, 07/25/07
--
CREATE PROCEDURE [dbo].[AmsSp_VLServices_GetDeviceLocations] 
@iMfrID int,
@sProtocol nvarchar(255),
@iConnectionState int
AS

declare @sSql nvarchar(max)
declare @sSqlWhereClause nvarchar(max)
declare @sTempSql nvarchar(max)
declare @sTempSqlWhereClause nvarchar(max)

--Setup the default where clause for all Select statements to use based on the inputs
set @sSqlWhereClause = ''
set @sTempSqlWhereClause = ''
set @sTempSql = ''

if ((@sProtocol <> '') OR (@iMfrId > 0) OR (@iConnectionState >= 0))
begin
	set @sSqlWhereClause = ' WHERE '
	if (@sProtocol <> '')
	begin
		set @sTempSqlWhereClause = ' AND (dbo.DeviceProtocols.Name=''' + @sProtocol + ''')'
		set @sSqlWhereClause = @sSqlWhereClause + '(Protocol=''' + @sProtocol + ''')'
		if ((@iMfrId > 0) OR (@iConnectionState >= 0))
		begin
			set @sSqlWhereClause = @sSqlWhereClause + ' AND '
		end
	end
	--Add Manufacturer filter if a iMfrId is specified and if it is not Conventional MfrId
	if (@iMfrId > 0)
	begin
		--HART manufacturers
		if (@iMfrId < 256)
		begin
			set @sTempSqlWhereClause = @sTempSqlWhereClause + ' AND ((dbo.MfrProtocols.MfrId=' + cast(@iMfrId as nvarchar(20)) + ') OR (dbo.DeviceLocation.AmsPath LIKE N''%MUX_DEVICE''))'
			set @sSqlWhereClause = @sSqlWhereClause + '((MfrId=' + cast(@iMfrId as nvarchar(20)) + ') OR (AmsPath LIKE N''%MUX_DEVICE''))'
		end
		--FF manufacturers
		if (@iMfrId >= 256)
		begin
			set @sTempSqlWhereClause = @sTempSqlWhereClause + ' AND (dbo.MfrProtocols.MfrId=' + cast(@iMfrId as nvarchar(20)) + ')'
			set @sSqlWhereClause = @sSqlWhereClause + '(MfrId=' + cast(@iMfrId as nvarchar(20)) + ')'
		end
		if (@iConnectionState >= 0)
		begin
			set @sSqlWhereClause = @sSqlWhereClause + ' AND '
		end
	end
	if (@iConnectionState >= 0)
	begin
		set @sTempSqlWhereClause = @sTempSqlWhereClause + ' AND (dbo.DeviceLocation.IdentStatus=' + cast(@iConnectionState as nvarchar(4)) + ')'
		set @sSqlWhereClause = @sSqlWhereClause + '(IdentStatus=' + cast(@iConnectionState as nvarchar(4)) + ')'
	end
end

--Setup a temp table
Create table #AmsSp_VLServices_GetDeviceLocations (
	NetworkInfoKey int, 
	PlantServerId nvarchar(255), 
	NetworkId nvarchar(255), 
	NetworkName nvarchar(1024), 
	NetworkKindAsString nvarchar (1024), 
	AsyncCommDepth int,
	AmsDevRevId int, 
	MfrName nvarchar(255), 
	MfrId int, 
	DeviceTypeName nvarchar(255), 
	DeviceTypeCode int, 
	DeviceRevisionCode int, 
	Protocol nvarchar(255), 
	AmsTag nvarchar(255), 
	SisStatus int, 
	IdentStatus int, 
	AmsDeviceId nvarchar(255), 
	Identifier nvarchar(255),
	AmsPath nvarchar(255), 
	moniker nvarchar(1024), 
	ProtocolRevision int, 
	SerialNumber nvarchar(255),
	SoftwareRev int,
	LatencyFactor smallint)
set @sTempSql = 'SELECT DISTINCT 
			dbo.NetworkInfo.NetworkInfoKey, 
			dbo.PlantServer.PlantServerId, 
			dbo.NetworkInfo.NetworkId, 
			dbo.NetworkInfo.NetworkName, 
			dbo.NetworkInfo.NetworkKindAsString, 
			AsyncCommDepth = case dbo.NetworkInfo.NetworkKindAsString
				when ''Mux Network'' then ''2''
					else ''1''
				end,
			dbo.DeviceRevisions.AmsDevRevId, 
			dbo.Manufacturers.Name AS MfrName, 
			dbo.MfrProtocols.MfrId, 
			dbo.DeviceTypes.Name AS DeviceTypeName, 
			dbo.DeviceTypes.DeviceType AS DeviceTypeCode, 
			dbo.DeviceRevisions.DeviceRevision AS DeviceRevisionCode, 
			dbo.DeviceProtocols.Name AS Protocol, 
			dbo.ExtBlockTags.ExtBlockTag AS AmsTag, 
			dbo.DeviceLocation.SisStatus, 
			dbo.DeviceLocation.IdentStatus, 
			dbo.Devices.AmsDeviceId, 
			dbo.Devices.Identifier, 
			dbo.DeviceLocation.AmsPath, 
			''moniker'' AS moniker, 
			dbo.Devices.ProtocolRevision, 
			dbo.Devices.Identifier AS SerialNumber, 
			dbo.AmsUdf_CurrentSoftwareRevision(dbo.BlockData.BlockKey) AS SoftwareRev,
			dbo.DeviceLocation.LatencyFactor
		FROM	dbo.NetworkInfo INNER JOIN
			dbo.DeviceLocation ON dbo.NetworkInfo.NetworkInfoKey = dbo.DeviceLocation.NetworkInfoKey INNER JOIN
			dbo.PlantServer ON dbo.NetworkInfo.PlantServerKey = dbo.PlantServer.PlantServerKey RIGHT OUTER JOIN
			dbo.Manufacturers INNER JOIN
			dbo.MfrProtocols ON dbo.Manufacturers.AmsMfrNameId = dbo.MfrProtocols.AmsMfrNameId INNER JOIN
			dbo.DeviceProtocols ON dbo.MfrProtocols.ProtocolId = dbo.DeviceProtocols.ProtocolId INNER JOIN
			dbo.DeviceTypes ON dbo.MfrProtocols.MfrProtocolId = dbo.DeviceTypes.MfrProtocolId INNER JOIN
			dbo.DeviceRevisions ON dbo.DeviceTypes.AmsDevTypeId = dbo.DeviceRevisions.AmsDevTypeId INNER JOIN
			dbo.Devices ON dbo.DeviceRevisions.AmsDevRevId = dbo.Devices.AmsDevRevId INNER JOIN
			dbo.Blocks ON dbo.Devices.DeviceKey = dbo.Blocks.DeviceKey INNER JOIN
			dbo.BlockAsgms ON dbo.Blocks.BlockKey = dbo.BlockAsgms.BlockKey INNER JOIN
			dbo.ExtBlockTags ON dbo.BlockAsgms.ExtBlockTagKey = dbo.ExtBlockTags.ExtBlockTagKey ON 
			dbo.DeviceLocation.BlockKey = dbo.Blocks.BlockKey LEFT OUTER JOIN
			dbo.BlockData ON dbo.Blocks.BlockKey = dbo.BlockData.BlockKey AND dbo.BlockData.ParamName = ''software_revision.0000009E.0000.0000''
		WHERE	(dbo.BlockAsgms.EventIdDayOut = 49710) AND (dbo.DeviceProtocols.Name <> ''Conventional'')'
set @sTempSql = @sTempSql + @sTempSqlWhereClause

insert into #AmsSp_VLServices_GetDeviceLocations exec (@sTempSql)

--This select statement gets the network information
set @sSql = 'SELECT DISTINCT
		PlantServerId, 
		NetworkInfoKey, 
		NetworkId, 
		NetworkName, 
		NetworkKindAsString,
		AsyncCommDepth
	FROM	#AmsSp_VLServices_GetDeviceLocations'

declare @sTempWhereClause nvarchar(2048)
if (@sSqlWhereClause = '')
begin
	set @sTempWhereClause = ' WHERE (NetworkInfoKey >= 0) AND (NetworkInfoKey IS NOT NULL)'
end
else
begin
	set @sTempWhereClause = @sSqlWhereClause + ' AND (NetworkInfoKey >= 0) AND (NetworkInfoKey IS NOT NULL)'
end
set @sSql = @sSql + @sTempWhereClause
print @sSql
exec(@sSql)


--This select statement gets the device type information
set @sSql = 'SELECT DISTINCT 
	      	AmsDevRevId, 
		MfrName, 
		MfrId, 
		DeviceTypeCode,
	      	DeviceTypeName, 
		DeviceRevisionCode,
		Protocol
	FROM   #AmsSp_VLServices_GetDeviceLocations'
set @sSql = @sSql + @sSqlWhereClause
exec(@sSql)


--This select statement gets the device information
set @sSql = 'SELECT   	AmsTag, 
			NetworkInfoKey = case NetworkInfoKey
				when ''-1'' then NULL
				else NetworkInfoKey
				end, 
			AmsDevRevId, 
                      	SisStatus, 
			IdentStatus, 
			Protocol, 
			MfrId, 
                      	DeviceTypeCode, 
			ProtocolRevision, 
			SerialNumber, 
                     	AmsPath, 
			''moniker'' AS Moniker, 
			AMSDeviceId,
			Identifier,
			SoftwareRev,
			LatencyFactor,
			DeviceRevisionCode
	FROM         	#AmsSp_VLServices_GetDeviceLocations'
set @sSql = @sSql + @sSqlWhereClause
exec(@sSql)

GO

