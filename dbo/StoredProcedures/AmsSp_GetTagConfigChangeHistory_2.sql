
-----------------------------------------------------------------------
-- AmsSp_GetTagConfigChangeHistory_2
--
-- Get tag configuration change history for both HART and FF devices.
-- This Sp is a updated version of AmsSp_GetTagConfigChangeHistory_1
--
-- Inputs -
--	ExtBlockTag
--
-- Outputs -
--	Recordset containing list of configuration change dates (in GMT).
--	EventTime	datetime,
--	EventIdDay	int,
--	EventIdFraction	int
--
-- Returns -
--	returns 0 if ok.
--	-1 - Error, unable to get information.
--
-- Ying XU 09/22/2003
--
-- Source control keywords --
-- $Date: 2/17/05 3:47p $
-- $Revision: 121 $
--
CREATE  PROCEDURE AmsSp_GetTagConfigChangeHistory_2
@AmsTag as nvarchar(256)
AS
set nocount on
declare @iReturnVal int
set @iReturnVal = 0
	
declare @nBlockKey as int

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
	EventTime	datetime,
	EventIdDay	int,
	EventIdFraction	int
)

-- setup the blockasgms cursor.
declare aCursor cursor for select BlockKey, EventTimeOut, EventTimeIn from AmsVw_TagBlockAsgms_1 where (AmsTag = @AmsTag)

-- now for each of the blockKeys scan the audit trail and put their results
-- into the temporary table.
declare @dtBAEventTimeOut as datetime, @dtBAEventTimeIn as datetime
open aCursor
fetch next from aCursor into @nBlockKey, @dtBAEventTimeOut, @dtBAEventTimeIn
while (@@fetch_status = 0)
begin


	INSERT #AuditTrail
		(EventTime, EventIdDay, EventIdFraction)
	SELECT DISTINCT EventLog.EventTime,
		EventLog.EventIdDay,
		EventLog.EventIdFraction
	FROM BlockData INNER JOIN
	    EventLog ON 
	    BlockData.EventIdDay = EventLog.EventIdDay AND 
	    BlockData.EventIdFraction = EventLog.EventIdFraction
	WHERE (EventLog.BlockKey = @nBlockKey) AND (BlockData.ValueMode = 'h') AND 
		(EventLog.EventTime BETWEEN @dtBAEventTimeIn and @dtBAEventTimeOut)

	fetch next from aCursor into @nBlockKey, @dtBAEventTimeOut, @dtBAEventTimeIn

end	-- of fetch while loop

-- now go ahead and send the data from the temporary table.
select * from #AuditTrail order by EventTime desc

-- cleanup
close aCursor
deallocate aCursor
drop table #AuditTrail

return (0)

GO

