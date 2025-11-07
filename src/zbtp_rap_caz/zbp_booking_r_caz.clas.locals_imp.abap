CLASS lhc_Booking DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Booking RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR Booking RESULT result.

    METHODS calculateTotalPrice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Booking~calculateTotalPrice.

    METHODS setBookingDate FOR DETERMINE ON SAVE
      IMPORTING keys FOR Booking~setBookingDate.

    METHODS setBookingNumber FOR DETERMINE ON SAVE
      IMPORTING keys FOR Booking~setBookingNumber.

    METHODS validateConnection FOR VALIDATE ON SAVE
      IMPORTING keys FOR Booking~validateConnection.

    METHODS validateCurrency FOR VALIDATE ON SAVE
      IMPORTING keys FOR Booking~validateCurrency.

    METHODS validateCustomer FOR VALIDATE ON SAVE
      IMPORTING keys FOR Booking~validateCustomer.

    METHODS validateFlightPrice FOR VALIDATE ON SAVE
      IMPORTING keys FOR Booking~validateFlightPrice.

    METHODS validateStatus FOR VALIDATE ON SAVE
      IMPORTING keys FOR Booking~validateStatus.

ENDCLASS.

CLASS lhc_Booking IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD calculateTotalPrice.

    " We are in booking so I need parent information first
    READ ENTITIES OF ztravel_r_caz IN LOCAL MODE
      ENTITY Booking BY \_Travel
      FIELDS ( TravelUUID )
      " Contiene la llave del draft y el UUID
      " Estoy mirando si es equivalente
     " WITH CORRESPONDING #( keys )
      WITH VALUE  #( FOR r_key IN keys ( %tky = r_key-%tky ) )
      RESULT DATA(travels).

    " Trigger parent internal action
    MODIFY ENTITIES OF ztravel_r_caz IN LOCAL MODE
        ENTITY Travel
        EXECUTE reCalcTotalPrice
        " Aquí ya tengo las llaves del padre
        FROM CORRESPONDING #( travels ).

  ENDMETHOD.

  METHOD setBookingDate.
  ENDMETHOD.

  METHOD setBookingNumber.
  ENDMETHOD.

  METHOD validateConnection.
  ENDMETHOD.

  METHOD validateCurrency.
  ENDMETHOD.

  METHOD validateCustomer.
  ENDMETHOD.

  METHOD validateFlightPrice.
  ENDMETHOD.

  METHOD validateStatus.
  ENDMETHOD.

ENDCLASS.
