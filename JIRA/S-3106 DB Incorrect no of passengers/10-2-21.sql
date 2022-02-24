exec cp_Get_Full_Ticket_Retail 'E7B37849'
exec cp_Get_Full_Ticket_Retail 'E7B40079'

exec cp_Get_Full_Ticket_Retail 'EUMPH492'  -- 179657764

exec cp_Get_Full_Ticket_Retail 'EULUT270' -- additional consumer created  144170346
exec cp_Get_Full_Ticket_V7 'EULUT270'

exec cp_Get_Full_Ticket_Retail 'EUNRU183'
exec cp_Get_Full_Ticket_Retail 'EUMPH492'

exec cp_Get_Full_Ticket_Retail 'PTWA2795'

exec cp_Get_Full_Ticket_Retail 'EUNNK839'
select * from tbl_sales_items where sale_id = 180474213 where product_id = 1; -- 326367802 sales_item_id


select * from tbl_item_consumer where sale_item_id = 326367802


 SElect c.consumer_id, c.consumer_type_id, c.forename, c.surname,
 c.date_created as consumer_created, c.consumer_role_id, 
 c.sale_id, si.sales_item_id, ct.consumer_type, ct.passenger_type_code, si.date_created as item_purchaseed_date
      FROM   tbl_item_consumer IC 
             INNER JOIN tbl_consumers C 
                     ON IC.consumer_id = C.consumer_id
             LEFT JOIN [dbo].[tbl_consumer_types] CT 
                    ON C.consumer_type_id = CT.consumer_type_id 
             INNER JOIN tbl_sales_items SI 
                     ON SI.sales_item_id = sale_item_id 
      WHERE  SI.sale_id = '178990351'
             AND SI.product_id = 1
----------------------------------
SElect c.consumer_id, c.consumer_type_id, c.forename, c.surname,
 c.date_created as consumer_created, c.consumer_role_id, 
 c.sale_id, si.sales_item_id, ct.consumer_type, ct.passenger_type_code, si.date_created as item_purchaseed_date
      FROM   tbl_item_consumer IC 
             INNER JOIN tbl_consumers C 
                     ON IC.consumer_id = C.consumer_id
             LEFT JOIN [dbo].[tbl_consumer_types] CT 
                    ON C.consumer_type_id = CT.consumer_type_id 
             INNER JOIN tbl_sales_items SI 
                     ON SI.sales_item_id = sale_item_id 
      WHERE  SI.sale_id = '180474213'
             AND SI.product_id = 1

--
SElect c.consumer_id, c.consumer_type_id, c.forename, c.surname,
 c.date_created as consumer_created, c.consumer_role_id, 
 c.sale_id, si.sales_item_id, ct.consumer_type, 
 ct.passenger_type_code, si.date_created as item_purchaseed_date,
 ea.email_address
      FROM   tbl_item_consumer IC 
             INNER JOIN tbl_consumers C 
                     ON IC.consumer_id = C.consumer_id
             LEFT JOIN [dbo].[tbl_consumer_types] CT 
                    ON C.consumer_type_id = CT.consumer_type_id 
             INNER JOIN tbl_sales_items SI 
                     ON SI.sales_item_id = sale_item_id
			 left join tbl_email_addresses	ea on ea.consumer_id = c.consumer_id 
					and c.consumer_id not in ( 0, 1, 2, 3, 4, 5, 5445592, 5445601, 5445609 ) 
      WHERE  SI.sale_id = '178990351'
             AND SI.product_id = 1
--

select top 5 * from tbl_item_consumer where sale_item_id = 322740219

select top 10 * from tbl_consumers;
select * from tbl_consumers where consumer_id in ( 0, 1, 2, 3, 4, 5, 5445592, 5445601, 5445609 )
select * from tbl_email_addresses where consumer_id in (0, 1, 2, 3, 4, 5, 5445592, 5445601, 5445609)

select * from tbl_email_addresses

select * from tbl_consumers where consumer_id = 144323141
select * from tbl_consumers where consumer_id = 144170346 -- 144170346 one more adult record with updated forename and surname
select * from tbl_consumer_types where consumer_type_id = 1
select * from tbl_item_consumer where consumer_id = 144323141; -- different sale-item id
select * from tbl_item_consumer where consumer_id = 144170346;

select * from tbl_sales_items where sales_item_id = 322740219
select * from tbl_sales_items where sale_id = '178990351'
select * from tbl_consumers c 
inner join tbl_item_consumer ic on ic.consumer_id = c.consumer_id
where ic.sale_item_id = 322740219

