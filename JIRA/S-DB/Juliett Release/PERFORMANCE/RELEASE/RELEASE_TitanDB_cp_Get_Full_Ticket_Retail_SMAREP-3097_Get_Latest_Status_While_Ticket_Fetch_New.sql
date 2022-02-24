USE [Titan]
GO

/****** Object:  StoredProcedure [dbo].[cp_Get_Full_Ticket_Retail]    Script Date: 13-10-2021 05:08:18 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





--sp_helptext cp_get_full_ticket_retail @ticket_serial = 'E2JD4247', @selected_sale_id = 92786539

--exec cp_get_full_ticket_retail @ticket_serial = 'E2JD4247', @selected_sale_id = 92786539

-- exec cp_Get_Full_Ticket_Retail 'E2JD366' 
-- sp_helptext cp_Get_Full_Ticket_Retail 
-- ============================================= 
-- Created By  :  Kajal Patel / Bhavesh Kashikar 
-- Create date  :  10/01/2020   
-- Description  :  Location Names Function 
-- ===========================================================
-- Modified By  :  Urvashi Trivedi   
-- Modified Date  :  28/01/2020   
-- Description  :  Added History Block and added new local parameter @Consm_id for performance improvement.
-- ===========================================================
-- Modified By  :  Urvashi Trivedi   
-- Modified Date  :  28/01/2020   
-- Description  :  SMAREP-735 New optional Parameter '@PNR' added; Default NULL.
-- =========================================================== 
-- Modified By : Jay Shah 
-- Modified Date : 17/02/2020 
-- Description : SMAREP-781 Get JourneyType from tbl_Journey_Summary instead of tbl_Ticket_Journeys 
-- =========================================================== 
-- Modified By  :  Bhavesh KAshikar 
-- Modified Date  :  06/03/2020   
-- Description  :  Fixed partial cancellation issue for excess fare. 
-- ===========================================================
-- Modified By  :  Urvashi Parmar 
-- Modified Date  :  01/04/2020   
-- Description  :  SMAREP-986 : changes to get timestamp of latest booking or amendment 
-- =========================================================== 
-- Modified By : Jay Shah 
-- Modified Date : 13/04/2020 
-- Description : SMAREP-1039 Additional ticket status 
-- ===========================================================
-- Modified By : Jay Shah 
-- Modified Date : 1/05/2020 
-- Description : Added originalJourneyType 
-- ===========================================================
-- Modified By  :  Urvashi Parmar 
-- Modified Date  :  01/04/2020   
-- Description  :  SMAREP-1091 : View Ticket - Ticket History : Modify View Ticket Endpoint in TDAMS 
-- =========================================================== 
-- Modified By  :  Kajal Patel 
-- Modified Date  :  14/05/2020   
-- Description  :  SMAREP-1173 : Updating this procedure to get details for specific saleID 
-- =========================================================== 
-- Modified By  :  Deepa Augustine
-- Modified Date:  22/05/2020   
-- Description  :  SMAREP-1208 : Renaming the Status 'RESERVED' text to 'BOOKED' text
-- =========================================================== 
-- Modified By  :  Deepa Augustine
-- Modified Date:  30/06/2020   
-- Description  :  SMAREP-1276 Added Refunded in the status comparision to include refunded and expired tickets 
-- =========================================================== 
-- Modified By  :  Urvashi Parmar
-- Modified Date:  18/08/2020   
-- Description  :  SMAREP-1424 : added changes to add new sales record into @tempbaskets table for resIssued ticket.
-- =========================================================== 
-- Modified By  :  Kajal Patel
-- Modified Date:  09/09/2020   
-- Description  :  SMAREP-1610 : Status displayed wrong when ticket amended through NXagents
-- =========================================================== 
-- Modified By  :  Urvashi Parmar
-- Modified Date:  11/12/2020   
-- Description  :  SMAREP-2047 : fixed issue of transaction date of expired ticket
-- =========================================================== 
-- Modified By  :  Bhavesh Kashikar
-- Modified Date:  22/02/2021
-- Description  :  SMAREP-1708 : Since Re-Issue status will be handled in ticket note, so removed Re-Issued status from here.
-- =========================================================== 
-- Modified By  :  Rahul Chauhan
-- Modified Date:  10/05/2021
-- Description  :  SMAREP-2425 : View Coach Card - Change in Stored Procedure for View Coach Card - Added consumer details to be displayed like holdername and -- holder email address
-- =========================================================== 
-- Modified By  :  Kajal Patel 
-- Modified Date:  13/05/2021
-- Description  :  SMAREP-2640 : Updated calculation of inbound and outbound journey fare for OD validation transaction.
-- =========================================================== 
-- Modified By  :  Maunish Soni
-- Modified Date:  22/07/2021
-- Description  :  SMAREP-2863 : Updated reference of getting agent name of sales from config table of Titan to tb_agent of ams db
-- =========================================================== 
-- Modified By  :  Rahul Chauhan
-- Modified Date:  28/07/2021
-- Description  :  SMAREP-2785 (Mercury-India Release) : Updated Lead Consumer table to get country code
-- =========================================================== 
-- Author		:  Maunish Soni
-- Modified date:  13-Oct-2021
-- Description	:  SMAREP-3097 : Adyen Payment Gateway : Refunds : DB Change to reflect AC_04 of SMAREP-2940 & AC_06 of SMAREP-2942
-- ============================================================================================

ALTER PROCEDURE [dbo].[cp_Get_Full_Ticket_Retail]  
(
	@ticket_serial VARCHAR(15), 
	@PNR           VARCHAR(100) = NULL, 
	@selected_sale_id       INT = NULL 
) 
AS 
  BEGIN 
      --set NOCOUNT ON 
      DECLARE @ticket_id INT 
      DECLARE @item_serial_id INT 
      DECLARE @timestamp DATETIME 

      SELECT TOP 1 @ticket_id = T.[ticket_id] 
      FROM   [dbo].[tbl_tickets] T 
      WHERE  ticket_serial = @ticket_serial 

      -- Get All Basket IDs 
      DECLARE @baskets TABLE 
        ( 
           basketorder   INT IDENTITY(1, 1), 
		   saleid        INT, 
           sale_date     DATETIME, 
           agent_user_id INT, 
           status        VARCHAR(25), 
           user_id       CHAR(8), 
           user_name     VARCHAR(50), 
           agent_id      INT, 
           agent_name    VARCHAR(50),
		   category      VARCHAR(10) --SMAREP-1424 - UP
        ) 

      INSERT INTO @baskets 
      SELECT DISTINCT b.sale_id, 
                      B.sale_date, 
                      B.agent_user_id, 
                      '', 
                      AU.user_id, 
                      AU.NAME, 
                      A.agent_id, 
                      (SELECT name 
                       FROM   [UKPTSQL03].[ams].[dbo].[tb_agent]
                       WHERE  agent_id COLLATE database_default = A.agent_code) 
					   ,''
      FROM   [dbo].[tbl_item_serial_link] AS ISL 
             INNER JOIN dbo.[tbl_sales_items] AS BI 
                     ON BI.item_serial_id = ISL.item_serial_id 
                        AND ISL.[ticket_id] = @ticket_id 
INNER JOIN dbo.tbl_sales AS B 
                     ON B.sale_id = BI.sale_id 
 INNER JOIN tbl_agent_users AU 
                     ON AU.agent_user_id = B.agent_user_id 
             INNER JOIN tbl_agents A 
                     ON A.agent_id = AU.agent_id 
		Where B.sale_id <= Isnull(@selected_sale_id,B.sale_id)
      ORDER  BY B.sale_id 

      -- Fix for SMAREP-1610
      UPDATE b 
      SET    status = 
             --select 
             CASE 
               WHEN BS.TransType = '' THEN 'REFUNDED' 
               WHEN BS.TransType = 'J' THEN 'PENDING REFUND' 
               WHEN BS.TransType = 'H' THEN 'PENDING PAYMENT REVERSAL'
			   WHEN BS.TransType = 'I' THEN 'PAYMENT REVERSED'
               WHEN BS.TransType = 'C' THEN 'CANCELLED' 
               WHEN BS.TransType IN ( 'A', 'D', 'E', 'F', 'O' ) THEN 'AMENDED' 
			   ELSE 'BOOKED' 
             END 
      FROM  @Baskets B 
			INNER JOIN tbl_basket_summary BS
					ON BS.Sale_ID = B.saleid

      DECLARE @LastActiveSaleID INT 

      SELECT TOP 1 @LastActiveSaleID = saleid 
      FROM   @Baskets 
      WHERE  status NOT IN ( 'CANCELLED', 'REFUNDED' ) 
      ORDER  BY saleid DESC 
	  
	  --select @LastActiveSaleID 
      DECLARE @SaleID INT 
      DECLARE @FirstSaleID INT 
      DECLARE @DateOfTransaction DATETIME 

	IF  Isnull(@selected_sale_id,0) <> 0
	BEGIN	
		IF (SELECT 	status from @Baskets WHERE saleid = @selected_sale_id  ) NOT IN ('CANCELLED', 'REFUNDED' )
		BEGIN 
			SET @LastActiveSaleID = @selected_sale_id
		END
		SELECT TOP 1 @SaleID = saleid, 
                   @DateOfTransaction = sale_date 
        FROM   @baskets 
		WHERE saleid = @selected_sale_id
	END
	ELSE
	BEGIN
		SELECT TOP 1 @SaleID = saleid, 
                   @DateOfTransaction = sale_date 
        FROM   @baskets 
        ORDER  BY saleid DESC
	END
	  
      DECLARE @PartialCancellationStatus INT 

      SET @PartialCancellationStatus=0 

      SELECT @PartialCancellationStatus = SIT.transaction_type_id 
      FROM   tbl_sales_item_transactions sit 
             INNER JOIN tbl_sales_items SI 
     ON SI.sales_item_id = SIT.sales_item_id 
             INNER JOIN tbl_transaction_types TT 
                     ON TT.transaction_type_id = SIT.transaction_type_id 
             INNER JOIN @Baskets B 
                     ON B.saleid = SI.sale_id 
      WHERE  SI.sale_id = @SaleID 
             AND SIT.transaction_type_id IN ( 12, 13 ) 

      SELECT @FirstSaleID = Min(saleid) 
      FROM   @baskets 

      SELECT @item_serial_id = SI.item_serial_id 
      FROM   tbl_sales_items SI 
      WHERE  SI.sale_id = @FirstSaleID 
             AND SI.product_id = 1 

      DECLARE @BasketFares TABLE 
        ( 
           sale_id          INT, 
           fare_type        CHAR(3) NULL, 
           farevalue        MONEY NULL, 
           fare_description CHAR(50) NULL 
        ) 

      INSERT @BasketFares 
      SELECT B.saleid, 
             Isnull(SJL.fare_type, ''), 
             Isnull(SI.item_single_value, 0), 
             Isnull(st_tick_desc, '') 
      FROM   @baskets B 
             LEFT JOIN tbl_sales_items SI 
                    ON B.saleid = SI.sale_id 
                       AND SI.product_id = 1 
             LEFT JOIN tbl_smartjourneylegs SJL 
                    ON SI.sales_item_id = SJL.sales_item_id 
                       AND SJL.leg_number = 0 
             LEFT JOIN [UKPTSQL05].netplans.dbo.tb_tick_typ 
                    ON st_tick_cd COLLATE database_default = SJL.fare_type 

      ---- Get FareType 
      DECLARE @FareType VARCHAR(3) 
      DECLARE @FareDescription CHAR(50) 

      SELECT @FareType = fare_type, 
             @FareDescription = fare_description 
  FROM   @BasketFares BF 
      WHERE  BF.sale_id = @FirstSaleID 

      --select @FareDescription = st_tick_desc from  
      --[netplans].[dbo].tb_tick_typ where st_tick_cd=@FareType 
      DECLARE @FirstTravelSalesItemID INT 

      SELECT @FirstTravelSalesItemID = sales_item_id 
      FROM   tbl_sales_items 
      WHERE  sale_id = @FirstSaleID 
             AND product_id = 1 

      DECLARE @ThirdPartyReference VARCHAR(100) 

      SELECT @ThirdPartyReference = [third_party_reference] 
      FROM   [dbo].[tbl_third_party_reference] 
      WHERE  [sales_item_id] = @FirstTravelSalesItemID 

      --------------  SMAREP-735 change 
      --DECLARE @PNR VARCHAR(100) 
      --SELECT @PNR = PNR 
      --FROM [PartnersDB].[dbo].[PartnerCampaignBookingsAdditionalDetails]  
      --WHERE PartnerCampaignBookingID IN ( 
      --    SELECT ID 
      --    FROM [PartnersDB].[dbo].[PartnerCampaignBookings] 
      --    WHERE TicketNumber = @ticket_serial 
      --      AND SaleID = @SaleID 
      --    ) 
      DECLARE @JourneyType VARCHAR(35) 

      SELECT @JourneyType = [ticket_journey_type_description] 
      FROM   tbl_journey_summary AS JS 
             INNER JOIN [tbl_ticket_journey_types] TJT 
                     ON JS.tickettype = TJT.ticket_journey_type_code 
      WHERE 
        -- BC edit 
        JS.sale_id = @SaleID 

      DECLARE @OriginalJourneyType VARCHAR(35) 

	  IF EXISTS (SELECT  JS.tickettype FROM tbl_journey_summary AS JS JOIN tbl_Basket_Summary BS ON JS.Sale_ID = BS.Sale_ID AND JS.TicketType = 'V'             
      WHERE  BS.TicketNo = @ticket_serial)
	  BEGIN
			SELECT @OriginalJourneyType = [ticket_journey_type_description] FROM [tbl_ticket_journey_types] WHERE ticket_journey_type_code = 'V'
	  END
	  ELSE
	  BEGIN
		  SELECT @OriginalJourneyType = [ticket_journey_type_description] 
		  FROM   tbl_journey_summary AS JS 
				 INNER JOIN [tbl_ticket_journey_types] TJT 
						 ON JS.tickettype = TJT.ticket_journey_type_code 
		  WHERE  -- BC edit 
			JS.sale_id = @FirstSaleID 
	  END



      DECLARE @BasketItems TABLE 
        ( 
           basketitemid      INT NOT NULL, 
           basketid          INT NOT NULL, 
           [description]     VARCHAR(35), 
           sku               CHAR(7), 
           product_id        INT, 
           item_single_value MONEY, 
           item_quantity     INT, 
           item_serial_id    INT, 
           sale_item_type_id INT, 
           product_type      VARCHAR(35), 
           product_category  VARCHAR(35), 
           product_family    VARCHAR(35) 
        ) 

      -- Get Latest Instance of Travel Product 
      --INSERT INTO @BasketItems 
      --SELECT [sales_item_id] 
      --  ,Sale_Id 
      --  ,Product_Description 
      --  ,Smart_Product_Type_Code + Smart_Product_Code 
      --  ,BI.Product_id 
      --  ,BI.item_single_value 
      --  ,BI.item_quantity 
      --  ,BI.item_serial_id 
      --  ,BI.sale_item_type_id 
      --  ,[type_description] 
      --  ,product_category_description 
      --  ,family_name 
      --FROM [dbo].[tbl_Sales_Items] AS BI 
      --INNER JOIN dbo.tbl_Products P ON BI.Product_id = P.Product_id 
      --  AND BI.Sale_id = @SaleID 
      --  AND BI.product_id = 1 
      --JOIN [dbo].[tbl_Product_Types] PT ON p.product_type_id = pt.product_type_id 
      --join [dbo].[tbl_Product_Category] PC ON p.product_category_id = pc.product_category_id 
      --join [dbo].[tbl_Product_family] PF ON p.product_family_id = PF.product_family_id 
      -- Get  
      -- Insert basket Items to temp table 
      INSERT INTO @BasketItems 
      SELECT [sales_item_id], 
             BI.sale_id, 
      product_description, 
             smart_product_type_code 
             + smart_product_code, 
             BI.product_id, 
             BI.item_single_value, 
             BI.item_quantity, 
             BI.item_serial_id, 
             BI.sale_item_type_id, 
             [type_description], 
             product_category_description, 
             family_name 
      FROM   [dbo].[tbl_sales_items] AS BI 
             JOIN @Baskets B 
               ON BI.sale_id = B.saleid 
      --AND bi.product_id <> 1 
             JOIN dbo.tbl_products P 
               ON BI.product_id = P.product_id 
             JOIN [dbo].[tbl_product_types] PT 
               ON p.product_type_id = pt.product_type_id 
             JOIN [dbo].[tbl_product_category] PC 
               ON p.product_category_id = pc.product_category_id 
             JOIN [dbo].[tbl_product_family] PF 
               ON p.product_family_id = PF.product_family_id 

      --SELECT TOP 1 
      --si2.sales_item_id, si2.date_created 
      --FROM  
      --[dbo].[tbl_Item_Serial_link] isl WITH (nolock) 
      --INNER JOIN [dbo].[tbl_Sales_Items] si2 WITH (nolock) 
      --ON isl.[item_serial_id] = si2.[item_serial_id] 
      --AND si2.[sale_item_type_id] IN (1,2)   
      --AND EXISTS (SELECT 0 FROM [tbl_SmartJourneyLegs] sjl2 WHERE sjl2.[sales_item_id] = si2.[sales_item_id]) 
      --ORDER BY si2.[date_created] DESC 
      DECLARE @Legs TABLE 
        ( 
           departuretime    DATETIME, 
           arrivaltime      DATETIME, 
           flightstart      DATETIME, 
           legnumber        SMALLINT, 
           legdirection     CHAR(1), 
           fromlocationcode CHAR(5), 
           fromstop         CHAR(1), 
           tolocationcode   CHAR(5), 
           tostop           CHAR(1), 
           brand            CHAR(2), 
           servicenumber    CHAR(3), 
           flightdirection  CHAR(1), 
           flightcode       CHAR(2), 
           checkintime      DATETIME, 
           bookingreference CHAR(4), 
           datecreated      DATETIME 
        ) 

      INSERT INTO @Legs 
      SELECT Dateadd(minute, departure_time % 60, ( Dateadd(hour, departure_time 
                                                                  / 
                                                                  60, 
                    Dateadd(s, departure_date, '01-Jan-1970 00:00:00' 
                    )) ))                               AS Departure_Time, 
             Dateadd(minute, arrival_time % 60, ( Dateadd(hour, arrival_time / 
                                                                60, 
             Dateadd(s, arrival_date, '01-Jan-1970 00:00:00' 
                                                  )) )) AS Arrival_Time, 
             --dateadd(d,(displacement_days * -1),(dateadd(s,departure_date,'01-Jan-1970 00:00:00'))) + (substring(flight_start_time,1,2) + ':' + substring(flight_start_time,3,2)) as Flight_Start,
             Dateadd(d, ( displacement_days * -1 ), ( 
             Dateadd(s, departure_date, '01-Jan-1970 00:00:00') )) + ( 
             Substring('0000' + flight_start_time, Len('0000' + 
             flight_start_time) 
             - 3 
             , 2) 
               + ':' 
               + Substring('0000' + flight_start_time, Len('0000' + 
             flight_start_time) 
             - 1, 2 
             ) )                                        AS Flight_Start, 
             leg_number, 
  leg_direction, 
             from_location_code, 
             from_stop, 
             to_location_code, 
             to_stop, 
             company_brand_code                         AS Brand, 
             service                                    AS Service_Number, 
             direction                AS Flight_Direction, 
             flight_code, 
             Dateadd(minute, check_in_time % 60, ( Dateadd(hour, check_in_time / 
                                                   60, 
             Dateadd(s, departure_date, '01-Jan-1970 00:00:00' 
             )) ))                                      AS Check_In_Time, 
             booking_reference, 
             SJL.date_created                           AS Date_Created 
      FROM   @BasketItems AS BI 
             INNER JOIN dbo.tbl_smartjourneylegs AS SJL 
                     ON SJL.sales_item_id = BI.basketitemid 
      WHERE  basketid = @LastActiveSaleID 

      DECLARE @Status VARCHAR(25) 

      SELECT @Status = status 
		FROM   @Baskets 
      WHERE  saleid = @SaleID 

      PRINT @Status 
	 IF  Isnull(@selected_sale_id,0) = 0
		BEGIN	

	
      IF( @Status IN ( 'BOOKED', 'AMENDED', 'REFUNDED' ) ) -- By DA:(SMAREP-1276 :Added Refunded Status)
        SELECT TOP 1 @Status = CASE 
                                 WHEN @JourneyType NOT IN ( 'Open return booked' 
                                                          ) 
                                      AND arrivaltime < Getdate() THEN 'EXPIRED' 
                                 WHEN @JourneyType IN ( 'Open return booked' ) 
                                      AND Datediff(day, arrivaltime, Getdate()) 
                                          >= 
                                          90 
                                                                          THEN 
                                 'EXPIRED' 
                                 ELSE @Status 
                               END 
        FROM   @Legs 
        ORDER  BY legnumber DESC 

      PRINT @Status 

	
      --SMAREP-1039 
      SELECT @Status = CASE 
                         WHEN @Status = 'EXPIRED' THEN 
                           CASE 
                             WHEN EXISTS(SELECT 1 
                                         FROM   @baskets 
                                         WHERE  status = 'REFUNDED') THEN 
                             'EXPIRED & REFUNDED' 
                             ELSE 'EXPIRED' 
                           END 
                         WHEN EXISTS(SELECT 1 
                                     FROM   @baskets 
                                     WHERE  status = 'CANCELLED') 
                              AND EXISTS(SELECT 1 
                                         FROM   @baskets 
                                         WHERE  status = 'REFUNDED') THEN 
                         'CANCELLED & REFUNDED' 
                         ELSE @Status 
                       END 

	END
      PRINT @Status 

      --SMAREP-986 - get latest transaction datetime  
      SELECT TOP 1 @timestamp = SI.date_created 
      FROM   @baskets B 
             INNER JOIN tbl_sales_items SI WITH(nolock) 
                     ON B.saleid = SI.sale_id 
                        AND SI.sale_item_type_id IN ( 1, 2 ) 
             INNER JOIN [tbl_smartjourneylegs] sjl 
                     ON sjl.[sales_item_id] = SI.[sales_item_id] 
      ORDER  BY SI.[date_created] DESC 

      -- (table 0) ticket header information 
      SELECT @SaleID                          AS saleId, 
             T.[ticket_id]                    AS ticketId, 
             [ticket_serial]                  AS ticketSerial, 
             @FareType                        AS fareType, 
             @FareDescription                 AS fareDescription, 
             Isnull(@JourneyType, '')         AS journeyType, 
             Isnull(@OriginalJourneyType, '') AS originalJourneyType, 
             @DateOfTransaction               AS dateOfTransaction, 
             Isnull(@PNR, '')                 AS pnr, 
             @Status                          AS ticketStatus, 
             @timestamp                       AS timestamp 
      FROM   [dbo].[tbl_tickets] AS T 
             INNER JOIN tbl_basket_summary B 
                     ON B.ticketno = ticket_serial 
                        AND B.sale_id = @SaleID 
      WHERE  T.[ticket_id] = @ticket_id 

     DECLARE @tempBaskets TABLE            --SMAREP-1424 - UP
        ( 
           basketorder INT IDENTITY(1, 1), 
           saleid        INT, 
           sale_date     DATETIME, 
           agent_user_id INT, 
           status        VARCHAR(25), 
           user_id       CHAR(8), 
           user_name     VARCHAR(50), 
           agent_id      INT, 
           agent_name    VARCHAR(50) ,
		   category      VARCHAR(10) 
        )

		--SMAREP-1424 - UP
		Insert INTO @tempBaskets SELECT saleid,sale_date,agent_user_id,
		status,user_id,user_name,agent_id, agent_name,category from @baskets

	    --SMAREP-1424 - UP
		--INSERT INTO @tempBaskets 
		--SELECT B.saleid,IT.date_created, B.agent_user_id,B.status,B.user_id,B.user_name, B.agent_id,B.agent_name,'REISSUED' FROM tbl_Sales_Item_Transactions IT JOIN tbl_Sales_Items SI on SI.sales_item_id = IT.sales_item_id
		-- JOIN @baskets B on SI.sale_id = B. saleid where B.status in ('BOOKED','AMENDED') and IT.transaction_type_id=8 and SI.product_id=1
		-- and sales_item_transaction_id <> (SELECT min(sales_item_transaction_id) FROM tbl_Sales_Item_Transactions where sales_item_id=It.sales_item_id and transaction_type_id=8)
		

      -- add new transaction history in basked if latest journey is expired 
      IF( @Status = 'EXPIRED' ) 
        BEGIN 
		     Declare @expiredTicketTrandactionDate DATETIME                    -- SMAREP-2047
		     SELECT TOP 1 @expiredTicketTrandactionDate = CASE 
                                 WHEN @JourneyType IN ( 'Open return booked') 
                                 THEN  DATEADD(day, 90, arrivaltime)                                 
                                 ELSE arrivaltime 
                               END 
			FROM   @Legs 
			ORDER  BY legnumber DESC 

            INSERT INTO @tempBaskets     --SMAREP-1424 - UP  -useed new @tempBaskets instead of @baskets
            SELECT TOP 1 saleid, 
                         @expiredTicketTrandactionDate, 
                         agent_user_id, 
                         'EXPIRED', 
                         user_id, 
                         user_name, 
					     agent_id, 
                         agent_name,
						 '' 
            FROM   @baskets 
            ORDER  BY 1 DESC 
        END
	
      -- (table 1) Select Latest basket 
      SELECT B.[saleid]         AS [saleId], 
             B.sale_date                   AS saleDate, 
             B.agent_user_id                         AS agentUserId, 
             B.user_id                               AS userId, 
             au.[name], 
             B.agent_id                              AS agentId, 
             B.agent_name                            AS agentName, 
             ag.agent_code                           AS agentCode, 
             CASE ag.agent_code 
               WHEN 'NXHQ' THEN 'Website' 
               WHEN 'D085' THEN 'Contact Centre' 
               ELSE 'Other Channel' 
             END                                     AS salesChannel, 
             B.basketorder 
             -- Ranbir. Added for ATB project - tbl_Group is added to include a new 'Travel-Shop' group which will be used to determine when to display Credit Card Transaction data. 
             , 
             (SELECT group_name 
              FROM   tbl_groups g 
                     INNER JOIN tbl_agent_groups h 
                             ON h.group_id = g.group_id 
              WHERE  h.agent_id = ag.agent_id 
                     AND group_name = 'Travel-Shop') AS agentGroup, 
             b.status
			 ,Case b.category                             -- SMAREP-1424 - UP
				When '' Then b.status
				Else b.category
			 End as category
      FROM   @tempBaskets AS B 
             JOIN dbo.tbl_agent_users AU 
               ON b.agent_user_id = au.agent_user_id 
             JOIN dbo.tbl_agents Ag 
               ON AU.agent_id = Ag.agent_id ORDER BY B.sale_date

      -- (table 2) basket items 
      SELECT BI.basketitemid                   AS salesItemId, 
             bi.product_id                     AS productId, 
             sale_item_type_id                 AS saleItemTypeId, 
             item_single_value                 AS itemSingleValue, 
item_quantity                     AS quantity, 
             B.sale_date                       AS saleDate, 
             from_date   AS fromDate, 
             to_date                           AS toDate, 
             BI.basketid                       AS saleId, 
             Isnull(ps.product_serial, 'None') AS serial, 
             BI.sku, 
             B.basketorder, 
             BI.product_type                   AS productType, 
             BI.[description]                  productDescription, 
             product_category                  productCategory, 
             product_family                    productFamily,
			 CS.forename					   AS firstNameOfHolder,
			 CS.surname                        AS lastNameOfHolder,
			 EA.email_address                  AS holderEmail			 
      FROM   @BasketItems AS BI 
             JOIN @baskets B 
				ON BI.basketid = B.saleid 
             JOIN tbl_item_serial_link ISL 
				ON BI.item_serial_id = ISL.item_serial_id 
             LEFT JOIN tbl_product_serials PS 
				ON ISL.product_serial_id = PS.product_serial_id 
             LEFT OUTER JOIN dbo.tbl_sale_item_validity AS F 
				ON BI.basketitemid = F.sale_item_id
			 LEFT JOIN dbo.tbl_item_consumer IC 
				ON IC.sale_item_id = BI.basketitemid AND IC.consumer_id NOT IN ( 0, 1, 2, 3, 4, 5, 5445592, 5445601, 5445609 ) 
			 LEFT JOIN dbo.tbl_Consumers CS
			    ON CS.consumer_id = IC.consumer_id
			 LEFT JOIN dbo.tbl_Email_Addresses EA
			    ON EA.consumer_id = IC.consumer_id
      --where B.SaleID=@SaleID 
      ORDER  BY salesitemid 

      -- (table 3) legs 
      SELECT * 
      FROM   @Legs 

      DECLARE @LeadConsumer TABLE 
        ( 
           consumerid            INT, 
           firstname             VARCHAR(40), 
           lastname              VARCHAR(40), 
           consumerroleid        INT, 
           consumertypeid        INT, 
           titleid               INT, 
           title                 VARCHAR(10), 
           email                 VARCHAR(128), 
           marketingconsent      BIT, 
           phone                 VARCHAR(15),
		   countryCode			 VARCHAR(5),                           -- Rahul C. SMAREP-2785
           phonemarketingconsent BIT 
        ) 
      DECLARE @Consm_id INT ---------  Change by Urvashi Trivedi  
      SELECT @Consm_id = consumer_id 
      FROM   tbl_payments 
      WHERE  sale_id = @saleId 

      INSERT INTO @LeadConsumer 
                  (consumerid, 
                   firstname, 
                   lastname, 
                   titleid, 
                   title, 
                   consumerroleid, 
                   consumertypeid) 
 -- Lead Pax 
      SELECT C.consumer_id ConsumerID, 
             forename      FirstName, 
             surname       LastName, 
             C.title_id    TitleID, 
             title, 
             Isnull(consumer_role_id, 6), 
             consumer_type_id 
      FROM   tbl_consumers C 
             INNER JOIN tbl_item_consumer IC 
                     ON C.consumer_id = IC.consumer_id 
             INNER JOIN tbl_sales_items SI 
                     ON SI.sales_item_id = sale_item_id 
             LEFT JOIN tbl_titles T 
                    ON T.title_id = C.title_id 
      WHERE  SI.sale_id = @FirstSaleId 
             AND C.consumer_id NOT IN ( 0, 1, 2, 3, 
                                        4, 5, 5445592, 5445601, 5445609 ) 
      UNION 
      -- For Paying 
      SELECT C.consumer_id ConsumerID, 
             forename      FirstName, 
             surname       LastName, 
             C.title_id    TitleID, 
             title, 
             Isnull(consumer_role_id, 7), 
             C.consumer_type_id 
      FROM   tbl_consumers C 
             --  INNER JOIN tbl_Payments P ON P.consumer_id = C.consumer_id  
             LEFT JOIN tbl_titles T 
                    ON T.title_id = C.title_id 
      WHERE  C.sale_id = @saleId 
              OR ( C.sale_id IS NULL 
                   AND ----P.Sale_id = @saleId 
                   C.consumer_id = @Consm_id ) 
                 AND C.consumer_id NOT IN ( 0, 1, 2, 3, 
                                            4, 5, 5445592, 5445601, 5445609 ) 

      DECLARE @records INT 

      IF EXISTS (SELECT 1 
                 FROM   dbo.tbl_ticket_distribution TD 
                 WHERE  TD.sale_id = @SaleID 
                        AND TD.distribution_type_id = 1) 
        BEGIN 
            -- add deliver to consumer 
            PRINT 'A' 

            INSERT INTO @LeadConsumer 
            (consumerid, 
                         firstname, 
                         lastname, 
                         titleid, 
                         title, 
                         consumerroleid) 
            SELECT C.consumer_id ConsumerID, 
                   forename      FirstName, 
                   surname       LastName, 
                   C.title_id    TitleID, 
                   title, 
                   8 
            FROM   tbl_consumers C 
                   LEFT JOIN tbl_titles T 
                          ON T.title_id = C.title_id 
            WHERE  C.sale_id = @saleId 
                   AND C.consumer_role_id = 8 

            SET @records = @@rowcount 

            -- check if records inserted 
            IF @records = 0 
              BEGIN 
                  PRINT 'B' 

                  INSERT INTO @LeadConsumer 
                              (consumerid, 
                               firstname, 
                               lastname, 
                               titleid, 
                               title, 
                               consumerroleid) 
                  SELECT C.consumer_id ConsumerID, 
                         forename      FirstName, 
                         surname       LastName, 
                         C.title_id    TitleID, 
                         title, 
                         8 
                  FROM   dbo.tbl_consumers C 
                         JOIN dbo.tbl_item_consumer IC 
                           ON C.consumer_id = IC.consumer_id 
                              AND C.consumer_id NOT IN ( 0, 1, 2, 3, 
                                                         4, 5, 5445592, 5445601, 
                                                         5445609 
                                                       ) 
                         JOIN dbo.tbl_sales_items SI 
                           ON SI.sales_item_id = IC.sale_item_id 
                              AND SI.product_id = 1 
  AND SI.sale_id = @saleid 
                 LEFT JOIN tbl_titles T 
                                ON T.title_id = C.title_id 
          END 
        END 

      -- (table 4)Pax Count 
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
      WHERE  SI.sale_id = @FirstSaleId 
             AND SI.product_id = 1 
      GROUP  BY passenger_type_code, 
                consumer_type 

      -- email address 
      UPDATE c 
      SET email = email_address, 
             marketingconsent = marketing_consent 
      FROM   @LeadConsumer AS C 
             INNER JOIN dbo.tbl_email_addresses AS E 
                     ON C.consumerid = E.consumer_id 
      WHERE  E.consumer_id NOT IN ( 0, 1, 2, 3, 
                                    4, 5, 5445592, 5445601, 5445609 ) 

      --  Phone contacts 
      UPDATE c 
      SET    phone = number,
			 countryCode = country_code, 
             phonemarketingconsent = marketing_consent 
      FROM   @LeadConsumer AS C 
             INNER JOIN dbo.tbl_phone_contacts AS PC 
                     ON C.consumerid = PC.consumer_id
			 LEFT JOIN dbo.tbl_Phone_Contacts_Country_Code PCC                   -- code SMAREP-2785: To take country code
					 ON PCC.phone_contacts_id = PC.phone_contacts_id
      WHERE  PC.consumer_id NOT IN ( 0, 1, 2, 3, 
                                     4, 5, 5445592, 5445601, 5445609 ) 

     
	 -- (table 5)Lead Pax 
      SELECT C.*, 
             L.NAME AS consumerRole 
      FROM   @LeadConsumer C 
             LEFT JOIN dbo.tbl_list L 
              ON C.consumerroleid = L.list_id 
                       AND listgroup_id = 3 

      --WHERE ConsumerRoleID = 6 
	  
	  
      -- (table 6) payments 
      SELECT distinct payment_id            AS paymentId, 
             P.payment_type_id     AS paymentTypeId, 
             consumer_id           AS consumerId, 
             P.card_details_id     AS cardDetailsId, 
             card_number           AS cardNumber, 
             authorisation_code    AS authorisationCode, 
             merchant_id           AS merchantId, 
             till_id               AS tillId, 
             nmp_id                AS nmpId, 
             currency_id           AS currencyId, 
             payment_value         AS paymentValue, 
             P.date_created        AS dateCreated, 
             P.sale_id             AS saleId, 
             P.sale_item_id        AS saleItemId, 
             foreign_payment_value AS foreignPaymentValue, 
             --B.basketorder         AS basketOrder, 
             [payment_type]        AS paymentType, 
             pp.NAME               AS 'paymentGateway' 
      FROM   dbo.tbl_payments AS P 
             JOIN @baskets B 
               ON P.sale_id = B.saleid 
                  AND payment_id <> 0 
             JOIN [dbo].[tbl_payment_types] PT 
               ON p.payment_type_id = pt.[payment_type_id] 
             LEFT JOIN [NXLookup].[dbo].[tbl_payment_providers] PP 
                    ON PP.id = P.payment_provider_id 
             LEFT JOIN dbo.tbl_card_details AS CD 
                    ON CD.card_details_id = P.card_details_id 
      --  WHERE sale_id = @saleID 
      ORDER  BY p.sale_id 

      -- (table 10) credit cards 
      --        SELECT 
      --                  P.card_details_id, 
      --                  CD.card_type_id, 
      --                  card_number, 
      --                  card_start_date, 
      --                  card_end_date, 
      --                  card_holder, 
      --                  CD.entry_mode_id, 
      --           customer_status, 
      --                  issue_number, 
      --     P.date_created, 
      --                 third_party_authorisation, 
      --          B.BasketOrder, 
      --          isnull([last_four_digits_of_card_number],'') [lastFourDigits], 
      --          PPT.unique_transaction_reference, -- Ranbir 09/08/17. Added for ATB project. Stores TID for SMART TS Chip and Pin transactions 
      --          EM.entry_mode, -- Ranbir 09/08/17. Added for ATB project - Gives mode of card payment e.g Chip and Pin  
      --          CT.card_description, -- Ranbir 09/08/17. Added for ATB project - Name of Credit Card.  
      --          P.merchant_id, -- Ranbir 09/08/17. Added for ATB project - First 2 chars need to be ** out. Revist this 21/06/2017.
      --          P.authorisation_code, -- Ranbir 09/08/17. Added for ATB project - Authorisation_code. 
      --          PPT.transaction_id -- Ranbir 09/08/17. NEW field Added for ATB project. Affect Replication  
  --      FROM 
      --                   dbo.tbl_Payments AS P  
      --                       left JOIN dbo.tbl_Card_Details     AS CD  
      --            ON CD.card_details_id = P.card_details_id 
      --           join @Baskets B 
      --            on  P.sale_id = B.SaleID 
      --              and P.card_details_id <> 0   
      --          left join [dbo].[tbl_Payment_Provider_Transactions]  PPT 
      --            on P.[payment_provider_transaction_id] = PPT.[id] 
      --          left join [dbo].[tbl_entry_modes]  AS EM -- Ranbir 
      --            on CD.[entry_mode_id] = EM.[entry_mode_id] 
      --          left join [dbo].[tbl_card_types]  AS CT -- Ranbir 
      --            on CD.[card_type_id] = CT.[card_type_id] 
    ----          end 
      ---- Amazon/Paypal Account 
      --SELECT  [Payment_Account],  sale_id 
      --  FROM [Titan].[dbo].[tbl_Payment_Account] ta 
      --    inner join tbl_payments P ON P.payment_id = ta.payment_id 
      --  where P.sale_id=@saleID 
      --  order by  1 desc 
	  
      -- (table 7) Addresses 
      SELECT DISTINCT Isnull(L.NAME, '') AS addressType, 
                      addresstypeid, 
                      marketingconsent, 
                      billing_address    billingAddress, 
                      CA.active, 
                      address1, 
                      address2, 
                      address3, 
                      town, 
                      postcode, 
                      CASE a.country_id 
                        WHEN 0 THEN '' 
                        ELSE country 
                      END                AS country, 
                      CASE a.county_id 
                        WHEN 0 THEN '' 
                        ELSE county 
                      END                AS county 
      FROM   @LeadConsumer AS C 
             INNER JOIN dbo.tbl_consumers_addresses AS CA 
                     ON CA.consumer_id = C.consumerid 
                        AND C.consumerid NOT IN ( 0, 1, 2, 3, 
                                                  4, 5, 5445592, 5445601, 
                                                  5445609 
                                                ) 
             INNER JOIN dbo.tbl_addresses AS A 
                     ON CA.address_id = A.address_id 
             LEFT JOIN dbo.tbl_list L 
                    ON A.addresstypeid = L.list_id 
                       AND L.listgroup_id = 1 
             INNER JOIN dbo.tbl_countries AS Co 
                     ON A.country_id = Co.country_id 
             INNER JOIN dbo.tbl_counties Cou 
                     ON A.county_id = Cou.county_id 

      DECLARE @TicketDistributions TABLE 
        ( 
           ticket_distribution_id INT NOT NULL, 
           ticket_id          INT NOT NULL, 
           ticket_type_id         INT NOT NULL, 
           distribution_type_id   INT NOT NULL, 
collectingagentcode  CHAR(5) NULL, 
sale_id                INT NOT NULL, 
           date_generated         DATETIME NOT NULL 
        ) 
      DECLARE @RemoteTicketCollected BIT 
      DECLARE @CollectingAgentCode CHAR(5) 

      -- insert into temp table 
      INSERT INTO @TicketDistributions 
                  (ticket_distribution_id, 
                   ticket_id, 
                   ticket_type_id, 
                   distribution_type_id, 
                   collectingagentcode, 
                   sale_id, 
                   date_generated) 
      SELECT ticket_distribution_id, 
             ticket_id, 
             ticket_type_id, 
             distribution_type_id, 
             (SELECT collection_agent 
              FROM   dbo.smartcollectionlocationsimport 
              WHERE  collection_location_id = collection_id) AS 
             CollectingAgentCode, 
             sale_id, 
             date_generated 
      FROM   dbo.tbl_ticket_distribution AS TD 
             INNER JOIN @baskets b 
               ON b.saleid = sale_id 
      ORDER  BY sale_id 

      --WHERE TD.sale_id = @SaleID 
      --  TicketDistributions 
      SELECT @CollectingAgentCode = collectingagentcode 
      FROM   @TicketDistributions 

      --Printing status 
      DECLARE @PrintStatus VARCHAR(35) 
      DECLARE @PrintDate DATETIME 

      SELECT @PrintStatus = transaction_type, 
             @PrintDate = SIT.date_created 
      FROM   tbl_sales_item_transactions sit 
             INNER JOIN tbl_sales_items SI 
                     ON SI.sales_item_id = SIT.sales_item_id 
             INNER JOIN tbl_transaction_types TT 
                     ON TT.transaction_type_id = SIT.transaction_type_id 
      WHERE  SI.sale_id = @SaleID 
  AND product_id = 1 
             AND SIT.transaction_type_id IN ( 8, 9 ) 
      ORDER  BY SIT.date_created DESC 

      -- set @RemoteTicketCollected 
      IF EXISTS (SELECT 1 
                 FROM   @TicketDistributions 
                 WHERE  distribution_type_id = 7) 
        BEGIN 
            PRINT 'Remote Collect Ticket' 

            IF EXISTS (SELECT 1 
                       FROM   [dbo].[tbl_ticket_queue_remote_collect] 
                       WHERE  [ticketno] = @ticket_serial) 
              BEGIN 
                  SET @RemoteTicketCollected = 0 

                  PRINT 'NOT COLLECTED' 
              END 
            ELSE 
              BEGIN 
                  SET @RemoteTicketCollected = 1 

                  PRINT 'COLLECTED' 
              END 
        END 

		Declare @distributionSaleID INT

		SELECT @distributionSaleID= max(sale_id) from @baskets B inner JOIN tbl_Ticket_Distribution D
		 on B.saleid = D.sale_id

      -- (table 8) TicketDistributionsType 
      SELECT ticket_distribution_id   AS distributionId, 
             ticket_id                AS ticketId, 
             ticket_type_id           AS ticketTypeId, 
             TDT.distribution_type_id AS distributionTypeId, 
             distribution_type        AS distributionType, 
             active, 
             distribution_code        AS distributionCode, 
             sort_order               AS sortOrder, 
             @CollectingAgentCode     AS collectingAgentCode, 
             @RemoteTicketCollected   remoteTicketCollected, 
             @PrintStatus             AS printStatus, 
             @PrintDate               AS printedDate, 
             sale_id 
      FROM   dbo.tbl_ticket_distribution_types AS TDT 
             INNER JOIN @TicketDistributions AS TD 
                     ON TD.distribution_type_id = TDT.distribution_type_id 
      WHERE  active = 1 and TD.sale_id = @distributionSaleID
      ORDER  BY date_generated ASC 

      -- (table 9) Coachcard details 
      -- Get Coachcard Numbers 
      SELECT dbo.tbl_pass_use.pass_number         coachCard, 
             dbo.tbl_consumer_types.consumer_type passType 
      FROM   dbo.tbl_pass_use 
        INNER JOIN dbo.tbl_consumer_types 
                     ON dbo.tbl_pass_use.pass_type = 
  dbo.tbl_consumer_types.passenger_type_code 
      WHERE  sale_id = @FirstSaleID 

      -- determine if ITX Ticket 
      DECLARE @IsExcessFarePayable BIT 

      SET @IsExcessFarePayable = 1 

      IF EXISTS (SELECT 1 
                 FROM   dbo.tbl_basket_summary 
                 WHERE  sale_id = @FirstSaleID 
                        AND LEFT(agentid, 2) = 'IX') 
        BEGIN 
            SET @IsExcessFarePayable = 0 
        END 

      -- Determine if Amendment Allowed 
      DECLARE @NonAmendableTicket BIT 

      SET @NonAmendableTicket = 0 

      IF EXISTS (SELECT 1 
                 FROM   nxlookup.dbo.tbl_faretypeamendablerefundabledefinitions 
                 WHERE  faretype = @FareType 
                        AND isamendable = 0) 
        BEGIN 
            SET @NonAmendableTicket = 1 
        END 

      DECLARE @IsTicketAmendableOnLine BIT 

  SET @IsTicketAmendableOnLine = 1 

      -- determine if Ticket has flexibility Addon 
      IF EXISTS (SELECT 1 
                 FROM   @BasketItems 
                 WHERE  sku IN ( 'H05H019', 'H05H020' )) 
        BEGIN 
            SET @IsTicketAmendableOnLine = 0 
        END 

      -- Check to see if Ticket has OX branded leg 
      IF EXISTS (SELECT 1 
                 FROM   @BasketItems AS BI 
                        INNER JOIN dbo.tbl_smartjourneylegs AS SJL 
                                ON SJL.sales_item_id = BI.basketitemid 
                                   AND SJL.company_brand_code = 'OX') 
        BEGIN 
            SET @IsTicketAmendableOnLine = 0 
        END 

      -- Check to see if Ticket is Eurolines 
      IF EXISTS (SELECT 1 
                 FROM   @BasketItems AS BI 
                        INNER JOIN dbo.tbl_smartjourneylegs AS SJL 
                         ON SJL.sales_item_id = BI.basketitemid 
                                   AND ( LEFT(SJL.from_location_code, 1) = 'A' 
                                          OR LEFT(SJL.to_location_code, 1) = 'E' 
                                       ) 
                ) 
        BEGIN 
            SET @IsTicketAmendableOnLine = 0 

            -- Allow OuiBus Alliance Tickets to be Amendable Online 
            IF EXISTS (SELECT 1 
                       FROM   @BasketItems AS BI 
                              INNER JOIN dbo.tbl_smartjourneylegs AS SJL 
                                      ON SJL.sales_item_id = BI.basketitemid 
                                         AND SJL.[company_brand_code] IN 
                                             ( 'NL', 'OU' )) 
              BEGIN 
                  SET @IsTicketAmendableOnLine = 1 
              END 
        END 

      -- check if NX Holiday Ticket 
      IF LEFT(@ticket_serial, 2) = 'NH' 
        BEGIN 
            SET @IsTicketAmendableOnLine = 0 
        END 

      -- Mark Open Jaws as NOT amendable online 
      IF EXISTS (SELECT 1 
                 FROM   dbo.tbl_ticket_journeys 
                 WHERE  ticket_journey_type_id = 4 
                        AND item_serial_id = @item_serial_id) 
        BEGIN 
            SET @IsTicketAmendableOnLine = 0 
        END 

      -- if Brit Xplorer Skimmer Pass Used NOT amendable online 
      IF EXISTS (SELECT 1 
                 FROM   dbo.tbl_pass_use 
                 WHERE  sale_id = @FirstSaleID 
                        AND [pass_type] = 'BX') 
        BEGIN 
            PRINT 'BX Used' 

            SET @IsTicketAmendableOnLine = 0 
            SET @NonAmendableTicket = 1 
        END 

      -- Has then be a Skimmer override on Initial Reservation ? 
      IF EXISTS (SELECT 1 
                 FROM   [dbo].[tbl_smart_overrides] SO 
                 WHERE  [sale_item_id] = @FirstTravelSalesItemID 
                        AND so.[override_reason] = 'SK') 
        BEGIN 
            PRINT 'SKIMMER OVERRIDE' 

            SET @IsTicketAmendableOnLine = 0 
 END 

      -- Return Over60s Count 
    DECLARE @Over60s INT 

      SET @Over60s = 0 

      SELECT @Over60s = over60 
      FROM   dbo.tbl_passenger_summary 
      WHERE  sale_id = @FirstSaleID 

      -- Return HighestFarePaidToDate 
      DECLARE @HighestFarePaidToDate MONEY 

      SET @HighestFarePaidToDate = 0 

      SELECT @HighestFarePaidToDate = Cast(Max(BS.highest_fare_paid_to_date) AS 
                                           MONEY) / 100 
      FROM   dbo.tbl_basket_summary BS 
      WHERE  BS.ticketno = @ticket_serial 

      -- Return Payment on latest basket 
      DECLARE @PaymentProvider VARCHAR(50) 
      DECLARE @PaymentType VARCHAR(50) 
      DECLARE @PaymentValue MONEY 
      DECLARE @PaymentAcccount VARCHAR(250) 

      SELECT @PaymentType = PT.payment_type, 
             @PaymentValue = P.payment_value, 
             @PaymentProvider = PP.[name], 
         @PaymentAcccount = Isnull(PA.payment_account, '') 
      FROM   dbo.tbl_payments P 
             JOIN tbl_payment_types PT 
               ON p.payment_type_id = PT.payment_type_id 
                  AND P.sale_id = @saleID 
             LEFT JOIN dbo.tbl_payment_provider_transactions PPT 
                    ON P.sale_id = PPT.sale_id 
             LEFT JOIN nxlookup.dbo.tbl_payment_providers PP 
                    ON PPT.payment_provider_id = PP.id 
             LEFT JOIN dbo.tbl_payment_account PA 
                    ON P.payment_id = PA.payment_id 

      -- get Journey Side Fare Values 
      DECLARE @OutBoundJourneySideFare MONEY 
      DECLARE @InBoundJourneySideFare MONEY 
      DECLARE @PreviousOutBoundJourneySideFare MONEY 
      DECLARE @PreviousInBoundJourneySideFare MONEY 

       --Changes for SMAREP-2640
      SELECT @OutBoundJourneySideFare = (CASE si.sale_item_type_id 
                   WHEN 3 THEN 0  ELSE js.OutBoundJourneySideFare END), 
				@InBoundJourneySideFare = (CASE si.sale_item_type_id 
                   WHEN 3 THEN 0  ELSE Isnull(inboundjourneysidefare, 0) END)
      FROM   dbo.tbl_journey_side_fares js
	  Join tbl_Sales_Items si on js.Sale_ID = si.sale_id
      WHERE  js.Sale_ID = @SaleID 

      SELECT TOP 1 @PreviousOutBoundJourneySideFare = outboundjourneysidefare, 
                   @PreviousInBoundJourneySideFare = Isnull(inboundjourneysidefare, 0) 
      FROM   dbo.tbl_journey_side_fares J 
             INNER JOIN @Baskets b 
                     ON b.saleid = J.sale_id 
      WHERE  sale_id < @SaleID 
      ORDER  BY sale_id DESC 

      -- if no side fares found   
      IF @OutBoundJourneySideFare IS NULL 
        -- determine Journey Type 
        BEGIN 
            PRINT 'No Outboundfare' 

            SELECT @OutBoundJourneySideFare = ( CASE ticket_journey_type_id 
                   WHEN 1 THEN 0.5 * si.item_single_value 
                   -- return 
                   WHEN 2 THEN si.item_single_value 
                   -- open return 
                   WHEN 3 THEN 0.5 * si.item_single_value 
                   -- validated open return 
                   WHEN 4 THEN 0.5 * si.item_single_value 
                   -- opem jaw return 
                   WHEN 5 THEN si.item_single_value 
                                                  -- single 
                                                  ELSE 0 
                                                END ), 
                   @InBoundJourneySideFare = ( CASE ticket_journey_type_id 
                   WHEN 1 THEN 0.5 * si.item_single_value 
                                                 -- return 
                                                 WHEN 2 THEN 0 -- open return 
                   WHEN 3 THEN 0.5 * si.item_single_value 
                   -- validated open return 
                   WHEN 4 THEN 0.5 * si.item_single_value 
                                                 -- opem jaw return 
                                                 WHEN 5 THEN 0 -- single 
                            ELSE 0 
            END ) 
            FROM   tbl_sales_items SI 
                   JOIN dbo.tbl_item_serial_link ISL 
                     ON si.item_serial_id = isl.item_serial_id 
                        AND si.sale_id = @SaleID 
                        AND si.product_id = 1 
                   JOIN dbo.tbl_ticket_journeys TTJ 
                     ON isl.item_serial_id = TTJ.item_serial_id 
        END 

      -- (Table -10) Summary information 
      -- open return valiadtion details 
      IF EXISTS (SELECT 1 
                 FROM   tbl_sales_items 
                 WHERE  sale_id = @FirstSaleID 
                        AND product_id = 1 
                        AND [sale_item_type_id] = 1) 
        BEGIN 
            -- travel transaction   
            PRINT 'Travel Transaction' 

            SELECT DISTINCT CASE ticket_journey_type_id 
                              WHEN 2 THEN 1 
                              ELSE 0 
                            END 
                            AS  isOpenReturn, 
                            Isnull(card_number, '') AS  lastFourDigits, 
                            from_location_code AS fromLocation, 
                            Dateadd(s, departure_date, '01-Jan-1970 00:00:00') AS originalDepartureDate, 
                            si.item_single_value AS originalFareValue, 
                            @IsExcessFarePayable AS isExcessFarePayable, 
                            @IsTicketAmendableOnLine AS isTicketAmendableOnLine, 
                            Isnull(@Over60s, 0) AS over60sCount, 
                            @HighestFarePaidToDate AS highestFarePaidToDate, 
                            @NonAmendableTicket 
                            AS 
                            ticketIsNotAmendable, 
                  @PaymentProvider 
                            AS 
                            paymentProvider, 
                            @PaymentType 
         AS 
                            paymentType, 
                            @PaymentValue 
                            AS 
                            paymentValue, 
                            @PaymentAcccount 
                            AS 
                            paymentAccount 
                            --incase of partial cancellation taking previous side fare, if outward is cancelled, so return become outward and prev inbound fare become outbound fare.
                            , 
                            ( CASE 
                                WHEN Isnull(@PartialCancellationStatus, 0) = 12 
                              THEN 
                                Isnull( 
                                @PreviousInBoundJourneySideFare, 0) 
                                WHEN Isnull(@PartialCancellationStatus, 0) = 13 
                              THEN 
                                Isnull( 
                                @PreviousOutBoundJourneySideFare, 0) 
                                ELSE Isnull(@OutBoundJourneySideFare, 0) 
                              END ) 
                            AS 
                            outBoundJourneySideFare, 
                            Isnull(@InBoundJourneySideFare, 0) 
                            AS 
                            inBoundJourneySideFare, 
                            Isnull(@PreviousOutBoundJourneySideFare, 0) 
                            AS 
                            previousOutBoundJourneySideFare, 
                            Isnull(@PreviousInBoundJourneySideFare, 0) 
                            AS 
                            previousInBoundJourneySideFare, 
                            @ThirdPartyReference 
                            thirdPartyReference 
            FROM   dbo.tbl_sales_items SI 
                   JOIN dbo.tbl_payments P 
                     ON si.sale_id = p.sale_id 
                        AND si.product_id = 1 
  AND si.sale_id = @FirstSaleID 
                   LEFT JOIN dbo.tbl_card_details CD 
                          ON p.card_details_id = cd.card_details_id 
                   JOIN dbo.tbl_smartjourneylegs SJL 
       ON si.sales_item_id = sjl.sales_item_id 
                        AND leg_number = 0 
                   JOIN dbo.tbl_item_serial_link ISL 
                     ON si.item_serial_id = isl.item_serial_id 
                   JOIN dbo.tbl_ticket_journeys TJ 
                     ON.isl.item_serial_id = tj.item_serial_id 
        END 
      ELSE 
        BEGIN 
            -- None Travel Transaction 
            PRINT 'Non Travel Transaction' 

            SELECT DISTINCT CASE ticket_journey_type_id 
                              WHEN 2 THEN 1 
                              ELSE 0 
                            END                     AS isOpenReturn, 
                            Isnull(card_number, '') AS lastFourDigits, 
                            ''                      AS fromLocation, 
                            ''                      AS originalDepartureDate, 
                     0                       AS originalFareValue, 
                            0                       AS isExcessFarePayable, 
                            0                       AS isTicketAmendableOnLine, 
                            0                       AS over60sCount, 
                            0                       AS highestFarePaidToDate, 
                            0                       AS ticketIsNotAmendable, 
                            @PaymentProvider        AS paymentProvider, 
                            @PaymentType            AS paymentType, 
                            @PaymentValue           AS paymentValue, 
      @PaymentAcccount        AS paymentAccount, 
                            0                       AS outBoundJourneySideFare, 
                            0                       AS inBoundJourneySideFare, 
                            0                       AS 
                            previousOutBoundJourneySideFare 
                            , 
                            0                       AS 
                            previousInBoundJourneySideFare, 
                            @ThirdPartyReference    thirdPartyReference 
            FROM   dbo.tbl_sales_items SI 
                   JOIN dbo.tbl_payments P 
                     ON si.sale_id = p.sale_id 
                        AND si.sale_id = @FirstSaleID 
                   LEFT JOIN dbo.tbl_card_details CD 
                          ON p.card_details_id = cd.card_details_id 
                   JOIN dbo.tbl_item_serial_link ISL 
                     ON si.item_serial_id = isl.item_serial_id 
                   LEFT JOIN dbo.tbl_ticket_journeys TJ 
                          ON.isl.item_serial_id = tj.item_serial_id 
        END 

      -- (table 15) Discounts details 
      SELECT discount_code AS discountCode, 
             campaign_code AS campaignCode, 
             value, 
             productsku, 
             campaignid, 
             sale_id       AS saleId 
      FROM   dbo.tbl_discounts_applied 
      WHERE  sale_id = @SaleID; 

      -- Voucher Userd details 
      SELECT serial_number       AS voucher, 
             voucher_value       AS value, 
             passenger_type_code AS paxType, 
             vu.sale_id          AS saleId 
      FROM   tbl_vouchers V 
             INNER JOIN tbl_voucher_use vu 
                     ON V.voucher_id = vu.voucher_id 
      WHERE  vu.sale_id = @saleid 

      SELECT B.saleid, 
             SO.sale_item_id     saleItemId, 
             SOR.override_reason overrideReason, 
             old_fare            oldFare, 
             new_fare            newFare, 
             NAME, 
             full_description    description 
      FROM   [dbo].[tbl_smart_overrides] SO 
             INNER JOIN tbl_agent_users AU 
                     ON SO.agent_user_id = AU.agent_user_id 
             INNER JOIN tbl_smart_override_reasons SOR 
                     ON SOR.override_code = SO.override_reason 
             INNER JOIN tbl_sales_items SI 
                     ON SI.sales_item_id = SO.sale_item_id 
             INNER JOIN @baskets B 
                     ON B.saleid = SI.sale_id 
      --where SI.sale_id=@saleid 
      ORDER  BY SO.date_created 
  END 




GO

