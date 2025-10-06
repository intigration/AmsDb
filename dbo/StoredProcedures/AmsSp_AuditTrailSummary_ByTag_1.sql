-----------------------------------------------------------------------
-- AmsSp_AuditTrailSummary_ByTag_1
--
-- Get AuditTrailSummary view by a tag.
--
-- Inputs --
--
--	@sAmsTag nvarchar(255) - the AmsTag.
--
--	(see AmsSp_AuditTrailSummary_All_1) for additional details.)
--
-- Joe Fisher - 12/1/2003
--

CREATE PROCEDURE AmsSp_AuditTrailSummary_ByTag_1
@sSelectClause nvarchar(max),
@sWhereClause nvarchar(max),
@sSortDirection nvarchar(50),
@bPageForward int,	-- != 0 is page forward else page backward
@nMaxCount int,
@bRecordCountOnly int,
@nReturnRowCount int output,
@sAmsTag nvarchar(255)
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

-- get audit trail info based on all blocks for the device.
set @sStmt = @sTmpSelect
set @sStmt = @sStmt + ' FROM AmsVw_TagBlockAsgms INNER JOIN AmsVw_DeviceLevelBlockKey ON AmsVw_TagBlockAsgms.BlockKey = AmsVw_DeviceLevelBlockKey.DeviceLevelBlockKey'
set @sStmt = @sStmt + ' INNER JOIN EventLog ON AmsVw_DeviceLevelBlockKey.BlockKey = EventLog.BlockKey AND AmsVw_TagBlockAsgms.EventTimeIn <= EventLog.EventTime AND EventLog.EventTime <= AmsVw_TagBlockAsgms.EventTimeOut'
set @sStmt = @sStmt + ' INNER JOIN EventCategories ON EventLog.Category = EventCategories.Category'
set @sStmt = @sStmt + ' INNER JOIN Users ON EventLog.UserKey = Users.UserKey'
set @sStmt = @sStmt + ' INNER JOIN ExtBlockTags ON AmsVw_TagBlockAsgms.AmsTag = ExtBlockTags.ExtBlockTag'
set @sStmt = @sStmt + ' LEFT JOIN Blocks ON EventLog.BlockKey = Blocks.BlockKey'
set @sStmt = @sStmt + ' LEFT JOIN Devices ON Blocks.DeviceKey = Devices.DeviceKey'
set @sStmt = @sStmt + ' LEFT JOIN DeviceRevisions ON Devices.AmsDevRevId = DeviceRevisions.AmsDevRevId'
set @sStmt = @sStmt + ' LEFT JOIN DeviceTypes ON DeviceRevisions.AmsDevTypeId = DeviceTypes.AmsDevTypeId'
set @sStmt = @sStmt + ' LEFT JOIN MfrProtocols ON DeviceTypes.MfrProtocolId = MfrProtocols.MfrProtocolId'
set @sStmt = @sStmt + ' LEFT JOIN Manufacturers ON MfrProtocols.AmsMfrNameId = Manufacturers.AmsMfrNameId'
set @sStmt = @sStmt + ' LEFT JOIN DeviceProtocols ON MfrProtocols.ProtocolId = DeviceProtocols.ProtocolId'
set @sStmt = @sStmt + ' LEFT OUTER JOIN AlertLog ON EventLog.EventIdDay = AlertLog.EventIdDay AND'
set @sStmt = @sStmt + ' EventLog.EventIdFraction = AlertLog.EventIdFraction'
set @sStmt = @sStmt + ' LEFT OUTER JOIN AlertTypes ON AlertLog.AlertTypeId = AlertTypes.AlertTypeId'
set @sStmt = @sStmt + ' WHERE (EventLog.Type >= 1 and EventLog.Type <= 9 and NOT EventLog.Type = 6 and NOT EventLog.Type = 9)'
set @sStmt = @sStmt + ' AND (AmsVw_DeviceLevelBlockKey.BlockIndex > 0)'
set @sStmt = @sStmt + ' AND (AmsVw_TagBlockAsgms.AmsTag = N''' + @sAmsTag + ''')'
set @sStmt = @sStmt + ' ' + @sWhere
if (@bRecordCountOnly = 0)
begin
	set @sStmt = @sStmt + ' ORDER BY EventLog.EventIdDay ' + @sSelectSortOrder
	set @sStmt = @sStmt + ', EventLog.EventIdFraction ' + @sSelectSortOrder
end

insert into #tTable exec (@sStmt)

-- get audit trail info for test definition changes.
set @sStmt = @sTmpSelect
set @sStmt = @sStmt + ' FROM TestDefAsgms'
set @sStmt = @sStmt + ' INNER JOIN ExtBlockTags ON TestDefAsgms.ExtBlockTagKey = ExtBlockTags.ExtBlockTagKey'
set @sStmt = @sStmt + ' INNER JOIN TestDefinitionHistory ON TestDefAsgms.TestDefinitionId = TestDefinitionHistory.TestDefinitionId'
set @sStmt = @sStmt + ' INNER JOIN EventLog'
set @sStmt = @sStmt + ' INNER JOIN Users ON Users.UserKey = EventLog.UserKey'
set @sStmt = @sStmt + ' INNER JOIN EventCategories ON EventCategories.Category = EventLog.Category'
set @sStmt = @sStmt + ' ON (TestDefinitionHistory.EventIdDay < TestDefAsgms.EventIdDayOut OR'
set @sStmt = @sStmt + ' TestDefinitionHistory.EventIdDay = TestDefAsgms.EventIdDayOut AND'
set @sStmt = @sStmt + ' TestDefinitionHistory.EventIdFraction < TestDefAsgms.EventIdFractionOut) AND'
set @sStmt = @sStmt + ' (TestDefinitionHistory.EventIdDay > TestDefAsgms.EventIdDayIn OR'
set @sStmt = @sStmt + ' TestDefinitionHistory.EventIdDay = TestDefAsgms.EventIdDayIn AND'
set @sStmt = @sStmt + ' TestDefinitionHistory.EventIdFraction >= TestDefAsgms.EventIdFractionIn) AND'
set @sStmt = @sStmt + ' TestDefinitionHistory.EventIdDay = EventLog.EventIdDay AND'
set @sStmt = @sStmt + ' TestDefinitionHistory.EventIdFraction = EventLog.EventIdFraction'
-- get blockAsgm associated with this tag for this eventId in time.  This allows us to get the correct
-- deviceBlock for this eventId in time.
set @sStmt = @sStmt + ' INNER JOIN BlockAsgms ON BlockAsgms.ExtBlockTagKey = ExtBlockTags.ExtBlockTagKey'
--
-- we want the block associated with the tag at this eventId in time so link up blocks with blockasgms.
set @sStmt = @sStmt + ' LEFT OUTER JOIN Blocks ON BlockAsgms.BlockKey = Blocks.BlockKey'
set @sStmt = @sStmt + ' LEFT OUTER JOIN Devices ON Blocks.DeviceKey = Devices.DeviceKey'
set @sStmt = @sStmt + ' LEFT OUTER JOIN DeviceRevisions ON Devices.AmsDevRevId = DeviceRevisions.AmsDevRevId'
set @sStmt = @sStmt + ' LEFT OUTER JOIN DeviceTypes ON DeviceRevisions.AmsDevTypeId = DeviceTypes.AmsDevTypeId'
set @sStmt = @sStmt + ' LEFT OUTER JOIN MfrProtocols ON DeviceTypes.MfrProtocolId = MfrProtocols.MfrProtocolId'
set @sStmt = @sStmt + ' LEFT OUTER JOIN Manufacturers ON MfrProtocols.AmsMfrNameId = Manufacturers.AmsMfrNameId'
set @sStmt = @sStmt + ' LEFT OUTER JOIN DeviceProtocols ON MfrProtocols.ProtocolId = DeviceProtocols.ProtocolId'
set @sStmt = @sStmt + ' LEFT OUTER JOIN AlertLog ON EventLog.EventIdDay = AlertLog.EventIdDay AND'
set @sStmt = @sStmt + ' EventLog.EventIdFraction = AlertLog.EventIdFraction'
set @sStmt = @sStmt + ' LEFT OUTER JOIN AlertTypes ON AlertLog.AlertTypeId = AlertTypes.AlertTypeId'
set @sStmt = @sStmt + ' WHERE (EventLog.Type >= 1 and EventLog.Type <= 9 and NOT EventLog.Type = 6 and NOT EventLog.Type = 9)'
set @sStmt = @sStmt + ' AND (EventLog.Category = 19)'
-- this gets the correct blockAsgms record for this eventId in time.
set @sStmt = @sStmt + ' AND ((EventLog.EventIdDay < BlockAsgms.EventIdDayOut)' 
set @sStmt = @sStmt + ' OR ((EventLog.EventIdDay = BlockAsgms.EventIdDayOut) AND (EventLog.EventIdFraction < BlockAsgms.EventIdFractionOut)))' 
set @sStmt = @sStmt + ' AND ((EventLog.EventIdDay > BlockAsgms.EventIdDayIn) OR ((EventLog.EventIdDay = BlockAsgms.EventIdDayIn) AND (EventLog.EventIdFraction >= BlockAsgms.EventIdFractionIn)))'
--
set @sStmt = @sStmt + ' AND (ExtBlockTags.ExtBlockTag = N''' + @sAmsTag + ''')'
set @sStmt = @sStmt + ' AND ((MfrProtocols.ProtocolId < 4) or (MfrProtocols.ProtocolId > 5))'
set @sStmt = @sStmt + ' ' + @sWhere
if (@bRecordCountOnly = 0)
begin
	set @sStmt = @sStmt + ' ORDER BY EventLog.EventIdDay ' + @sSelectSortOrder
	set @sStmt = @sStmt + ', EventLog.EventIdFraction ' + @sSelectSortOrder
end

insert into #tTable exec (@sStmt)

-- get audit trail info based on eventLog
set @sStmt = @sTmpSelect
set @sStmt = @sStmt + ' FROM BlockAsgms INNER JOIN'
set @sStmt = @sStmt + ' ExtBlockTags ON BlockAsgms.ExtBlockTagKey = ExtBlockTags.ExtBlockTagKey INNER JOIN'
set @sStmt = @sStmt + ' EventLog ON BlockAsgms.BlockKey = EventLog.BlockKey INNER JOIN'
set @sStmt = @sStmt + ' Users ON Users.UserKey = EventLog.UserKey INNER JOIN'
set @sStmt = @sStmt + ' EventCategories ON EventCategories.Category = EventLog.Category LEFT OUTER JOIN'
set @sStmt = @sStmt + ' Blocks ON EventLog.BlockKey = Blocks.BlockKey LEFT OUTER JOIN'
set @sStmt = @sStmt + ' Devices ON Blocks.DeviceKey = Devices.DeviceKey LEFT OUTER JOIN'
set @sStmt = @sStmt + ' DeviceRevisions ON Devices.AmsDevRevId = DeviceRevisions.AmsDevRevId LEFT OUTER JOIN'
set @sStmt = @sStmt + ' DeviceTypes ON DeviceRevisions.AmsDevTypeId = DeviceTypes.AmsDevTypeId LEFT OUTER JOIN'
set @sStmt = @sStmt + ' MfrProtocols ON DeviceTypes.MfrProtocolId = MfrProtocols.MfrProtocolId LEFT OUTER JOIN'
set @sStmt = @sStmt + ' Manufacturers ON MfrProtocols.AmsMfrNameId = Manufacturers.AmsMfrNameId LEFT OUTER JOIN'
set @sStmt = @sStmt + ' DeviceProtocols ON MfrProtocols.ProtocolId = DeviceProtocols.ProtocolId'
set @sStmt = @sStmt + ' LEFT OUTER JOIN AlertLog ON EventLog.EventIdDay = AlertLog.EventIdDay AND'
set @sStmt = @sStmt + ' EventLog.EventIdFraction = AlertLog.EventIdFraction'
set @sStmt = @sStmt + ' LEFT OUTER JOIN AlertTypes ON AlertLog.AlertTypeId = AlertTypes.AlertTypeId'
set @sStmt = @sStmt + ' WHERE (EventLog.Type >= 1 and EventLog.Type <= 9 and NOT EventLog.Type = 6 and NOT EventLog.Type = 9)'
-- the following is checking to make sure that only those blockAsgms records containing the event are included
-- (I think!! jdf)
set @sStmt = @sStmt + ' AND (EventLog.BlockKey = BlockAsgms.BlockKey)'
set @sStmt = @sStmt + ' AND ((EventLog.EventIdDay < BlockAsgms.EventIdDayOut)' 
set @sStmt = @sStmt + ' OR ((EventLog.EventIdDay = BlockAsgms.EventIdDayOut) AND (EventLog.EventIdFraction < BlockAsgms.EventIdFractionOut)))' 
set @sStmt = @sStmt + ' AND ((EventLog.EventIdDay > BlockAsgms.EventIdDayIn) OR ((EventLog.EventIdDay = BlockAsgms.EventIdDayIn) AND (EventLog.EventIdFraction >= BlockAsgms.EventIdFractionIn)))'
set @sStmt = @sStmt + ' AND (ExtBlockTags.ExtBlockTag = N''' + @sAmsTag + ''')'
set @sStmt = @sStmt + ' ' + @sWhere
if (@bRecordCountOnly = 0)
begin
	set @sStmt = @sStmt + ' ORDER BY EventLog.EventIdDay ' + @sSelectSortOrder
	set @sStmt = @sStmt + ', EventLog.EventIdFraction ' + @sSelectSortOrder
end

insert into #tTable exec (@sStmt)

set @sStmt = @sTmpSelect
set @sStmt = @sStmt + ' FROM TestDefAsgms'
set @sStmt = @sStmt + ' INNER JOIN BlockAsgms'
set @sStmt = @sStmt + ' INNER JOIN ExtBlockTags ON BlockAsgms.ExtBlockTagKey = ExtBlockTags.ExtBlockTagKey'
set @sStmt = @sStmt + ' ON TestDefAsgms.ExtBlockTagKey = ExtBlockTags.ExtBlockTagKey'
set @sStmt = @sStmt + ' INNER JOIN Users'
set @sStmt = @sStmt + ' INNER JOIN EventLog ON Users.UserKey = EventLog.UserKey'
set @sStmt = @sStmt + ' INNER JOIN EventCategories ON EventCategories.Category = EventLog.Category'
set @sStmt = @sStmt + ' ON TestDefAsgms.EventIdDayIn = EventLog.EventIdDay AND TestDefAsgms.EventIdFractionIn = EventLog.EventIdFraction'
set @sStmt = @sStmt + ' LEFT OUTER JOIN Blocks ON BlockAsgms.BlockKey = Blocks.BlockKey'
set @sStmt = @sStmt + ' LEFT OUTER JOIN Devices ON Blocks.DeviceKey = Devices.DeviceKey'
set @sStmt = @sStmt + ' LEFT OUTER JOIN DeviceRevisions ON Devices.AmsDevRevId = DeviceRevisions.AmsDevRevId'
set @sStmt = @sStmt + ' LEFT OUTER JOIN DeviceTypes ON DeviceRevisions.AmsDevTypeId = DeviceTypes.AmsDevTypeId'
set @sStmt = @sStmt + ' LEFT OUTER JOIN MfrProtocols ON DeviceTypes.MfrProtocolId = MfrProtocols.MfrProtocolId'
set @sStmt = @sStmt + ' LEFT OUTER JOIN Manufacturers ON MfrProtocols.AmsMfrNameId = Manufacturers.AmsMfrNameId'
set @sStmt = @sStmt + ' LEFT OUTER JOIN DeviceProtocols ON MfrProtocols.ProtocolId = DeviceProtocols.ProtocolId'
set @sStmt = @sStmt + ' LEFT OUTER JOIN AlertLog ON EventLog.EventIdDay = AlertLog.EventIdDay AND'
set @sStmt = @sStmt + ' EventLog.EventIdFraction = AlertLog.EventIdFraction'
set @sStmt = @sStmt + ' LEFT OUTER JOIN AlertTypes ON AlertLog.AlertTypeId = AlertTypes.AlertTypeId'
set @sStmt = @sStmt + ' WHERE (EventLog.Type >= 1 and EventLog.Type <= 9 and NOT EventLog.Type = 6 and NOT EventLog.Type = 9)'
set @sStmt = @sStmt + ' AND (EventLog.Category = 49)'
set @sStmt = @sStmt + ' AND (ExtBlockTags.ExtBlockTag = N''' + @sAmsTag + ''')'
set @sStmt = @sStmt + ' AND (TestDefAsgms.EventIdDayIn = EventLog.EventIdDay  AND TestDefAsgms.EventIdFractionIn = EventLog.EventIdFraction'
set @sStmt = @sStmt + '     AND (BlockAsgms.EventIdDayIn < EventLog.EventIdDay OR (BlockAsgms.EventIdDayIn = EventLog.EventIdDay AND BlockAsgms.EventIdFractionIn < EventLog.EventIdFraction))'
set @sStmt = @sStmt + '     AND (BlockAsgms.EventIdDayOut > EventLog.EventIdDay OR (BlockAsgms.EventIdDayOut = EventLog.EventIdDay AND BlockAsgms.EventIdFractionOut > EventLog.EventIdFraction)))'
set @sStmt = @sStmt + ' AND ((MfrProtocols.ProtocolId < 4) or (MfrProtocols.ProtocolId > 5))'
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

