CLASS lhc_BookingSupplement DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR BookingSupplement RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR BookingSupplement RESULT result.

    METHODS calculateTotalPrice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR BookingSupplement~calculateTotalPrice.

    METHODS setBookSupplNumber FOR DETERMINE ON MODIFY
      IMPORTING keys FOR BookingSupplement~setBookSupplNumber.

    METHODS validateCurrency FOR VALIDATE ON SAVE
      IMPORTING keys FOR BookingSupplement~validateCurrency.

    METHODS validatePrice FOR VALIDATE ON SAVE
      IMPORTING keys FOR BookingSupplement~validatePrice.

    METHODS validateSupplement FOR VALIDATE ON SAVE
      IMPORTING keys FOR BookingSupplement~validateSupplement.

ENDCLASS.

CLASS lhc_BookingSupplement IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD calculateTotalPrice.

    " We are in booking so I need parent's parent information first
    READ ENTITIES OF ztravel_r_caz IN LOCAL MODE
      ENTITY BookingSupplement BY \_Travel
      FIELDS ( TravelUUID )
      " Contiene la llave del draft y el UUID
      " Estoy mirando si es equivalente
      WITH CORRESPONDING #( keys )
     "WITH VALUE  #( FOR r_key IN keys ( %tky = r_key-%tky ) )
      RESULT DATA(travels).

    " Trigger parent internal action
    MODIFY ENTITIES OF ztravel_r_caz IN LOCAL MODE
        ENTITY Travel
        EXECUTE reCalcTotalPrice
        " Aquí ya tengo las llaves del padre
        FROM CORRESPONDING #( travels ).

  ENDMETHOD.

  METHOD setBookSupplNumber.
  ENDMETHOD.

  METHOD validateCurrency.
  ENDMETHOD.

  METHOD validatePrice.
  ENDMETHOD.

  METHOD validateSupplement.
  ENDMETHOD.

ENDCLASS.
