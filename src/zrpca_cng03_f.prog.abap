*----------------------------------------------------------------------
* Información General
*----------------------------------------------------------------------
* Identificador: 0001
* Programa     : ZRPCA_CNG03.
* Include      : ZRPCA_CNG03_F
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
* Include de subrutinas
*&---------------------------------------------------------------------*
*&      Form  SELECT_MARA
*&---------------------------------------------------------------------*
*      **Consulta para obtener datos de la tabla MARA
****-------------------------------------------------------------------*
FORM select_mara CHANGING p_ti_mara TYPE gtt_mara.
  SELECT
    matnr
    ersda
    ernam
    laeda
    aenam
    vpsta
   FROM mara  INTO TABLE p_ti_mara.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  SELECT_MAKT
*&---------------------------------------------------------------------*
**      Consulta para obtener datos de la tabla MAKT filtrnado por
**      el codigo del material
****-------------------------------------------------------------------*
FORM select_makt USING p_ti_mara TYPE gtt_mara CHANGING p_ti_makt TYPE gtt_makt.
  IF p_ti_mara IS NOT INITIAL.
    SELECT
      matnr
      maktx
      INTO TABLE p_ti_makt
      FROM makt
      FOR ALL ENTRIES IN p_ti_mara
      WHERE matnr EQ p_ti_mara-matnr.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SELECT_EKPO
*&---------------------------------------------------------------------*
*       Consulta para obtener datos de la tabla EKPO filtrando por
*        el codigo del material.
****-------------------------------------------------------------------*
FORM select_ekpo USING p_ti_makt TYPE gtt_makt CHANGING p_ti_ekpo TYPE gtt_ekpo.
  IF p_ti_makt IS NOT INITIAL.
    SELECT
     matnr
     ebeln
     brgew
     gewei
     netpr
    INTO TABLE p_ti_ekpo
    FROM ekpo FOR ALL ENTRIES IN p_ti_makt
    WHERE matnr EQ p_ti_makt-matnr.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  SELECT_EKKO
*&---------------------------------------------------------------------*
*       Consulta para obtener datos de la tabla EKKO filtrando por
*        el codigo del material.
****-------------------------------------------------------------------*
FORM select_ekko USING p_ti_ekpo TYPE gtt_ekpo CHANGING p_ti_ekko TYPE gtt_ekko.
  DATA: lti_ekpo_aux TYPE  gtt_ekpo.
  lti_ekpo_aux = p_ti_ekpo.
  SORT  p_ti_ekpo BY ebeln.
  DELETE ADJACENT DUPLICATES FROM lti_ekpo_aux COMPARING ebeln.
  IF p_ti_ekpo IS NOT INITIAL.
    SELECT
     ebeln
     waers
   INTO TABLE p_ti_ekko
   FROM ekko AS mr FOR ALL ENTRIES IN p_ti_ekpo
   WHERE ebeln EQ p_ti_ekpo-ebeln.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  START_OF_SELECTION
*&---------------------------------------------------------------------*
*       Inicio de subrutinas del programa Z.
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM start_of_selection .
  DATA: lti_mara    TYPE STANDARD TABLE OF gty_mara,
        lti_makt    TYPE STANDARD TABLE OF gty_makt,
        lti_ekpo    TYPE STANDARD TABLE OF gty_ekpo,
        lti_ekko    TYPE STANDARD TABLE OF gty_ekko,
        lti_catalog TYPE lvc_t_fcat.

  PERFORM select_mara CHANGING lti_mara.
  PERFORM select_makt USING lti_mara
                      CHANGING lti_makt.
  PERFORM select_ekpo USING lti_makt
                    CHANGING lti_ekpo.
  PERFORM select_ekko USING lti_ekpo
                  CHANGING lti_ekko.
  PERFORM set_gti_alv USING lti_mara
                            lti_makt
                            lti_ekpo
                            lti_ekko.
  PERFORM u_prepare_fieldcatalog CHANGING lti_catalog.

  PERFORM view_alv USING  lti_catalog.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  SET_GTI_ALV
