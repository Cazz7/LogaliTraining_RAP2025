CLASS lhc_Travel DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    CONSTANTS:
        BEGIN OF travel_status,
        open type c LENGTH 1 value 'O', " Open
        accepted type c LENGTH 1 VALUE 'A', " Accepted
        rejected type c LENGTH 1 VALUE 'X', " Rejected
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
  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD acceptTravel.

  " EML
  " Ya tengo la instancia, no es necesario leerla
  MODIFY ENTITIES OF ZTRAVEL_R_CAZ IN LOCAL MODE
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

  result = value #( for travel in travels ( %tky = travel-%tky
                                            %param = travel ) ).

  ENDMETHOD.

  METHOD deductDiscount.
  ENDMETHOD.

  METHOD reCalcTotalPrice.
  ENDMETHOD.

  METHOD rejectTravel.

  " EML
  " Ya tengo la instancia, no es necesario leerla
  MODIFY ENTITIES OF ZTRAVEL_R_CAZ IN LOCAL MODE
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

  result = value #( for travel in travels ( %tky = travel-%tky
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

  delete travels where OverallStatus IS NOT INITIAL.

  check travels is not initial.

  MODIFY ENTITIES OF ZTRAVEL_R_CAZ IN LOCAL MODE
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
