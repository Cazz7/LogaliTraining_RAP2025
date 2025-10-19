@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Clientes'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #B,
    sizeCategory: #S,
    dataClass: #MASTER
}
@Metadata.allowExtensions: true
define view entity zc_clientes_Caz 
    as select from ztb_clientes_caz as Clientes
        inner join ztb_clnt_lib_caz as RelClLib on RelClLib.id_cliente = Clientes.id_cliente
{
    key RelClLib.id_libro as IdLibro,
    key Clientes.id_cliente as IdCliente,
    key Clientes.tipo_acceso as Acceso,
    Clientes.nombre as Nombre,
    Clientes.apellidos as Apellidos,
    Clientes.email as Email,
    Clientes.url as Imagen
}
