@EndUserText.label: 'Báo cáo lưu chuyển tiền tệ'
@ObjectModel.query.implementedBy: 'ABAP:ZCL_FI_CASHFLOW_RERORT'
@UI: {
    headerInfo: {
        typeName: 'Báo cáo lưu chuyển tiền tệ',
        typeNamePlural: 'Báo cáo lưu chuyển tiền tệ',
        title: {
            type: #STANDARD,
            label: 'Báo cáo lưu chuyển tiền tệ'
        }
    }
}
define custom entity ZI_FI_CASHFLOW_RERORT

{
      @Consumption.valueHelpDefinition: [{ entity : {  name: 'I_CompanyCodeStdVH' , element: 'CompanyCode' } }]
  key CompanyCode           : bukrs;
      //@Consumption.valueHelpDefinition: [{ entity : {  name: 'I_RU_FinStmntCashFlowVersionT' , element: 'Version' } }]
  key Version               : zde_firu_cf_version;
  key Item                  : zde_firu_cf_item;
      @Consumption.valueHelpDefinition: [{ entity : {  name: 'I_Ledger' , element: 'Ledger' } }]
  key Ledger                : fins_ledger;
      @Consumption.valueHelpDefinition: [{ entity : {  name: 'I_GLAccount' , element: 'GLAccount' } }]
      @EndUserText.label    : 'GL Account'
  key GLAccount             : abap.char(10);
  key FiscalYear            : gjahr;
      @EndUserText.label    : 'Form Period'
  key FromPeriod            : abap.numc( 2 );
      @EndUserText.label    : 'To Period'
  key ToPeriod              : abap.numc( 2 );
      @EndUserText.label    : 'Comparison Year'
  key CompYear              : gjahr;
      @EndUserText.label    : 'From Comparison Period'
  key FromCompPeriod          : abap.numc( 2 );
      @EndUserText.label    : 'To Comparison Period'
  key ToCompPeriod          : abap.numc( 2 );
  key StatryRptRunID        : srf_report_run_id;
  key StatryRptgEntity      : srf_reporting_entity;
  key StatryRptCategory     : srf_rep_cat_id;

      report_date           : datum;
      butxt                 : butxt;
      gjahr                 : gjahr;
      waers                 : waers;
      fiscal_prd_fr         : monat;
      fiscal_prd_to         : monat;
      bukrs                 : bukrs;
      report_date_fr        : datum;
      report_date_to        : datum;
      currency_txt          : abap.char(15);
      col_items             : abap.char(20);
      col_period            : abap.char(20);
      col_comparison_period : abap.char(20);
      col_extend            : abap.char(20);
      fiscal_year_cmp       : gjahr;

      liquidityitemname     : abap.char(60);
      liquidityitem         : abap.char( 16 );
      display_currency      : waers;
      amount                : abap.char( 30 );
      amount_prev           : abap.char( 30 );
      @Semantics.amount.currencyCode : 'display_currency'
      cal_amount            : abap.curr( 23, 2 );
      @Semantics.amount.currencyCode : 'display_currency'
      cal_amount_prev       : abap.curr( 23, 2 );
      node_id               : abap.numc( 8 );
      node_order            : abap.numc( 6 );

      @UI                   : {
      lineItem              : [ { position: 70, label: 'Chỉ tiêu' } ],
      identification        : [ { position: 70, label: 'Chỉ tiêu' } ] }
      @EndUserText.label    : 'Chỉ tiêu'
      fs_item_txt_vn        : abap.char( 255 );
      @UI                   : {
      lineItem              : [ { position: 80, label: 'Criteria' } ],
      identification        : [ { position: 80, label: 'Criteria' } ] }
      @EndUserText.label    : 'Comparison Period'
      fs_item_txt_en        : abap.char( 255 );
      @UI                   : {
      lineItem              : [ { position: 90, label: 'Mã số' } ],
      identification        : [ { position: 90, label: 'Mã số' } ] }
      @EndUserText.label    : 'Mã số'
      fsnode                : abap.char( 10 );
      @UI.hidden            : true
      is_bold               : abap_boolean;
      @UI.hidden            : true
      is_nega               : abap_boolean;
      @UI                   : {
      lineItem              : [ { position: 100, label: 'Thuyết minh' } ],
      identification        : [ { position: 100, label: 'Thuyết minh' } ] }
      @EndUserText.label    : 'Thuyết minh'
      fs_note               : abap.char( 10 );

      @UI.hidden            : true
      CompNameVI            : abap.char(100);
      @UI.hidden            : true
      CompAddressVI         : abap.char(100);
      @UI.hidden            : true
      CompNameEN            : abap.char(100);
      @UI.hidden            : true
      CompAddressEN         : abap.char(100);
      @UI.hidden            : true
      CompTaxCode           : abap.char(100);
}
