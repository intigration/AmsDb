-----------------------------------------------------------------------
-- AmsSp_AuditTrailSummary_ByDevice_1
--
-- Get AuditTrailSummary view by a device.
--
-- Inputs --
--
--	@nDeviceLevelBlockKey int - the blockKey for the deviceLevelBlock (ie. where
--		blockIndex = 0)
--
--	(see AmsSp_AuditTrailSummary_All_1) for additional details.)
--
-- Joe Fisher - 12/1/2003
--

CREATE PROCEDURE AmsSp_AuditTrailSummary_ByDevice_1
@sSelectClause nvarchar(max),
@sWhereClause nvarchar(max),
@sSortDirection nvarchar(50),
@bPageForward int,	-- != 0 is page forward else page backward
@nMaxCount int,
@bRecordCountOnly int,
@nReturnRowCount int output,
@nDeviceLevelBlockKey int
AS
declare @sStmt nvarchar(max)
-- 'desc' / 'asc' is based on the UI paging through the list with the most
-- recent event at the top of the list (ie. sorted in descending order.)
-- 'asc' means get the events from the eventId specified to the more recent
-- and conversely 'desc' means get the events from the eventId specified to
-- oldest.
declare @sSortOrder nvarchar(10)
set @sSortOrder = @sSortDirection

-- negative page forward, max count, and record count only are invalid
if ((@bPageForward < 0) or (@nMaxCount < 0) or (@bRecordCountOnly < 0))
begin
	return -1
end

-- the @bPageForward determines the sort order of the selects going into the temp table.
-- if @bPageForward = 1 then we want to start at a time and work backward in time.
-- if @bPageForward = 0 then we want to start at a time and work forward in time.
declare @sSelectSortOrder nvarchar(10)
if (@bPageForward = 0)
begin
	set @sSelectSortOrder = 'ASC'
end
else
begin
	set @sSelectSortOrder = 'DESC'
end

declare @sMaxCount nvarchar(10)
set @sMaxCount = cast(@nMaxCount as nvarchar(10))

-- cleanup the user's where clause
declare @sWhere nvarchar(max)
set @sWhere = ltrim(rtrim(@sWhereClause))
if (len(@sWhere) > 0)
	set @sWhere = 'AND ' + @sWhere
--print @sWhere

declare @sBlockKey nvarchar(10)
set @sBlockKey = cast(@nDeviceLevelBlockKey as nvarchar(10))

-- setup temp table depending on whether we are just after the record count.
declare @sTmpSelect nvarchar(max)
set @sTmpSelect = ''

Create table #tTable (RecCt int)

if (@bRecordCountOnly = 1)
begin
	set @sTmpSelect = 'SELECT count(*) as RecCt'
end
else
begin
	set @sTmpSelect = 'SELECT top ' + @sMaxCount
	set @sTmpSelect = @sTmpSelect + ' EventLog.EventIdDay,'
	set @sTmpSelect = @sTmpSelect + ' EventLog.EventIdFraction,'
	set @sTmpSelect = @sTmpSelect + ' Blocks.BlockKey,'
	set @sTmpSelect = @sTmpSelect + ' CONVERT(nvarchar, EventLog.EventTime,121) AS EventTime,'
	set @sTmpSelect = @sTmpSelect + ' EventCategories.CategoryDesc,'
	set @sTmpSelect = @sTmpSelect + ' EventLog.ComputerId,'
	set @sTmpSelect = @sTmpSelect + ' Users.UserName,'
	set @sTmpSelect = @sTmpSelect + ' EventLog.Source,'
	set @sTmpSelect = @sTmpSelect + ' EventLog.Type,'
	set @sTmpSelect = @sTmpSelect + ' EventLog.Description,'
	set @sTmpSelect = @sTmpSelect + ' Extblocktags.ExtBlockTag,'
	set @sTmpSelect = @sTmpSelect + ' EventLog.Category,'
	set @sTmpSelect = @sTmpSelect + ' Blocks.BlockIndex,'
	set @sTmpSelect = @sTmpSelect + ' Blocks.BlockType,'
	set @sTmpSelect = @sTmpSelect + ' Devices.DeviceKey,' 
	set @sTmpSelect = @sTmpSelect + ' Manufacturers.Name AS Manufacturer,'
	set @sTmpSelect = @sTmpSelect + ' DeviceProtocols.Name AS DeviceProtocol,'
	set @sTmpSelect = @sTmpSelect + ' DeviceTypes.Name AS DeviceType,'
	set @sTmpSelect = @sTmpSelect + ' DeviceRevisions.Name AS DeviceRevision,'
	set @sTmpSelect = @sTmpSelect + ' Devices.Identifier AS Identifier,'
	set @sTmpSelect = @sTmpSelect + ' CAST(EventLog.Other AS varbinary(255)) as Other,'
	set @sTmpSelect = @sTmpSelect + ' AlertLog.AlertId,'
	set @sTmpSelect = @sTmpSelect + ' AlertTypes.Uid AS AlertTypeUid,'
	set @sTmpSelect = @sTmpSelect + ' AlertTypes.AlertTypeName'

	alter table #tTable add EventIdDay int,
		EventIdFraction int,
		BlockKey int,
		EventTime nvarchar(255),
		CategoryDesc nvarchar(255),
		ComputerId int,
		UserName nvarchar(50),
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
		Other varbinary(255),
		AlertId nvarchar(484),
		AlertTypeUid nvarchar(20),
		AlertTypeName nvarchar(10)
	alter table #tTable drop column RecCt
