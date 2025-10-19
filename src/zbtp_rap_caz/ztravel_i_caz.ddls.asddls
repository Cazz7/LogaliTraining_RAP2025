@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Travel Interface Entity'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZTRAVEL_I_CAZ
  provider contract transactional_interface
  as projection on ZTRAVEL_R_CAZ
{
  key TravelUUID,
      TravelID,
      AgencyID,
      CustomerID,
      BeginDate,
      EndDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      BookingFee,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      TotalPrice,
      CurrencyCode,
      Description,
      OverallStatus,
      
      //Estos ya no son necesarios porque son manejados en la entidad raíz
      //@Semantics.user.createdBy: true
      //LocalCreatedBy,
      //@Semantics.systemDateTime.createdAt: true
      //LocalCreatedAt,
      //@Semantics.user.localInstanceLastChangedBy: true
      //LocalLastChangedBy,
      
      
      //Local Etag Field -> OData Etag
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      LocalLastChangedAt,
      //Total Etag Field ->
      @Semantics.systemDateTime.lastChangedAt: true
      LocalChangedAt,
      /* Associations */
      _Agency,
      _Booking : redirected to composition child ZBOOKING_I_CAZ,
      _Currency,
      _Customer,
      _OverallStatus
}
