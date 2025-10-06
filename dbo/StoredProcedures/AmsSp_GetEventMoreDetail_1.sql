
----------------------------------------------------------------------
-- AmsSp_GetEventMoreDetail_1
--
-- Get MoreDetail from EventLog table for the given day/fraction Id.
--
-- Inputs -
--	@nEventIdDay int	EventIdDay.
--	@nEventIdFraction int	EventIdFraction.
--
-- Output -
--	A recordset with the following three columns 
--	Type		Event Type
--	Category	Event Category
--	MoreDetail	MoreDetail data
--
-- Returns -
--	0 - successful.
--	-1 - General error on execution of the stored procedure.
--
-- Nghy Hong 11/30/2004
--
CREATE PROCEDURE AmsSp_GetEventMoreDetail_1
@nEventIdDay int,
@nEventIdFraction int
AS
declare @nReturn int
set @nReturn = 0

SELECT Type, Category, MoreDetail
FROM   EventLog
WHERE  (EventIdDay = @nEventIdDay) AND (EventIdFraction = @nEventIdFraction)

if (@@ERROR != 0)
Begin
	set @nReturn = -1
End

return @nReturn

GO

