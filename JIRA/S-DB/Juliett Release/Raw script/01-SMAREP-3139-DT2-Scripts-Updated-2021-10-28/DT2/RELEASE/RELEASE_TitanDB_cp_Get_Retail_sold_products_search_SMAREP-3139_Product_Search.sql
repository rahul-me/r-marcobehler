USE [Titan]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ============================================= 
-- Created By  :  Maunish Soni
-- Create date  : 26/10/2021   
-- Description  : Search Sold Product list with criteria passed
-- EXECUTE cp_Get_Retail_sold_products_search '1810, 1811, 442, 20, 28, 29, 30'
-- ===========================================================

CREATE PROCEDURE [dbo].[cp_Get_Retail_sold_products_search] 
(
  @productIdsList nvarchar(1000),
  @coachSerial nvarchar(15),
  @ticketSerial nvarchar(15),
  @surname nvarchar(40),
  @email nvarchar(150),
  @postcode nvarchar(10),
  @last4 nvarchar(10),
  @fromSaleDate nvarchar(20),
  @toSaleDate nvarchar(20),
  @fromExpiryDate nvarchar(20),
  @toExpiryDate nvarchar(20),
  @pageSize int,
  @limitRows int,
  @pageNumber int,
  @sortBy nvarchar(20),
  @sortOrder nvarchar(5)
)

AS
BEGIN

DECLARE @mainQuery nvarchar(3000);
DECLARE @countQuery nvarchar(3000);
DECLARE @criterias nvarchar(1000);
DECLARE @sorting nvarchar(100);
DECLARE @LimitRowsString nvarchar(10);
DECLARE @pageIndexString nvarchar(10);

SET @LimitRowsString = CONVERT(nvarchar(10), @limitRows);
SET @pageIndexString = CONVERT(nvarchar(10), @pageSize * @pageNumber);

SET @mainQuery = '';
SET @countQuery = '';
SET @criterias = '';
SET @sorting = '';

