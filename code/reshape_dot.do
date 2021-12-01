*=================================================
*DOT 1965
*=================================================
cd "C:\Users\thecs\Dropbox (Boston University)\boston_university\8-Research Assistantship\scanning\release"

local dataset_list ged svp aptitudes interests physdem 

foreach file in `dataset_list' {
    use "data/`file'_release_v1.dta", clear
    
    ds job_title task_id occ_group worker_function requirement, not

    reshape wide `r(varlist)', i(job_title task_id) j(requirement)

    order job_title occ_group worker_function task_id, first

    tempfile `file'
    save ``file''
}


use "data/worker_function_release_v1.dta", clear
foreach dataset in  `dataset_list'  {
    merge 1:1  job_title task_id using ``dataset'', nogen
}

merge  1:1 job_title task_id using  "data/temp_release_v1.dta", nogen


save "data/merged_dataset_release_v1", replace