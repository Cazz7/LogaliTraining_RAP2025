@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_ALLOWED
@EndUserText.label: 'CDS Categoría'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #B, // Características
    sizeCategory: #S, // Volumen de datos
    dataClass: #MASTER // Tipos de datos
}
define view entity ZC_CATEGO_CAZ
  as select from ztb_catego_caz
{
  key bi_categ    as Categoria,
      descripcion as Descripcion
}
