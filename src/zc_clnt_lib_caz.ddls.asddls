@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_ALLOWED
@EndUserText.label: 'Clientes libros'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #B,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZC_CLNT_LIB_CAZ
  as select from ztb_clnt_lib_caz
{
  key id_libro                     as IdLibro, //Pendiente terminar
      count( distinct id_cliente ) as Ventas
}
group by
  id_libro;
