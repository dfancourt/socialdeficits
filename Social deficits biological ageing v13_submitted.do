//The association between social deficits and perceived and physiological ageing

//Author: Daisy Fancourt

//Dataset
cd "C:\Users\rmjldfa\OneDrive - University College London\3. Research\6. Datasets\ELSA"
use "ELSA merged data waves 2-10 fully harmonised_Oct24", clear

merge 1:1 idauniq using "wave_2_nurse_data_v2", keepus(bmiobe)
rename bmiobe w2bmi
drop _merge
merge 1:1 idauniq using "wave_4_nurse_data", keepus(bmiobe)
rename bmiobe w4bmi
drop _merge
merge 1:1 idauniq using "wave_6_elsa_nurse_data_v2", keepus(BMIOBE)
rename BMIOBE w6bmi
drop _merge

*******************************************************************************
***********************************SAMPLE SELECTION****************************
*******************************************************************************

count //19,605
*Included if completed w2self-completion
drop if w2outscw2!=1
count //8354
*Included if aged 50+
drop if w2age<50 
count //8,129
gen agecen2 = w2age-50	
gen agecen4	= w4age-50
gen agecen6 = w6age-50															
su agecen* //range 0-49

*******************************************************************************
***********************************SOCIAL PREDICTORS***************************
*******************************************************************************

///STRUCTURAL
//MARITAL STATUS
recode w2dimar 2=1 3=1 4/6=0 1=0 -8=0, gen(w2married)
 lab def yesno 0 "no" 1 "yes"
 lab var w2married "S: marital status"
 lab val w2married yesno
tab w2married

//SOCIAL NETWORK SIZE 
local network w2scfrdm w2scfamm w2scchdm
foreach V of local network {
	recode `V' (min/-1=.)
}

egen w2networksize=rowtotal(w2scfrdm w2scfamm w2scchdm)
tab w2networksize
*hist w2networksize
recode w2networksize 30/max=30, gen(w2networksizew) //winsorising at 30
*hist w2networksizew
  lab var w2networksizew "S: close social relationships"
  
  rename w2scfrdm w2networkfriends
  rename w2scfamm w2networkfamily
  rename w2scchdm w2networkchildren

//SOCIAL INTEGRATION - participation in a broad range of social relationships, including active engagement in a variety of social activities or relationships
local scorg w2scorg01-w2scorg08
foreach V of local scorg {
	recode `V' (min/-1=.)
}
egen w2groupn=rowtotal(w2scorg01-w2scorg08), mi
label var w2groupn "Number of group memberships"
tab w2groupn

local culture w2scacta w2scactc w2scactd 
foreach V of local culture {
	recode `V' (min/-1=.) (5/6=0) (1/4=1), gen(`V'b)
	}
	tab w2scactab

local volun w4erfvolmo w4erfvolle w4erfvolor w4erfvolvi w4erfvolbe w4erfvoled w4erfvolin w4erfvolse w4erfvoltr w4erfvolre w4erfvolca w4erfvolpr w4erfvol
foreach V of local volun {
	recode `V' (min/0=0), gen(`V'b)
}
egen w4volun=rowtotal(w4erfvolmob w4erfvolleb w4erfvolorb w4erfvolvib w4erfvolbeb w4erfvoledb w4erfvolinb w4erfvolseb w4erfvoltrb w4erfvolreb w4erfvolcab w4erfvolprb w4erfvolb)
tab w4volun

egen w2integration=rowtotal(w2groupn w2scactab w2scactcb w2scactdb w4volun)
tab w2integration	
  lab var w2integration "S: social integration"

//LIVING ALONE
recode w2hhtot 1=1 2/max=0, gen(w2livealone)
tab w2livealone
  lab var w2livealone "S: lives alone"

//SOCIAL ISOLATION
label def iso 0 "Weekly or more" 1 "Less than weekly"

local socialx scchdg scchdh scchdi scfamg scfamh scfami scfrdg scfrdh scfrdi
foreach V of local socialx {
  replace w2`V'=w3`V' if w2`V'==-9
}

local socialx scchdg scchdh scchdi scfamg scfami scfrdg scfrdh scfrdi
foreach V of local socialx {
  replace w2`V'=w4`V' if w2`V'==-9
}

local socialm w2scchdg w2scchdh w2scchdi w2scfamg w2scfamh w2scfami w2scfrdg w2scfrdh w2scfrdi
foreach V of local socialm {
  recode `V' (-9=.) (-1=.) (1=6) (2=5) (3=4) (4=3) (5=2) (6=1), gen(`V'i)
  label values `V'i iso
}
 tab1 w2scchdgi w2scchdhi w2scchdii w2scfamgi w2scfamhi w2scfamii w2scfrdgi w2scfrdhi w2scfrdii

egen w2isolatedmiss=rowmiss(w2scchdgi w2scfamgi w2scfrdgi w2scchdhi w2scfamhi w2scfrdhi)
egen w2isolated=rmean(w2scchdgi w2scfamgi w2scfrdgi w2scchdhi w2scfamhi w2scfrdhi) 
tab w2isolated
 lab var w2isolated "S: socially isolated"
 
 egen w2isolatedfriends=rmean(w2scchdgi w2scchdhi)
 egen w2isolatedfamily=rmean(w2scfamgi w2scfamhi)
 egen w2isolatedchildren=rmean(w2scfrdgi w2scfrdhi)
 
 recode w2isolatedfriends min/max=. if w2scfrd==2
 recode w2isolatedchildren min/max=. if w2scchd==2
 recode w2isolatedfamily min/max=. if w2scfam==2

////////////////////////FUNCTIONAL
//SOCIAL SUPPORT
//rely on you, let you down, open up if problem
//12 variables with 1-4 for each, 12-48 potential, with higher -> higher socsup
local socsupx scptrb scchdb scfamb scfrdb scptrc scchdc scfamc scfrdc 
foreach V of local socsupx {
  replace w2`V'=w3`V' if w2`V'==-9
}

local socsupx scptrb scchdb scfamb scfrdb scptrc scchdc scfamc scfrdc 
foreach V of local socsupx {
  replace w2`V'=w4`V' if w2`V'==-9
}

local socsup w2scptrb w2scchdb w2scfamb w2scfrdb w2scptrc w2scchdc w2scfamc w2scfrdc 
foreach V of local socsup {
	recode `V' -9=. -1=1 4=1 3=2 2=3 1=4, gen (`V'_)
}

