-----------------------------------------------------------------------
-- AmsSp_AuditTrail_AllEvents_1
--
--	Note: this stored procedure was developed with AMS Device Manager audit trail UI and
--		genericExports.AuditTrail interface in mind.
--	  	Data returned is always sorted by EventIdDay, EventIdFraction in descending order.
--
-- Get audit trail event information based on the following user supplied parameters -
--
--	@sSelectClause	this contains a valid SQL select clause comprised of the following
--		possible columns --
		--	 EventIdDay int,
		--	 EventIdFraction int,
		--	 BlockKey int,
		--	 EventTime datetime,
		--	 CategoryDesc nvarchar(255),
		--	 ComputerId int,
		--	 Users nvarchar(50),
		--	 Source nvarchar(50),
		--	 Type int,
		--	 Description nvarchar(1024),
		--	 ExtBlockTag nvarchar(40),
		--	 Category int,
		--	 BlockIndex int,
		--	 BlockType nvarchar(1),
		--	 DeviceKey int,
		--	 Manufacturer nvarchar(255),
		--	 DeviceProtocol nvarchar(255),
		--	 DeviceType nvarchar(255),
		--	 DeviceRevision nvarchar(255),
		--	 Identifier nvarchar(255),
		--	 MfrId int,
		--	 DeviceTypeCode int,
		--	 DeviceRevisionCode int,
		--	 ProtocolRev int,
		--	 DispositionId int,
		--	 PlantServer nvarchar(255),
		--	 Disposition nvarchar(255),
		--	 AmsDeviceId nvarchar(255),
		--	 Other nvarchar(255)
--
--	@sWhereClause	standard SQL where clause (NOTE: without the 'WHERE' statement,
--		this will be added) based on any of the above columns and corresponding criteria.
--
--	@sDirection	 indicates what direction you want to traverse the overall view;
--		DESC = go back in time.
--		ASC  = go forward in time.
--
--	@nMaxCount		indicates the maximum number of records to return.
--
--
-- Outputs -
--	
--
-- Returns -
--		total records obtained.
--
-- Joe Fisher - 11/10/2003
--

CREATE PROCEDURE AmsSp_AuditTrail_AllEvents_1
@sSelectClause nvarchar(max),
@sWhereClause nvarchar(max),
@sDirection nvarchar(50),
@nMaxCount int
AS
declare @sStmt nvarchar(max)
-- 'desc' / 'asc' is based on the UI paging through the list with the most
-- recent event at the top of the list (ie. sorted in descending order.)
-- 'asc' means get the events from the eventId specified to the more recent
-- and conversely 'desc' means get the events from the eventId specified to
-- oldest.
declare @sSortOrder nvarchar(10)
set @sSortOrder = @sDirection

if (@nMaxCount < 0)
begin
	return -1
end

declare @sMaxCount nvarchar(10)
set @sMaxCount = cast(@nMaxCount as nvarchar(10))

-- cleanup the user's where clause
declare @sWhere nvarchar(max)
set @sWhere = ltrim(rtrim(@sWhereClause))
if (len(@sWhere) > 0)
	set @sWhere = 'WHERE ' + @sWhere
--print @sWhere

Create table #tTable
	(EventIdDay int,
	 EventIdFraction int,
	 BlockKey int,
	 EventTime datetime,
	 CategoryDesc nvarchar(255),
	 ComputerId int,
	 Users nvarchar(50),
	 Source nvarchar(50),
	 Type int,
	 Description nvarchar(1024),
	 ExtBlockTag nvarchar(40),
	 Category int,
	 BlockIndex int,
	 BlockType nvarchar(1),
	 DeviceKey int,
	 Manufacturer nvarchar(255),
	 DeviceProtocol nvarchar(255),
	 DeviceType nvarchar(255),
	 DeviceRevision nvarchar(255),
	 Identifier nvarchar(255),
	 MfrId int,
	 DeviceTypeCode int,
	 DeviceRevisionCode int,
	 ProtocolRev int,
	 DispositionId int,
	 PlantServer nvarchar(255),
	 Disposition nvarchar(255),
	 AmsDeviceId nvarchar(255),
	 Other nvarchar(255)
	)