*&---------------------------------------------------------------------*
*       Se unen las cuatro consultas de los forms anteriores para
*       mostrar la union en el alv.
*----------------------------------------------------------------------*
FORM set_gti_alv  USING    p_lti_mara TYPE gtt_mara
                           p_lti_makt TYPE gtt_makt
                           p_lti_ekpo TYPE gtt_ekpo
                           p_lti_ekko TYPE gtt_ekko.

  DATA: les_mara    TYPE gty_mara,
        les_makt    TYPE gty_makt,
        les_ekpo    TYPE gty_ekpo,
        les_ekko    TYPE gty_ekko,
        les_alv_aux TYPE gty_zmara_cng.

** Aputador de cada campo de la taba Mara
  FIELD-SYMBOLS: <lfs_mara> TYPE gty_mara.
  LOOP AT p_lti_mara ASSIGNING <lfs_mara>.
    CLEAR les_alv_aux.
    READ TABLE p_lti_makt INTO les_makt WITH KEY matnr = <lfs_mara>-matnr.
    IF sy-subrc EQ 0.
*      les_alv_aux-mandt = <lfs_mara>-mandt.
      les_alv_aux-matnr = <lfs_mara>-matnr.
      les_alv_aux-ersda = <lfs_mara>-ersda.
      les_alv_aux-ernam  = <lfs_mara>-ernam.
      les_alv_aux-laeda = <lfs_mara>-laeda.
      les_alv_aux-aenam = <lfs_mara>-aenam.
      les_alv_aux-vpsta = <lfs_mara>-vpsta.
      les_alv_aux-maktx = les_makt-maktx.
    ENDIF.

    READ TABLE p_lti_ekpo INTO les_ekpo WITH  KEY matnr = <lfs_mara>-matnr.
    IF sy-subrc EQ 0.
*      les_alv_aux-EBELN = les_ekpo-EBELN.
      les_alv_aux-brgew = les_ekpo-brgew.
      les_alv_aux-gewei = les_ekpo-gewei.
      les_alv_aux-netpr = les_ekpo-netpr.
      READ TABLE p_lti_ekko INTO les_ekko WITH  KEY ebeln = les_ekpo-ebeln.
      IF sy-subrc EQ 0.
        les_alv_aux-waers = les_ekko-waers.
      ENDIF.
    ENDIF.

    IF les_alv_aux IS NOT INITIAL.
      APPEND les_alv_aux TO gti_alv.
    ENDIF.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  u_prepare_fieldcatalog
*&---------------------------------------------------------------------*
*       Creacion de los catalogos de la ALV.
*----------------------------------------------------------------------*
FORM u_prepare_fieldcatalog CHANGING p_lti_catalog TYPE lvc_t_fcat.
** creacion de una estructura para el catalogo
  DATA: les_catalog TYPE lvc_s_fcat.
** Propiedades de  la columna check
  CLEAR les_catalog.
   les_catalog-fieldname = 'check'.
   les_catalog-tabname = 'gti_alv'.
   les_catalog-col_pos = 0.
   les_catalog-coltext = 'check'.
   les_catalog-checkbox = 'X'.
   les_catalog-edit = 'X'.
  APPEND les_catalog TO p_lti_catalog.
** Propiedades de  la columna catalogo MANDTR
  CLEAR les_catalog.
  les_catalog-fieldname = 'matnr'.
  les_catalog-tabname = 'gti_alv'.
  les_catalog-col_pos = 1.
  les_catalog-coltext = 'CODIGO MATERIAL'.
  les_catalog-col_opt = 'X'.
  APPEND les_catalog TO p_lti_catalog.
** Propiedades de  la columna catalogo MANDTX
  CLEAR les_catalog.
  les_catalog-fieldname = 'maktx'.
  les_catalog-tabname = 'gti_alv'.
  les_catalog-col_pos = 2.
  les_catalog-coltext = 'DESCRIPCION MATERIAL'.
  les_catalog-col_opt = 'X'.
  APPEND les_catalog TO p_lti_catalog.
