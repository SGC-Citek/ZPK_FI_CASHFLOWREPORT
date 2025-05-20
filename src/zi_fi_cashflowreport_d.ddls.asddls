@EndUserText.label: 'BC Lưu chuyển Tiền tệ - PP Gián Tiếp'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity ZI_FI_CASHFLOWREPORT_D
  as select from ZTB_CASHFLOW_CF
  association to parent ZI_FI_CASHFLOWREPORT_S as _KhaiBOMasterDataAll on $projection.SingletonID = _KhaiBOMasterDataAll.SingletonID
{
  key VERSION as Version,
  key ITEM as Item,
  BOLD as Bold,
  NEGATIVE as Negative,
  FSITEXTVN as Fsitextvn,
  FSITEXTEN as Fsitexten,
  FSNODE as Fsnode,
  FS_NOTE as FsNote,
  @Consumption.hidden: true
  1 as SingletonID,
  _KhaiBOMasterDataAll
  
}