IF  Isnull(@coachSerial, '') <> ''
	BEGIN
		SET @criterias = @criterias + ' AND PS.product_serial = '''+@coachSerial+'''';
	END
ELSE IF  Isnull(@ticketSerial, '') <> ''
	BEGIN
		SET @criterias = @criterias + ' AND T.ticket_serial = '''+@ticketSerial+'''';
	END
ELSE 
	BEGIN
		IF Isnull(@surname, '') <> ''
		BEGIN
			SET @criterias = @criterias + ' AND CS.surname like ''%'+@surname+'%''';
		END
		
		IF Isnull(@email, '') <> ''
		BEGIN
			SET @criterias = @criterias + ' AND EA.email_address = '''+@email+'''';
		END
		
		IF Isnull(@postcode, '') <> ''
		BEGIN
			SET @criterias = @criterias + ' AND A.postcode = '''+@postcode+'''';
		END
		
		IF Isnull(@last4, '') <> ''
		BEGIN
			SET @criterias = @criterias + ' AND RIGHT(CD.card_number,4) = '''+@last4+'''';
		END
		
		IF Isnull(@fromSaleDate, '') <> ''
		BEGIN
			SET @criterias = @criterias + ' AND SI.date_created >= CONVERT(DATETIME, '''+@fromSaleDate+''')';
		END
		
		IF Isnull(@toSaleDate, '') <> ''
		BEGIN
			SET @criterias = @criterias + ' AND SI.date_created <= CONVERT(DATETIME,'''+@toSaleDate+''')';
		END
		
		IF Isnull(@fromExpiryDate, '') <> ''
		BEGIN
			SET @criterias = @criterias + ' AND SLV.to_date >= CONVERT(DATETIME,'''+@fromExpiryDate+''')';
		END
		
		IF Isnull(@toExpiryDate, '') <> ''
		BEGIN
			SET @criterias = @criterias + ' AND SLV.to_date <= CONVERT(DATETIME,'''+@toExpiryDate+''')';
		END
		
	END	
	
SET @sortOrder = LOWER(Isnull(@sortOrder, ''));
SET @sortBy = Isnull(@sortBy, '');
	
IF  @sortBy = 'ticketSerial'
	BEGIN
		SET @sorting = ' ORDER BY T.ticket_serial';
	END
ELSE IF @sortBy = 'coachSerial'
	BEGIN
		SET @sorting = ' ORDER BY Isnull(PS.product_serial, ''N/A'')';
	END
ELSE IF @sortBy = 'productName'
	BEGIN
		SET @sorting = ' ORDER BY P.product_description';
	END
ELSE IF @sortBy = 'cardHolderName'
	BEGIN
		SET @sorting = ' ORDER BY Isnull(CS.forename + '' '' + CS.surname, ''N/A'')';
	END
ELSE IF @sortBy = 'startDate'
	BEGIN
		SET @sorting = ' ORDER BY SLV.from_date';
	END
ELSE IF @sortBy = 'expiryDate'
	BEGIN
		SET @sorting = ' ORDER BY SLV.to_date';
	END
ELSE IF @sortBy = 'email'
	BEGIN
		SET @sorting = ' ORDER BY Isnull(EA.email_address, ''N/A'')';
	END
ELSE IF @sortBy = 'postCode'
	BEGIN
		SET @sorting = ' ORDER BY A.postcode';
	END
ELSE IF @sortBy = 'payment'
	BEGIN
		SET @sorting = ' ORDER BY CD.card_number';
	END

SET @sorting = @sorting + @sortOrder;

SET @mainQuery = 'SELECT ticketSerial, coachSerial, productName, cardHolderName, startDate, expiryDate, email, postCode, payment'+
				' FROM (SELECT TOP '+ @LimitRowsString +'  ticketSerial, coachSerial, productName, cardHolderName, startDate, expiryDate, email, postCode, payment'+
				' FROM (SELECT TOP '+ @pageIndexString +' T.ticket_serial AS ticketSerial, Isnull(PS.product_serial, ''N/A'') AS coachSerial, P.product_description AS productName, Isnull(CS.forename + '' '' + CS.surname, ''N/A'') AS cardHolderName, SLV.from_date as startDate, SLV.to_date as expiryDate, Isnull(EA.email_address, ''N/A'') AS email, A.postcode AS postCode, (CASE WHEN CD.card_number = ''************0'' THEN ''CASH'' ELSE RIGHT(CD.card_number,4) END) AS payment'+
				' FROM tbl_Sales_items SI WITH (nolock) '+
				' LEFT JOIN tbl_sale_item_validity SLV  WITH (nolock) ON SLV.sale_item_id= SI.sales_item_id'+
				' INNER JOIN tbl_products P  WITH (nolock) ON SI.product_id = P.product_id and SI.product_id IN ('+ @productIdsList +')'+
				' INNER JOIN tbl_product_category PC  WITH (nolock) ON P.product_category_id = PC.product_category_id'+
				' INNER JOIN tbl_product_family PF  WITH (nolock) ON P.product_family_id = PF.product_family_id'+
				' INNER JOIN tbl_item_serial_link ISL  WITH (nolock) ON SI.item_serial_id = ISL.item_serial_id '+
				' INNER JOIN tbl_product_serials PS  WITH (nolock) ON ISL.product_serial_id = PS.product_serial_id '+
				' LEFT JOIN tbl_tickets T WITH (nolock) ON ISL.ticket_id = T.ticket_id'+
				' LEFT JOIN dbo.tbl_item_consumer IC   WITH (nolock) ON IC.sale_item_id = SI.sales_item_id AND IC.consumer_id NOT IN ( 0, 1, 2, 3, 4, 5, 5445592, 5445601, 5445609 ) '+
				' LEFT JOIN dbo.tbl_Consumers CS  WITH (nolock) ON CS.consumer_id = IC.consumer_id AND CS.consumer_role_id = 10'+
				' LEFT JOIN dbo.tbl_consumers_addresses AS CA  WITH (nolock) ON CA.consumer_id = CS.consumer_id '+
				' INNER JOIN dbo.tbl_addresses AS A  WITH (nolock) ON CA.address_id = A.address_id '+
				' LEFT JOIN dbo.tbl_Email_Addresses EA  WITH (nolock) ON EA.consumer_id = IC.consumer_id'+
				' LEFT JOIN tbl_payments PAY WITH (nolock) ON PAY.sale_id = SI.sale_id AND payment_id <> 0'+ 
				' LEFT JOIN tbl_card_details CD  WITH (nolock) ON CD.card_details_id = PAY.card_details_id'+
				' WHERE 1 = 1';	
				
SET @countQuery = 'SELECT count(SI.sales_item_id) as rowCounts'+
				' FROM tbl_Sales_items SI WITH (nolock) '+
				' LEFT JOIN tbl_sale_item_validity SLV  WITH (nolock) ON SLV.sale_item_id= SI.sales_item_id'+
				' INNER JOIN tbl_products P  WITH (nolock) ON SI.product_id = P.product_id and SI.product_id IN ('+ @productIdsList +')'+
				' INNER JOIN tbl_product_category PC  WITH (nolock) ON P.product_category_id = PC.product_category_id'+
				' INNER JOIN tbl_product_family PF  WITH (nolock) ON P.product_family_id = PF.product_family_id'+
				' INNER JOIN tbl_item_serial_link ISL  WITH (nolock) ON SI.item_serial_id = ISL.item_serial_id '+
				' INNER JOIN tbl_product_serials PS  WITH (nolock) ON ISL.product_serial_id = PS.product_serial_id '+
				' LEFT JOIN tbl_tickets T WITH (nolock) ON ISL.ticket_id = T.ticket_id'+
				' LEFT JOIN dbo.tbl_item_consumer IC   WITH (nolock) ON IC.sale_item_id = SI.sales_item_id AND IC.consumer_id NOT IN ( 0, 1, 2, 3, 4, 5, 5445592, 5445601, 5445609 ) '+
				' LEFT JOIN dbo.tbl_Consumers CS  WITH (nolock) ON CS.consumer_id = IC.consumer_id AND CS.consumer_role_id = 10'+
				' LEFT JOIN dbo.tbl_consumers_addresses AS CA  WITH (nolock) ON CA.consumer_id = CS.consumer_id '+
				' INNER JOIN dbo.tbl_addresses AS A  WITH (nolock) ON CA.address_id = A.address_id '+
				' LEFT JOIN dbo.tbl_Email_Addresses EA  WITH (nolock) ON EA.consumer_id = IC.consumer_id'+
				' LEFT JOIN tbl_payments PAY WITH (nolock) ON PAY.sale_id = SI.sale_id AND payment_id <> 0'+ 
				' LEFT JOIN tbl_card_details CD  WITH (nolock) ON CD.card_details_id = PAY.card_details_id'+
				' WHERE 1 = 1'

SET @countQuery = @countQuery + @criterias;
SET @mainQuery = @mainQuery + @criterias;

IF @sorting = ''
	BEGIN
		SET @mainQuery = @mainQuery + ' ORDER BY T.ticket_serial) AS TSL1'+
									' ORDER BY ticketSerial DESC) AS TSL2'+
									' ORDER BY ticketSerial ASC';
	END
ELSE 
	BEGIN
		SET @mainQuery = @mainQuery + @sorting  + ' ) AS TSL1'+
									' ORDER BY ticketSerial DESC) AS TSL2'+
									' ORDER BY ticketSerial ASC';
	END	
	
EXEC sp_executesql @mainQuery
EXEC sp_executesql @countQuery

END

GO