
-------------------------------------------------------------------------------
-- AmsUdf_EventTimeAsDblToEventIdFraction
--
-- Converts an event time represented as a double (e.g. VT_DATE's sourced by 
-- C++ application code) into an EventIdFraction.
--
-- Inputs --
--	dEventTime
--
-- Returns --
--	nEventIdFraction
--
-- Author --
--	Kevin Mixter
--	10/02/2003
--
-- Source control keywords --
-- $Date: 2/22/05 3:48p $
-- $Revision: 34 $
--
CREATE   FUNCTION AmsUdf_EventTimeAsDblToEventIdFraction
(@dEventTime double precision)  
RETURNS int
AS  
BEGIN 
declare @dDecimalPart double precision

set @dDecimalPart = cast((@dEventTime - dbo.AmsUdf_EventTimeAsDblToEventIdDay(@dEventTime)) as double precision)
return (cast(((@dDecimalPart * cast(2147483648.0 as double precision)) + 0.5) as int))
END

GO

