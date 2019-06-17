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
*Programa Include definción de variables.
*----------------------------------------------------------------------
* Definicion de tipos
*----------------------------------------------------------------------
TYPES:
**TIPO PARA LA ALV ZMARA_CNG
  BEGIN OF gty_zmara_cng,
    mandt TYPE sy-mandt,
    matnr TYPE mara-matnr,
    maktx TYPE makt-maktx,
    ersda TYPE mara-ersda,
    ernam TYPE mara-ernam,
    laeda TYPE mara-laeda,
    aenam TYPE mara-aenam,
    vpsta TYPE mara-vpsta,
    check TYPE c,
    estad TYPE char4,
    brgew TYPE ekpo-brgew,
    gewei TYPE ekpo-gewei,
    netpr TYPE ekpo-netpr,
    waers TYPE ekko-waers,
  END OF gty_zmara_cng,

**TIPO CAMPOS TABLA MARA
  BEGIN OF gty_mara,
    matnr TYPE mara-matnr,
    ersda TYPE mara-ersda,
    ernam TYPE mara-ernam,
    laeda TYPE mara-laeda,
    aenam TYPE mara-aenam,
    vpsta TYPE mara-vpsta,
  END OF gty_mara,

**TIPOS CAMPOS TABLA MAKT (MATERIALES)
  BEGIN OF gty_makt,
     MATNR TYPE MAKT-MATNR,
     maktx TYPE makt-maktx,
  END OF gty_makt,

** TIPOS CAMPOS TABLA EKPO (Posición del documento de compras)
 BEGIN OF gty_ekpo,
  MATNR TYPE MATNR,
  EBELN TYPE EKPO-EBELN,
  BRGEW  TYPE EKPO-BRGEW,
  GEWEI  TYPE EKPO-GEWEI,
  NETPR  TYPE EKPO-NETPR,
END OF gty_ekpo,

** TIPOS CAMPOS TABLA EKKO (Cabecera del documento de compras)
 BEGIN OF gty_ekko,
  EBELN  TYPE EKKO-EBELN,
  WAERS  TYPE EKKO-WAERS,
END OF gty_ekko.

**     TIPO TABLA ESTANDAR DEL TIPO MARA
TYPES: gtt_mara TYPE STANDARD TABLE OF gty_mara,
**     TIPO TABLA ESTANDAR DEL TIPO MAKT
       gtt_makt TYPE STANDARD TABLE OF gty_makt,
       gtt_ekpo TYPE STANDARD TABLE OF gty_ekpo,
       gtt_ekko TYPE STANDARD TABLE OF gty_ekko.
*Tipo tablas internas
TYPES: gtt_alv TYPE STANDARD TABLE OF gty_zmara_cng.
*----------------------------------------------------------------------
* Definición tablas internas
*----------------------------------------------------------------------
* tablas internas para gestionar datos de la tabla mara
DATA:
  gti_alv TYPE gtt_alv,
*  Reference to the instance of ALV Grid
  go_alv       TYPE REF TO cl_gui_alv_grid,

*  Reference to the custom container that we placed in the screen
  go_cust      TYPE REF TO cl_gui_custom_container,

* Work area for field catalog
  gs_fcat      TYPE lvc_s_fcat,
  OK_CODE TYPE SY-UCOMM.


*
*FORM prepare_fcat.
*
*  DEFINE add_fcat.
*    clear gs_fcat.
*    gs_fcat-col_pos = &1.
*    gs_fcat-fieldname = &2.
*    gs_fcat-coltext = &3.
*    gs_fcat-outputlen = &4.
*    append gs_fcat to gt_fcat.
*  END-OF-DEFINITION.
*
*  add_fcat:
*     1 'KUNNR' 'Customer No.' 15,
*     2 'LAND1' 'Country'      5,
*     3 'NAME1' 'Name'         30,
*     4 'ORT01' 'City'         20.
*
*ENDFORM.
