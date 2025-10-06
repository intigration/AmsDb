-----------------------------------------------------------------------
-- AmsSp_AuditTrailSummary_All_1
--
-- Note: Special sp for dbw_v1_2::CAuditTrailSummaryEx and it's associated
--	classes.  Ultimately used by AMS audit trail viewer, specifically code
--	src/apps/fmslogv project.
--
-- Note: Other stored procedures in this 'class' are --
--		AmsSp_AuditTrailSummary_ByDevice_1
--		AmsSp_AuditTrailSummary_ByTag_1
--	these sp's do very similar things as this stored procedure but are more
--	tailored towards device and tag level auditTrailSummary views.
--
-- These sp's are based on the client obtaining a AuditTrailSummary view in a
--	'paged' manner.  Paging helps break-up the overall view especially when more
--	than 100,000 auditTrail records are involved.
--
-- These sp's are highly dependant on using the eventIdDay, eventIdFraction as
--	the paging boundaries.
--
--
-- Inputs -
--	sSelectClause nvarchar(max) - select which columns from the output recordset
--		Note: do NOT include the 'Select' in the statement.
--	sWhereClause nvarchar(max) - the filter to be applied to the view
--		Note: do NOT include the 'Where' in the statement.
--	sSortDirection nvarchar(50) - the eventIdDay, eventIdFraction sort direction
--			must be either 'DESC' or 'ASC'
--	bPageForward int	-- != 0 is page forward else page backward
--	nMaxCount int - maximum number of records to return.
--	bRecordCountOnly int - 0 = return the total record count for the query;
--		if <> 0 then return the recordset.
--
-- Output recordset -
--  Output recordset is dependant on @bRecordCountOnly.
--  If @bRecordCountOnly = 0 then only return a single row with a single column --
--		RecordCount	int
--
--	If @bRecordCountOnly <> 0 then recordset includes what is indicated by the @sSelectClause
--	from the following --
--		EventIdDay int,
--		EventIdFraction int,
--		BlockKey int,
--		EventTime nvarchar(255),
--		CategoryDesc nvarchar(255),
--		ComputerId int,
--		UserName nvarchar(50),
--		Source nvarchar(50),
--		Type int,
--		Description nvarchar(1024),
--		ExtBlockTag nvarchar(40),
--		Category int,
--		BlockIndex int,
--		BlockType nvarchar(1),
--		DeviceKey int,
--		Manufacturer nvarchar(255),
--		DeviceProtocol nvarchar(255),
--		DeviceType nvarchar(255),
--		DeviceRevision nvarchar(255),
--		Identifier nvarchar(255),
--		Other varbinary(255),	-- note that this will be coming back varbinary
--		AlertId nvarchar(484),
--		AlertTypeUid nvarchar(20),
--		AlertTypeName nvarchar(10)
--	
-- Outputs -
--	nReturnRowCount int	- the number of rows in the recordset.
--		Note: if this number is less than nMaxCount then you can assume that you have reached
--		the end of the view.
--
-- Returns -
--	0 - successful.
--	-1 - Error, general error.
--
-- Joe Fisher - 12/1/2003
--

CREATE PROCEDURE AmsSp_AuditTrailSummary_All_1
@sSelectClause nvarchar(max),
@sWhereClause nvarchar(max),
@sSortDirection nvarchar(50),
@bPageForward int,	-- != 0 is page forward else page backward
@nMaxCount int,
@bRecordCountOnly int,
@nReturnRowCount int output
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

