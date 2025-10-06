
----------------------------------------------------------------------
-- AmsSp_AL_InitializeForDevice_1
--
-- Initialize the AlertList for the individual device.
--
-- Inputs -
--  @nBlockKey - the blockKey of the device.
--	@dtStartTime datetime - no longer applicable
--
-- Outputs -
--  @nAlertsAdded - no longer applicable.
--
-- Returns -
--	0 - successful.
--	-1 - Error.
--
-- James Kramer 11/26/2007
--
CREATE  PROCEDURE AmsSp_AL_InitializeForDevice_1
@nBlockKey int,
@dtStartTime datetime,
@nAlertsAdded int output
AS

--print 'AmsSp_AL_InitializeForDevice_1 - ' + cast(@dtStartTime as nvarchar(100))
set nocount on

declare @nReturn int
set @nReturn = 0
set @nAlertsAdded = 0

declare @nALUpdated int
declare @nDMLUpdated int
declare @nPSAMUpdated int

set @nALUpdated = 0
set @nDMLUpdated = 0
set @nPSAMUpdated = 0

return @nReturn

GO

