
-------------------------------------------------------------------------------
-- AmsUdf_BinaryToInt 
--
-- Converts the binary input to an integer output.
--
-- Inputs --
--	@bBinaryValue - The block key for which to get the current software revision for.
--
-- Outputs --
--	iIntegerValue as int
--
-- Author --
--	Corey Middendorf
--	10/21/04
--
CREATE FUNCTION AmsUdf_BinaryToInt 
(@bBinaryValue varbinary(4))  
RETURNS int

AS  
BEGIN 


return (cast(cast(left(@bBinaryValue,1) as binary(1)) as int) + 
	(cast(cast(substring(@bBinaryValue,2,1) as binary(1)) as int) * 256) + 
	(cast(cast(substring(@bBinaryValue,3,1) as binary(1)) as int) * 65536) + 
	(cast(cast(substring(@bBinaryValue,4,1) as binary(1)) as int) * 16777216))
END

GO

