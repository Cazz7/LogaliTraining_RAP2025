CLASS lhc_Travel DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    CONSTANTS:
      BEGIN OF travel_status,
        open     TYPE c LENGTH 1 VALUE 'O', " Open
        accepted TYPE c LENGTH 1 VALUE 'A', " Accepted
        rejected TYPE c LENGTH 1 VALUE 'X', " Rejected
      END OF travel_status.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR Travel RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Travel RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR Travel RESULT result.

    METHODS acceptTravel FOR MODIFY
      IMPORTING keys FOR ACTION Travel~acceptTravel RESULT result.

    METHODS deductDiscount FOR MODIFY
      IMPORTING keys FOR ACTION Travel~deductDiscount RESULT result.

    METHODS reCalcTotalPrice FOR MODIFY
      IMPORTING keys FOR ACTION Travel~reCalcTotalPrice.

    METHODS rejectTravel FOR MODIFY
      IMPORTING keys FOR ACTION Travel~rejectTravel RESULT result.

    METHODS Resume FOR MODIFY
      IMPORTING keys FOR ACTION Travel~Resume.

    METHODS calculateTotalPrice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Travel~calculateTotalPrice.

    METHODS setStatusToOpen FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Travel~setStatusToOpen.

    METHODS setTravelNumber FOR DETERMINE ON SAVE
      IMPORTING keys FOR Travel~setTravelNumber.

    METHODS validateAgency FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateAgency.

    METHODS validateBookingFee FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateBookingFee.

    METHODS validateCurrency FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateCurrency.

    METHODS validateCustomer FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateCustomer.

    METHODS validateDates FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateDates.

ENDCLASS.

