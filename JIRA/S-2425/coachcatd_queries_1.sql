select top 10 * from logs where applicationName = 'Mercury Reservation Request' order by log_id desc;

SELECT serials.product_serial,
consumerType.Passenger_Type_Code as PassengerTypeCode,
validity.to_date as ToDate,
validity.from_date as FromDate
FROM
dbo.tbl_Sale_Item_Validity validity with(NOLOCK)
Inner Join dbo.tbl_Sales_Items sale_item with(NOLOCK) ON sale_item_id =sale_item.sales_item_id AND active=1
INNER join dbo.tbl_Products products on products.product_id=sale_item.product_id AND products.product_category_id=10 --10 is Product Category for Coachcard
INNER JOIN dbo.tbl_Item_Serial_Link isl with(NOLOCK) on sale_item.item_serial_id=isl.item_serial_id
Inner Join dbo.tbl_Product_Serials serials with(NOLOCK) on isl.product_serial_id = serials.product_serial_id
Inner JOIN dbo.tbl_Consumer_Types consumerType with(NOLOCK) ON consumerType.consumer_type_id= products.product_consumer_type_id
inner JOIN tbl_Tickets ts on ts.ticket_id =isl.ticket_id and ts.ticket_serial='U2002417'

select top 10 * from tbl_Consumers order by consumer_id desc;

select * from dbo.tbl_Products p inner join tbl_product_category cat on p.product_category_id = cat.product_category_id