set @sStmt = 'SELECT top ' + @sMaxCount
set @sStmt = @sStmt + ' EventLog.EventIdDay'
set @sStmt = @sStmt + ', EventLog.EventIdFraction'
set @sStmt = @sStmt + ', EventLog.BlockKey'
set @sStmt = @sStmt + ', CONVERT(nvarchar, EventLog.EventTime, 121) AS EventTime'
set @sStmt = @sStmt + ', EventCategories.CategoryDesc'
set @sStmt = @sStmt + ', EventLog.ComputerId'
set @sStmt = @sStmt + ', Users.UserName'
set @sStmt = @sStmt + ', EventLog.Source'
set @sStmt = @sStmt + ', EventLog.Type'
set @sStmt = @sStmt + ', EventLog.Description'
set @sStmt = @sStmt + ', CASE'
set @sStmt = @sStmt + ' When EventLog.blockkey <> -1'
set @sStmt = @sStmt + ' then'
set @sStmt = @sStmt + ' (SELECT  ExtBlockTag'
set @sStmt = @sStmt + ' FROM dbo.AmsVw_DevBlkLvl_BlockTagAsgms v1'
set @sStmt = @sStmt + ' WHERE (v1.BlockKey = EventLog.blockkey) and'
set @sStmt = @sStmt + ' ((EventLog.EventIdDay < v1.EventIdDayOut) OR'
set @sStmt = @sStmt + ' ((EventLog.EventIdDay = v1.EventIdDayOut) AND (EventLog.EventIdFraction < v1.EventIdFractionOut)))'
set @sStmt = @sStmt + ' AND'
set @sStmt = @sStmt + ' ((EventLog.EventIdDay > v1.EventIdDayIn) OR'
set @sStmt = @sStmt + ' ((EventLog.EventIdDay = v1.EventIdDayIn) AND (EventLog.EventIdFraction >= v1.EventIdFractionIn)))'
set @sStmt = @sStmt + ' )'
set @sStmt = @sStmt + ' else null'
set @sStmt = @sStmt + ' end'	-- CASE
set @sStmt = @sStmt + ' as ExtBlockTag'
set @sStmt = @sStmt + ', EventLog.Category'
set @sStmt = @sStmt + ', Blocks.BlockIndex'
set @sStmt = @sStmt + ', Blocks.BlockType'
set @sStmt = @sStmt + ', Devices.DeviceKey'
set @sStmt = @sStmt + ', Manufacturers.Name AS Manufacturer'
set @sStmt = @sStmt + ', DeviceProtocols.Name AS DeviceProtocol'
set @sStmt = @sStmt + ', DeviceTypes.Name AS DeviceType'
set @sStmt = @sStmt + ', DeviceRevisions.Name AS DeviceRevision'
set @sStmt = @sStmt + ', Devices.Identifier AS Identifier'
set @sStmt = @sStmt + ', MfrProtocols.MfrId as MfrId'
set @sStmt = @sStmt + ', DeviceTypes.DeviceType as DeviceTypeCode'
set @sStmt = @sStmt + ', DeviceRevisions.DeviceRevision as DeviceRevisionCode'
set @sStmt = @sStmt + ', Devices.ProtocolRevision AS ProtocolRevision'
set @sStmt = @sStmt + ', Devices.DispositionId AS DispositionId'
set @sStmt = @sStmt + ', PlantServer.PlantServerId AS PlantServer'
set @sStmt = @sStmt + ', Dispositions.Name AS Disposition'
set @sStmt = @sStmt + ', Devices.AmsDeviceId AS AmsDeviceId'
set @sStmt = @sStmt + ', EventLog.Other'
set @sStmt = @sStmt + ' FROM (Users INNER JOIN'
set @sStmt = @sStmt + ' (EventCategories INNER JOIN EventLog ON EventCategories.Category = EventLog.Category AND EventLog.Category <> 49 )'
set @sStmt = @sStmt + ' ON Users.UserKey = EventLog.UserKey)'
set @sStmt = @sStmt + ' LEFT JOIN BlockAsgms ON ( BlockAsgms.BlockKey = EventLog.BlockKey AND'
set @sStmt = @sStmt + ' ((EventLog.EventIdDay < BlockAsgms.EventIdDayOut) OR'
set @sStmt = @sStmt + ' (EventLog.EventIdDay = BlockAsgms.EventIdDayOut AND EventLog.EventIdFraction < BlockAsgms.EventIdFractionOut)) AND'
set @sStmt = @sStmt + ' ((EventLog.EventIdDay > BlockAsgms.EventIdDayIn) OR'
set @sStmt = @sStmt + ' ((EventLog.EventIdDay = BlockAsgms.EventIdDayIn) AND'
set @sStmt = @sStmt + ' EventLog.EventIdFraction >= BlockAsgms.EventIdFractionIn)))'
set @sStmt = @sStmt + ' LEFT JOIN ExtBlockTags ON ExtBlockTags.ExtBlockTagKey = BlockAsgms.ExtBlockTagKey'
set @sStmt = @sStmt + ' LEFT JOIN Blocks ON EventLog.BlockKey = Blocks.BlockKey'
set @sStmt = @sStmt + ' LEFT JOIN Devices ON Blocks.DeviceKey = Devices.DeviceKey'
set @sStmt = @sStmt + ' LEFT JOIN DeviceRevisions ON Devices.AmsDevRevId = DeviceRevisions.AmsDevRevId'
set @sStmt = @sStmt + ' LEFT JOIN DeviceTypes ON DeviceRevisions.AmsDevTypeId = DeviceTypes.AmsDevTypeId'
set @sStmt = @sStmt + ' LEFT JOIN MfrProtocols ON DeviceTypes.MfrProtocolId = MfrProtocols.MfrProtocolId'
set @sStmt = @sStmt + ' LEFT JOIN Manufacturers ON MfrProtocols.AmsMfrNameId = Manufacturers.AmsMfrNameId'
set @sStmt = @sStmt + ' LEFT JOIN DeviceProtocols ON MfrProtocols.ProtocolId = DeviceProtocols.ProtocolId'
set @sStmt = @sStmt + ' LEFT JOIN Dispositions ON Dispositions.DispositionId = Devices.DispositionId'
set @sStmt = @sStmt + ' LEFT OUTER JOIN PlantServer INNER JOIN'
set @sStmt = @sStmt + ' DeviceLocation ON PlantServer.PlantServerKey = DeviceLocation.PlantServerKey ON Blocks.BlockKey = DeviceLocation.BlockKey'
set @sStmt = @sStmt + ' ' + @sWhere
set @sStmt = @sStmt + ' ORDER BY EventLog.EventIdDay ' + @sSortOrder
set @sStmt = @sStmt + ', EventLog.EventIdFraction ' + @sSortOrder

