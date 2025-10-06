-----------------------------------------------------------------------
-- AmsSp_DevProtocol_GetAddId_1
--
-- Get device Protocol Id. if not found, then add it.
--
-- Inputs -
--	@sProtocolName nvarchar(255)
--		Protocol name
--	@sDescription nvarchar(255)
--		Protocol Description
--
-- Outputs -
--	nProtocolId
--
-- Returns -
--	0 - successful.
--	-1 - Error, unable to get mfr id.
--
-- Jane Xiao (6/23/2003)
--

CREATE PROCEDURE AmsSp_DevProtocol_GetAddId_1
@sProtocolName nvarchar(255),
@sDescription nvarchar(255),
@nProtocolId int OUTPUT
AS

declare @iReturnVal int
set @iReturnVal = 0

-- get ProtocolID if present.
select @nProtocolId = ProtocolId
from DeviceProtocols with (nolock)
where Name = @sProtocolName

if @@rowcount = 0 
--Protocol not found, add it
begin
	-- get the next AmsProtocolId
	declare @NextProtocolId int
	select @NextProtocolId = max(ProtocolId) + 1 from DeviceProtocols
	-- add Protocol to db
	insert DeviceProtocols with (rowlock) (ProtocolId, Name, Description)
	values (@NextProtocolId, @sProtocolName, @sDescription)
	if (@@ERROR <> 0)
	begin
		set @iReturnVal = -1
	end
	else --get new ID
	begin
		set @nProtocolId = @NextProtocolId
	end
end

return @iReturnVal

GO