-- get audit trail info
set @sStmt = @sTmpSelect
set @sStmt = @sStmt + ' FROM  ExtBlockTags INNER JOIN BlockAsgms ON ExtBlockTags.ExtBlockTagKey = BlockAsgms.ExtBlockTagKey'
set @sStmt = @sStmt + ' RIGHT OUTER JOIN EventLog INNER JOIN EventCategories ON EventCategories.Category = EventLog.Category'
set @sStmt = @sStmt + ' INNER JOIN Users ON Users.UserKey = EventLog.UserKey'
set @sStmt = @sStmt + ' LEFT OUTER JOIN AlertLog ON EventLog.EventIdDay = AlertLog.EventIdDay AND'
set @sStmt = @sStmt + ' EventLog.EventIdFraction = AlertLog.EventIdFraction'
set @sStmt = @sStmt + ' LEFT OUTER JOIN AlertTypes ON AlertLog.AlertTypeId = AlertTypes.AlertTypeId'
set @sStmt = @sStmt + ' LEFT OUTER JOIN Blocks ON EventLog.BlockKey = Blocks.BlockKey'
set @sStmt = @sStmt + ' LEFT OUTER JOIN AmsVw_DeviceLevelBlockKey ON AmsVw_DeviceLevelBlockKey.BlockKey = Blocks.BlockKey'
set @sStmt = @sStmt + ' ON BlockAsgms.BlockKey = AmsVw_DeviceLevelBlockKey.DeviceLevelBlockKey'
set @sStmt = @sStmt + ' AND (EventLog.EventIdDay < BlockAsgms.EventIdDayOut OR'
set @sStmt = @sStmt + ' EventLog.EventIdDay = BlockAsgms.EventIdDayOut AND EventLog.EventIdFraction < BlockAsgms.EventIdFractionOut) AND'
set @sStmt = @sStmt + ' (EventLog.EventIdDay > BlockAsgms.EventIdDayIn OR'
set @sStmt = @sStmt + ' EventLog.EventIdDay = BlockAsgms.EventIdDayIn AND EventLog.EventIdFraction >= BlockAsgms.EventIdFractionIn)'
set @sStmt = @sStmt + ' LEFT OUTER JOIN Devices ON Blocks.DeviceKey = Devices.DeviceKey'
set @sStmt = @sStmt + ' LEFT OUTER JOIN DeviceRevisions ON Devices.AmsDevRevId = DeviceRevisions.AmsDevRevId'
set @sStmt = @sStmt + ' LEFT OUTER JOIN DeviceTypes ON DeviceRevisions.AmsDevTypeId = DeviceTypes.AmsDevTypeId'
set @sStmt = @sStmt + ' LEFT OUTER JOIN MfrProtocols ON DeviceTypes.MfrProtocolId = MfrProtocols.MfrProtocolId'
set @sStmt = @sStmt + ' LEFT OUTER JOIN Manufacturers ON MfrProtocols.AmsMfrNameId = Manufacturers.AmsMfrNameId'
set @sStmt = @sStmt + ' LEFT OUTER JOIN DeviceProtocols ON MfrProtocols.ProtocolId = DeviceProtocols.ProtocolId'
set @sStmt = @sStmt + ' WHERE (EventLog.Category <> 49 )'
set @sStmt = @sStmt + ' ' + @sWhere
if (@bRecordCountOnly = 0)
begin
	set @sStmt = @sStmt + ' ORDER BY EventLog.EventIdDay ' + @sSelectSortOrder
	set @sStmt = @sStmt + ', EventLog.EventIdFraction ' + @sSelectSortOrder
end

insert into #tTable exec (@sStmt)

-- get audit trail info for test schemes.
set @sStmt = @sTmpSelect
set @sStmt = @sStmt + ' FROM EventLog INNER JOIN EventCategories ON EventCategories.Category = EventLog.Category'
set @sStmt = @sStmt + ' INNER JOIN Users ON Users.UserKey = EventLog.UserKey'
set @sStmt = @sStmt + ' LEFT JOIN TestDefAsgms ON ( EventLog.EventIDDay = TestDefAsgms.EventIdDayIn AND'
set @sStmt = @sStmt + ' EventLog.EventIDFraction = TestDefAsgms.EventIdFractionIn)'
set @sStmt = @sStmt + ' LEFT OUTER JOIN AlertLog ON EventLog.EventIdDay = AlertLog.EventIdDay AND'
set @sStmt = @sStmt + ' EventLog.EventIdFraction = AlertLog.EventIdFraction'
set @sStmt = @sStmt + ' LEFT OUTER JOIN AlertTypes ON AlertLog.AlertTypeId = AlertTypes.AlertTypeId'
set @sStmt = @sStmt + ' LEFT JOIN ExtBlockTags ON (TestDefAsgms.ExtBlockTagKey = ExtBlockTags.ExtBlockTagKey)'
set @sStmt = @sStmt + ' INNER JOIN BlockAsgms ON ExtBlockTags.ExtBlockTagKey = Blockasgms.ExtBlockTagKey'
-- the following is checking to make sure that only those blockAsgms records containing the event are included
-- (I think!! jdf)
set @sStmt = @sStmt + ' AND ((EventLog.EventIdDay = BlockAsgms.EventIdDayOut AND EventLog.EventIdFraction < BlockAsgms.EventIdFractionOut)'
set @sStmt = @sStmt + ' OR (EventLog.EventIdDay < BlockAsgms.EventIdDayOut))'
set @sStmt = @sStmt + ' AND ((EventLog.EventIdDay = BlockAsgms.EventIdDayIn AND EventLog.EventIdFraction >= BlockAsgms.EventIdFractionIn)'
set @sStmt = @sStmt + ' OR (EventLog.EventIdDay > BlockAsgms.EventIdDayIn))'
--
set @sStmt = @sStmt + ' LEFT JOIN Blocks ON BlockAsgms.BlockKey = Blocks.BlockKey'
set @sStmt = @sStmt + ' LEFT JOIN Devices ON Blocks.DeviceKey = Devices.DeviceKey'
set @sStmt = @sStmt + ' LEFT JOIN DeviceRevisions ON Devices.AmsDevRevId = DeviceRevisions.AmsDevRevId'
set @sStmt = @sStmt + ' LEFT JOIN DeviceTypes ON DeviceRevisions.AmsDevTypeId = DeviceTypes.AmsDevTypeId'
set @sStmt = @sStmt + ' LEFT JOIN MfrProtocols ON DeviceTypes.MfrProtocolId = MfrProtocols.MfrProtocolId'
set @sStmt = @sStmt + ' LEFT JOIN Manufacturers ON MfrProtocols.AmsMfrNameId = Manufacturers.AmsMfrNameId'
set @sStmt = @sStmt + ' LEFT JOIN DeviceProtocols ON MfrProtocols.ProtocolId = DeviceProtocols.ProtocolId'
set @sStmt = @sStmt + ' WHERE (EventLog.Category = 49)'
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

