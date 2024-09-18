CLASS zcl_fixedasset_integration DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    METHODS:
        fetch_data_from_backend IMPORTING zfixedassetid TYPE string RETURNING VALUE(r_blob) TYPE string,
        create_xml_body IMPORTING odata_response TYPE zzz1_fixedassetreport RETURNING VALUE(r_xml) TYPE string.

    TYPES :
      BEGIN OF ads_struct,
        xdp_Template TYPE string,
        xml_Data     TYPE string,
        form_Type    TYPE string,
        form_Locale  TYPE string,
        tagged_Pdf   TYPE string,
        embed_Font   TYPE string,
      END OF ads_struct."

    CONSTANTS lc_ads_render TYPE string VALUE '/v1/adsRender/pdf'.
    CONSTANTS lc_storage_name TYPE string VALUE 'templateSource=storageName'.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_FIXEDASSET_INTEGRATION IMPLEMENTATION.


  METHOD fetch_data_from_backend.
    DATA:
      ls_entity_key    TYPE zzz1_fixedassetreport,
      ls_business_data TYPE zzz1_fixedassetreport,
      lo_http_client   TYPE REF TO if_web_http_client,
      lo_resource      TYPE REF TO /iwbep/if_cp_resource_entity,
      lo_client_proxy  TYPE REF TO /iwbep/if_cp_client_proxy,
      lo_request       TYPE REF TO /iwbep/if_cp_request_read,
      lo_response      TYPE REF TO /iwbep/if_cp_response_read.

    TRY.
        " Create http client
        " Details depend on your connection settings
        DATA(lo_destination) = cl_http_destination_provider=>create_by_comm_arrangement(
                                                     comm_scenario  = 'ZFIXEDASSET_BACKEND'
                                                     comm_system_id = 'S4H_CAL'
                                                     service_id     = 'ZFIXEDASSET_REST' ).
        lo_http_client = cl_web_http_client_manager=>create_by_http_destination( lo_destination ).


        lo_client_proxy = cl_web_odata_client_factory=>create_v2_remote_proxy(
          EXPORTING
            iv_service_definition_name = 'ZFIXEDASSET'
            io_http_client             = lo_http_client
            iv_relative_service_root   = 'sap/opu/odata/sap/ZZ1_FIXEDASSETREPORT_CDS' ).


        " Set entity key
        ls_entity_key = VALUE #(
                  fixedassetexternalid  = zfixedassetid  ).

        " Navigate to the resource
        lo_resource = lo_client_proxy->create_resource_for_entity_set( 'ZZ1_FIXEDASSETREPORT' )->navigate_with_key( ls_entity_key ).

        " Execute the request and retrieve the business data
        lo_response = lo_resource->create_request_for_read( )->execute( ).
        lo_response->get_business_data( IMPORTING es_business_data = ls_business_data ).

        r_blob = create_xml_body( ls_business_data ).


      CATCH /iwbep/cx_cp_remote INTO DATA(lx_remote).
        " Handle remote Exception
        " It contains details about the problems of your http(s) connection

      CATCH /iwbep/cx_gateway INTO DATA(lx_gateway).
        " Handle Exception

    ENDTRY.
  ENDMETHOD.


  METHOD create_xml_body.

    DATA: lxs_data_xml TYPE xstring,
          lxs_xdp      TYPE xstring,
          lxs_pdf      TYPE xstring,
          li_pages     TYPE int4,
          ls_trace     TYPE string,
          lv_date      TYPE d.

    CONVERT TIME STAMP odata_response-LastChangeDate TIME ZONE sy-zonlo INTO DATE lv_date.

    DATA(lv_xml_temp) = '<form1>' && |\n|  &&
                        '   <QRCodeBarcode1>' && |{ odata_response-Assetserialnumber }| && '</QRCodeBarcode1>' && |\n|  &&
                        '   <TextField1>' && |{ odata_response-Fixedassetexternalid }| && '</TextField1>' && |\n|  &&
                        '   <TextField2>' && |{ odata_response-CompanyCodeName }| && '</TextField2>' && |\n|  &&
                        '   <TextField3>' && |{ odata_response-UserDescription }| && '</TextField3>' && |\n|  &&
                        '   <DateField1>' && |{ lv_date }| && '</DateField1>' && |\n|  &&
                        '   <TextField4>' && |{ odata_response-FixedAssetDescription }| && '</TextField4>' && |\n|  &&
                        '   <TextField5>' && |{ odata_response-LocationName }| && '</TextField5>' && |\n|  &&
                        '   <TextField6>' && |{ odata_response-Room }| && '</TextField6>' && |\n|  &&
                        '   <TextField7></TextField7>' && |\n|  &&
                        '   <TextField8></TextField8>' && |\n|  &&
                        '</form1>'.

    DATA(lv_xml) = cl_web_http_utility=>encode_base64( lv_xml_temp ).

    DATA(ls_body) = VALUE ads_struct( xdp_Template = 'FixedAsset/FixedAsset_Move'
                                      xml_Data = lv_xml
                                      form_Type = 'print'
                                      form_Locale = 'en'
                                      tagged_Pdf = '0'
                                      embed_font = '0' ).

    DATA(lv_json) = /ui2/cl_json=>serialize( data = ls_body compress = abap_true pretty_name = /ui2/cl_json=>pretty_mode-camel_case ).

    TRY.
        "create http destination by url; API endpoint for API sandbox
        DATA(lo_http_destination) = cl_http_destination_provider=>create_by_cloud_destination(
                                      i_name                  = 'ADS_SRV'
                                      i_authn_mode            = if_a4c_cp_service=>service_specific
                                    ).
        "create HTTP client by destination
        DATA(lo_web_http_client) = cl_web_http_client_manager=>create_by_http_destination( lo_http_destination ) .

        "adding headers
        DATA(lo_web_http_request) = lo_web_http_client->get_http_request( ).
        lo_web_http_request->set_header_fields( VALUE #(
                                                        (  name = 'DataServiceVersion' value = '2.0' )
                                                        (  name = 'Accept' value = 'application/json' )
                                                        (  name = 'Content-Type' value = 'application/json' )
                                                        ) ).
        lo_web_http_request->set_query( query =  lc_storage_name ).
        lo_web_http_request->set_uri_path( i_uri_path = lc_ads_render ).

        lo_web_http_request->append_text(
          EXPORTING
            data   = lv_json
        ).

        "set request method and execute request
        DATA(lo_web_http_response) = lo_web_http_client->execute( if_web_http_client=>post ).
        DATA(lv_response) = lo_web_http_response->get_text( ).

        FIELD-SYMBOLS:
          <data>                TYPE data,
          <field>               TYPE any,
          <pdf_based64_encoded> TYPE any.

        "lv_json_response has the following structure `{"fileName":"PDFOut.pdf","fileContent":"JVB..."}

        DATA(lr_data) = /ui2/cl_json=>generate( json = lv_response ).

        IF lr_data IS BOUND.
          ASSIGN lr_data->* TO <data>.
          ASSIGN COMPONENT `fileContent` OF STRUCTURE <data> TO <field>.
          IF sy-subrc EQ 0.
            ASSIGN <field>->* TO <pdf_based64_encoded>.
            r_xml = <pdf_based64_encoded>.
          ENDIF.
        ENDIF.

      CATCH cx_root INTO DATA(lx_exception).

    ENDTRY.

  ENDMETHOD.
ENDCLASS.
