-----------------------------------------------------------------------
-- AmsSp_CreateAmsTagName_1
--
-- Create a AmsTag name in mm/dd/yyyy hh:mm:ss.sss format based on
-- current local time.
--
--
-- Inputs -
--	none
--
-- Outputs -
--	@sAmsTag		nvarchar(255)
--	
--
-- Returns -
--	0 - successful.
--	-1 - Error, unable to generate.
--
-- Joe Fisher - 9/3/2003
--

CREATE PROCEDURE AmsSp_CreateAmsTagName_1
@sAmsTag		nvarchar(255) output
AS
declare @iReturnVal int
set @iReturnVal = 0
set @sAmsTag = ''

declare @currentTime as datetime
set @currentTime = getdate()

declare @datePart as nvarchar(4)
set @datePart = convert(nvarchar, datepart(month,@currentTime))
if len(@datePart) = 1 set @datePart = '0' + @datePart
set @sAmsTag = @datePart
set @datePart = convert(nvarchar, datepart(day,@currentTime))
if len(@datePart) = 1 set @datePart = '0' + @datePart
set @sAmsTag = @sAmsTag + '/' + @datePart
set @datePart = convert(nvarchar, datepart(year,@currentTime))
set @sAmsTag = @sAmsTag + '/' + @datePart
set @datePart = convert(nvarchar, datepart(hour,@currentTime))
if len(@datePart) = 1 set @datePart = '0' + @datePart
set @sAmsTag = @sAmsTag + ' ' + @datePart
set @datePart = convert(nvarchar, datepart(minute,@currentTime))
if len(@datePart) = 1 set @datePart = '0' + @datePart
set @sAmsTag = @sAmsTag + ':' + @datePart
set @datePart = convert(nvarchar, datepart(second,@currentTime))
if len(@datePart) = 1 set @datePart = '0' + @datePart
set @sAmsTag = @sAmsTag + ':' + @datePart
set @datePart = convert(nvarchar, datepart(millisecond,@currentTime))
if len(@datePart) = 1 set @datePart = '00' + @datePart
else if len(@datePart) = 2 set @datePart = '0' + @datePart
set @sAmsTag = @sAmsTag + '.' + @datePart

return @iReturnVal

GO

