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
            %msg = new /dmo/cm_flight_messages(
                        textid = /dmo/cm_flight_messages=>not_authorized
                        severity = if_abap_behv_message=>severity-error  )
            %global = if_abap_behv=>mk-on
         ) to reported-travel.
      ENDIF.

    ENDIF.

    " Update / Edit
    if requested_authorizations-%update = if_abap_behv=>mk-on or
        requested_authorizations-%action-Edit = if_abap_behv=>mk-on. " Porque el Accept Travel por ejemplo hace una edición

        " Esto suelta un error por defecto, pero es mejor practica indicar que error
      IF lv_technical_name = 'CB9980005564'.
        result-%update = if_abap_behv=>auth-allowed.
        result-%action-Edit = if_abap_behv=>auth-allowed.
      ELSE.
        result-%create = if_abap_behv=>auth-unauthorized.
        result-%action-Edit = if_abap_behv=>auth-unauthorized.

        APPEND VALUE #(
            %msg = new /dmo/cm_flight_messages(
                        textid = /dmo/cm_flight_messages=>not_authorized
                        severity = if_abap_behv_message=>severity-error  )
            %global = if_abap_behv=>mk-on
         ) to reported-travel.

      ENDIF.

    " Delete
    IF requested_authorizations-%delete = if_abap_behv=>mk-on.

        " Esto suelta un error por defecto, pero es mejor practica indicar que error
      IF lv_technical_name = 'CB9980005564'.
        result-%delete = if_abap_behv=>auth-allowed.
      ELSE.
        result-%delete = if_abap_behv=>auth-unauthorized.

        APPEND VALUE #(
            %msg = new /dmo/cm_flight_messages(
                        textid = /dmo/cm_flight_messages=>not_authorized
                        severity = if_abap_behv_message=>severity-error  )
            %global = if_abap_behv=>mk-on
         ) to reported-travel.
      ENDIF.

    ENDIF.

    endif.

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
  ENDMETHOD.

  METHOD reCalcTotalPrice.
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
  ENDMETHOD.

  METHOD validateDates.
  ENDMETHOD.

ENDCLASS.