local socsupr w2scptre w2scchde w2scfame w2scfrde
foreach V of local socsupr {
	recode `V' -9=. -1=4, gen (`V'_)
}

tab1 w2scptrb_ w2scchdb_ w2scfamb_ w2scfrdb_ w2scptrc_ w2scchdc_ w2scfamc_ w2scfrdc_ w2scptre_ w2scchde_ w2scfame_ w2scfrde_ 
egen w2socsupmiss=rowmiss(w2scptrb_ w2scchdb_ w2scfamb_ w2scfrdb_ w2scptrc_ w2scchdc_ w2scfamc_ w2scfrdc_ w2scptre_ w2scchde_ w2scfame_ w2scfrde_ )
egen w2socsup=rmean(w2scptrb_ w2scchdb_ w2scfamb_ w2scfrdb_ w2scptrc_ w2scchdc_ w2scfamc_ w2scfrdc_ w2scptre_ w2scchde_ w2scfame_ w2scfrde_ ) 
 lab var w2socsup "F: social support"
 tab w2socsup

egen w2socsupfamily=rmean(w2scfamb_ w2scfamc_ w2scfame_)
egen w2socsupfriends=rmean(w2scfrdb_ w2scfrdc_ w2scfrde_)
egen w2socsupchildren=rmean(w2scchdb_ w2scchdc_ w2scchde_)
egen w2socsupspouse=rmean(w2scptrb_ w2scptrc_ w2scptre_)

 recode w2socsupfriends min/max=. if w2scfrd==2
 recode w2socsupchildren min/max=. if w2scchd==2
 recode w2socsupfamily min/max=. if w2scfam==2
 recode w2socsupspouse min/max=. if w2married==0
 
//LONELINESS
local feelx scfeela scfeelb scfeelc
foreach V of local feelx {
  replace w2`V'=w3`V' if w2`V'==-9
}

recode w2scfeela min/-1=.
recode w2scfeelb min/-1=.
recode w2scfeelc min/-1=.
egen w2uclamiss=rowmiss(w2scfeela w2scfeelb w2scfeelc)
egen w2ucla=rowtotal(w2scfeela w2scfeelb w2scfeelc) if w2uclamiss==0
 lab var w2ucla "F: loneliness"

////////////////////////QUALITY
//MARITAL QUALITY
replace w2scptrg=w3scptrg if w2scptrg==-9
replace w2scptrg=w4scptrg if w2scptrg==-9

recode w2scptrg -9=. -1=0 3/4=1 1=3, gen(w2maritalq)
 lab def close3 0 "Not married" 1 "Not at all/very close" 2 "Quite close" 3 "Very close"
 lab val w2maritalq close3
 lab var w2maritalq "Q: marital quality"
 tab w2maritalq

//RELATIONSHIP STRAIN - maybe split into positive and negative relationships
//criticse you, get on your nerves, (not) understand you
//12 variables with 1-4 for each, 12-48 potential, with higher -> higher socstrain

local socstrx scptrf scchdf scfamf scfrdf scptrd scchdd scfamd scfrdd scptra scchda scfama scfrda
foreach V of local socstrx {
  replace w2`V'=w3`V' if w2`V'==-9
}

local socstrx scptrf scchdf scfamf scfrdf scptrd scchdd scfamd scfrdd scptra scchda scfama scfrda
foreach V of local socstrx {
  replace w2`V'=w4`V' if w2`V'==-9
}

local socstr w2scptrf w2scchdf w2scfamf w2scfrdf w2scptrd w2scchdd w2scfamd w2scfrdd
foreach V of local socstr {
	recode `V' -9=. -1=1 4=1 3=2 2=3 1=4, gen (`V'_)
}

local socstrr w2scptra w2scchda w2scfama w2scfrda
foreach V of local socstrr {
	recode `V' -9=. -1=4, gen (`V'_)
}

tab1 w2scptrf_ w2scchdf_ w2scfamf_ w2scfrdf_ w2scptrd_ w2scchdd_ w2scfamd_ w2scfrdd_ w2scptra_ w2scchda_ w2scfama_ w2scfrda_ 
egen w2socstrmiss=rowmiss(w2scptrf_ w2scchdf_ w2scfamf_ w2scfrdf_ w2scptrd_ w2scchdd_ w2scfamd_ w2scfrdd_ w2scptra_ w2scchda_ w2scfama_ w2scfrda_ )
egen w2socstr=rmean(w2scptrf_ w2scchdf_ w2scfamf_ w2scfrdf_ w2scptrd_ w2scchdd_ w2scfamd_ w2scfrdd_ w2scptra_ w2scchda_ w2scfama_ w2scfrda_ ) 
 lab var w2socstr "Q: social strain"
 tab w2socstr

egen w2socstrfamily=rmean(w2scfamf_ w2scfamd_ w2scfama_)
egen w2socstrfriends=rmean(w2scfrdf_ w2scfrdd_ w2scfrda_)
egen w2socstrchildren=rmean(w2scchdf_ w2scchdd_ w2scchda_)
egen w2socstrspouse=rmean(w2scptrf_ w2scptrd_ w2scptra_)

 recode w2socstrfriends min/max=. if w2scfrd==2
 recode w2socstrchildren min/max=. if w2scchd==2
 recode w2socstrfamily min/max=. if w2scfam==2
 recode w2socstrspouse min/max=. if w2married==0

*******************************************************************************
***********************************COVARIATES - BASELINE*********************************
*******************************************************************************

*****************AGE
recode w2age (50/54=1 "50-54") (55/59=2 "55-59") (60/64=3 "60-64") (65/69=4 "65-69") (70/74=5 "70-74") (75/max=6 "75 or above"), into (w2agecat)