** Propiedades de  la columna catalogo ERSDA
  CLEAR les_catalog.
  les_catalog-fieldname = 'ersda'.
  les_catalog-tabname = 'gti_alv'.
  les_catalog-col_pos = 3.
  les_catalog-coltext = 'FECHA CREACION'.
  les_catalog-col_opt = 'X'.
  APPEND les_catalog TO p_lti_catalog.

  CLEAR les_catalog.
  les_catalog-fieldname = 'ernam'.
  les_catalog-tabname = 'gti_alv'.
  les_catalog-col_pos = 4.
  les_catalog-coltext = 'ernam'.
  les_catalog-col_opt = 'X'.
  APPEND les_catalog TO p_lti_catalog.

  CLEAR les_catalog.
  les_catalog-fieldname = 'laeda'.
  les_catalog-tabname = 'gti_alv'.
  les_catalog-col_pos = 5.
  les_catalog-coltext = 'laeda'.
  les_catalog-col_opt = 'X'.
  APPEND les_catalog TO p_lti_catalog.

  CLEAR les_catalog.
  les_catalog-fieldname = 'aenam'.
  les_catalog-tabname = 'gti_alv'.
  les_catalog-col_pos = 6.
  les_catalog-coltext = 'aenam'.
  les_catalog-col_opt = 'X'.
  APPEND les_catalog TO p_lti_catalog.

  CLEAR les_catalog.
  les_catalog-fieldname = 'vpsta'.
  les_catalog-tabname = 'gti_alv'.
  les_catalog-col_pos = 7.
  les_catalog-coltext = 'vpsta'.
  APPEND les_catalog TO p_lti_catalog.

  CLEAR les_catalog.
  les_catalog-fieldname = 'BRGEW'.
  les_catalog-tabname = 'gti_alv'.
  les_catalog-col_pos = 8.
  les_catalog-coltext = 'BRGEW'.
  les_catalog-col_opt = 'X'.
  APPEND les_catalog TO p_lti_catalog.

  CLEAR les_catalog.
  les_catalog-fieldname = 'GEWEI'.
  les_catalog-tabname = 'gti_alv'.
  les_catalog-col_pos = 9.
  les_catalog-coltext = 'GEWEI'.
  les_catalog-col_opt = 'X'.
  les_catalog-edit = 'X'.
  APPEND les_catalog TO p_lti_catalog.

  CLEAR les_catalog.
  les_catalog-fieldname = 'NETPR'.
  les_catalog-tabname = 'gti_alv'.
  les_catalog-col_pos = 10.
  les_catalog-coltext = 'NETPR'.
  APPEND les_catalog TO p_lti_catalog.

  CLEAR les_catalog.
  les_catalog-fieldname = 'WAERS'.
  les_catalog-tabname = 'gti_alv'.
  les_catalog-col_pos = 11.
  les_catalog-coltext = 'WAERS'.
  les_catalog-col_opt = 'X'.
  APPEND les_catalog TO p_lti_catalog.

  CLEAR les_catalog.
  les_catalog-fieldname = 'ESTADO'.
  les_catalog-tabname = 'gti_alv'.
  les_catalog-col_pos = 12.
  les_catalog-coltext = 'ESTADO'.
  les_catalog-col_opt = 'X'.
  les_catalog-icon = 'X'.
  APPEND les_catalog TO p_lti_catalog.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  view_alv
*&---------------------------------------------------------------------*
*       Se crea objeto container
*----------------------------------------------------------------------*
FORM view_alv USING p_lti_catalog TYPE lvc_t_fcat.

 DATA:
*g_custom_container TYPE REF TO cl_gui_container,
    g_custom_container TYPE REF TO cl_gui_custom_container,
    gc_layout          TYPE lvc_s_layo.

  CREATE OBJECT g_custom_container EXPORTING container_name = 'CUST'.
  CREATE OBJECT go_alv EXPORTING i_parent = g_custom_container.
  CALL METHOD go_alv->set_table_for_first_display
    EXPORTING
*     i_buffer_active               =
*     i_bypassing_buffer            =
*     i_consistency_check           =
*     i_structure_name              =
*     is_variant                    =
*     i_save                        =
*     i_default                     = 'X'
      is_layout                     = gc_layout
*     is_print                      =
*     it_special_groups             =
*     it_toolbar_excluding          =
*     it_hyperlink                  =
*     it_alv_graphics               =
*     it_except_qinfo               =
*     ir_salv_adapter               =
    CHANGING
      it_outtab                     = gti_alv
      it_fieldcatalog               = p_lti_catalog
*     it_sort                       =
*     it_filter                     =
    EXCEPTIONS
      invalid_parameter_combination = 1
      program_error                 = 2
      too_many_lines                = 3
      OTHERS                        = 4.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.
** llamado a la pantalla de la dinpro 0100 la cual contiene el container
  CALL SCREEN 0100.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  INSERT_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
