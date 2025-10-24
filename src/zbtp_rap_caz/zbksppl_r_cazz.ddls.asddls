@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking supplement root entity'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #A,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZBKSPPL_R_CAZZ
  as select from zbksppl_caz_a

  association        to parent zbooking_r_caz as _Booking        on $projection.BookingUUID = _Booking.BookingUUID
  association [1..1] to ZTRAVEL_R_CAZ         as _Travel         on $projection.TravelUUID = _Travel.TravelUUID

  association [1..1] to /DMO/I_Supplement     as _Product        on $projection.SupplementID = _Product.SupplementID
  association [1..*] to /DMO/I_SupplementText as _SupplementText on $projection.SupplementID = _SupplementText.SupplementID

{
  key booksuppl_uuid        as BooksupplUUID,
      travel_uuid             as TravelUUID,
      booking_uuid           as BookingUUID,
      booking_supplement_id as BookingSupplementID,
      supplement_id         as SupplementID,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      price                 as Price,
      currency_code         as CurrencyCode,
      //Local Etag Field -> OData Etag
      @Semantics.systemDateTime.lastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,

      _Booking,
      _Travel,

      _Product,
      _SupplementText
}