CLASS lhc_Travel IMPLEMENTATION.

  METHOD get_instance_features.

    READ ENTITIES OF ztravel_r_caz IN LOCAL MODE
        ENTITY Travel
        FIELDS ( OverallStatus )
        WITH CORRESPONDING #( keys )
        RESULT DATA(travels).

    result = VALUE #( FOR travel IN travels ( %tky = travel-%tky
    " Primero los features de los campos
    %field-BookingFee = COND #( WHEN travel-OverallStatus = travel_status-accepted
                                THEN if_abap_behv=>fc-f-read_only
                                ELSE if_abap_behv=>fc-f-unrestricted )
    " Ahora los features de los actions
    %action-acceptTravel = COND #( WHEN travel-OverallStatus = travel_status-accepted
                                THEN if_abap_behv=>fc-o-disabled
                                ELSE if_abap_behv=>fc-o-enabled )

    %action-rejectTravel = COND #( WHEN travel-OverallStatus = travel_status-rejected
                                THEN if_abap_behv=>fc-o-disabled
                                ELSE if_abap_behv=>fc-o-enabled )

    %action-deductDiscount = COND #( WHEN travel-OverallStatus = travel_status-accepted
                                THEN if_abap_behv=>fc-o-disabled
                                ELSE if_abap_behv=>fc-o-enabled )

    " También puedo deshabilitar una asociación
    %assoc-_Booking = COND #( WHEN travel-OverallStatus = travel_status-rejected
                                THEN if_abap_behv=>fc-o-disabled
                                ELSE if_abap_behv=>fc-o-enabled )
                                  ) ).

  ENDMETHOD.

  METHOD get_instance_authorizations.

    " Definimos autorizaciones a nivel de instancia y a nivel global
    DATA: update_requested TYPE abap_bool,
          update_granted   TYPE abap_bool,
          delete_requested TYPE abap_bool,
          delete_granted   TYPE abap_bool.

    " Leo primero la entidad para ver qué tiene o qué agencia tiene
    READ ENTITIES OF ztravel_r_caz IN LOCAL MODE
    ENTITY Travel
    FIELDS ( AgencyID )
    " Cuando leemos siempre será corresponding
    WITH CORRESPONDING #( keys )
    RESULT DATA(Travels).

    " A nivel de instancia el crear un registro es una actualización
    update_requested = COND #( WHEN requested_authorizations-%update = if_abap_behv=>mk-on
                                  OR requested_authorizations-%action-Edit = if_abap_behv=>mk-on
                                  THEN abap_true
                                  ELSE abap_false ).

    delete_requested = COND #( WHEN requested_authorizations-%delete = if_abap_behv=>mk-on
                                  THEN abap_true
                                  ELSE abap_false ).

    DATA(lv_technical_name) = cl_abap_context_info=>get_user_technical_name( ).

    LOOP AT travels INTO DATA(travel).

      " Update
      IF update_requested = abap_true.

        IF travel-agencyID NE '070014'.
          update_granted = abap_true.
        ELSE.
          update_granted = abap_false.
          APPEND VALUE #( %msg = NEW /dmo/cm_flight_messages( textid = /dmo/cm_flight_messages=>not_authorized_for_agencyid
                                                              agency_id = travel-AgencyID
                                                              severity = if_abap_behv_message=>severity-error  )
          ) TO reported-travel.
        ENDIF.

      ENDIF.

      " Delete
      IF delete_requested = abap_true.

        IF travel-agencyID NE '070014'.
          update_granted = abap_true.
        ELSE.
          delete_granted = abap_false.
          APPEND VALUE #( %msg = NEW /dmo/cm_flight_messages( textid = /dmo/cm_flight_messages=>not_authorized_for_agencyid
                                                              agency_id = travel-AgencyID
                                                              severity = if_abap_behv_message=>severity-error  )
          ) TO reported-travel.
        ENDIF.

      ENDIF.

      " Informar el resultado
      " Declaro las variables directamente en el append value
      APPEND VALUE #( LET upd_auth = COND #( WHEN update_granted EQ abap_true
                                             THEN if_abap_behv=>auth-allowed
                                             ELSE if_abap_behv=>auth-unauthorized )
                          del_auth = COND #( WHEN delete_granted EQ abap_true
                                             THEN if_abap_behv=>auth-allowed
                                             ELSE if_abap_behv=>auth-unauthorized )
                      IN
                      %tky = travel-%tky
                      %update = upd_auth
                      %action-edit = upd_auth
                      %delete = del_auth
       ) TO result.

    ENDLOOP.

  ENDMETHOD.

  METHOD get_global_authorizations.
    " https://community.sap.com/t5/technology-blog-posts-by-members/smooth-transition-to-abap-for-cloud-development-cheat-sheet/ba-p/13571567
    " Definimos autorizaciones a nivel de instancia y a nivel global
    " Aquí se podrían hacer authority checks por ejemplo
    DATA(lv_technical_name) = cl_abap_context_info=>get_user_technical_name( ).


    " Valido si me están solicitando la operación de creación
    " Create
    IF requested_authorizations-%create = if_abap_behv=>mk-on.

      " Esto suelta un error por defecto, pero es mejor practica indicar que error
      IF lv_technical_name = 'CB9980005564'.
        result-%create = if_abap_behv=>auth-allowed.
      ELSE.
        result-%create = if_abap_behv=>auth-unauthorized.

        APPEND VALUE #(
            %msg = NEW /dmo/cm_flight_messages(
                        textid = /dmo/cm_flight_messages=>not_authorized
                        severity = if_abap_behv_message=>severity-error  )
            %global = if_abap_behv=>mk-on
         ) TO reported-travel.
      ENDIF.

    ENDIF.

    " Update / Edit
    IF requested_authorizations-%update = if_abap_behv=>mk-on OR
        requested_authorizations-%action-Edit = if_abap_behv=>mk-on. " Porque el Accept Travel por ejemplo hace una edición

      " Esto suelta un error por defecto, pero es mejor practica indicar que error
      IF lv_technical_name = 'CB9980005564'.
        result-%update = if_abap_behv=>auth-allowed.
        result-%action-Edit = if_abap_behv=>auth-allowed.
      ELSE.
        result-%create = if_abap_behv=>auth-unauthorized.
        result-%action-Edit = if_abap_behv=>auth-unauthorized.

        APPEND VALUE #(
            %msg = NEW /dmo/cm_flight_messages(
                        textid = /dmo/cm_flight_messages=>not_authorized
                        severity = if_abap_behv_message=>severity-error  )
            %global = if_abap_behv=>mk-on
         ) TO reported-travel.

      ENDIF.

      " Delete
      IF requested_authorizations-%delete = if_abap_behv=>mk-on.

        " Esto suelta un error por defecto, pero es mejor practica indicar que error
        IF lv_technical_name = 'CB9980005564'.
          result-%delete = if_abap_behv=>auth-allowed.
        ELSE.
          result-%delete = if_abap_behv=>auth-unauthorized.

          APPEND VALUE #(
              %msg = NEW /dmo/cm_flight_messages(
                          textid = /dmo/cm_flight_messages=>not_authorized
                          severity = if_abap_behv_message=>severity-error  )
              %global = if_abap_behv=>mk-on
           ) TO reported-travel.
        ENDIF.

      ENDIF.

    ENDIF.

  ENDMETHOD.

  METHOD acceptTravel.

    " EML
    " Ya tengo la instancia, no es necesario leerla
    MODIFY ENTITIES OF ztravel_r_caz IN LOCAL MODE
    ENTITY Travel
    UPDATE
    FIELDS ( OverallStatus )
    WITH VALUE #( FOR key IN keys ( %tky = key-%tky
                                          OverallStatus = travel_status-accepted  ) ).

    READ ENTITIES OF ztravel_r_caz IN LOCAL MODE
    ENTITY Travel
    ALL FIELDS
    WITH CORRESPONDING #( keys )
    RESULT DATA(travels).

    result = VALUE #( FOR travel IN travels ( %tky = travel-%tky
                                              %param = travel ) ).

  ENDMETHOD.

  METHOD deductDiscount.

    " Se hace un loop para poder aplicar el descuento a varios
    DATA travels_for_update TYPE TABLE FOR UPDATE ztravel_R_caz.

    DATA(keys_discount) = keys.

    LOOP AT keys_discount ASSIGNING FIELD-SYMBOL(<key_discount>)
    WHERE %param-discount_percent IS INITIAL
    OR %param-discount_percent > 100
    OR %param-discount_percent <= 0.

      " Para reportar que hubo un fallo y cortar el hilo de ejecución se usa failed
      APPEND VALUE #( %tky = <key_discount>-%tky ) TO failed-travel.

      APPEND VALUE #( %tky = <key_discount>-%tky
      %msg = NEW /dmo/cm_flight_messages(
                  textid = /dmo/cm_flight_messages=>discount_invalid
                  severity = if_abap_behv_message=>severity-error  )
      " Now it is an element
      %element-BookingFee = if_abap_behv=>mk-on
      %op-%action-deductDiscount = if_abap_behv=>mk-on
   ) TO reported-travel.

    ENDLOOP.

    CHECK failed-travel IS INITIAL.

    READ ENTITIES OF ztravel_r_caz IN LOCAL MODE
    ENTITY Travel
    FIELDS ( BookingFee )
    WITH CORRESPONDING #( keys_discount )
    RESULT DATA(travels).

    DATA percentage TYPE decfloat16.

    LOOP AT travels ASSIGNING FIELD-SYMBOL(<travel>).

      DATA(discount_percent) = keys_discount[ KEY id %tky = <travel>-%tky ]-%param-discount_percent.
      percentage = discount_percent / 200.
      DATA(reduce_fee) = <travel>-BookingFee * ( 1 - percentage ).

      APPEND VALUE #( %tky = <travel>-%tky  bookingFee = reduce_fee ) TO travels_for_update.

    ENDLOOP.

    " Finalmente modifico la entidad
    MODIFY ENTITIES OF ztravel_r_caz IN LOCAL MODE
    ENTITY Travel
    UPDATE
    FIELDS ( BookingFee )
    WITH travels_for_update.

    " La vuelvo a leer y la retorno
    READ ENTITIES OF ztravel_r_caz IN LOCAL MODE
    ENTITY Travel
    ALL FIELDS
    WITH CORRESPONDING #( keys )
    RESULT DATA(travels_discount).

    result = VALUE #( FOR travel IN travels_discount ( %tky = travel-%tky
                                                        %param = travel ) ).

  ENDMETHOD.

  METHOD reCalcTotalPrice.

    TYPES: BEGIN OF ty_amount_per_curr,
             amount        TYPE /dmo/total_price,
             currency_code TYPE /dmo/currency_code,
           END OF ty_amount_per_curr.

    DATA: amount_per_curr TYPE STANDARD TABLE OF ty_amount_per_curr.

    " Read Travel
    READ ENTITIES OF ztravel_r_caz IN LOCAL MODE
    ENTITY Travel
    FIELDS ( BookingFee CurrencyCode )
    WITH CORRESPONDING #( keys )
    RESULT DATA(travels).

    DELETE travels WHERE CurrencyCode IS INITIAL.

    LOOP AT travels ASSIGNING FIELD-SYMBOL(<travel>).

      amount_per_curr = VALUE #( ( amount = <travel>-BookingFee
                                   currency_code = <travel>-CurrencyCode ) ).

      " Read Bookings through the association
      READ ENTITIES OF ztravel_r_caz IN LOCAL MODE
      ENTITY Travel BY \_Booking " Path expression
      " Qué campos pueden cambiar a través del booking?
      FIELDS ( FlightPrice CurrencyCode )
      WITH VALUE #( ( %tky = <travel>-%tky ) )
      RESULT DATA(bookings).

      " Ahora sumo lo de la entidad hija
      LOOP AT bookings INTO DATA(booking) WHERE CurrencyCode IS NOT INITIAL.

        COLLECT VALUE ty_amount_per_curr( amount = booking-FlightPrice
                                          currency_code = booking-CurrencyCode ) INTO amount_per_curr.

      ENDLOOP.

      " El booking supplement a pesar de ser el "nieto"
      " tiene una relación definida por el travelUUID
      " Entonces no es necesario hacer otro LOOP
      READ ENTITIES OF ztravel_r_caz IN LOCAL MODE
      ENTITY Booking BY \_BookingSupplement
      FIELDS ( Price CurrencyCode )
      WITH VALUE #( FOR r_booking IN bookings ( %tky = r_booking-%tky ) )
      RESULT DATA(bookingSuplement).


    ENDLOOP.


  ENDMETHOD.

  METHOD rejectTravel.

    " EML
    " Ya tengo la instancia, no es necesario leerla
    MODIFY ENTITIES OF ztravel_r_caz IN LOCAL MODE
    ENTITY Travel
    UPDATE
    FIELDS ( OverallStatus )
    WITH VALUE #( FOR key IN keys ( %tky = key-%tky
                                          OverallStatus = travel_status-rejected  ) ).

    READ ENTITIES OF ztravel_r_caz IN LOCAL MODE
    ENTITY Travel
    ALL FIELDS
    WITH CORRESPONDING #( keys )
    RESULT DATA(travels).

    result = VALUE #( FOR travel IN travels ( %tky = travel-%tky
                                              %param = travel ) ).

  ENDMETHOD.

  METHOD Resume.
  ENDMETHOD.

  METHOD calculateTotalPrice.

    " Hacer uso del internal action
    MODIFY ENTITIES OF ztravel_r_caz IN LOCAL MODE
    ENTITY Travel
    EXECUTE reCalcTotalPrice
    FROM CORRESPONDING #( keys ).

  ENDMETHOD.

  METHOD setStatusToOpen.

    " EML - Entity Manipulation Language
    READ ENTITIES OF ztravel_r_caz IN LOCAL MODE
    ENTITY Travel
    FIELDS ( OverallStatus )
    " Contiene la llave del draft y el UUID
    WITH CORRESPONDING #( keys )
    RESULT DATA(travels).

    DELETE travels WHERE OverallStatus IS NOT INITIAL.

    CHECK travels IS NOT INITIAL.

    MODIFY ENTITIES OF ztravel_r_caz IN LOCAL MODE
    ENTITY Travel
    UPDATE
    FIELDS ( OverallStatus )
    WITH VALUE #( FOR travel IN travels ( %tky = travel-%tky
                                          OverallStatus = travel_status-open  ) ).

  ENDMETHOD.

  METHOD setTravelNumber.

    READ ENTITIES OF ztravel_r_caz IN LOCAL MODE
    ENTITY Travel
    FIELDS ( TravelID )
    WITH CORRESPONDING #( keys )
    RESULT DATA(travels).

    DELETE travels WHERE TravelID IS NOT INITIAL.

    " Obtengo el último registro guardado
    SELECT SINGLE FROM ztravel_caz_a
    FIELDS MAX( travel_id )
    INTO @DATA(max_travel_id).

    " Desde el frontend pueden mandarme más de un registro