end

-- Get audit trail info based on eventLog.
--
set @sStmt = @sTmpSelect
set @sStmt = @sStmt + ' FROM Blocks INNER JOIN Blocks AS DeviceBlocks ON DeviceBlocks.DeviceKey = Blocks.DeviceKey'
set @sStmt = @sStmt + ' INNER JOIN Eventlog ON Blocks.BlockKey = Eventlog.BlockKey'
set @sStmt = @sStmt + ' INNER JOIN Users ON Users.UserKey = EventLog.UserKey'
set @sStmt = @sStmt + ' INNER JOIN EventCategories ON EventCategories.Category = EventLog.Category'
set @sStmt = @sStmt + ' LEFT JOIN Devices ON Blocks.DeviceKey = Devices.DeviceKey'
set @sStmt = @sStmt + ' LEFT JOIN DeviceRevisions ON Devices.AmsDevRevId = DeviceRevisions.AmsDevRevId'
set @sStmt = @sStmt + ' LEFT JOIN DeviceTypes ON DeviceRevisions.AmsDevTypeId = DeviceTypes.AmsDevTypeId'
set @sStmt = @sStmt + ' LEFT JOIN MfrProtocols ON DeviceTypes.MfrProtocolId = MfrProtocols.MfrProtocolId'
set @sStmt = @sStmt + ' LEFT JOIN Manufacturers ON MfrProtocols.AmsMfrNameId = Manufacturers.AmsMfrNameId' 
set @sStmt = @sStmt + ' LEFT JOIN DeviceProtocols ON MfrProtocols.ProtocolId = DeviceProtocols.ProtocolId'
-- the following will include all events for this device to be reported whether it was assigned to a tag
-- or not (bad in my opinion- jdf) see comqa19135
set @sStmt = @sStmt + ' LEFT OUTER JOIN ExtBlockTags INNER JOIN BlockAsgms ON ExtBlockTags.ExtBlockTagKey = BlockAsgms.ExtBlockTagKey'
set @sStmt = @sStmt + ' ON BlockAsgms.BlockKey = DeviceBlocks.BlockKey'
set @sStmt = @sStmt + ' AND (EventLog.EventIdDay < BlockAsgms.EventIdDayOut OR'
set @sStmt = @sStmt + ' EventLog.EventIdDay = BlockAsgms.EventIdDayOut AND EventLog.EventIdFraction < BlockAsgms.EventIdFractionOut)'
set @sStmt = @sStmt + ' AND (EventLog.EventIdDay > BlockAsgms.EventIdDayIn OR'
set @sStmt = @sStmt + ' EventLog.EventIdDay = BlockAsgms.EventIdDayIn AND EventLog.EventIdFraction >= dbo.BlockAsgms.EventIdFractionIn)'
-- Also get the Alert info
set @sStmt = @sStmt + ' LEFT OUTER JOIN AlertLog ON EventLog.EventIdDay = AlertLog.EventIdDay AND'
set @sStmt = @sStmt + ' EventLog.EventIdFraction = AlertLog.EventIdFraction'
set @sStmt = @sStmt + ' LEFT OUTER JOIN AlertTypes ON AlertLog.AlertTypeId = AlertTypes.AlertTypeId'
set @sStmt = @sStmt + ' WHERE (EventLog.Type >= 1 and EventLog.Type <= 9 and NOT EventLog.Type = 6 and NOT EventLog.Type = 9)'
set @sStmt = @sStmt + ' AND (DeviceBlocks.Blockkey =  (SELECT DLBK.DeviceLevelBlockKey FROM AmsVw_DeviceLevelBlockKey AS DLBK WHERE DLBK.BlockKey = ' + @sBlockKey + '))'
set @sStmt = @sStmt + ' ' + @sWhere
if (@bRecordCountOnly = 0)
begin
	set @sStmt = @sStmt + ' ORDER BY EventLog.EventIdDay ' + @sSelectSortOrder
	set @sStmt = @sStmt + ', EventLog.EventIdFraction ' + @sSelectSortOrder
