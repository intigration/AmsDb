
-------------------------------------------------------------------------------
-- AmsUdf_EventTimeAsDblToEventIdDay 
--
-- Converts an event time represented as a double (e.g. VT_DATE's sourced by 
-- C++ application code) into an EventIdDay.
--
-- Inputs --
--	dEventTime
--
-- Returns --
--	nEventIdDay
--
-- Author --
--	Kevin Mixter
--	10/02/2003
--
-- Source control keywords --
-- $Date: 2/22/05 3:48p $
-- $Revision: 34 $
--
CREATE FUNCTION AmsUdf_EventTimeAsDblToEventIdDay
(@dEventTime double precision)  
RETURNS int
AS  
BEGIN 
return(FLOOR(@dEventTime))
END

GO