*****************ETHNICITY
replace w2fqethnr=w3fqethnr if w2fqethnr<0
replace w2fqethnr=w4fqethnr if w2fqethnr<0

recode w2fqethnr (-9/-1=.) (1=0) (2=1), gen(w2ethnicity)

label define label4 0 "White" 1 "Not White"
label values w2ethnicity label4
lab var w2ethnicity "Ethnicity"

*****************GENDER
codebook w2sex
recode w2sex 1=0 2=1
  label var w2sex "Sex"
  label def sex1 0 "Male" 1 "Female"
  label values w2sex sex1

*****************WEALTH
replace w2nettotw_bu_s=w3nettotw_bu_s if w2nettotw_bu_s==.
replace w2nettotw_bu_s=w4nettotw_bu_s if w2nettotw_bu_s==.

xtile w2wealth = w2nettotw_bu_s, n(5)

tab1 w2wealth		
  label var w2wealth "Net non-pension wealth (quintiles)"
  label def wealth 1 "1 - lowest wealth quintile" 5 "5 - highest wealth quintile"
  label val w2wealth wealth

*****************EDUCATION
replace w2edqual=w3edqual if w2edqual<0
replace w2edqual=w4edqual if w2edqual<0

codebook w2edqual
tab1 w2edqual
recode w2edqual (min/-1=.) (3=2) (4=3) (5=3) (6=2) (7=3), gen(w2educ)
tab1 w2educ
  label var w2educ "Educational attainment"
  label define w2educ 1 "Degree" 2 "nvq3 A level/higher education" 3 "nvq2/gce o level" 
  label values w2educ w2educ	
  tab w2educ

*****************EMPOLYMENT STATUS
replace w2worktime=w3worktime if w2worktime==.8
replace w2worktime=w4worktime if w2worktime==.8

codebook w2worktime
recode w2worktime -8=. -1=0 2=1, gen(w2working)
codebook w2working 	
  label var w2working "Working status"
  label def work 0 "Not working" 1 "Working full/part-time"
  label val w2working work
  tab w2working

*****************HOUSING TENURE
replace w2hotenu=w3hotenu if w2hotenu<0
replace w2hotenu=w4hotenu if w2hotenu<0

rename w2tenure w2tenureo
gen w2tenure=.
replace w2tenure=0 if w2hotenu==2 | w2hotenu==3 | w2hotenu==4 | w2hotenu==5 | w2hotenu==-7
replace w2tenure=1 if w2hotenu==1

label define home 0 "Other" 1 "Outright homeowner"
label values w2tenure home
lab var w2tenure "Housing tenure"
tab w2tenure

*****************PHYSICAL HEALTH
recode w2hedib01 -8=0 1/9=1 96=0, gen(w2chronic)
tab w2chronic

label values w2chronic yesno
tab w2chronic
lab var w2chronic "No. of chronic conditions"

*****************ADL's
//headldr 	adl: difficulty dressing, including putting on shoes and socks 
//headlwa 	adl: difficulty walking across a room	 
//headlba 	adl: difficulty bathing or showering 
//headlea 	adl: difficulty eating, such as cutting up food 
//headlbe 	adl: difficulty getting in and out of bed 
//headlwc 	adl: difficulty using the toilet, including getting up or down 

local headl headldr headlwa headlba headlea headlbe headlwc
foreach V of local headl {
  replace w2`V'=w3`V' if w2`V'==-9
}

gen w2adl=w2headldr+w2headlwa+w2headlba+w2headlea+w2headlbe+w2headlwc
lab var w2adl "No. of ADL limitations"

*****************DEPRESSIVE SYMPTOMS
replace w2cesd_sc=w3cesd_sc if w2cesd_sc<0
replace w2cesd_sc=w4cesd_sc if w2cesd_sc<0

recode w2cesd_sc -2=., gen(w2depressive)
recode w2depressive 0/2=0 3/max=1, gen(w2depression)
 label var w2depression "Depression (CESD>=3)"
 label val w2depression yesno
 tab w2depression

*****************SELF REPORTED HEALTH
replace w2srh_hrs=w4srh_hrs if w2srh_hrs<0

recode w2srh_hrs (-9=.) (-8=.) (-2=.) (-1=.) (1=5) (2=4) (4=2) (5=1), gen(w2health)

label define label11 5 "Excellent" 4 "Very good" 3 "Good" 2 "Fair" 1 "Poor"
label values w2health label11
lab var w2health "Self-reported health"
tab w2health

*****************PHYSICAL ACTIVITY
//HeActa 		Frequency does vigorous sports or activities 
//HeActb 		Frequency does moderate sports or activities 
//HeActc 	    Frequency does mild sports or activities 

recode w2heactc w2heactb w2heacta (min/-1=.)
replace w2heactc=w3heactc if w2heactc==.
replace w2heactb=w3heactb if w2heactb==.
replace w2heacta=w3heacta if w2heacta==.

gen sedentaryc=w2heactc 
gen sedentaryb=w2heactb 
gen sedentarya=w2heacta 
recode sedentaryc 3/4=0 min/0=0 2=1, gen(sedentaryc2)
recode sedentaryb 3/4=0 min/0=0 2=1, gen(sedentaryb2)
recode sedentarya 3/4=0 min/0=0 2=1, gen(sedentarya2)
gen w2sedentary=0
replace w2sedentary=1 if sedentarya2==0 & sedentaryb2==0 & sedentaryc2==0
tab w2sedentary
 label var w2sedentary "Physically inactive"
 label val w2sedentary yesno
 tab w2sedentary

******************ALCOHOL
replace w2scal7b=w3scal7b if w2scal7b==-9
replace w2scal7b=w4scal7b if w2scal7b==-9

