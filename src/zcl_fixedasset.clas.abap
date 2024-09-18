CLASS zcl_fixedasset DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS: get_html IMPORTING lv_xml TYPE string RETURNING VALUE(ui_html) TYPE string.

    DATA: lv_xml TYPE string.

    INTERFACES if_http_service_extension .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_FIXEDASSET IMPLEMENTATION.


  METHOD if_http_service_extension~handle_request.

    DATA(lt_param) = request->get_form_fields( ).
    READ TABLE lt_param REFERENCE INTO DATA(lr_asset_key) WITH KEY name = 'assetid'.

    IF sy-subrc = 0.

      lv_xml = NEW zcl_fixedasset_integration( )->fetch_data_from_backend( lr_asset_key->value ).
      response->set_text( get_html( lv_xml ) ).

    ELSE.
      response->set_status( i_code = 400 i_reason = 'Invalid Parameter Passed').
    ENDIF.

  ENDMETHOD.


  METHOD get_html.

    ui_html = '<!DOCTYPE html>' && |\n|  &&
              '<html lang="en-US">' && |\n|  &&
              |\n|  &&
              '<head>' && |\n|  &&
              '  <meta charset="UTF-8">' && |\n|  &&
              '  <meta name="viewport" content="width=device-width, initial-scale=1">' && |\n|  &&
              '  <title>PDF from BTP</title>' && |\n|  &&
              '</head>' && |\n|  &&
              |\n|  &&
              '<body>' && |\n|  &&
              |\n|  &&
              '  <script>' && |\n|  &&
              '    var encodedPdfContent =' && '''' && |{ lv_xml }| && '''' && ';' && |\n|  &&
              '    var decodedPdfContent = atob(encodedPdfContent);' && |\n|  &&
              '    var byteArray = new Uint8Array(decodedPdfContent.length);' && |\n|  &&
              '    for (var i = 0; i < decodedPdfContent.length; i++) {' && |\n|  &&
              '      byteArray[i] = decodedPdfContent.charCodeAt(i);' && |\n|  &&
              '    }' && |\n|  &&
              '    var blob = new Blob([byteArray.buffer], {' && |\n|  &&
              '      type: ''application/pdf''' && |\n|  &&
              '    });' && |\n|  &&
              '    var _pdfurl = URL.createObjectURL(blob);' && |\n|  &&
              '    window.open(_pdfurl, "_self");' && |\n|  &&
              '  </script>' && |\n|  &&
              |\n|  &&
              '</body>' && |\n|  &&
              |\n|  &&
              '</html>'.

  ENDMETHOD.
ENDCLASS.
