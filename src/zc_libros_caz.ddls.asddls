@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_ALLOWED
@EndUserText.label: 'CDS Libros'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #B,
    sizeCategory: #S,
    dataClass: #MIXED
}
@Metadata.allowExtensions: true
define view entity ZC_LIBROS_CAZ
  as select from    ztb_libros_caz  as Libros
    inner join      ztb_catego_caz  as Categ  on Libros.bi_categ = Categ.bi_categ
    left outer join ZC_CLNT_LIB_CAZ as Ventas on Libros.id_libro = Ventas.IdLibro

  //Association is technically an outer join that is not executed immediately
  association [0..*] to zc_clientes_Caz as _Clientes on $projection.IdLibro = _Clientes.IdLibro
{
  key Libros.id_libro   as IdLibro,
      Libros.titulo     as Titulo,
      Libros.bi_categ   as Categoria,
      Libros.autor      as Autor,
      Libros.editorial  as Editorial,
      Libros.idioma     as Idioma,
      Libros.paginas    as Paginas,
      @Semantics.amount.currencyCode: 'Moneda'
      Libros.precio     as Precio,
      Libros.moneda     as Moneda,

      // KPI
      case
        when Ventas.Ventas < 1 then 0
        when Ventas.Ventas = 1 then 1
        when Ventas.Ventas = 2 then 2
        when Ventas.Ventas > 2 then 3
        else 0
      end               as Ventas,
      Categ.descripcion as Descripcion,

      Libros.formato    as Formato,
      Libros.url        as Imagen,
      // It's a good practice to use this naming convention
      _Clientes // If I put it this way it is not published and it is not executed immediately
      //_Clientes.Email // If I put it this way it is a projection, it is not the best practice
}
