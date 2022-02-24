use NXlookup;

select * from tbl_Payment_Providers;

delete from tbl_Payment_Providers where id = 19;

insert into tbl_Payment_Providers (name, description) values ('Adyen', 'test');


USE NXlookup;
EXEC sp_help tbl_Payment_Providers

USE NXLookup;

DECLARE @adyen_id int;
SET @adyen_id = 0 ;

DECLARE @adyen_string varchar(10);
SET @adyen_string = 'Adyen'

SELECT @adyen_id = id FROM tbl_Payment_Providers WHERE UPPER(name) = UPPER(@adyen_string);

print @adyen_id;

IF (@adyen_id = 0)
	BEGIN
		INSERT INTO tbl_Payment_Providers (name, description) values (@adyen_string, @adyen_string)
	END
ELSE 
	BEGIN
		UPDATE tbl_Payment_Providers SET name = @adyen_string, description = @adyen_string WHERE id = @adyen_id;
	END	


print UPPER('NiGel')