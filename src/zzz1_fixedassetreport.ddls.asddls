/********** GENERATED on 07/28/2022 at 00:20:59 by CB9980000000**************/
 @OData.entitySet.name: 'ZZ1_FixedAssetReport' 
 @OData.entityType.name: 'ZZ1_FixedAssetReportType' 
 define root abstract entity ZZZ1_FIXEDASSETREPORT { 
 key FixedAssetExternalID : abap.char( 17 ) ; 
 @Odata.property.valueControl: 'AssetClass_vc' 
 AssetClass : abap.char( 8 ) ; 
 AssetClass_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Odata.property.valueControl: 'AssetSerialNumber_vc' 
 AssetSerialNumber : abap.char( 18 ) ; 
 AssetSerialNumber_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Odata.property.valueControl: 'CompanyCodeName_vc' 
 CompanyCodeName : abap.char( 25 ) ; 
 CompanyCodeName_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Odata.property.valueControl: 'LastChangeDate_vc' 
 LastChangeDate : RAP_CP_ODATA_V2_EDM_DATETIME ; 
 LastChangeDate_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Odata.property.valueControl: 'LastChangedByUser_vc' 
 LastChangedByUser : abap.char( 12 ) ; 
 LastChangedByUser_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Odata.property.valueControl: 'FixedAssetDescription_vc' 
 FixedAssetDescription : abap.char( 50 ) ; 
 FixedAssetDescription_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Odata.property.valueControl: 'AssetAdditionalDescription_vc' 
 AssetAdditionalDescription : abap.char( 50 ) ; 
 AssetAdditionalDescription_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Odata.property.valueControl: 'AssetLocation_vc' 
 AssetLocation : abap.char( 10 ) ; 
 AssetLocation_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Odata.property.valueControl: 'Room_vc' 
 Room : abap.char( 8 ) ; 
 Room_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Odata.property.valueControl: 'Location_vc' 
 Location : abap.char( 10 ) ; 
 Location_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Odata.property.valueControl: 'Plant_vc' 
 Plant : abap.char( 4 ) ; 
 Plant_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Odata.property.valueControl: 'AddressID_vc' 
 AddressID : abap.char( 10 ) ; 
 AddressID_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Odata.property.valueControl: 'LocationName_vc' 
 LocationName : abap.char( 40 ) ; 
 LocationName_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Odata.property.valueControl: 'UserDescription_vc' 
 UserDescription : abap.char( 80 ) ; 
 UserDescription_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 ETAG__ETAG : abap.string( 0 ) ; 
 
 } 
