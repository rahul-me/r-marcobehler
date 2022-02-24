USE [Titan]
Go

UPDATE tbl_Ticket_Distribution_Types
SET active = 0
WHERE distribution_type = 'Not Applicable';