*  max_travel_id + 1
*  max_travel_id + 2
*  max_travel_id + 3
    MODIFY ENTITIES OF ztravel_r_caz IN LOCAL MODE
    ENTITY Travel
    UPDATE
    FIELDS ( TravelID )
    WITH VALUE #( FOR travel IN travels INDEX INTO i ( %tky = travel-%tky
                                                       TravelID = max_travel_id + i ) ).

  ENDMETHOD.

  METHOD validateAgency.
  ENDMETHOD.

  METHOD validateBookingFee.
  ENDMETHOD.

  METHOD validateCurrency.
  ENDMETHOD.

  METHOD validateCustomer.

    " Aunque ya existe la validación a nivel frontend también se debe hacer a nivel backend porque
    " se podría mandar un customer ID que no existe
    DATA customers TYPE SORTED TABLE OF /dmo/customer WITH UNIQUE KEY client customer_id.

    READ ENTITIES OF ztravel_r_CAZ IN LOCAL MODE
         ENTITY Travel
         FIELDS ( CustomerID )
         WITH CORRESPONDING #( keys )
         RESULT DATA(travels).

    " Se pueden descartar duplicados y EXCEPT * es para exceptuar el resto de los campos. No se si será necesario en este caso
    customers = CORRESPONDING #( travels DISCARDING DUPLICATES MAPPING customer_id = CustomerID EXCEPT * ).

    DELETE customers WHERE customer_id IS INITIAL.

    IF customers IS NOT INITIAL.

      " Inner join con tabla interna para validar con catálogo de cliente
      SELECT FROM /dmo/customer AS db
             INNER JOIN @customers AS it ON db~customer_id = it~customer_id
             FIELDS db~customer_id
             INTO TABLE @DATA(valid_customers).

    ENDIF.

    LOOP AT travels INTO DATA(travel).

      APPEND VALUE #( %tky        = travel-%tky
                      %state_area = 'VALIDATE_CUSTOMER' ) TO reported-travel.

      IF travel-CustomerID IS INITIAL.

        APPEND VALUE #( %tky = travel-%tky ) TO failed-travel.

        APPEND VALUE #( %tky = travel-%tky
                        %state_area = 'VALIDATE_CUSTOMER'
                        %msg = NEW /dmo/cm_flight_messages( textid   = /dmo/cm_flight_messages=>enter_customer_id
                                                            severity = if_abap_behv_message=>severity-error )
                        %element-CustomerId = if_abap_behv=>mk-on ) TO reported-travel.

      ELSEIF NOT line_exists( valid_customers[ customer_id = travel-CustomerID ] ).

        APPEND VALUE #( %tky = travel-%tky ) TO failed-travel.

        APPEND VALUE #( %tky = travel-%tky
                        %state_area = 'VALIDATE_CUSTOMER'
                        %msg = NEW /dmo/cm_flight_messages( textid      = /dmo/cm_flight_messages=>customer_unkown
                                                            customer_id = travel-CustomerID
                                                            severity    = if_abap_behv_message=>severity-error )
                        %element-CustomerId = if_abap_behv=>mk-on ) TO reported-travel.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD validateDates.
  ENDMETHOD.

ENDCLASS.
