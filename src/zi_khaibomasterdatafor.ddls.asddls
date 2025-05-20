@EndUserText.label: 'BC Lưu chuyển Tiền tệ - PP Gián Tiếp'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity ZI_KhaiBOMasterDataFor
  as select from ztb_cashflow_cf
  association to parent ZI_KhaiBOMasterDataFor_S as _KhaiBOMasterDataAll on $projection.SingletonID = _KhaiBOMasterDataAll.SingletonID
{
  key version as Version,
  key item as Item,
  bold as Bold,
  negative as Negative,
  fsitextvn as Fsitextvn,
  fsitexten as Fsitexten,
  fsnode as fsnode,
  fs_note as fsnote,
  @Consumption.hidden: true
  1 as SingletonID,
  _KhaiBOMasterDataAll
  
}