insert into #tTable exec (@sStmt)

set @sStmt = 'SELECT top ' + @sMaxCount
set @sStmt = @sStmt + ' EventLog.EventIdDay'
set @sStmt = @sStmt + ', EventLog.EventIdFraction'
set @sStmt = @sStmt + ', EventLog.BlockKey'
set @sStmt = @sStmt + ', CONVERT(nvarchar, EventLog.EventTime, 121) AS EventTime'
set @sStmt = @sStmt + ', EventCategories.CategoryDesc'
set @sStmt = @sStmt + ', EventLog.ComputerId'
set @sStmt = @sStmt + ', Users.UserName'
set @sStmt = @sStmt + ', EventLog.Source'
set @sStmt = @sStmt + ', EventLog.Type'
set @sStmt = @sStmt + ', EventLog.Description'
set @sStmt = @sStmt + ', CASE'
set @sStmt = @sStmt + ' When EventLog.blockkey <> -1'
set @sStmt = @sStmt + ' then'
set @sStmt = @sStmt + ' (SELECT  ExtBlockTag'
set @sStmt = @sStmt + ' FROM dbo.AmsVw_DevBlkLvl_BlockTagAsgms v1'
set @sStmt = @sStmt + ' WHERE (v1.BlockKey = EventLog.blockkey) and'
set @sStmt = @sStmt + ' ((EventLog.EventIdDay < v1.EventIdDayOut) OR'
set @sStmt = @sStmt + ' ((EventLog.EventIdDay = v1.EventIdDayOut) AND (EventLog.EventIdFraction < v1.EventIdFractionOut)))'
set @sStmt = @sStmt + ' AND'
set @sStmt = @sStmt + ' ((EventLog.EventIdDay > v1.EventIdDayIn) OR'
set @sStmt = @sStmt + ' ((EventLog.EventIdDay = v1.EventIdDayIn) AND (EventLog.EventIdFraction >= v1.EventIdFractionIn)))'
set @sStmt = @sStmt + ' )'
set @sStmt = @sStmt + ' else null'
set @sStmt = @sStmt + ' end'	-- CASE
set @sStmt = @sStmt + ' as ExtBlockTag'
set @sStmt = @sStmt + ', EventLog.Category'
set @sStmt = @sStmt + ', Blocks.BlockIndex'
set @sStmt = @sStmt + ', Blocks.BlockType'
set @sStmt = @sStmt + ', Devices.DeviceKey'
set @sStmt = @sStmt + ', Manufacturers.Name AS Manufacturer'
set @sStmt = @sStmt + ', DeviceProtocols.Name AS DeviceProtocol'
set @sStmt = @sStmt + ', DeviceTypes.Name AS DeviceType'
set @sStmt = @sStmt + ', DeviceRevisions.Name AS DeviceRevision'
set @sStmt = @sStmt + ', Devices.Identifier AS Identifier'
set @sStmt = @sStmt + ', MfrProtocols.MfrId as MfrId'
set @sStmt = @sStmt + ', DeviceTypes.DeviceType as DeviceTypeCode'
set @sStmt = @sStmt + ', DeviceRevisions.DeviceRevision as DeviceRevisionCode'
set @sStmt = @sStmt + ', Devices.ProtocolRevision AS ProtocolRevision'
set @sStmt = @sStmt + ', Devices.DispositionId AS DispositionId'
set @sStmt = @sStmt + ', PlantServer.PlantServerId AS PlantServer'
set @sStmt = @sStmt + ', Dispositions.Name AS Disposition'
set @sStmt = @sStmt + ', Devices.AmsDeviceId AS AmsDeviceId'
set @sStmt = @sStmt + ', EventLog.Other'
set @sStmt = @sStmt + ' FROM (Users INNER JOIN'
set @sStmt = @sStmt + ' (EventCategories INNER JOIN EventLog ON EventCategories.Category = EventLog.Category AND EventLog.Category = 49)'
set @sStmt = @sStmt + ' ON Users.UserKey = EventLog.UserKey)'
set @sStmt = @sStmt + ' LEFT JOIN TestDefAsgms ON ( EventLog.EventIDDay = TestDefAsgms.EventIdDayIn AND'
set @sStmt = @sStmt + ' EventLog.EventIDFraction = TestDefAsgms.EventIdFractionIn)'
set @sStmt = @sStmt + ' LEFT JOIN ExtBlockTags ON (TestDefAsgms.ExtBlockTagKey = ExtBlockTags.ExtBlockTagKey)'
set @sStmt = @sStmt + ' LEFT JOIN Blocks ON EventLog.BlockKey = Blocks.BlockKey'
set @sStmt = @sStmt + ' LEFT JOIN Devices ON Blocks.DeviceKey = Devices.DeviceKey'
set @sStmt = @sStmt + ' LEFT JOIN DeviceRevisions ON Devices.AmsDevRevId = DeviceRevisions.AmsDevRevId'
set @sStmt = @sStmt + ' LEFT JOIN DeviceTypes ON DeviceRevisions.AmsDevTypeId = DeviceTypes.AmsDevTypeId'
set @sStmt = @sStmt + ' LEFT JOIN MfrProtocols ON DeviceTypes.MfrProtocolId = MfrProtocols.MfrProtocolId'
set @sStmt = @sStmt + ' LEFT JOIN Manufacturers ON MfrProtocols.AmsMfrNameId = Manufacturers.AmsMfrNameId'
set @sStmt = @sStmt + ' LEFT JOIN DeviceProtocols ON MfrProtocols.ProtocolId = DeviceProtocols.ProtocolId'
set @sStmt = @sStmt + ' LEFT JOIN Dispositions ON Dispositions.DispositionId = Devices.DispositionId'
set @sStmt = @sStmt + ' LEFT OUTER JOIN PlantServer INNER JOIN'
set @sStmt = @sStmt + ' DeviceLocation ON PlantServer.PlantServerKey = DeviceLocation.PlantServerKey ON Blocks.BlockKey = DeviceLocation.BlockKey'
set @sStmt = @sStmt + ' ' + @sWhere
set @sStmt = @sStmt + ' AND ((MfrProtocols.ProtocolId < 4) or (MfrProtocols.ProtocolId > 5))'
set @sStmt = @sStmt + ' ORDER BY EventLog.EventIdDay ' + @sSortOrder
set @sStmt = @sStmt + ', EventLog.EventIdFraction ' + @sSortOrder

insert into #tTable exec (@sStmt)

set @sStmt = 'select top ' + @sMaxCount + ' ' + @sSelectClause + ' from #tTable'
set @sStmt = @sStmt + ' ORDER BY EventIdDay DESC, EventIdFraction DESC'

declare @nRecords int
exec (@sStmt)
set @nRecords = @@ROWCOUNT

drop table #tTable

return @nRecords

GO

