
----------------------------------------------------------------------
-- AmsSp_AL_Initialize_1
--
-- Initialize the AlertList.  This no longer deletes the alerts from the alert list
--
-- Inputs -
--	@dtStartTime datetime - not applicable anymore
--  @bForceInitialize - not applicable anymore
--
-- Outputs -
--  none.
--
-- Returns -
--	0 - successful.
--	-1 - Error.
--
-- James Kramer 11/26/2007
--
CREATE PROCEDURE AmsSp_AL_Initialize_1
@dtStartTime datetime,
@bForceInitialize int
AS

--print 'AmsSp_AL_Initialize_1'

set nocount on

declare @nReturn int
set @nReturn = 0

-- initialize the tracking table.
exec AmsSp_ALTrack_Initialize_1
-- initialize the notifyQ
exec AmsSp_NotifyQ_Initialize_1

declare @cr1 cursor

declare @nALUpdated int
declare @nDMLUpdated int
declare @nPSAMUpdated int

set @nALUpdated = 0
set @nDMLUpdated = 0
set @nPSAMUpdated = 0

return @nReturn

GO

