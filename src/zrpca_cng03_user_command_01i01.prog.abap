*----------------------------------------------------------------------
* Información General
*----------------------------------------------------------------------
* Identificador: 0001
* Programa     : ZRPCA_CNG03.
* Include      : ZRPCA_CNG03_V
* Autor Prog.  : Netw consulting.(Camilo Naranjo Gonzalez).
* Contacto:      camilong92@gmail.com
* Fecha Creac. : 11.05.2018.
*----------------------------------------------------------------------
* HISTORICO DE MODIFICACIONES
*----------------------------------------------------------------------
* Fecha:                | Fábrica:
*----------------------------------------------------------------------
* Modificación:
*----------------------------------------------------------------------
***INCLUDE ZRPCA_CNG03_USER_COMMAND_01I01.
*include PAI
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.
  CASE OK_CODE.
    WHEN 'BACK'.
       LEAVE TO SCREEN 0.
    WHEN 'CANCEL'.
       LEAVE  PROGRAM.
    WHEN 'EXIT'.
       EXIT.
   WHEN 'SAVE'.
     PERFORM INSERT_ALV.
  ENDCASE.
ENDMODULE.

FORM insert_alv .

ENDFORM.
