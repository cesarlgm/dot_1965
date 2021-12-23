*=============================================================================================================
*DOT 1965: RESHAPES LONG FORMAT FILES
*=============================================================================================================
* Author: César Garro-Marín
* e-mail: cesarlgm@bu.edu


*INSTRUCTIONS: please modify the working directory below to the container of the DOT 1965 repository
cd "C:\Users\thecs\Dropbox (Boston University)\boston_university\8-Research Assistantship\scanning\release"


*=====================================================================
*CREATION OF DATA/READY_TO_USE_FILES/DOT1965_WIDE_V1.DTA
*=====================================================================

*Reshapes the long format files into wide format
{
    local dataset_list ged svp aptitudes interests physdem 

    foreach file in `dataset_list' {
        use "data/long_format/`file'_long_v1.dta", clear
        
        ds job_title task_id occ_group worker_function requirement, not

        local `file'_list `r(varlist)'
        
        foreach variable in ``file'_list' {
            local `variable'_lbl: variable label `variable'
        }

        reshape wide `r(varlist)', i(job_title task_id) j(requirement)

        order job_title occ_group worker_function task_id, first


        tempfile `file'
        save ``file''
    }


    use "data/long_format/worker_function_long_v1.dta", clear
    foreach dataset in  `dataset_list'  {
        merge 1:1  job_title task_id using ``dataset'', nogen
    }

    merge  1:1 job_title task_id using  "data/long_format/temp_long_v1.dta", nogen

    foreach dataset in `dataset_list' { 
        foreach variable in ``dataset'_list' {
            foreach item of varlist `variable'* {
                label var `item' "``variable'_lbl'"
            }
        }
    }

    joinby job_title using "data/ready_to_use_files/cw_dot65_census1970"

    order job_title task_id occ1970, first
    
    order cw_weight, last

    save "data/ready_to_use_files/dot1965_wide_v1", replace
}

*=====================================================================
*CREATION OF DATA/READY_TO_USE_FILES/DOT1965_SUMMARY_V1.DTA
*=====================================================================

*Computes averages, min and max of skill requirements by job title 
{
    *Computing max min mean
    foreach dataset in `dataset_list' { 
        foreach variable in ``dataset'_list' {
            egen `variable'_mean=rowmean(`variable'*)
            label var `variable'_mean "``variable'_lbl' (mean)"
            egen `variable'_max=rowmax(`variable'*)
            label var `variable'_max "``variable'_lbl' (max)"
            egen `variable'_min=rowmax(`variable'*)
            label var `variable'_min "``variable'_lbl' (min)"
        }
    }

    keep job_title-task_id varch-sts ged_mean-see_min occ1970 cw_weight

    order job_title task_id occ1970, first

    order cw_weight, last

    save "data/ready_to_use_files/dot1965_summary_v1", replace
}