select top 10 * from tbl_list

exec sp_help tbl_consumers

select top 1 * from tbl_consumer_role

SELECT CT.passenger_type_code consumerType, 
             ( CASE 
                 WHEN consumer_type = 'Ghost' THEN 'Infants' 
                 ELSE consumer_type 
               END )                typeDescription, 
     Count(1)               paxCount 
      FROM   tbl_item_consumer IC 
             INNER JOIN tbl_consumers C 
                     ON IC.consumer_id = C.consumer_id 
             LEFT JOIN [dbo].[tbl_consumer_types] CT 
                    ON C.consumer_type_id = CT.consumer_type_id 
             INNER JOIN tbl_sales_items SI 
                     ON SI.sales_item_id = sale_item_id 
      WHERE  SI.sale_id =  '178990351'
             AND SI.product_id = 1 
      GROUP  BY passenger_type_code, 
                consumer_type



SELECT * 
 SElect c.consumer_id, c.consumer_type_id, c.forename, c.surname,
 c.date_created as consumer_created, c.consumer_role_id, 
 c.sale_id, si.sales_item_id, ct.consumer_type, ct.passenger_type_code, si.date_created as item_purchaseed_date
      FROM   tbl_item_consumer IC 
             INNER JOIN tbl_consumers C 
                     ON IC.consumer_id = C.consumer_id
             LEFT JOIN [dbo].[tbl_consumer_types] CT 
                    ON C.consumer_type_id = CT.consumer_type_id 
             INNER JOIN tbl_sales_items SI 
                     ON SI.sales_item_id = sale_item_id 
      WHERE  SI.sale_id = '180557596'
             AND SI.product_id = 1
			 
-- 179657764
 SElect c.consumer_id, c.consumer_type_id, c.forename, c.surname,
 c.date_created as consumer_created, c.consumer_role_id, 
 c.sale_id, si.sales_item_id, ct.consumer_type, 
 ct.passenger_type_code, si.date_created as item_purchaseed_date
 --ea.*
      FROM   tbl_item_consumer IC 
             INNER JOIN tbl_consumers C 
                     ON IC.consumer_id = C.consumer_id
             LEFT JOIN [dbo].[tbl_consumer_types] CT 
                    ON C.consumer_type_id = CT.consumer_type_id 
             INNER JOIN tbl_sales_items SI 
                     ON SI.sales_item_id = sale_item_id
			 --Inner join tbl_email_addresses	ea on ea.consumer_id = .consumer_id
      WHERE  SI.sale_id = '179657764'
             AND SI.product_id = 1


SElect c.consumer_id, c.consumer_type_id, c.forename, c.surname,
 c.date_created as consumer_created, c.consumer_role_id, 
 c.sale_id, si.sales_item_id, ct.consumer_type, 
 ct.passenger_type_code, si.date_created as item_purchaseed_date,
 ea.*
      FROM   tbl_item_consumer IC 
             INNER JOIN tbl_consumers C 
                     ON IC.consumer_id = C.consumer_id
             LEFT JOIN [dbo].[tbl_consumer_types] CT 
                    ON C.consumer_type_id = CT.consumer_type_id 
             INNER JOIN tbl_sales_items SI 
                     ON SI.sales_item_id = sale_item_id
			 left join tbl_email_addresses	ea on ea.consumer_id = c.consumer_id 
      WHERE  SI.sale_id = '179657764'
             AND SI.product_id = 1


-- (F Sid)180474213 - Ticket - EUNNK839
SElect c.consumer_id, c.consumer_type_id, c.forename, c.surname,
 c.date_created as consumer_created, c.consumer_role_id, 
 c.sale_id, si.sales_item_id, ct.consumer_type, 
 ct.passenger_type_code, si.date_created as item_purchaseed_date,
 ea.*
      FROM   tbl_item_consumer IC 
             INNER JOIN tbl_consumers C 
                     ON IC.consumer_id = C.consumer_id
             LEFT JOIN [dbo].[tbl_consumer_types] CT 
                    ON C.consumer_type_id = CT.consumer_type_id 
             INNER JOIN tbl_sales_items SI 
                     ON SI.sales_item_id = sale_item_id
			 left join tbl_email_addresses	ea on ea.consumer_id = c.consumer_id 
      WHERE  SI.sale_id = '180474213'
             AND SI.product_id = 1