﻿CREATE PROCEDURE InsertAppl
  @Apno int,
  @ApStatus char(1),
  @UserID varchar(8),
  @Billed bit,
  @Investigator varchar(8),
  @EnteredBy varchar(8),
  @ApDate datetime,
  @CompDate datetime,
  @Clno smallint,
  @Attn varchar(25),
  @Last varchar(20),
  @First varchar(20),
  @Middle varchar(20),
  @Alias varchar(30),
  @Alias2 varchar(30),
  @Alias3 varchar(30),
  @Alias4 varchar(30),
  @SSN varchar(11),
  @DOB datetime,
  @Sex varchar(1),
  @DL_State varchar(2),
  @DL_Number varchar(20),
  @Addr_Num varchar(6),
  @Addr_Dir varchar(2),
  @Addr_Street varchar(19),
  @Addr_StType varchar(2),
  @Addr_Apt varchar(5),
  @City varchar(16),
  @State varchar(2),
  @Zip varchar(5),
  @Pos_Sought varchar(25),
  @Update_Billing bit,
  @Priv_Notes text,
  @Pub_Notes text
as
  set nocount on
  insert into Appl
    (Apno, ApStatus, UserID, Billed, Investigator, EnteredBy,
      ApDate, CompDate, Clno, Attn, Last, First, Middle,
      Alias, Alias2, Alias3, Alias4, SSN, DOB, Sex,
      DL_State, DL_Number, Addr_Num, Addr_Dir,
      Addr_Street, Addr_StType, Addr_Apt, City, State, Zip,
      Pos_Sought, Update_Billing, Priv_Notes, Pub_Notes)
  values
    (@Apno, @ApStatus, @UserID, @Billed, @Investigator, @EnteredBy,
      @ApDate, @CompDate, @Clno, @Attn, @Last, @First, @Middle,
      @Alias, @Alias2, @Alias3, @Alias4, @SSN, @DOB, @Sex,
      @DL_State, @DL_Number, @Addr_Num, @Addr_Dir,
      @Addr_Street, @Addr_StType, @Addr_Apt, @City, @State, @Zip,
      @Pos_Sought, @Update_Billing, @Priv_Notes, @Pub_Notes)
