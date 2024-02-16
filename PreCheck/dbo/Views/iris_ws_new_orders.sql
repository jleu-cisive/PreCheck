
CREATE VIEW [dbo].[iris_ws_new_orders]
AS
SELECT     VT.code AS vendor_type, CAST(NULL AS UNIQUEIDENTIFIER) AS order_key, 'New' AS order_status, A.APNO AS applicant_id, C.CrimID AS screening_id, 
                      'false' AS is_criminal_case_record, NULL AS parent_screening_id, VS.id AS vendor_search_id, 'criminal' AS search_type, 
                      VS.search_type_qualifier AS search_qualifier, VS.court_type, VS.country_code, VS.region, 
                      CASE 
						WHEN (VT.CODE like '%innovative%' AND VS.search_type_qualifier like '%statewide%') THEN  'Statewide' 
                        ELSE REPLACE(REPLACE(VS.county, '''', ''), '.', '') END AS county, 
                      CASE WHEN A.Last = '' THEN NULL ELSE A.Last END AS last_name, CASE WHEN A.First = '' THEN NULL ELSE A.First END AS first_name, 
                      CASE WHEN A.Middle = '' THEN NULL ELSE A.Middle END AS middle_name, CASE WHEN UPPER(A.Sex) = 'M' THEN 'male' WHEN UPPER(A.Sex) 
                      = 'F' THEN 'female' ELSE 'unspecified' END AS sex, CASE WHEN A.DOB = '' THEN NULL ELSE CONVERT(CHAR(10), A.DOB, 102) END AS dob, 
                      CASE WHEN A.SSN = '' THEN NULL ELSE A.SSN END AS ssn, CASE WHEN A.Alias1_Last = '' THEN NULL ELSE A.Alias1_Last END AS last_name_1, 
                      CASE WHEN A.Alias1_First = '' THEN NULL ELSE A.Alias1_First END AS first_name_1, CASE WHEN A.Alias1_Middle = '' THEN NULL 
                      ELSE A.Alias1_Middle END AS middle_name_1, CASE WHEN A.Alias2_Last = '' THEN NULL ELSE A.Alias2_Last END AS last_name_2, 
                      CASE WHEN A.Alias2_First = '' THEN NULL ELSE A.Alias2_First END AS first_name_2, CASE WHEN A.Alias2_Middle = '' THEN NULL 
                      ELSE A.Alias2_Middle END AS middle_name_2, CASE WHEN A.Alias3_Last = '' THEN NULL ELSE A.Alias3_Last END AS last_name_3, 
                      CASE WHEN A.Alias3_First = '' THEN NULL ELSE A.Alias3_First END AS first_name_3, CASE WHEN A.Alias3_Middle = '' THEN NULL 
                      ELSE A.Alias3_Middle END AS middle_name_3, CASE WHEN A.Alias4_Last = '' THEN NULL ELSE A.Alias4_Last END AS last_name_4, 
                      CASE WHEN A.Alias4_First = '' THEN NULL ELSE A.Alias4_First END AS first_name_4, CASE WHEN A.Alias4_Middle = '' THEN NULL 
                      ELSE A.Alias4_Middle END AS middle_name_4, CASE WHEN Datalength(C.CRIM_SpecialInstr) = 0 THEN NULL 
                      ELSE C.CRIM_SpecialInstr END AS special_instructions, C.txtlast, C.txtalias, C.txtalias2, C.txtalias3, C.txtalias4, A.APNO
FROM         dbo.Crim AS C INNER JOIN
                      dbo.Appl AS A ON C.APNO = A.APNO INNER JOIN
                      dbo.iris_ws_vendor_searches AS VS ON C.CNTY_NO = VS.county_id AND C.vendorid = VS.vendor_id INNER JOIN
                      dbo.iris_ws_vendor_type AS VT ON VS.vendor_type_id = VT.id
WHERE     (C.Clear IN ('M')) AND (C.InUseByIntegration IS NULL) AND C.IsHidden = 0



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
         Left = -1237
      End
      Begin Tables = 
         Begin Table = "C"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 121
               Right = 207
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "A"
            Begin Extent = 
               Top = 6
               Left = 245
               Bottom = 121
               Right = 425
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "VS"
            Begin Extent = 
               Top = 126
               Left = 38
               Bottom = 241
               Right = 223
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "VT"
            Begin Extent = 
               Top = 126
               Left = 261
               Bottom = 226
               Right = 440
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
      Begin ColumnWidths = 11
         Column = 4575
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'iris_ws_new_orders';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 1, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'iris_ws_new_orders';

