*****CREATION OF MASTER ELSA DATASET*****

cd "C:\Users\rmjldfa\OneDrive - University College London\3. Research\6. Datasets\ELSA"

use "wave_9_elsa_data_eul_v2.dta", clear
rename * w9*
rename w9idauniq idauniq
save "wave_9_elsa_data_eul_v2_merge.dta", replace

use "wave_10_elsa_data_eul_v4.dta", clear
rename * w10*
rename w10idauniq idauniq
save "wave_10_elsa_data_eul_v4_merge.dta", replace

use "wave_9_ifs_derived_variables_v2", clear
rename * w9*
rename w9idauniq idauniq
save "wave_9_ifs_derived_variables_v2_merge", replace

use "wave_10_ifs_derived_variables", clear
rename * w10*
rename w10idauniq idauniq
save "wave_10_ifs_derived_variables_merge", replace

use "ELSA waves 2-8 merged data, IFS and wealth", clear
merge 1:1 idauniq using "wave_9_elsa_data_eul_v2_merge"
drop _merge
merge 1:1 idauniq using "wave_10_elsa_data_eul_v4_merge"
drop _merge
merge 1:1 idauniq using "wave_9_ifs_derived_variables_v2_merge"
drop _merge
merge 1:1 idauniq using "wave_10_ifs_derived_variables_merge"
drop _merge

drop w2PersNo
drop w6HeADLda
drop w6Indobyr
drop w7HeADLda
drop w7Indobyr
rename *, lower

drop w2w2wgt
rename w2w2* w2*
drop w3w3lwgt
drop w3w3edqual
rename w3w3* w3*
rename w5w5* w5*
drop w6sic2003
drop w6w6lwgt
rename w6w6* w6*
drop w7w7lwgt
rename w7w7* w7*
rename w8w8* w8*
rename w9w9* w9*
rename w10w10* w10*

numlabel _all, add
save "ELSA merged data waves 2-10 fully harmonised_Oct24", replace