recode w2scal7b -9=. -1=0 1=3 2=3 3=2 4=1 5/max=0, gen(w2alcohol)
 label def alc 0 "less than once a week" 1 "once or twice a week" 2 "3 or 4 times a week" 3 "5 or more times a week"
 label val w2alcohol alc 
 recode w2alcohol 1/2=0 3=1, gen(w2alcohol2)
 label def alc2 0 "<5 times a week" 1 "5+ times a week" 
 label val w2alcohol2 alc2
 tab w2alcohol2
 label var w2alcohol2 "Alcohol consumption"

*****************SMOKING
//smoker
//HeSkb 
//HeSkc 
replace w2smoker=1 if w2smoker<0 & w3smoker==1
replace w2smoker=0 if w2smoker<0 & w3smoker==0
tab w2smoker
 label var w2smoker "Current smoker"
 label val w2smoker yesno
 tab w2smoker
 
******************BMI
recode w2bmi w4bmi w6bmi (-1=.)
replace w2bmi=w4bmi if w2bmi==.
replace w2bmi=w6bmi if w2bmi==.
tab w2bmi 														//has 1,028 missing if just w4
mdesc w2bmi														//908 missing if w6 too
recode w2bmi 2=1 3=2 4/6=3
 lab def bmi1 1 "BMI<25" 2 "BMI 25-30" 3 "BMI>=30"
 lab val w2bmi bmi1
 lab var w2bmi "BMI"
 tab w2bmi
 
******************PERCEIVED AGE
recode w2scold min/0=., gen(page2)
recode w4psagf min/0=., gen(page4)
recode w6psagf min/0=., gen(page6)

*******************************************************************************
*****************************RESHAPE DATASET*************************
*******************************************************************************
global social "w2married w2networksizew w2integration w2livealone w2isolated w2socsup w2ucla w2maritalq w2socstr"
global covariates "w2age w2agecat w2ethnicity w2sex w2wealth w2educ w2working w2tenure w2chronic w2adl w2depression w2health w2sedentary w2alcohol2 w2smoker w2bmi"
mdesc $social $covariates agecen2 agecen4 agecen6 page2 page4 page6

//xtset idauniq wave_num


merge 1:1 idauniq using "ba_v4_wide"
count //11,573
save "social biological age paper core dataset v03", replace

*******************************************************************************
*****************************RUN ANALYSES*************************
*******************************************************************************
cd "C:\Users\rmjldfa\OneDrive - University College London\3. Research\6. Datasets\ELSA"
use "social biological age paper core dataset v03", clear

global social "w2married w2networksizew w2integration w2livealone w2isolated w2socsup w2ucla w2maritalq w2socstr"
global covariates "w2age w2agecat w2ethnicity w2sex w2wealth w2educ w2working w2tenure w2chronic w2adl w2depression w2health w2sedentary w2alcohol2 w2smoker w2bmi"

**************************EXPOSURES
mark nomiss
markout nomiss $social $covariates
tab nomiss
drop if nomiss==0 //7,269 have all variables
count //7,047 have covariates if including BMI

*******************************************************************************
***********************************OUTCOMES*********************************
*******************************************************************************
recode w2age 99=90
recode w4age 99=90

****************PHYSIOLOGICAL AGE
gen baca2=ba2-w2age
gen baca4=ba4-w4age
gen baca6=ba6-w6age

****************PERCIVED AGE
gen paca2=page2-w2age
gen paca4=page4-w4age
gen paca6=page6-w6age

label var paca2 "Perceived age acceleration"
label var baca2 "Physiological age acceleration"
label var ba2 "Physiological age"
label var page2 "Perceived age"

recode baca2 min/0=0 0.00001/max=1, gen(baca2_above)
recode paca2 min/0=0 0.00001/max=1, gen(paca2_above)
tab1 baca2_above paca2_above

*RECODING
global socialbinneg "w2isolated w2ucla w2socstr"

foreach V of global socialbinneg {
  xtile `V'_4=`V', n(4)
  recode `V'_4 1/3=0 4=1, gen(`V'_4b)
  recode `V'_4 1=1 2/4=0, gen(`V'_4b_pos)
}

global socialbinpos "w2networksizew w2integration w2socsup" 

foreach V of global socialbinpos {
  xtile `V'_4=`V', n(4)
  recode `V'_4 1/3=0 4=1, gen(`V'_4b_pos)
  recode `V'_4 1=1 2/4=0, gen(`V'_4b)
}

recode w2livealone 0=1 1=0, gen(w2livealone_pos)

recode w2agecat 2=1 3/4=2 5/6=3
 lab def agecat 1 "50-59" 2 "60-69" 3 "70+"
 lab val w2agecat agecat
 tab w2agecat

recode w2adl 2/max=2
 lab def adl2 2 "2+" 
 lab val w2adl adl2
 tab w2adl
 
lab var w2age "Chronological age (years)"
lab var page2 "Perceived age (years)"
lab var ba2 "Physiological age (years)"
 
*SET MODELS
global socialteff "w2livealone w2networksizew_4b w2integration_4b w2isolated_4b w2socsup_4b w2ucla_4b w2socstr_4b"
global socialteff_pos "w2livealone_pos w2networksizew_4b_pos w2integration_4b_pos w2isolated_4b_pos w2socsup_4b_pos w2ucla_4b_pos w2socstr_4b_pos"

global modelexp "w2ethnicity i.w2sex w2wealth w2educ i.w2working i.w2tenure i.w2sedentary i.w2alcohol2 i.w2smoker i.w2chronic w2adl w2health"
global modelout "w2ethnicity i.w2sex w2wealth w2educ i.w2working i.w2tenure i.w2sedentary i.w2alcohol2 i.w2smoker i.w2chronic w2bmi w2depression"

*******************************************************************************
***********************************DESCRIPTIVES*************************
*******************************************************************************
mark nomissbaca
mark nomisspaca
markout nomissbaca baca2 
markout nomisspaca paca2
tab nomissbaca nomisspaca
count 

global dems_cont "w2age page2 ba2"
global dems_binary "i.w2sex i.w2ethnicity i.w2working i.w2tenure i.w2sedentary i.w2alcohol2 i.w2smoker i.w2chronic i.w2depression"
global dems_cat "i.w2wealth i.w2educ i.w2adl i.w2health i.w2bmi"

