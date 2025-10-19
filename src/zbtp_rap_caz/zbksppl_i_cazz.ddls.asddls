@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking Supplement interface Entity'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZBKSPPL_i_CAZZ
  as projection on ZBKSPPL_R_CAZZ
{
  key BooksupplUUID,
      TravelUUID,
      BookingUUID,
      BookingSupplementID,
      SupplementID,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      Price,
      CurrencyCode,
      //Local Etag Field -> OData Etag
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      LocalLastChangedAt,
      /* Associations */
      _Booking : redirected to parent ZBOOKING_I_CAZ,
      _Product,
      _SupplementText,
      _Travel : redirected to ZTRAVEL_I_CAZ
}
