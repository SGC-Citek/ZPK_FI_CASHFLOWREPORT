CLASS zcl_fi_cashflow_rerort DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES:
      if_rap_query_provider.
    DATA: gt_data TYPE TABLE OF zi_fi_cashflow_rerort.
  PROTECTED SECTION.
  PRIVATE SECTION.
    METHODS: get_data_db
      IMPORTING io_request TYPE REF TO if_rap_query_request.
ENDCLASS.



CLASS ZCL_FI_CASHFLOW_RERORT IMPLEMENTATION.


  METHOD get_data_db.
    TYPES: lv_fiscal_year   TYPE n LENGTH 4,
           lv_fiscal_period TYPE n LENGTH 2.
    DATA: lv_bukrs             TYPE bukrs,
          lv_ver_cf            TYPE zde_firu_cf_version,
          lv_ledger            TYPE fins_ledger,
          lr_glaccount         TYPE RANGE OF char10,
          lv_fiscal_year       TYPE lv_fiscal_year,
          lv_from_period       TYPE lv_fiscal_period,
          lv_to_period         TYPE lv_fiscal_period,
          lv_fiscal_year_comp  TYPE lv_fiscal_year,
          lv_form_period_comp  TYPE lv_fiscal_period,
          lv_to_period_comp    TYPE lv_fiscal_period,
          lv_statryrptrunid    TYPE srf_report_run_id,
          lv_statryrptgentity  TYPE srf_reporting_entity,
          lv_statryrptcategory TYPE srf_rep_cat_id.

    DATA: lt_data TYPE TABLE OF zc_fi_income_statement.

    " get filter by parameter -----------------------
    TRY.
        DATA(lt_filter_cond) = io_request->get_filter( )->get_as_ranges( ).
      CATCH cx_rap_query_filter_no_range INTO DATA(lx_no_sel_option).
    ENDTRY.
    IF lt_filter_cond IS NOT INITIAL.
      LOOP AT lt_filter_cond REFERENCE INTO DATA(ls_filter_cond).
        CASE ls_filter_cond->name.
          WHEN 'COMPANYCODE'.
            lv_bukrs                = ls_filter_cond->range[ 1 ]-low.
          WHEN 'VERSION'.
            lv_ver_cf               = ls_filter_cond->range[ 1 ]-low.
          WHEN 'LEDGER'.
            lv_ledger               = ls_filter_cond->range[ 1 ]-low.
          WHEN 'GLACCOUNT'.
            lr_glaccount            = CORRESPONDING #( ls_filter_cond->range[] ).
          WHEN 'FISCALYEAR'.
            lv_fiscal_year          = ls_filter_cond->range[ 1 ]-low.
          WHEN 'FROMPERIOD'.
            lv_from_period          = ls_filter_cond->range[ 1 ]-low.
          WHEN 'TOPERIOD'.
            lv_to_period            = ls_filter_cond->range[ 1 ]-low.
          WHEN 'COMPYEAR'.
            lv_fiscal_year_comp     = ls_filter_cond->range[ 1 ]-low.
          WHEN 'FROMCOMPPERIOD'.
            lv_form_period_comp     = ls_filter_cond->range[ 1 ]-low.
          WHEN 'TOCOMPPERIOD'.
            lv_to_period_comp       = ls_filter_cond->range[ 1 ]-low.
          WHEN 'STATRYRPTRUNID'.
            lv_statryrptrunid       = ls_filter_cond->range[ 1 ]-low.
          WHEN 'STATRYRPTGENTITY'.
            lv_statryrptgentity       = ls_filter_cond->range[ 1 ]-low.
          WHEN 'STATRYRPTCATEGORY'.
            lv_statryrptcategory      = ls_filter_cond->range[ 1 ]-low.
          WHEN OTHERS.
        ENDCASE.
      ENDLOOP.
    ENDIF.
    " get filter by parameter -----------------------

    SELECT FROM ztb_cashflow_cf AS cf
      FIELDS *
      WHERE cf~version = 'VN02'
      ORDER BY item
      INTO TABLE @DATA(lt_cashflow_cf).

    CHECK sy-subrc EQ 0.

    DATA lt_column_name TYPE STANDARD TABLE OF srf_column_name.
    lt_column_name = VALUE #( ( 'LIQUIDITYITEMNAME' ) ( 'LIQUIDITYITEM' )  ( 'DISPLAY_CURRENCY' ) ( 'AMOUNT' ) ( 'AMOUNT_PREV' ) ( 'NODE_ID' ) ( 'NODE_ORDER' )  ).

    DATA lt_column_hd TYPE STANDARD TABLE OF srf_column_name.
    lt_column_hd = VALUE #( ( 'REPORT_DATE' ) ( 'BUTXT' )  ( 'GJAHR' ) ( 'WAERS' ) ( 'FISCAL_PRD_FR' )  ( 'FISCAL_PRD_TO' ) ( 'BUKRS' ) ( 'REPORT_DATE_FR' )
                            ( 'REPORT_DATE_TO' ) ( 'CURRENCY_TXT' ) ( 'COL_ITEMS' ) ( 'COL_PERIOD' ) ( 'COL_COMPARISON_PERIOD' ) ( 'COL_EXTEND' ) ( 'FISCAL_YEAR_CMP' ) ).

    TRY.

        DATA(lr_report) = cl_srf_facade=>get_report_run_by_id(  iv_rep_cat_id   = lv_statryrptcategory
                                                                 iv_reporting_entity = lv_statryrptgentity
                                                                 iv_report_run_id = lv_statryrptrunid ).
