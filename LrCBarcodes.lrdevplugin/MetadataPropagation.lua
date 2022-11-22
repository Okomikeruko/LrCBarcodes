local LrApplication = import "LrApplication"
local LrBinding = import 'LrBinding'
local LrDialogs = import 'LrDialogs'
local LrFunctionContext = import 'LrFunctionContext'
local LrProgressScope = import "LrProgressScope"
local LrView = import 'LrView'

MetadataPropagation = {}
function MetadataPropagation.showCustomDialog()
    LrFunctionContext.callWithContext("showCustomDialog", function( context )
        local items = {
            { title = "Barcode Type",  value = "barcodeType"  },
            { title = 'Barcode Value', value = "barcodeValue" },
            { title = "Title",         value = "title"        },
            { title = "Caption",       value = "caption"      },
            { title = "Copy Name",     value = "copyName"     },
            { title = "Label",         value = "label"        },
            { title = "Headline",      value = "headline"     },
            { title = "Person Shown",  value = "personShown"  }
        }
        local props = LrBinding.makePropertyTable( context )
        props.sourceField = ""
        props.destinationField = ""
        props.limitSession = false
        props.limitCount = 10

        local f = LrView.osFactory()

        local c = f:column {
            bind_to_object = props,
            f:row {
                f:column {
                    f:static_text {
                        title = "Source Field",
                    },
                    f:popup_menu {
                        value = LrView.bind("sourceField"),
                        items = items
                    },
                },
                f:column {
                    f:static_text {
                        title = "Destination Field",
                    },
                    f:popup_menu {
                        value = LrView.bind("destinationField"),
                        items = items
                    }
                }
            },
            -- f:static_text {
            --     title = "Propagation Limits"
            -- },
            -- f:row {
            --     f:checkbox {
            --         title = "Limit photos per section",
            --         value = LrView.bind("limitSession")
            --     },
            --     f:edit_field {
            --         value = LrView.bind("limitCount"),
            --         enabled = LrView.bind("limitSession")
            --     }
            -- }
        }
        local result = LrDialogs.presentModalDialog {
            title = "Metadata Propagation",
            contents = c
        }

        if result == 'ok' then
            MetadataPropagation.processMetadata(props)
        end
    end)
end

function MetadataPropagation.processMetadata(props)
    local b = "barcode"
    local count, max = 0, 0
    local progressScope = LrProgressScope({
        title = 'Propagating Metadata'
    })
    LrFunctionContext.postAsyncTaskWithContext( "processMetadata", function( context )
        progressScope:attachToFunctionContext( context )
        local catalog = LrApplication.activeCatalog()
        catalog:withWriteAccessDo( "processMetadata", function( )
            local photos = catalog:getAllPhotos()
            max = TableLength(photos)
            local value = nil
            for _, photo in pairs(photos) do
                count = count + 1
                -- Get source field value if present
                local v = nil
                if string.sub(props.sourceField, 1, string.len(b)) == b then
                    v = photo:getPropertyForPlugin( _PLUGIN, props.sourceField, nil, true )
                else
                    v = photo:getFormattedMetadata( props.sourceField )
                end
                if v ~= nil then value = v end
                -- -- Set target destination field
                if value ~= nil then
                    if string.sub(props.destinationField, 1, string.len(b)) == b then
                        photo:setPropertyForPlugin( _PLUGIN, props.destinationField, value )
                    else
                        photo:setRawMetadata( props.destinationField, value )
                    end
                end
                progressScope:setPortionComplete( count, max )
            end -- end for loop
        end) -- end catalog gate
        progressScope:done()
        LrDialogs.message(
            "Metadata Propagation Complete",
            "Processed " .. count .. " of " .. max .. " photos",
            "info"
        )
    end) -- end async task
end

function TableLength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end

MetadataPropagation.showCustomDialog()