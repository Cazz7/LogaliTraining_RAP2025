@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking root entity'
@Metadata.ignorePropagatedAnnotations: true
define view entity zbooking_r_caz
  as select from zbooking_caz_a

  composition [0..*] of ZBKSPPL_R_CAZZ           as _BookingSupplement

  //must indicate who the father is
  association        to parent ZTRAVEL_R_CAZ            as _Travel on  $projection.TravelUUID = _Travel.TravelUUID

  // 1..1 porque si ya hay un registro de header debe existir necesariamente uno del hijo
  association [1..1] to /DMO/I_Customer          as _Customer      on  $projection.CustomerID = _Customer.CustomerID
  association [1..1] to /DMO/I_Carrier           as _Carrier       on  $projection.AirlineID = _Carrier.AirlineID
  association [1..1] to /DMO/I_Connection        as _Connection    on  $projection.AirlineID    = _Connection.AirlineID
                                                                   and $projection.ConnectionID = _Connection.ConnectionID
  association [1..1] to /DMO/I_Booking_Status_VH as _BookingStatus on  $projection.BookingStatus = _BookingStatus.BookingStatus
{
  key booking_uuid          as BookingUUID,
      parent_uuid           as TravelUUID,
      booking_id            as BookingID,
      booking_date          as BookingDate,
      customer_id           as CustomerID,
      carrier_id            as AirlineID,
      connection_id         as ConnectionID,
      flight_date           as FlightDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      flight_price          as FlightPrice,
      currency_code         as CurrencyCode,
      booking_status        as BookingStatus,
      //Local Etag Field -> OData Etag
      @Semantics.systemDateTime.lastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,

      _BookingSupplement,

      _Travel,

      _Customer,
      _Carrier,
      _Connection,
      _BookingStatus

}