*        lr_report->get_info(
*          RECEIVING
*            rs_rep_run = DATA(ls_reprun)
*        ).
**
*        lr_report->get_rep_run_parameters(
**          IMPORTING
**            eo_msg_handler =
*          RECEIVING
*            rt_rep_run_par = DATA(lt_param)
*        ).
        DATA(lr_records) = lr_report->execute_query(
          EXPORTING
            iv_query_id    = 'Q_CN_CASH_FLOW_NODES_INDT'
            it_column_name = CONV #( lt_column_name )
            io_msg_handler = cl_srf_facade=>get_message_handler( )
        ).

        DATA(lr_records_head) = lr_report->execute_query(
          EXPORTING
            iv_query_id    = 'CASH_FLOW_HEADER'
            it_column_name = CONV #( lt_column_hd )
            io_msg_handler = cl_srf_facade=>get_message_handler( )
        ).

        FIELD-SYMBOLS: <lt_record>       TYPE ANY TABLE, <fs_records_head> TYPE table.
        DATA: lv_item TYPE zde_firu_cf_item.
        ASSIGN lr_records->* TO <lt_record>.
        ASSIGN lr_records_head->* TO <fs_records_head>.
        READ TABLE <fs_records_head> ASSIGNING FIELD-SYMBOL(<ls_recordhd>) INDEX 1.
        IF sy-subrc = 0.
          ASSIGN COMPONENT 'BUKRS' OF STRUCTURE <ls_recordhd> TO FIELD-SYMBOL(<fs_comp>).
          SELECT SINGLE FROM ZCORE_I_PROFILE_COMPANYCODE_V2 AS com
          FIELDS *
          WHERE companycode = @<fs_comp>
          INTO @DATA(ls_comp).
        ENDIF.

        LOOP AT <lt_record> ASSIGNING FIELD-SYMBOL(<ls_record>).
          APPEND INITIAL LINE TO gt_data REFERENCE INTO DATA(lr_data).

          IF <ls_recordhd> IS ASSIGNED.
            MOVE-CORRESPONDING <ls_recordhd> TO lr_data->*.
          ENDIF.

          lr_data->compaddressen = ls_comp-Address.
          lr_data->compaddressvi = ls_comp-Address.
          lr_data->compnameen    = ls_comp-LongName.
          lr_data->compnamevi    = ls_comp-LongName.
          lr_data->comptaxcode   = ls_comp-VATNumber.

          MOVE-CORRESPONDING <ls_record> TO lr_data->*.
          lv_item = lr_data->node_id.
          READ TABLE lt_cashflow_cf INTO DATA(ls_cashflow_cf) WITH KEY item = lv_item BINARY SEARCH.
          IF sy-subrc = 0.
            lr_data->fs_item_txt_vn = ls_cashflow_cf-fsitextvn.
            lr_data->fs_item_txt_en = ls_cashflow_cf-fsitexten.
            lr_data->is_bold = ls_cashflow_cf-bold.
            lr_data->is_nega = ls_cashflow_cf-negative.
            lr_data->fsnode = ls_cashflow_cf-fsnode.
            lr_data->fs_note = ls_cashflow_cf-fs_note.
          ENDIF.

          IF lr_data->is_nega EQ 'X'.
            lr_data->cal_amount *= -1.
            lr_data->cal_amount_prev *= -1.
          ENDIF.

        ENDLOOP.


      CATCH cx_srf_error.
    ENDTRY.
  ENDMETHOD.


  METHOD if_rap_query_provider~select.

    " get list field requested ----------------------
    DATA(lt_reqs_element) = io_request->get_requested_elements( ).
    DATA(lt_aggr_element) = io_request->get_aggregation( )->get_aggregated_elements( ).
    IF lt_aggr_element IS NOT INITIAL.
      LOOP AT lt_aggr_element ASSIGNING FIELD-SYMBOL(<lfs_aggr_elements>).
        DELETE lt_reqs_element WHERE table_line = <lfs_aggr_elements>-result_element.
        DATA(lv_aggr) = |{ <lfs_aggr_elements>-aggregation_method }( { <lfs_aggr_elements>-input_element } ) as { <lfs_aggr_elements>-result_element }|.
        APPEND lv_aggr TO lt_reqs_element.
      ENDLOOP.
    ENDIF.

    DATA(lv_reqs_element) = concat_lines_of( table = lt_reqs_element sep = `, ` ).
    " get list field requested ----------------------

    " get list field ordered ------------------------
    DATA(lt_sort) = io_request->get_sort_elements(  ).

    DATA(lt_sort_criteria) = VALUE string_table( FOR ls_sort IN lt_sort ( ls_sort-element_name && COND #( WHEN ls_sort-descending = abap_true THEN ` descending`
                                                                                                                                              ELSE ` ascending` ) ) ).

    DATA(lv_sort_element) = COND #( WHEN lt_sort_criteria IS INITIAL THEN `Item` ELSE concat_lines_of( table = lt_sort_criteria sep = `, ` ) ).
    " get list field ordered ------------------------

    " get range of row data -------------------------
    DATA(lv_top)      = io_request->get_paging( )->get_page_size( ).
    DATA(lv_skip)     = io_request->get_paging( )->get_offset( ).
    DATA(lv_max_rows) = COND #( WHEN lv_top = if_rap_query_paging=>page_size_unlimited THEN 0
                                ELSE lv_top ).
    IF lv_max_rows = -1 .
      lv_max_rows = 1.
    ENDIF.
    " get range of row data -------------------------

    "get data --------------------------------------
    DATA: lv_fieldname   TYPE c LENGTH 30,
          lv_count       TYPE int1,
          lv_prev_serial TYPE c LENGTH 18.

    get_data_db( EXPORTING io_request = io_request ).

    DATA: lt_data LIKE gt_data.
    SELECT (lv_reqs_element)
    FROM @gt_data AS data
    ORDER BY (lv_sort_element)
    INTO CORRESPONDING FIELDS OF TABLE @lt_data
    OFFSET @lv_skip UP TO @lv_max_rows ROWS.

    IF io_request->is_data_requested( ).
      io_response->set_data( lt_data ).
    ENDIF.
    IF io_request->is_total_numb_of_rec_requested( ).
      io_response->set_total_number_of_records( lines( lt_data ) ).
    ENDIF.
    "get data --------------------------------------
  ENDMETHOD.
ENDCLASS.
