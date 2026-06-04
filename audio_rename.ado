*! version 1.0.0  Rahul Paul  04jun2026
*! audiorename: Renames & copies audio files by respondent ID

program define audiorename
    version 15.0
    
    syntax , CSVpath(string) DESTfolder(string) DATEfolder(string) ///
        [ MEDIAdir(string) IDvar(string) AUDIOvar(string) DATEvar(string) ///
          CONsentvar(string) EXTension(string) ]
    
    // Set parameter defaults
    if "`idvar'" == ""      local idvar "main_id"
    if "`audiovar'" == ""   local audiovar "audio"
    if "`datevar'" == ""    local datevar "calc_date_el"
    if "`consentvar'" == "" local consentvar "consent_participation"
    if "`extension'" == ""  local extension "m4a"
    if "`mediadir'" == ""   local mediadir "."
    
    preserve
    
    // Clean and normalize directory trailing slashes
    local mediadir = subinstr("`mediadir'", "\", "/", .)
    local destfolder = subinstr("`destfolder'", "\", "/", .)
    if substr("`mediadir'", -1, 1) == "/" local mediadir = substr("`mediadir'", 1, length("`mediadir'")-1)
    if substr("`destfolder'", -1, 1) == "/" local destfolder = substr("`destfolder'", 1, length("`destfolder'")-1)
    
    // Setup destination folder
    local final_dest "`destfolder'/`datefolder'"
    cap mkdir "`final_dest'"
    display as text _n "Target destination is: " as result "`final_dest'"
    
    // Import Data
    import delimited "`csvpath'", bindquote(strict) clear
    confirm variable `idvar' `audiovar' `datevar' `consentvar'
    
    // Filter down to targeted tracker subset
    keep if `consentvar' == 1
    tempvar start_date
    gen `start_date' = lower(string(date(`datevar', "YMD"), "%tdDDmonCCYY"))
    keep if `start_date' == "`datefolder'"
    
    if _N == 0 {
        display as error "❌ No matching records found for date: `datefolder'"
        exit 198
    }
    
    duplicates drop `idvar', force
    
    // Construct uniform media paths and filename mappings
    tempvar clean_media new_name formatted_id
    gen `clean_media' = "`mediadir'/" + substr(`audiovar', strpos(`audiovar', "\") + 1, .)
    replace `clean_media' = "`mediadir'/" + substr(`audiovar', strpos(`audiovar', "/") + 1, .) ///
        if strpos(`audiovar', "\") == 0 & strpos(`audiovar', "/") > 0
    replace `clean_media' = "`mediadir'/" + `audiovar' ///
        if strpos(`audiovar', "\") == 0 & strpos(`audiovar', "/") == 0
        
    gen `new_name' = strtrim(string(`idvar', "%15.0f")) + ".`extension'"
    gen `formatted_id' = string(`idvar', "%15.0f")
    
    // Loop over files safely using native Stata copy engines
    local N = _N
    local success_count = 0
    local fail_count = 0
    
    display as text "Processing `N' audio files..."
    quietly {
        forvalues i = 1/`N' {
            local old = `clean_media'[`i']
            local new = `new_name'[`i']
            local id  = `formatted_id'[`i']
            
            if fileexists("`old'") {
                cap copy "`old'" "`final_dest'/`new'", replace
                if _rc == 0 local success_count = `success_count' + 1
                else        local fail_count = `fail_count' + 1
            }
            else {
                noisily display as error "⚠️ Audio file not found for ID `id': `old'"
                local fail_count = `fail_count' + 1
            }
        }
    }
    
    display as text "----------------------------------------"
    display as text "Audio Process Complete Summary:"
    display as result "  Successfully copied: `success_count' audio file(s)"
    if `fail_count' > 0 display as error "  Failed / Missing:    `fail_count' audio file(s)"
    display as text "----------------------------------------"
    
    restore
end