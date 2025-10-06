-----------------------------------------------------------------------
-- AmsSp_MfrProtocols_GetAddId_2
--
-- Get the mfrProtocol database key for the mfrId - protocol combination.
-- If the combination is not found then it is added.
-- Also this function checks to see if the suggested manufacturer name is
-- in the Manufacturers table- if not, it is also added.
--
-- Inputs -
--  @nMfrId int
--      Manufacture Id
--  @sProtocolName nvarchar(255)
--      Protocol Name
--  @sSuggestedManufacturerName nvarchar(255)
--      Name of manufacturer if mfrid-protocol combination not found.
--
-- Outputs -
--  nMfrProtocolKey
--
-- Returns -
--  0 - successful.
--  -1 - Error, unable to get mfr id.
--	-2 - Error, protocolName not present.
--	-3 - Error, unable get/add manufacturer.
--	-4 - Error, unable to add the MfrProtocol entry.
--
-- Joe Fisher 10/16/2003
--

CREATE PROCEDURE AmsSp_MfrProtocols_GetAddId_2
@nMfrId int,
@sProtocolName nvarchar(255),
@sSuggestedManufacturerName nvarchar(255),
@nMfrProtocolKey int OUTPUT
AS
declare @nReturnVal int
set @nReturnVal = 0
declare @nSpRetVal int

set nocount on

-- get the protocolKey- note: protocolName must be present.
declare @nProtocolKey int
select @nProtocolKey = ProtocolId from DeviceProtocols with (nolock) where Name = @sProtocolName
if (@@rowcount = 0)
begin
	return -2	-- protocol not found.
end

-- get mfrId - Protocol combination if present.
declare @sMfrId nvarchar(255)
set @sMfrId = cast(@nMfrId as nvarchar(255))
select @nMfrProtocolKey = MfrProtocolId from MfrProtocols with (nolock) where (ProtocolId = @nProtocolKey) and (MfrId = @sMfrId)

if (@@rowcount = 0)
--mfrId - Protocol combination not found, add it
begin
	-- we want to make this atomic
	begin transaction

	-- go get - add this manufacturer database key.
	declare @nMfrDbKey int
	exec @nSpRetVal = AmsSp_DevManufacturer_GetAddId_1 @sSuggestedManufacturerName,
													   @sSuggestedManufacturerName,
													   @nMfrDbKey output
	if (@nSpRetVal <> 0)
	begin
		rollback transaction
		return -3	-- unable to get/add manufacturer
	end

	-- add the mfrId - Protocol combination
	declare @nMfrProtDbKey int
	exec @nSpRetVal = AmsSp_MfrProtocols_GetAddId_1 @nMfrDbKey,
													   @nProtocolKey,
													   @sMfrId,
													   @nMfrProtDbKey output
	if (@nSpRetVal <> 0)
	begin
		rollback transaction
		return -4	-- unable to get/add MfrProtocol
	end

	-- successful add.
	commit transaction
	set @nMfrProtocolKey = @nMfrProtDbKey
end

return 0

GO