end

insert into #tTable exec (@sStmt)

-- get audit trail info based on testDefinitionHistory (ie. testScheme changes)
set @sStmt = @sTmpSelect
set @sStmt = @sStmt + ' FROM EventLog  INNER JOIN TestDefinitionHistory ON TestDefinitionHistory.EventIdDay = EventLog.EventIdDay'
set @sStmt = @sStmt + ' AND TestDefinitionHistory.EventIdFraction = EventLog.EventIdFraction'
set @sStmt = @sStmt + ' INNER JOIN TestDefAsgms ON TestDefinitionHistory.TestDefinitionId = TestDefAsgms.TestDefinitionId'
-- the following is restricting the TestDefAsgms record ranges containing the eventId.
-- (I think!! - jdf)
set @sStmt = @sStmt + ' AND ((TestDefinitionHistory.EventIdDay = TestDefAsgms.EventIdDayOut AND TestDefinitionHistory.EventIdFraction < TestDefAsgms.EventIdFractionOut)'
set @sStmt = @sStmt + ' OR (TestDefinitionHistory.EventIdDay < TestDefAsgms.EventIdDayOut))'
set @sStmt = @sStmt + ' AND ((TestDefinitionHistory.EventIdDay = TestDefAsgms.EventIdDayIn AND TestDefinitionHistory.EventIdFraction >= TestDefAsgms.EventIdFractionIn)'
set @sStmt = @sStmt + ' OR (TestDefinitionHistory.EventIdDay > TestDefAsgms.EventIdDayIn))'
--
set @sStmt = @sStmt + ' INNER JOIN BlockAsgms ON TestDefAsgms.ExtBlockTagKey = Blockasgms.ExtBlockTagKey'
-- the following is checking to make sure that only those blockAsgms records containing the event are included
-- (I think!! jdf)
set @sStmt = @sStmt + ' AND ((TestDefinitionHistory.EventIdDay = BlockAsgms.EventIdDayOut AND TestDefinitionHistory.EventIdFraction < BlockAsgms.EventIdFractionOut)'
set @sStmt = @sStmt + ' OR (TestDefinitionHistory.EventIdDay < BlockAsgms.EventIdDayOut))'
set @sStmt = @sStmt + ' AND ((TestDefinitionHistory.EventIdDay = BlockAsgms.EventIdDayIn AND TestDefinitionHistory.EventIdFraction >= BlockAsgms.EventIdFractionIn)'
set @sStmt = @sStmt + ' OR (TestDefinitionHistory.EventIdDay > BlockAsgms.EventIdDayIn))'
--
set @sStmt = @sStmt + ' INNER JOIN ExtBlockTags ON TestDefAsgms.ExtBlockTagKey = ExtBlockTags.ExtBlockTagKey'
set @sStmt = @sStmt + ' INNER JOIN users ON Users.UserKey = EventLog.UserKey '
set @sStmt = @sStmt + ' INNER JOIN EventCategories ON EventCategories.Category = EventLog.Category'
set @sStmt = @sStmt + ' LEFT JOIN Blocks ON BlockAsgms.BlockKey = Blocks.BlockKey'
set @sStmt = @sStmt + ' LEFT JOIN Devices ON Blocks.DeviceKey = Devices.DeviceKey'
set @sStmt = @sStmt + ' LEFT JOIN DeviceRevisions ON Devices.AmsDevRevId = DeviceRevisions.AmsDevRevId'
set @sStmt = @sStmt + ' LEFT JOIN DeviceTypes ON DeviceRevisions.AmsDevTypeId = DeviceTypes.AmsDevTypeId'
set @sStmt = @sStmt + ' LEFT JOIN MfrProtocols ON DeviceTypes.MfrProtocolId = MfrProtocols.MfrProtocolId'
set @sStmt = @sStmt + ' LEFT JOIN Manufacturers ON MfrProtocols.AmsMfrNameId = Manufacturers.AmsMfrNameId'
set @sStmt = @sStmt + ' LEFT JOIN DeviceProtocols ON MfrProtocols.ProtocolId = DeviceProtocols.ProtocolId'
-- Also get the Alert info
set @sStmt = @sStmt + ' LEFT OUTER JOIN AlertLog ON EventLog.EventIdDay = AlertLog.EventIdDay AND'
set @sStmt = @sStmt + ' EventLog.EventIdFraction = AlertLog.EventIdFraction'
set @sStmt = @sStmt + ' LEFT OUTER JOIN AlertTypes ON AlertLog.AlertTypeId = AlertTypes.AlertTypeId'
set @sStmt = @sStmt + ' WHERE (EventLog.Type >= 1 and EventLog.Type <= 9 and NOT EventLog.Type = 6 and NOT EventLog.Type = 9)'
set @sStmt = @sStmt + ' AND (EventLog.Category = 19)'
set @sStmt = @sStmt + ' AND (BlockAsgms.Blockkey = ' + @sBlockKey + ')'
set @sStmt = @sStmt + ' AND ((MfrProtocols.ProtocolId < 4) or (MfrProtocols.ProtocolId > 5))'
set @sStmt = @sStmt + ' ' + @sWhere
if (@bRecordCountOnly = 0)
begin
	set @sStmt = @sStmt + ' ORDER BY EventLog.EventIdDay ' + @sSelectSortOrder
	set @sStmt = @sStmt + ', EventLog.EventIdFraction ' + @sSelectSortOrder
