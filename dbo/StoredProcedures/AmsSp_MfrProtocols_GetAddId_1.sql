-----------------------------------------------------------------------
-- AmsSp_MfrProtocols_GetAddId_1
--
-- Get Mfr Protocol Id. if not found, then add it.
--
-- Inputs -
--  @nMfrNameId int
--      Manufacture name Id
--  @nProtocolId int
--      Protocol Description
--  @sMfrId nvarchar(255)
--      Manufacture ID
--
-- Outputs -
--  nMfrProtocolId
--
-- Returns -
--  0 - successful.
--  -1 - Error, unable to get mfr id.
--
-- Jane Xiao (6/23/2003)
--

CREATE PROCEDURE AmsSp_MfrProtocols_GetAddId_1
@nMfrNameId int,
@nProtocolId int,
@sMfrId nvarchar(255),
@nMfrProtocolId int OUTPUT
AS

declare @iReturnVal int
set @iReturnVal = 0

-- get MfrProtocolId if present.
select @nMfrProtocolId = MfrProtocolId
from MfrProtocols with (nolock)
where (AmsMfrNameId = @nMfrNameId)
and (ProtocolId = @nProtocolId)
and (MfrId = @sMfrId)

if @@rowcount = 0 
--MfrProtocols not found, add it
begin
	-- get the next MfrProtocolId
	declare @NextMfrProtocolId int
	select @NextMfrProtocolId = max(MfrProtocolId) + 1 from MfrProtocols
	-- add MfrProtocol to db
	insert MfrProtocols with (rowlock) (MfrProtocolId, AmsMfrNameId, ProtocolId, MfrId)
	values (@NextMfrProtocolId, @nMfrNameId, @nProtocolId, @sMfrId)
	if (@@ERROR <> 0)
	begin
		set @iReturnVal = -1
	end
	else --get new ID
	begin
		set @nMfrProtocolId = @NextMfrProtocolId
	end
end

return @iReturnVal

GO

