
-----------------------------------------------------------------------
-- AmsSp_GetConfigurationHistoryByBlockKey_2
--
-- Get configuration history for a point in time by blockKey.
-- Note: point-in-time is defined as DBW_HIGHRES_TIME.day and fraction
--	components.
--
-- Inputs -
--	nBlockKey	integer	the blockKey.
--	nEventDay	integer	the day component of the point-in-time (GMT).
--	nEventFraction	integer	the fraction component of the point-in-time (GMT).
--	cValueMode	char(1) either 'h' (for historic data) or
--				'o' (for offline data)
--
-- Outputs -
--	Recordset containing list parameters for that point in time.
--
-- Returns -
--	returns 0 if ok.
--	-1 - Error, unable to get information.
--
-- Joe Fisher, 02/26/02
--
-- Source control keywords --
-- $Date: 2/17/05 3:47p $
-- $Revision: 121 $
--
CREATE PROCEDURE AmsSp_GetConfigurationHistoryByBlockKey_2
@nBlockKey as integer,
@nEventDay as integer,
@nEventFraction as integer,
@cValueMode as char(1)
AS

set nocount on

declare @iReturnVal int
set @iReturnVal = 0

declare @rsBlockKey	integer
declare @rsEventIdDay	integer
declare @rsEventIdFraction	integer
declare @rsParamKind	char(1)
declare @rsParamName	nvarchar(255)
declare @rsValueMode	char(1)
declare @rsParamDataType	tinyint
declare @rsParamDataSize	integer
declare @rsParamData	varchar(255)
declare @rsArchived	bit

-- create the temporary table.
create table #ConfigParams
(
	BlockKey	integer,
	EventIdDay	integer,
	EventIdFraction	integer,
	ParamKind	char(1),
	ParamName	nvarchar(255),
	ValueMode	char(1),
	ParamDataType	tinyint,
	ParamDataSize	integer,
	ParamData	varbinary(255) --nvarchar(255)
)

-- Get the list of distinct Parameters for this block.
declare aCursor cursor for select distinct ParamName from BlockData with (nolock) where (BlockKey = @nBlockKey) and (ValueMode = @cValueMode) and (ParamKind = 'P')

-- now for each of the parameters scan the BlockData table for the single value that just less
-- than or equal to the point-in-time.
-- If no value is found for that parameter then the EventIdDay = -1, EventIdFraction = -1, and
-- the ParamData is set to 'NA'
declare @sParamName as nvarchar(255)
open aCursor
fetch next from aCursor into @sParamName
while (@@fetch_status = 0)
begin

	SELECT     TOP 1 @rsBlockKey = dbo.BlockData.BlockKey,
			 @rsEventIdDay = dbo.BlockData.EventIdDay,
   			 @rsEventIdFraction = dbo.BlockData.EventIdFraction,
			 @rsParamKind = dbo.BlockData.ParamKind,
			 @rsParamName = dbo.BlockData.ParamName, 
	                 @rsValueMode = dbo.BlockData.ValueMode,
			 @rsParamDataType = dbo.BlockData.ParamDataType,
			 @rsParamDataSize = dbo.BlockData.ParamDataSize,
			 @rsParamData = dbo.BlockData.ParamData,
			 @rsArchived = dbo.BlockData.Archived
	FROM         dbo.BlockData with (nolock) INNER JOIN
	                      dbo.EventLog with (nolock) ON dbo.BlockData.EventIdDay = dbo.EventLog.EventIdDay AND dbo.BlockData.EventIdFraction = dbo.EventLog.EventIdFraction
	WHERE     (dbo.BlockData.ParamKind = 'P') AND
		  (dbo.BlockData.ValueMode = @cValueMode) AND
		  (dbo.BlockData.BlockKey = @nBlockKey) AND 
	          (dbo.BlockData.ParamName = @sParamName) AND
		  (dbo.BlockData.EventIdDay >= 0) AND
		  ((dbo.BlockData.EventIdDay < @nEventDay) OR
			((dbo.BlockData.EventIdDay = @nEventDay) AND (dbo.BlockData.EventIdFraction <= @nEventFraction)))
	ORDER BY dbo.EventLog.EventIdDay DESC, dbo.EventLog.EventIdFraction DESC
-- tried using the following to avoid tying into the really large EventLog table
-- but it seems that the calculations and conversions are more expensive than the
-- join to the EventLog table.
--	ORDER BY CAST(EventIdDay + EventIdFraction / 2147483648.0 AS float) DESC

	if (@@rowcount = 1)
	begin
		insert #ConfigParams (	BlockKey,
				EventIdDay,
				EventIdFraction,
				ParamKind,
				ParamName,
				ValueMode,
				ParamDataType,
				ParamDataSize,
				ParamData)
		values	      ( @rsBlockKey,
				@rsEventIdDay,
				@rsEventIdFraction,
				@rsParamKind,
				@rsParamName,
				@rsValueMode,
				@rsParamDataType,
				@rsParamDataSize,
				cast(@rsParamData as varbinary(255)))
	end

	fetch next from aCursor into @sParamName
end	-- while on the aCursor fetch.

	select  		BlockKey,
				EventIdDay,
				EventIdFraction,
				ParamKind,
				ParamName,
				ValueMode,
				ParamDataType,
				ParamDataSize,
				ParamData
		from #ConfigParams
		order by ParamName asc

-- cleanup
close aCursor
deallocate aCursor
drop table #ConfigParams

return @iReturnVal

GO

