--select * from [dbo].[iris_ws_all_orders]
CREATE VIEW [dbo].[iris_ws_all_orders]
AS
SELECT   top 500 vendor_type, order_key, order_status, applicant_id, screening_id, is_criminal_case_record, parent_screening_id, vendor_search_id, search_type, 
                      search_qualifier, court_type, country_code, region, county, last_name, first_name, middle_name, sex, dob, ssn, last_name_1, first_name_1, 
                      middle_name_1, last_name_2, first_name_2, middle_name_2, last_name_3, first_name_3, middle_name_3, last_name_4, first_name_4, 
                      middle_name_4, special_instructions, txtlast, txtalias, txtalias2, txtalias3, txtalias4
FROM         dbo.iris_ws_unconfirmed_orders
UNION ALL
SELECT  top 500 vendor_type, order_key, order_status, applicant_id, screening_id, is_criminal_case_record, parent_screening_id, vendor_search_id, search_type, 
                      search_qualifier, court_type, country_code, region, county, last_name, first_name, middle_name, sex, dob, ssn, last_name_1, first_name_1, 
                      middle_name_1, last_name_2, first_name_2, middle_name_2, last_name_3, first_name_3, middle_name_3, last_name_4, first_name_4, 
                      middle_name_4, special_instructions, txtlast, txtalias, txtalias2, txtalias3, txtalias4
FROM         dbo.iris_ws_waiting_orders

GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4[30] 2[40] 3) )"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 3
   End
   Begin DiagramPane = 
      PaneHidden = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 5
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'iris_ws_all_orders';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 1, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'iris_ws_all_orders';

