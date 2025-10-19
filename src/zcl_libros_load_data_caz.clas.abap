CLASS zcl_libros_load_data_caz DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_libros_load_data_caz IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    DATA: lt_acc_cate TYPE TABLE OF ztb_acc_cate_caz,
          lt_catego   TYPE TABLE OF ztb_catego_caz,
          lt_clientes TYPE TABLE OF ztb_clientes_caz,
          lt_clnt_lib TYPE TABLE OF ztb_clnt_lib_caz,
          lt_libros   TYPE TABLE OF ztb_libros_caz.


** Categoría de Acceso **
    lt_acc_cate = VALUE #(
        ( bi_categ = 'F' tipo_acceso = 'L'  )
        ( bi_categ = 'C' tipo_acceso = 'E'  )
        ( bi_categ = 'D' tipo_acceso = 'E'  )
        ( bi_categ = 'R' tipo_acceso = 'L'  )
        ( bi_categ = 'T' tipo_acceso = 'L'  )
        ( bi_categ = 'H' tipo_acceso = 'E'  )
        ( bi_categ = 'B' tipo_acceso = 'E'  )
        ( bi_categ = 'M' tipo_acceso = 'E'  )
        ( bi_categ = 'O' tipo_acceso = 'E'  )
     ).

** Categoría de Usuario **
    lt_catego = VALUE #(
        ( bi_categ = 'F' descripcion = 'Lectura' )
        ( bi_categ = 'C' descripcion = 'Escritura' )
        ( bi_categ = 'D' descripcion = 'Escritura' )
    ).

** Listado de clientes **
    lt_clientes = VALUE #(
        ( id_cliente = 'IDC123' tipo_acceso = 'L' nombre = 'Cristian' apellidos = 'Zapata' email = 'email1@gmail.com' url = '' )
        ( id_cliente = 'IDC444' tipo_acceso = 'L' nombre = 'Jose' apellidos = 'Ramírez' email = 'email2@gmail.com' url = '' )
        ( id_cliente = 'IDC001' tipo_acceso = 'L' nombre = 'Pepito' apellidos = 'Perez' email = 'email3@gmail.com' url = '' )
    ).

** Libros por usuario **
    lt_clnt_lib = VALUE #(
        ( id_cliente = 'IDC123' id_libro = 'IDL001' )
        ( id_cliente = 'IDC123' id_libro = 'IDL003' )
        ( id_cliente = 'IDC001' id_libro = 'IDL001' )
        ( id_cliente = 'IDC001' id_libro = 'IDL002' )
        ( id_cliente = 'IDC001' id_libro = 'IDL004' )
    ).


** Información de libros **
    lt_libros = VALUE #(
        ( id_libro = 'IDL001' bi_categ = 'F' titulo = 'Harry Potter y la piedra filosofal' autor = 'J.K. Rowling' editorial = 'Salamandra'
        idioma = 'S' paginas = 256 precio = '72000' moneda = 'COP' formato = 'F' url = '' )
        ( id_libro = 'IDL002' bi_categ = 'D' titulo = 'Hábitos atómicos' autor = 'James Clear' editorial = 'Booket'
        idioma = 'S' paginas = 328 precio = '38500' moneda = 'COP' formato = 'F' url = '' )
        ( id_libro = 'IDL003' bi_categ = 'F' titulo = 'Cien años de Soledad' autor = 'Gabriel García Marquez' editorial = 'Debolsillo'
        idioma = 'S' paginas = 496 precio = '48300' moneda = 'COP' formato = 'F' url = '' )
        ( id_libro = 'IDL004' bi_categ = 'B' titulo = 'Freddie Mercury. Una biografía' autor = 'Alfonso Casas' editorial = 'RANDOM COMICS'
        idioma = 'S' paginas = 144 precio = '59500' moneda = 'COP' formato = 'F' url = '' )
    ).

    DELETE FROM ztb_acc_cate_caz.
    INSERT ztb_acc_cate_caz FROM TABLE @lt_acc_cate.

    DELETE FROM ztb_catego_caz.
    INSERT ztb_catego_caz FROM TABLE @lt_catego.

    DELETE FROM ztb_clientes_caz.
    INSERT ztb_clientes_caz FROM TABLE @lt_clientes.

    DELETE FROM ztb_clnt_lib_caz.
    INSERT ztb_clnt_lib_caz FROM TABLE @lt_clnt_lib.

    DELETE FROM ztb_libros_caz.
    INSERT ztb_libros_caz FROM TABLE @lt_libros.

  ENDMETHOD.
ENDCLASS.
