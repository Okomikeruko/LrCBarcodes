-- Load Libraries
local LrApplication = import 'LrApplication'
local LrDialogs = import 'LrDialogs'
local LrFunctionContext = import 'LrFunctionContext'
local LrProgressScope = import "LrProgressScope"
local LrView = import 'LrView'

BarcodeDetection = {}

-- Request permission
function BarcodeDetection.requestPermission()
    LrFunctionContext.callWithContext("requestPermission", function( context )
        local f = LrView.osFactory()
        local c = f:column {
            f:static_text {
                title = "The plug-in LrC Barcodes is requesting permission to write to your catalog."
            },
            f:static_text {
                title = "This operation could take a long time."
            }
        }
        local result = LrDialogs.presentModalDialog {
            title = "Run Barcode Detection",
            contents = c,
            actionVerb = "Proceed"
        }
        if result == 'ok' then
            BarcodeDetection.detectBarcodes()
        end
    end)
end
-- Initialize Event
function BarcodeDetection.detectBarcodes()
    local progressScope = LrProgressScope({
        title = "Detecting Barcodes"
    })
    LrFunctionContext.postAsyncTaskWithContext( "detectBarcodes", function( context )
        progressScope:attachToFunctionContext( context )
        -- Get Collection
        local catalog = LrApplication.activeCatalog()
        local count, found, errorCount = 0, 0, 0
        local errors = {}
        local keyOne = "<symbol type='"
        local keyOneEnd = "' quality='"
        local keyTwo = "<data><!%[CDATA%["
        local keyTwoEnd = "%]%]></data>"
        catalog:withPrivateWriteAccessDo( function( )
            local photos = catalog:getAllPhotos()
            local max = TableLength(photos)
            -- Each Photo
            for _, photo in pairs(photos) do
                -- increment count of total images found
                count = count + 1
                -- Detect presense of barcode
                local path = photo:getRawMetadata("path")
                local handle = assert(io.popen(_PLUGIN.path .. "/bin/zbarimg --xml " .. path, 'r'))
                local result = handle:read("*all")
                handle:close()
                -- if results have type and value
                if result ~= "" then
                    local _, typeIndex  = string.find(result, keyOne)
                    local _, valueIndex = string.find(result, keyTwo)
                    if typeIndex ~= nil and valueIndex ~= nil then
                        -- collect barcode data
                        local typeIndexEnd, _ = string.find(result, keyOneEnd)
                        local valueIndexEnd, _ = string.find(result, keyTwoEnd)
                        local barcodeType  = string.sub(result,
                                                        typeIndex + 1,
                                                        typeIndexEnd - 1 )
                        local barcodeValue = string.sub(result,
                                                        valueIndex + 1,
                                                        valueIndexEnd - 1 )
                        -- assign type and value to photo's metadata
                        photo:setPropertyForPlugin( _PLUGIN, "barcodeType", barcodeType )
                        photo:setPropertyForPlugin( _PLUGIN, "barcodeValue", barcodeValue )
                    else
                        table.insert(errors, photo:getFormattedMetadata("fileName"))
                    end
                    -- increment count of found barcodes
                    found = found + 1
                end
                errorCount = TableLength(errors)
                -- update task bar
                progressScope:setPortionComplete( count, max )
                progressScope:setCaption(
                    "Processed " .. count .. " photo(s), " .. found .. " barcode(s) detected."
                )
           end
        end)
        local message = "Processed " .. count .. " photo(s), " .. found .. " barcode(s) detected."
        if errorCount ~= 0 then
            local fileNames = ""
            for _, fileName in pairs(errors) do
                fileNames = fileNames .. ", " .. fileName
            end
            -- Notify on completion.
            LrDialogs.message(
                "Barcode Detection Complete",
                message .. "\nThere were " .. errorCount .. "error(s) detected in the following files: \n" ..
                string.sub(fileNames, 2),
                "warning"
            )
        else
            -- Notify on completion.
            LrDialogs.message(
                "Barcode Detection Complete",
                message,
                "info"
            )
        end
        progressScope:done()
    end)

end

function TableLength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end

BarcodeDetection.requestPermission()