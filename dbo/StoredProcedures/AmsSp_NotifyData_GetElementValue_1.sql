----------------------------------------------------------------------
-- AmsSp_NotifyData_GetElementValue_1
--
-- Get the element value from the notifyData.
--
-- Inputs -
--  @sNotifyData  nvarchar(max) - the notifyData packet.
--  @sElementName nvarchar(128) - element name.
--
-- Outputs -
--  @sElementValue nvarchar(1024) - element value.
--
-- Returns -
--	0 - successful.
--	-1 - not found.
--  -2 - error.
--
-- Joe Fisher 9/22/2004
--
CREATE PROCEDURE AmsSp_NotifyData_GetElementValue_1
@sNotifyData nvarchar(max),
@sElementName nvarchar(128),
@sElementValue nvarchar(1024) output
AS
declare @nReturn int
set @nReturn = 0

set @sElementValue = ''

-- we must have a non-blank elementName and notifydata to work with.
--print '@sNotifyData=' + @sNotifyData
--print '@sElementName=' + @sElementName
if (len(@sNotifyData) <= 0) or (len(@sElementName) <= 0) return -2

declare @nPos int
declare @nEndPos int
select @nPos = charindex(@sElementName, @sNotifyData)
--print '@nPos=' + cast(@nPos as nvarchar(10))
if (@nPos > 0)
begin
	-- element name is '<elementName>'
	set @nPos = @nPos + len(@sElementName) + len('>')
--	print '@nPos=' + cast(@nPos as nvarchar(10))
	-- element value stops at first '<'
	set @nEndPos = charindex('</', @sNotifyData, @nPos)
--	print '@nEndPos=' + cast(@nEndPos as nvarchar(10))
	if (@nEndPos > 0)
	begin
		-- get the element value
		set @sElementValue = substring(@sNotifyData, @nPos, @nEndPos - @nPos)
	end
	else
	begin
		-- did not find elementValue ending
		set @nReturn = -2
	end
end
else
begin
	-- did not find element
	set @nReturn = -1
end

return @nReturn

GO

