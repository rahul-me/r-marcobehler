declare @a varchar(2)
set @a = ' ';

IF ISNULL(@a,'') <> ''
	BEGIN
		print @a
		print 'not null not empty'
	END
ELSE 
	BEGIN
		print @a
		print 'null or empty'
	END