end

insert into #tTable exec (@sStmt)

-- get audit trail info based on calibration testScheme assignment changes.
set @sStmt = @sTmpSelect
set @sStmt = @sStmt + ' FROM EventLog INNER JOIN TestDefAsgms ON TestDefAsgms.EventIdDayIn = EventLog.EventIdDay AND TestDefAsgms.EventIdFractionIn = EventLog.EventIdFraction'
set @sStmt = @sStmt + ' INNER JOIN BlockAsgms ON TestDefAsgms.ExtBlockTagKey = Blockasgms.ExtBlockTagKey'
-- the following is checking to make sure that only those blockAsgms records containing the event are included
-- (I think!! jdf)
set @sStmt = @sStmt + ' AND ((EventLog.EventIdDay = BlockAsgms.EventIdDayOut AND EventLog.EventIdFraction < BlockAsgms.EventIdFractionOut)'
set @sStmt = @sStmt + ' OR (EventLog.EventIdDay < BlockAsgms.EventIdDayOut))'
set @sStmt = @sStmt + ' AND ((EventLog.EventIdDay = BlockAsgms.EventIdDayIn AND EventLog.EventIdFraction >= BlockAsgms.EventIdFractionIn)'
set @sStmt = @sStmt + ' OR (EventLog.EventIdDay > BlockAsgms.EventIdDayIn))'
--
set @sStmt = @sStmt + ' INNER JOIN ExtBlockTags ON TestDefAsgms.ExtBlockTagKey = ExtBlockTags.ExtBlockTagKey'
set @sStmt = @sStmt + ' INNER JOIN users ON Users.UserKey = EventLog.UserKey'
set @sStmt = @sStmt + ' INNER JOIN EventCategories ON EventCategories.Category = EventLog.Category'
set @sStmt = @sStmt + ' LEFT JOIN Blocks ON BlockAsgms.BlockKey = Blocks.BlockKey'
set @sStmt = @sStmt + ' LEFT JOIN Devices ON Blocks.DeviceKey = Devices.DeviceKey'
set @sStmt = @sStmt + ' LEFT JOIN DeviceRevisions ON Devices.AmsDevRevId = DeviceRevisions.AmsDevRevId'
set @sStmt = @sStmt + ' LEFT JOIN DeviceTypes ON DeviceRevisions.AmsDevTypeId = DeviceTypes.AmsDevTypeId'
set @sStmt = @sStmt + ' LEFT JOIN MfrProtocols ON DeviceTypes.MfrProtocolId = MfrProtocols.MfrProtocolId'
set @sStmt = @sStmt + ' LEFT JOIN Manufacturers ON MfrProtocols.AmsMfrNameId = Manufacturers.AmsMfrNameId'
set @sStmt = @sStmt + ' LEFT JOIN DeviceProtocols ON MfrProtocols.ProtocolId = DeviceProtocols.ProtocolId'
-- Also get the Alert info
set @sStmt = @sStmt + ' LEFT OUTER JOIN AlertLog ON EventLog.EventIdDay = AlertLog.EventIdDay AND'
set @sStmt = @sStmt + ' EventLog.EventIdFraction = AlertLog.EventIdFraction'
set @sStmt = @sStmt + ' LEFT OUTER JOIN AlertTypes ON AlertLog.AlertTypeId = AlertTypes.AlertTypeId'
set @sStmt = @sStmt + ' WHERE (EventLog.Type >= 1 and EventLog.Type <= 9 and NOT EventLog.Type = 6 and NOT EventLog.Type = 9)'
set @sStmt = @sStmt + ' AND (EventLog.Category = 49)'
set @sStmt = @sStmt + ' AND ((MfrProtocols.ProtocolId < 4) or (MfrProtocols.ProtocolId > 5))'
set @sStmt = @sStmt + ' AND (BlockAsgms.Blockkey = ' + @sBlockKey + ')'
set @sStmt = @sStmt + ' ' + @sWhere
if (@bRecordCountOnly = 0)
begin
	set @sStmt = @sStmt + ' ORDER BY EventLog.EventIdDay ' + @sSelectSortOrder
	set @sStmt = @sStmt + ', EventLog.EventIdFraction ' + @sSelectSortOrder
