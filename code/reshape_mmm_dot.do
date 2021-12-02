*=============================================================================================================
*DOT 1965: CREATING WIDE FILE
*=============================================================================================================
cd "C:\Users\thecs\Dropbox (Boston University)\boston_university\8-Research Assistantship\scanning\release"

*Reshapes the dataset into wide format
{
    local dataset_list ged svp aptitudes interests physdem 

    foreach file in `dataset_list' {
        use "data/`file'_long_v1.dta", clear
        
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


    use "data/worker_function_long_v1.dta", clear
    foreach dataset in  `dataset_list'  {
        merge 1:1  job_title task_id using ``dataset'', nogen
    }

    merge  1:1 job_title task_id using  "data/temp_long_v1.dta", nogen

    foreach dataset in `dataset_list' { 
        foreach variable in ``dataset'_list' {
            foreach item of varlist `variable'* {
                label var `item' "``variable'_lbl'"
            }
        }
    }

    joinby job_title using "data/cw_dot65_census1970"

    save "data/dot1965_wide_long_v1", replace
}

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

    keep job_title-task_id varch-sts ged_mean-see_min

    joinby job_title using "data/cw_dot65_census1970"

    save "data/dot1965_summary_v1", replace
}