///Descriptives table
dtable $dems_cont $dems_binary $dems_cat, nosample ///
 nformat(%9.1f mean sd minmax) ///
 nformat(%9.2f proportion fvproportion) ///
 title("Table 1: Sample descriptives")   ///
 col(summary("Mean (SD) / Proportion (%)"))

putdocx clear
cd "C:\Users\rmjldfa\OneDrive - University College London\3. Research\5. Papers\236. Social deficits biological ageing"
collect export "Fig 1a", as(docx) replace

///Correlations 
pwcorr w2livealone w2networksizew w2integration w2isolated w2socsup w2ucla w2socstr
matrix C = r(C)
heatplot C, values(format(%9.3f)) lower nodiagonal legend(off) aspectratio(1) color(hcl bluered, reverse) label saving(heatplot, replace)
  
graph matrix w2livealone w2networksizew w2integration w2isolated w2socsup w2ucla w2socstr, half
vioplot paca2, saving(pacavio)
vioplot baca2, saving(bacavio)
graph combine pacavio.gph bacavio.gph, ycommon
  
pwcorr baca2 paca2, sig star(.05)

twoway (histogram paca2, color(blue)) (histogram baca2, fcolor(none) lcolor(red)) , ///
  legend(order(1 "Perceived age" 2 "Physiological age")) xtitle(Difference from chronological age) saving(histo, replace)

heatplot baca2 paca2
hexplot baca2 paca2, keylabels(, format(%9.2f)) label saving(hexplor, replace)

tab baca2 
tab paca2
hexplot ba2 w2age, size color(PiYG) p(lcolor(black) lwidth(vthin) lalign(center)) ylabel(0(20)130) xlabel(50(10)100) keylabels(, format(%9.2f)) saving(ba2, replace)
hexplot page2 w2age, size color(inferno) p(lcolor(black) lwidth(vthin) lalign(center)) ylabel(0(20)130) xlabel(50(10)100) keylabels(, format(%9.2f)) saving(pa2, replace)
graph combine pa2.gph ba2.gph

scatter baca2 w2age
twoway scatter paca2 w2age, mcolor(green) lcolor(blue) ytitle("Perceived age acceleration") || lfit paca2 w2age, legend(off) saving(pascat, replace)
twoway scatter baca2 w2age, ytitle("Physiological age acceleration")  || lfit baca2 w2age, legend(off) saving(bascat, replace)
graph combine pascat.gph bascat.gph

*******************************************************************************
***********************************CROSS-SECTIONAL*****************************
*******************************************************************************

graph drop _all

