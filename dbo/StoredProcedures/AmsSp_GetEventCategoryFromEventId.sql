----------------------------------------------------------------------
-- AmsSp_GetEventCategoryFromEventId
--
-- Get the eventCategory value for the given eventId.
--
-- Inputs -
--  @nEventIdDay - the eventIdDay.
--	@nEventIdFraction - the eventIdFraction.
--
-- Outputs -
--  @nEventCategoryId int - the found event category
--
-- Returns -
--	0 - successful.
--	-1 - EventId not found.
--
-- Joe Fisher 10/28/2004
--
CREATE PROCEDURE AmsSp_GetEventCategoryFromEventId
@nEventIdDay int,
@nEventIdFraction int,
@nEventCategoryId int output,
@sEventSource nvarchar(50) output
AS
set nocount on
set @nEventCategoryId = -99
set @sEventSource = ''
select @nEventCategoryId = Category, @sEventSource = Source from EventLog with (nolock) where (EventIdDay = @nEventIdDay) and (EventIdFraction = @nEventIdFraction)
if (@@rowcount <> 1)
begin
	return -1	-- did not find the event.
end
return 0

GO

