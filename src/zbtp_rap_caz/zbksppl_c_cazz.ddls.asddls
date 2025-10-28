@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking Supplement Consumption Entity'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
@ObjectModel.semanticKey: [ 'BookingSupplementID' ]
define view entity ZBKSPPL_C_CAZZ as projection on ZBKSPPL_R_CAZZ 
{
  key BooksupplUUID,
      TravelUUID,
      BookingUUID,

      @Search.defaultSearchElement: true
      BookingSupplementID,

      @ObjectModel.text.element: [ 'SupplementDescription' ]
      @Consumption.valueHelpDefinition: [{ entity: { name: '/DMO/I_Supplement_StdVH',
                                                     element: 'SupplementID'},
                                           additionalBinding: [{ localElement: 'Price',
                                                                 element: 'Price',
                                                                 usage: #RESULT },
                                                               { localElement: 'CurrencyCode',
                                                                 element: 'CurrencyCode',
                                                                 usage: #RESULT }],
                                           useForValidation: true }]
      SupplementID,
      _SupplementText.Description as SupplementDescription : localized,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      Price,

      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_CurrencyStdVH',
                                                     element: 'Currency'},
                                           useForValidation: true }]
      CurrencyCode,

      LocalLastChangedAt,
    
    
    /* Associations */
    _Booking : redirected to parent ZBOOKING_C_CAZ,
    _Product,
    _SupplementText,
    _Travel : redirected to ZTRAVEL_C_CAZ
}
