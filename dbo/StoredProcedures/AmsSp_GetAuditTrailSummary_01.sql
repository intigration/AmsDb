-----------------------------------------------------------------------
-- AmsSp_GetAuditTrailSummary_01
--
-- Get audit trail summary for a given time frame either by
-- AmsTag or for the device that is currently assigned to the
-- AmsTag.
--
-- The output recordset is sorted by EventTime in descending order.
--
-- Note: times are vtDates in GMT.
--
-- Inputs -
-- Note: inputs should always have a default value so that middle tier component
--	accessing can ignore for flexibility (per Doug & Joe.)
--
--	AmsTag (default blank).
--	ByDevice (default false).
--	StartTime (default 1/1/1900).
--	EndTime (default 12/31/9999).
--
-- Outputs the following recordset -
--	AmsTag
--	EventId
--	EventTime
--  UserName
--  Type
--  CategoryDesc
--  Description
--
-- Returns -
--	returns 0 if ok.
--	-1 - Error, unable to get information.
--
-- Joe Fisher, 06/12/2001
--
-- Source control keywords --
-- $Date: 2/17/05 3:47p $
-- $Revision: 121 $
--
CREATE Procedure AmsSp_GetAuditTrailSummary_01
@AmsTag as nvarchar(256)='',
@ByDevice as tinyint=0,
@StartTime as datetime='1/1/1900',
@EndTime as datetime='12/31/9999'
As

set nocount on
	
declare @nBlockKey as int

if (@AmsTag <> '')
begin
	-- we have a tag.  Get audit trail based on tag or by device.
	if (@ByDevice = 0)
	begin
		-- get audit trail by AmsTag
	-- print 'obtaining audit trail by tag for ' + @sAmsTag
		-- since EventLog is associated by BlockKey only (bad!) then we need to find
		-- all the blockAsgms for this tag for the given time period.
		-- since this could be a iterative process for more than one blockKey then
		-- we will setup a temporary table to hold the audit trail results as we
		-- scan each of the blockKeys.

		-- create the temporary table.
		create table #AuditTrail
		(
			AmsTag		nvarchar(256),
			EventID		nvarchar(30),
			EventTime	datetime,
			UserName	nvarchar(256),
			Type		nvarchar(256),
			CategoryDesc	nvarchar(256),
			Description	nvarchar(256)
		)

		-- setup the blockasgms cursor.
		declare aCursor cursor for select BlockKey, EventTimeOut, EventTimeIn from AmsVw_TagBlockAsgms where (AmsTag = @AmsTag)

		-- now for each of the blockKeys scan the audit trail and put their results
		-- into the temporary table.
		declare @dtBAEventTimeOut as datetime, @dtBAEventTimeIn as datetime
		declare @dtStartTime1 as datetime, @dtEndTime1 as datetime
		open aCursor
		fetch next from aCursor into @nBlockKey, @dtBAEventTimeOut, @dtBAEventTimeIn
		while (@@fetch_status = 0)
		begin

			-- we need to make sure that blockAsgms in / out event times do not
			-- exceed the requested start / end times.
			select @dtStartTime1 = @StartTime
			if (@dtBAEventTimeIn > @StartTime)
			begin
				select @dtStartTime1 = @dtBAEventTimeIn
			end
			select @dtEndTime1 = @EndTime
			if (@dtBAEventTimeOut < @EndTime)
			begin
				select @dtEndTime1 = @dtBAEventTimeOut
			end

			INSERT #AuditTrail
				(AmsTag, EventId, EventTime, UserName, Type, CategoryDesc, Description)
			SELECT @AmsTag,
				cast(cast(EventLog.EventIdDay as nvarchar(10)) + '.' + cast(EventLog.EventIdFraction as nvarchar(15)) as nvarchar(30)) as EventId,
				EventLog.EventTime, 
				Users.UserName,
				EventLog.Type, 
				EventCategories.CategoryDesc,
				EventLog.Description
			FROM EventLog INNER JOIN EventCategories ON 
				EventLog.Category = EventCategories.Category INNER JOIN
				Users ON EventLog.UserKey = Users.UserKey
			WHERE (EventLog.BlockKey = @nBlockKey) AND 
				(EventLog.EventTime BETWEEN @dtStartTime1 and @dtEndTime1)

			fetch next from aCursor into @nBlockKey, @dtBAEventTimeOut, @dtBAEventTimeIn

		end	-- of fetch while loop

		-- now go ahead and send the data from the temporary table.
		select * from #AuditTrail order by EventTime desc

		-- cleanup
		close aCursor
		deallocate aCursor
		drop table #AuditTrail

	end
	else
	begin
		-- get audit trail by the device currently assigned to AmsTag
		-- get the blockKey currently assigned to AmsTag.
		select @nBlockKey = BlockKey from AmsVw_CurrentTagBlockAsgms where (AmsTag = @AmsTag)
	-- print 'obtaining audit trail by device for blockkey ' + cast(@nBlockKey as nvarchar(10))

		SELECT @AmsTag as AmsTag,
			cast(cast(EventLog.EventIdDay as nvarchar(10)) + '.' + cast(EventLog.EventIdFraction as nvarchar(15)) as nvarchar(30)) as EventId,
			EventLog.EventTime, 
			Users.UserName,
			EventLog.Type, 
			EventCategories.CategoryDesc,
			EventLog.Description
		FROM EventLog INNER JOIN EventCategories ON 
			EventLog.Category = EventCategories.Category INNER JOIN
			Users ON EventLog.UserKey = Users.UserKey
		WHERE (EventLog.BlockKey = @nBlockKey) AND 
			(EventLog.EventTime BETWEEN @StartTime and @EndTime)
		ORDER BY EventTime DESC
	end
end
else
begin
	-- we have blank tag so get all events within the start and end times.
	SELECT @AmsTag as AmsTag,
		cast(cast(EventLog.EventIdDay as nvarchar(10)) + '.' + cast(EventLog.EventIdFraction as nvarchar(15)) as nvarchar(30)) as EventId,
		EventLog.EventTime, 
		Users.UserName,
		EventLog.Type, 
		EventCategories.CategoryDesc,
		EventLog.Description
	FROM EventLog INNER JOIN EventCategories ON 
		EventLog.Category = EventCategories.Category INNER JOIN
		Users ON EventLog.UserKey = Users.UserKey
	WHERE (EventLog.EventTime BETWEEN @StartTime and @EndTime)
	ORDER BY EventTime DESC
end
return (0)

GO

