return {
    LrSdkVersion = 5.0,
    LrToolkitIdentifier = 'com.adobe.lightroom.sdk.lrcbarcodes',
    LrPluginName = "LrC Barcodes",
    LrMetadataProvider = 'MetadataProvider.lua',
    LrMetadataTagsetFactory = 'MetadataTagsetFactory.lua',
    LrExportMenuItems = {
       {
            title = "Run Barcode Detection",
            file = "RunBarcodeDetection.lua"
        },
        {
            title = "Metadata Propagation",
            file = "MetadataPropagation.lua"
        }
    }
}