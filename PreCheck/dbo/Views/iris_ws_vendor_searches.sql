-- Alter View iris_ws_vendor_searches
CREATE VIEW dbo.iris_ws_vendor_searches
WITH SCHEMABINDING 
AS
SELECT     RC.id, R.R_id AS vendor_id, C.CNTY_NO AS county_id, CASE WHEN R.R_id IN (1255562) 
                      THEN 'x_countyCivil' WHEN C.A_County LIKE '%state%' THEN 'statewide' ELSE 'county' END AS search_type_qualifier, CASE WHEN R.R_id IN (1255562) 
                      THEN 'civil' ELSE 'felonyMisdemeanor' END AS court_type, CASE WHEN R.R_Name LIKE '%omni%' THEN 3 WHEN R.R_Name LIKE '%innov%' THEN 2 ELSE NULL 
                      END AS vendor_type_id, 'US' AS country_code, C.State AS region, CASE WHEN C.A_County LIKE '%state%' THEN NULL ELSE C.A_County END AS county
FROM         dbo.TblCounties AS C WITH (nolock) INNER JOIN
                      dbo.Iris_Researcher_Charges AS RC WITH (nolock) INNER JOIN
                      dbo.Iris_Researchers AS R WITH (nolock) ON RC.Researcher_id = R.R_id ON C.CNTY_NO = RC.cnty_no
WHERE     (R.R_Delivery = 'WEB SERVICE')

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
         Configuration = "(H (4 [30] 2 [40] 3))"
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
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "C"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 125
               Right = 224
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "RC"
            Begin Extent = 
               Top = 126
               Left = 38
               Bottom = 245
               Right = 254
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "R"
            Begin Extent = 
               Top = 6
               Left = 262
               Bottom = 125
               Right = 459
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 9
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'iris_ws_vendor_searches';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 1, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'iris_ws_vendor_searches';