*****MAIN ANALYSES
foreach V of global socialteff {
	teffects ipwra (baca2 $modelout) (`V' $modelexp) [pweight=w2scw2wgt]
	estimates store m`V'
    nlcom _b[ATE:r1vs0.`V'] / _b[POmean:0.`V'] 	
	estimates store pom_`V'
	
	teffects ipwra (paca2 $modelout) (`V' $modelexp) [pweight=w2scw2wgt]
	estimates store n`V'
    nlcom _b[ATE:r1vs0.`V'] / _b[POmean:0.`V'] 	
	estimates store pon_`V'
	
	}
	
coefplot (nw2livealone) (nw2networksizew_4b) (nw2integration_4b) (nw2isolated_4b) (nw2socsup_4b) (nw2ucla_4b) (nw2socstr_4b) ///
      , xline(0) nolabels drop(_cons) nokey ///
	  axis(1) mcolor(black) ciopts(lcolor(black)) grid(none) nooff ///
	  coeflabels(r1vs0.w2livealone="Living alone" r1vs0.w2networksizew_4b="Small social network" r1vs0.w2integration_4b="Low social integration" r1vs0.w2isolated_4b="High social isolation" r1vs0.w2socsup_4b="Low social support" r1vs0.w2ucla_4b="High loneliness" r1vs0.w2socstr_4b="High social strain") ///
      b1title(Difference in perceived age (years)) saving(pacamain, replace)
	  
coefplot (mw2livealone) (mw2networksizew_4b) (mw2integration_4b) (mw2isolated_4b) (mw2socsup_4b) (mw2ucla_4b) (mw2socstr_4b) ///
      , xline(0) nolabels drop(_cons) nokey ///
	  axis(1) mcolor(black) ciopts(lcolor(black)) grid(none) nooff ///
	  coeflabels(r1vs0.w2livealone="Living alone" r1vs0.w2networksizew_4b="Small social network" r1vs0.w2integration_4b="Low social integration" r1vs0.w2isolated_4b="High social isolation" r1vs0.w2socsup_4b="Low social support" r1vs0.w2ucla_4b="High loneliness" r1vs0.w2socstr_4b="High social strain") ///
      b1title(Difference in phsyiological age (years)) saving(bacamain, replace)

graph combine pacamain.gph bacamain.gph, xcommon
graph save figmain, replace

///COEFFICIENTS FOR COPYING INTO WORD TABLES
etable, column(index) estimates(nw2livealone nw2networksizew_4b nw2integration_4b nw2isolated_4b nw2socsup_4b nw2ucla_4b nw2socstr_4b) ///
   showstars showstarsnote  stars(.05 "*" .01 "**" .001 "***", attach(_r_b)) ///
   title(Supplementary Table 1: Average treatment effects and 95% confidence intervals) ///
   cstat(_r_b,  nformat(%4.2f) font(Calibri, size(11))) ///
   cstat(_r_ci, nformat(%5.2f) cidelimiter(,) font(Calibri, size(11))) ///
   notes (ANY NOTES HERE) ///
   notestyles(font(Calibri, size(10) italic))  
collect style row split, nospacer dups(first)
collect preview
* Combine b and se in a composite result called bse
collect composite define bse = _r_b _r_ci, trim
collect layout (coleq#colname#result[bse] result[N]) (cmdset#stars) (), name(ETable)
collect preview

etable, column(index) estimates(mw2livealone mw2networksizew_4b mw2integration_4b mw2isolated_4b mw2socsup_4b mw2ucla_4b mw2socstr_4b) ///
   showstars showstarsnote  stars(.05 "*" .01 "**" .001 "***", attach(_r_b)) ///
   title(Supplementary Table 1: Average treatment effects and 95% confidence intervals) ///
   cstat(_r_b,  nformat(%4.2f) font(Calibri, size(11))) ///
   cstat(_r_ci, nformat(%5.2f) cidelimiter(,) font(Calibri, size(11))) ///
   notes (ANY NOTES HERE) ///
   notestyles(font(Calibri, size(10) italic))  
collect style row split, nospacer dups(first)
collect preview
* Combine b and se in a composite result called bse
collect composite define bse = _r_b _r_ci, trim
collect layout (coleq#colname#result[bse] result[N]) (cmdset#stars) (), name(ETable)
collect preview
	  	  
*****SENSITIVITY ANALYSES - INCLUDING DEPRESSION FOR EXPOSURE
foreach V of global socialteff {
	teffects ipwra (baca2 $modelout) (`V' $modelexp w2depression) [pweight=w2scw2wgt]
	estimates store m1`V'
    nlcom _b[ATE:r1vs0.`V'] / _b[POmean:0.`V'] 	

	teffects ipwra (paca2 $modelout) (`V' $modelexp w2depression) [pweight=w2scw2wgt]
	estimates store n1`V'
    nlcom _b[ATE:r1vs0.`V'] / _b[POmean:0.`V'] 	
	}

coefplot (n1w2livealone) (n1w2networksizew_4b) (n1w2integration_4b) (n1w2isolated_4b) (n1w2socsup_4b) (n1w2ucla_4b) (n1w2socstr_4b) ///
      , xline(0) nolabels drop(_cons) nokey ///
	  axis(1) mcolor(black) ciopts(lcolor(black)) grid(none) nooff ///
	  coeflabels(r1vs0.w2livealone="Living alone" r1vs0.w2networksizew_4b="Small social network" r1vs0.w2integration_4b="Low social integration" r1vs0.w2isolated_4b="High social isolation" r1vs0.w2socsup_4b="Low social support" r1vs0.w2ucla_4b="High loneliness" r1vs0.w2socstr_4b="High social strain") ///
      b1title(Difference in perceived age (years)) saving(pacas1, replace)
	  
coefplot (m1w2livealone) (m1w2networksizew_4b) (m1w2integration_4b) (m1w2isolated_4b) (m1w2socsup_4b) (m1w2ucla_4b) (m1w2socstr_4b) ///
      , xline(0) nolabels drop(_cons) nokey ///
	  axis(1) mcolor(black) ciopts(lcolor(black)) grid(none) nooff ///
	  coeflabels(r1vs0.w2livealone="Living alone" r1vs0.w2networksizew_4b="Small social network" r1vs0.w2integration_4b="Low social integration" r1vs0.w2isolated_4b="High social isolation" r1vs0.w2socsup_4b="Low social support" r1vs0.w2ucla_4b="High loneliness" r1vs0.w2socstr_4b="High social strain") ///
      b1title(Difference in physiological age (years)) saving(bacas1, replace)
	  
graph combine pacas1.gph bacas1.gph, xcommon
graph save figs1, replace
	  	  
*****SENSITIVITY ANALYSES - RESTRICTING TO SAME SAMPLE
foreach V of global socialteff {
	teffects ipwra (baca2 $modelout) (`V' $modelexp) [pweight=w2scw2wgt] if nomissbaca==1 & nomisspaca==1
	estimates store m2`V'
    nlcom _b[ATE:r1vs0.`V'] / _b[POmean:0.`V'] 	

	teffects ipwra (paca2 $modelout) (`V' $modelexp) [pweight=w2scw2wgt] if nomissbaca==1 & nomisspaca==1
	estimates store n2`V'
    nlcom _b[ATE:r1vs0.`V'] / _b[POmean:0.`V'] 	
	}

coefplot (n2w2livealone) (n2w2networksizew_4b) (n2w2integration_4b) (n2w2isolated_4b) (n2w2socsup_4b) (n2w2ucla_4b) (n2w2socstr_4b) ///
      , xline(0) nolabels drop(_cons) nokey ///
	  axis(1) mcolor(black) ciopts(lcolor(black)) grid(none) nooff ///
	  coeflabels(r1vs0.w2livealone="Living alone" r1vs0.w2networksizew_4b="Small social network" r1vs0.w2integration_4b="Low social integration" r1vs0.w2isolated_4b="High social isolation" r1vs0.w2socsup_4b="Low social support" r1vs0.w2ucla_4b="High loneliness" r1vs0.w2socstr_4b="High social strain") ///
      b1title(Difference in perceived age (years)) saving(pacas2, replace)
	  
coefplot (m2w2livealone) (m2w2networksizew_4b) (m2w2integration_4b) (m2w2isolated_4b) (m2w2socsup_4b) (m2w2ucla_4b) (m2w2socstr_4b) ///
      , xline(0) nolabels drop(_cons) nokey ///
	  axis(1) mcolor(black) ciopts(lcolor(black)) grid(none) nooff ///
	  coeflabels(r1vs0.w2livealone="Living alone" r1vs0.w2networksizew_4b="Small social network" r1vs0.w2integration_4b="Low social integration" r1vs0.w2isolated_4b="High social isolation" r1vs0.w2socsup_4b="Low social support" r1vs0.w2ucla_4b="High loneliness" r1vs0.w2socstr_4b="High social strain") ///
      b1title(Difference in physiological age (years)) saving(bacas2, replace)

graph combine pacas2.gph bacas2.gph, xcommon
graph save figs2, replace

***SENSITIVITY ANALYSES RESTRICTING TO WITHIN 30 YEARS
gen baca2_30=baca2
replace baca2_30=. if baca2_30<-30
replace baca2_30=. if baca2_30>30

gen paca2_30=paca2
replace paca2_30=. if paca2_30<-30
replace paca2_30=. if paca2_30>30

foreach V of global socialteff {
	teffects ipwra (baca2_30 $modelout) (`V' $modelexp) [pweight=w2scw2wgt] 
	estimates store m5`V'
    nlcom _b[ATE:r1vs0.`V'] / _b[POmean:0.`V'] 	

	teffects ipwra (paca2_30 $modelout) (`V' $modelexp) [pweight=w2scw2wgt]
	estimates store n5`V'
    nlcom _b[ATE:r1vs0.`V'] / _b[POmean:0.`V'] 	
	}
	
coefplot (n5w2livealone) (n5w2networksizew_4b) (n5w2integration_4b) (n5w2isolated_4b) (n5w2socsup_4b) (n5w2ucla_4b) (n5w2socstr_4b) ///
      , xline(0) nolabels drop(_cons) nokey ///
	  axis(1) mcolor(black) ciopts(lcolor(black)) grid(none) nooff ///
	 coeflabels(r1vs0.w2livealone="Living alone" r1vs0.w2networksizew_4b="Small social network" r1vs0.w2integration_4b="Low social integration" r1vs0.w2isolated_4b="High social isolation" r1vs0.w2socsup_4b="Low social support" r1vs0.w2ucla_4b="High loneliness" r1vs0.w2socstr_4b="High social strain") ///
     b1title(Difference in perceived age (years)) saving(pacas5, replace)
	  
coefplot (m5w2livealone) (m5w2networksizew_4b) (m5w2integration_4b) (m5w2isolated_4b) (m5w2socsup_4b) (m5w2ucla_4b) (m5w2socstr_4b) ///
      , xline(0) nolabels drop(_cons) nokey ///
	  axis(1) mcolor(black) ciopts(lcolor(black)) grid(none) nooff ///
	 coeflabels(r1vs0.w2livealone="Living alone" r1vs0.w2networksizew_4b="Small social network" r1vs0.w2integration_4b="Low social integration" r1vs0.w2isolated_4b="High social isolation" r1vs0.w2socsup_4b="Low social support" r1vs0.w2ucla_4b="High loneliness" r1vs0.w2socstr_4b="High social strain") ///
      b1title(Difference in phsyiological age (years)) saving(bacas5, replace)

graph combine pacas5.gph bacas5.gph, xcommon
graph save figs5, replace

***SENSITIVTY ANALYSIS - ALL POSITIVES
foreach V of global socialteff_pos {
	teffects ipwra (baca2 $modelout) (`V' $modelexp) [pweight=w2scw2wgt]
	estimates store m6`V'
    nlcom _b[ATE:r1vs0.`V'] / _b[POmean:0.`V'] 	

	teffects ipwra (paca2 $modelout) (`V' $modelexp) [pweight=w2scw2wgt]
	estimates store n6`V'
    nlcom _b[ATE:r1vs0.`V'] / _b[POmean:0.`V'] 	
	}
	
coefplot (n6w2livealone_pos) (n6w2networksizew_4b_pos) (n6w2integration_4b_pos) (n6w2isolated_4b_pos) (n6w2socsup_4b_pos) (n6w2ucla_4b_pos) (n6w2socstr_4b_pos) ///
      , xline(0) nolabels drop(_cons) nokey ///
	  axis(1) mcolor(black) ciopts(lcolor(black)) grid(none) nooff ///
	  coeflabels(r1vs0.w2livealone_pos="Living with others" r1vs0.w2networksizew_4b_pos="Large social network" r1vs0.w2integration_4b_pos="High social integration" r1vs0.w2isolated_4b_pos="Low social isolation" r1vs0.w2socsup_4b_pos="High social support" r1vs0.w2ucla_4b_pos="Low loneliness" r1vs0.w2socstr_4b_pos="Low social strain") ///
	   b1title(Difference in perceived age (years)) saving(pacas6, replace)
	  
coefplot (m6w2livealone_pos) (m6w2networksizew_4b_pos) (m6w2integration_4b_pos) (m6w2isolated_4b_pos) (m6w2socsup_4b_pos) (m6w2ucla_4b_pos) (m6w2socstr_4b_pos) ///
      , xline(0) nolabels drop(_cons) nokey ///
	  axis(1) mcolor(black) ciopts(lcolor(black)) grid(none) nooff ///
	  coeflabels(r1vs0.w2livealone_pos="Living with others" r1vs0.w2networksizew_4b_pos="Large social network" r1vs0.w2integration_4b_pos="High social integration" r1vs0.w2isolated_4b_pos="Low social isolation" r1vs0.w2socsup_4b_pos="High social support" r1vs0.w2ucla_4b_pos="Low loneliness" r1vs0.w2socstr_4b_pos="Low social strain") ///
      b1title(Difference in phsyiological age (years)) saving(bacas6, replace)

graph combine pacas6.gph bacas6.gph, xcommon
graph save figs6, replace

*****SENSITIVITY ANALYSES - AGE SPLIT
foreach V of global socialteff {
	teffects ipwra (baca2 $modelout) (`V' $modelexp) [pweight=w2scw2wgt] if w2age<65
	estimates store m3`V'
    nlcom _b[ATE:r1vs0.`V'] / _b[POmean:0.`V'] 	

	teffects ipwra (paca2 $modelout) (`V' $modelexp) [pweight=w2scw2wgt] if w2age<65
	estimates store n3`V'
    nlcom _b[ATE:r1vs0.`V'] / _b[POmean:0.`V'] 	
	}

coefplot (n3w2livealone) (n3w2networksizew_4b) (n3w2integration_4b) (n3w2isolated_4b) (n3w2socsup_4b) (n3w2ucla_4b) (n3w2socstr_4b) ///
      , xline(0) nolabels drop(_cons) nokey ///
	  axis(1) mcolor(black) ciopts(lcolor(black)) grid(none) nooff ///
	   coeflabels(r1vs0.w2livealone="Living alone" r1vs0.w2networksizew_4b="Small social network" r1vs0.w2integration_4b="Low social integration" r1vs0.w2isolated_4b="High social isolation" r1vs0.w2socsup_4b="Low social support" r1vs0.w2ucla_4b="High loneliness" r1vs0.w2socstr_4b="High social strain") ///
     b1title(Difference in perceived age (years)) saving(pacas3, replace)
	  
coefplot (m3w2livealone) (m3w2networksizew_4b) (m3w2integration_4b) (m3w2isolated_4b) (m3w2socsup_4b) (m3w2ucla_4b) (m3w2socstr_4b) ///
      , xline(0) nolabels drop(_cons) nokey ///
	  axis(1) mcolor(black) ciopts(lcolor(black)) grid(none) nooff ///
	  coeflabels(r1vs0.w2livealone="Living alone" r1vs0.w2networksizew_4b="Small social network" r1vs0.w2integration_4b="Low social integration" r1vs0.w2isolated_4b="High social isolation" r1vs0.w2socsup_4b="Low social support" r1vs0.w2ucla_4b="High loneliness" r1vs0.w2socstr_4b="High social strain") ///
      b1title(Difference in physiological age (years)) saving(bacas3, replace)

foreach V of global socialteff {
	teffects ipwra (baca2 $modelout) (`V' $modelexp) [pweight=w2scw2wgt] if w2age>=65
	estimates store m4`V'
    nlcom _b[ATE:r1vs0.`V'] / _b[POmean:0.`V'] 	

	teffects ipwra (paca2 $modelout) (`V' $modelexp) [pweight=w2scw2wgt] if w2age>=65
	estimates store n4`V'
    nlcom _b[ATE:r1vs0.`V'] / _b[POmean:0.`V'] 	
	}

teffects ipwra (paca2 $modelout) (w2livealone $modelexp) [pweight=w2scw2wgt] if w2age>=65
teffects ipwra (baca2 $modelout) (w2livealone $modelexp) [pweight=w2scw2wgt] if w2age>=65
	
	
coefplot (n4w2livealone) (n4w2networksizew_4b) (n4w2integration_4b) (n4w2isolated_4b) (n4w2socsup_4b) (n4w2ucla_4b) (n4w2socstr_4b) ///
      , xline(0) nolabels drop(_cons) nokey ///
	  axis(1) mcolor(black) ciopts(lcolor(black)) grid(none) nooff ///
	 coeflabels(r1vs0.w2livealone="Living alone" r1vs0.w2networksizew_4b="Small social network" r1vs0.w2integration_4b="Low social integration" r1vs0.w2isolated_4b="High social isolation" r1vs0.w2socsup_4b="Low social support" r1vs0.w2ucla_4b="High loneliness" r1vs0.w2socstr_4b="High social strain") ///
       b1title(Difference in perceived age (years)) saving(pacas4, replace)
	  
coefplot (m4w2livealone) (m4w2networksizew_4b) (m4w2integration_4b) (m4w2isolated_4b) (m4w2socsup_4b) (m4w2ucla_4b) (m4w2socstr_4b) ///
      , xline(0) nolabels drop(_cons) nokey ///
	  axis(1) mcolor(black) ciopts(lcolor(black)) grid(none) nooff ///
	  coeflabels(r1vs0.w2livealone="Living alone" r1vs0.w2networksizew_4b="Small social network" r1vs0.w2integration_4b="Low social integration" r1vs0.w2isolated_4b="High social isolation" r1vs0.w2socsup_4b="Low social support" r1vs0.w2ucla_4b="High loneliness" r1vs0.w2socstr_4b="High social strain") ///
      b1title(Difference in physiological age (years)) saving(bacas4, replace)

graph combine pacas3.gph bacas3.gph pacas4.gph bacas4.gph, xcommon
graph save figs4, replace

*****SENSITIVITY ANALYSES - USING WAVE 4 OUTCOMES
foreach V of global socialteff {
	teffects ipwra (baca4 $modelout) (`V' $modelexp) [pweight=w2scw2wgt] 
	estimates store m7`V'
    nlcom _b[ATE:r1vs0.`V'] / _b[POmean:0.`V'] 	

	teffects ipwra (paca4 $modelout) (`V' $modelexp) [pweight=w2scw2wgt] 
	estimates store n7`V'
    nlcom _b[ATE:r1vs0.`V'] / _b[POmean:0.`V'] 	
	}

coefplot (n7w2livealone) (n7w2networksizew_4b) (n7w2integration_4b) (n7w2isolated_4b) (n7w2socsup_4b) (n7w2ucla_4b) (n7w2socstr_4b) ///
      , xline(0) nolabels drop(_cons) nokey ///
	  axis(1) mcolor(black) ciopts(lcolor(black)) grid(none) nooff ///
	  coeflabels(r1vs0.w2livealone="Living alone" r1vs0.w2networksizew_4b="Small social network" r1vs0.w2integration_4b="Low social integration" r1vs0.w2isolated_4b="High social isolation" r1vs0.w2socsup_4b="Low social support" r1vs0.w2ucla_4b="High loneliness" r1vs0.w2socstr_4b="High social strain") ///
      b1title(Difference in perceived age (years)) saving(pacas7, replace)
	  
coefplot (m7w2livealone) (m7w2networksizew_4b) (m7w2integration_4b) (m7w2isolated_4b) (m7w2socsup_4b) (m7w2ucla_4b) (m7w2socstr_4b) ///
      , xline(0) nolabels drop(_cons) nokey ///
	  axis(1) mcolor(black) ciopts(lcolor(black)) grid(none) nooff ///
	  coeflabels(r1vs0.w2livealone="Living alone" r1vs0.w2networksizew_4b="Small social network" r1vs0.w2integration_4b="Low social integration" r1vs0.w2isolated_4b="High social isolation" r1vs0.w2socsup_4b="Low social support" r1vs0.w2ucla_4b="High loneliness" r1vs0.w2socstr_4b="High social strain") ///
      b1title(Difference in physiological age (years)) saving(bacas7, replace)

graph combine pacas7.gph bacas7.gph, xcommon
graph save figs7, replace