end

insert into #tTable exec (@sStmt)

if (@bRecordCountOnly = 0)
begin
	-- we need now take all the above union's that have been combined into
	-- tempTable #tTable and par that down to the final user's nMaxCount
	-- and apply the proper eventId sorting.
	Create table #tFinalTable (EventIdDay int,
		EventIdFraction int,
		BlockKey int,
		EventTime nvarchar(255),
		CategoryDesc nvarchar(255),
		ComputerId int,
		UserName nvarchar(50),
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
		Other varbinary(255),
		AlertId nvarchar(484),
		AlertTypeUid nvarchar(20),
		AlertTypeName nvarchar(10))

	set @sStmt = 'select top ' + @sMaxCount + ' * from #tTable'
	set @sStmt = @sStmt + ' ORDER BY EventIdDay ' + @sSelectSortOrder
	set @sStmt = @sStmt + ', EventIdFraction ' + @sSelectSortOrder

	insert into #tFinalTable exec (@sStmt)

	-- now return the rows in the client's sort order.
	set @sStmt = 'select top ' + @sMaxCount + ' ' + @sSelectClause + ' from #tFinalTable'
	set @sStmt = @sStmt + ' ORDER BY EventIdDay ' + @sSortOrder
	set @sStmt = @sStmt + ', EventIdFraction ' + @sSortOrder

	exec (@sStmt)
	set @nReturnRowCount = @@ROWCOUNT

	drop table #tFinalTable
end
else
begin
	-- we only want a record count; note- each above union will produce a count
	-- for their respective union statement.
	set @sStmt = 'select SUM(RecCt) as RecordCount from #tTable'
	exec (@sStmt)
	set @nReturnRowCount = @@ROWCOUNT
end

drop table #tTable

return 0

GO

