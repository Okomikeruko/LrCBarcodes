To Do

Develop Methods:

* File -> Plug-in Extras -> Run barcode detection
* File -> Plug-in Extras -> Metadata Propagation

---

## Run Barcode Detection

Permission

    The plug-in "NAME" is requesting permission to write to yoru catalog.
    This operation could take a long time.
    (Cancel) (Proceed)

See Manual p113

Task bar

    title = "Detecting barcodes from [X] photo(s)."
    Process
        Opened Catelog
        Processed [X] photo(s), [Y] barcodes detected.
    
    Assign metadata fields:
        Barcode Type
        Barcode Value

Complete dialog

    title = "Processed [X] photo(s), [Y] barcodes detected.
    (OK)

---

## Run Metadata Propagation

Dialog Box

    Source Field => Barcode Content
        * Barcode Type
        * Barcode Content
        ---
        * Title
        * Caption
        * Copy Name
        * Label
        --- 
        * Headline
        * Person Shown
    Destination Field => Copy Name
    Propagation Limits 
        [_] Limit photos per section [ num input ]
    Preview window
    Footer 
        [X] photo(s) with [Y] sections
        (Cancel) (OK)
    