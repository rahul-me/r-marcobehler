USE [Titan]
GO

DECLARE	@return_value int

EXEC	@return_value = [dbo].[cp_Get_Full_Ticket_Retail]
		@ticket_serial = N'U2002740'

SELECT	'Return Value' = @return_value

GO


-- U2002430  Travel Ticket
-- U2002436  Other Product Purchase

-- U2002438  Other Product Purchase - Latest Ticket Number for Investigation


select top 6 * from tbl_sales_items order by sales_item_id desc;

select top 5 * from tbl_sales order by sale_id desc;

select * from tbl_sales where sale_id = 92791240;

select si.* from tbl_sales_items si inner join (select * from tbl_sales where sale_id = 92791240) a on si.sale_id = a.sale_id;
select si.*,a.* from tbl_sales_items si inner join (select * from tbl_sales where sale_id = 92791240) a on si.sale_id = a.sale_id;

select top 10 * from tbl_sales s inner join tbl_sales_items si on s.sale_id = si.sale_id;

select * from tbl_products where product_id in (4, 20, 1810, 1811, 1230);
select top 2 * from tbl_product_types pt order by pt.product_type_id desc;
select top 2 * from tbl_product_category pc order by pc.product_category_id desc;
select * from tbl_product_category pc where pc.product_category_code in ('C','P') order by pc.product_category_id desc;
select top 2 * from tbl_product_family pf order by pf.product_family_id desc;

select * from (select * from tbl_product_category pc where pc.product_category_code in ('C','P')) pc left join tbl_products p on pc.product_category_id = p.product_category_id;

-- prodcuts its types and category
select p.product_category_id,pt.*, pc.product_category_id, pc.product_category_code as CategoryCode, pc.product_category_description as CategoryDescription from (select * from tbl_products p where p.product_id in (4, 20, 1810, 1811, 1230)) p inner join tbl_product_types pt on p.product_type_id = pt.product_type_id left join tbl_product_category pc on p.product_category_id = pc.product_category_id;
-- products its types, category and family
select p.product_category_id,pt.*, pc.product_category_id, pc.product_category_code as CategoryCode, pc.product_category_description as CategoryDescription, pf.family_name from (select * from tbl_products p where p.product_id in (4, 20, 1810, 1811, 1230)) p inner join tbl_product_types pt on p.product_type_id = pt.product_type_id left join tbl_product_category pc on p.product_category_id = pc.product_category_id left join tbl_product_family pf on p.product_family_id = pf.product_family_id;

select top 10 * from tbl_tickets order by ticket_id desc;

select top 2 * from tbl_Sales_Item_Transactions order by sales_item_transaction_id desc ;

exec sp_help tbl_Consumers;



--important as of now
select * from tbl_Consumers where sale_id = 92791244 order by consumer_id desc;
select top 3 * from tbl_item_consumer where sale_item_id = 318473905;
select si.*,a.* from tbl_sales_items si inner join (select * from tbl_sales where sale_id = 92791244) a on si.sale_id = a.sale_id;
select * from tbl_Email_Addresses where consumer_id in (select consumer_id from tbl_Consumers where sale_id = 92791244)
select top 3 * from tbl_Email_Addresses order by email_id desc; 

select * from tbl_Consumers where sale_id = 92791244 order by consumer_id desc;
select * from tbl_Email_Addresses where consumer_id in (select consumer_id from tbl_Consumers where sale_id = 92791244)

-- 318473905

-- 
select top 20 * from tbl_tickets order by ticket_id desc;

select top 10 * from logs order by log_id desc;

select top 5 * from tbl_Email_Addresses order by email_id desc;



-- Investigation for REQUIREMENT
-- Sale Id: 92791268
select * from tbl_sales where sale_id = 92791268;
select * from tbl_sales_items where sale_id = 92791268;
select * from tbl_item_consumer where sale_item_id in (select sales_item_id from tbl_sales_items where sale_id = 92791268);
select * from tbl_Consumers where sale_id = 92791268;
select * from tbl_Consumers where sale_id = 92791282;

-- new sale id 92791282
select * from tbl_Email_Addresses where consumer_id in (select consumer_id from tbl_item_consumer where sale_item_id in (select sales_item_id from tbl_sales_items where sale_id = 92791268))
select top 3 * from tbl_addresses order by address_id desc;
select * from tbl_list;



