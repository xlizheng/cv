local fnd = subinstr("`c(current_date )'"," ","",3)
local fnt = subinstr("`c(current_time)'",":","",2)


//DI干旱指数
cd "C:\Users\tq06t\OneDrive\气象数据\地面资料日值数据集\result"
cls
clear all
timer clear 1
timer on 1
drop _all
frame create results  di  wdj taua taub p start stop
forvalues k=-7/5{
    forvalues j=20/25{
        qui {
        use "C:\Users\tq06t\OneDrive\气象数据\地面资料日值数据集\陵城区降水.dta", replace
        keep if days>`k' & days<(`k'+`j')
        destring year, replace
        merge m:1 year using "C:\Users\tq06t\OneDrive\气象数据\地面资料日值数据集\陵城区产量.dta"
        drop if _merge==1
        drop yield _merge
        save "C:\Users\tq06t\OneDrive\气象数据\地面资料日值数据集\陵城区降水temp.dta", replace
        
        }
        forvalues i=500(10)2000 {
            qui {
            use "C:\Users\tq06t\OneDrive\气象数据\地面资料日值数据集\陵城区降水temp.dta", replace
            bysort year: egen wdj=sum(pre2020)
            gen di1=`i'-wdj
            replace di1=0 if di1<0
            gen di=di1/`i'
            merge m:1 year using "C:\Users\tq06t\OneDrive\气象数据\地面资料日值数据集\陵城区产量.dta", nogenerate
            duplicates drop year , force
            tsset year
            
        }
        ktau  di  lr_low
             
        frame post results  (di)  (`i')  (r(tau_a)) (r(tau_b)) (r(p)) (`k') (`j')
        
        }
    }
}
frame change results

frame results: save di`fnd'_`fnt'.dta, replace
timer off 1
timer list 1



//高温指数HTI设计  最高气温

use "C:\Users\tq06t\OneDrive\气象数据\地面资料日值数据集\陵城区.dta", replace
keep date avetem maxtem 
capture gen year=year(date)
gen date1="0725"
tostring year, replace
gen date2=year+date1
gen dat3e=date(date2,"YMD")
rename dat3e date3
gen days=date-date3
destring year ,replace
save "C:\Users\tq06t\OneDrive\气象数据\地面资料日值数据集\陵城区气温.dta", replace

cd "C:\Users\tq06t\OneDrive\气象数据\地面资料日值数据集\result"
cls
clear all
timer clear 1
timer on 1
drop _all
frame create results  htii yieldd htd taua taub p start stop
forvalues k=5/10{
    forvalues j=20/30{
        qui {
        use "C:\Users\tq06t\OneDrive\气象数据\地面资料日值数据集\陵城区气温.dta", replace
        keep if days>`k' & days<(`i'+`j')
        merge m:1 year using "C:\Users\tq06t\OneDrive\气象数据\地面资料日值数据集\陵城区产量.dta"
        drop if _merge==1
        drop yield _merge
        save "C:\Users\tq06t\OneDrive\气象数据\地面资料日值数据集\陵城区气温temp.dta", replace
        }
        forvalues i=300(1)365 {
            qui {            
            use "C:\Users\tq06t\OneDrive\气象数据\地面资料日值数据集\陵城区气温temp.dta", replace
            gen ht=1 if maxtem>=`i'
       
            replace ht=0 if maxtem==.
            bysort year: movavg ht3=ht, lags(3)
            gen hts=1 if ht3==0.75
            bysort year: egen hti=sum(hts)
            merge m:1 year using "C:\Users\tq06t\OneDrive\气象数据\地面资料日值数据集\陵城区产量.dta", nogenerate
            duplicates drop year , force
            }
        ktau  hti  lr_low
        frame post results (hti) (yield_w) (`i')  (r(tau_a)) (r(tau_b)) (r(p)) (`k') (`j')
        }
    }
}
frame change results
frame results: save hti`fnd'_`fnt'.dta, replace
timer off 1
timer list 1


/*阴雨寡照rsi指数设计*/

use "C:\Users\tq06t\OneDrive\气象数据\地面资料日值数据集\陵城区.dta", replace
keep date pre2020 ssd
capture gen year=year(date)
gen date1="0701"
tostring year, replace
gen date2=year+date1
gen dat3e=date(date2,"YMD")
rename dat3e date3
gen days=date-date3
save "C:\Users\tq06t\OneDrive\气象数据\地面资料日值数据集\陵城区日照.dta", replace


cls
clear all
timer clear 1
timer on 1
drop _all
frame create results  rsi  rs taua taub p start stop
forvalues k=1/15{
    forvalues j=20/40{
        qui {
        use "C:\Users\tq06t\OneDrive\气象数据\地面资料日值数据集\陵城区日照.dta", replace
        keep if days>`k' & days<`j'
        destring year, replace
        merge m:1 year using "C:\Users\tq06t\OneDrive\气象数据\地面资料日值数据集\陵城区产量.dta"
        drop if _merge==1
        drop yield _merge
        save "C:\Users\tq06t\OneDrive\气象数据\地面资料日值数据集\陵城区日照temp.dta", replace
        }
        forvalues i=1(1)80 {
            qui {
            
            use "C:\Users\tq06t\OneDrive\气象数据\地面资料日值数据集\陵城区日照temp.dta", replace
            gen rs=1 if ssd <=`i'
            replace rs=0 if ssd==.
            bysort year: egen rsi=sum(rs)
            replace rsi=rsi-8
            replace rsi=0 if rsi<0
            merge m:1 year using "C:\Users\tq06t\OneDrive\气象数据\地面资料日值数据集\陵城区产量.dta", nogenerate
            duplicates drop year , force
            tsset year
            
            }
        
        ktau  rsi  lr_low
        
        
        frame post results  (rsi)  (`i')  (r(tau_a)) (r(tau_b)) (r(p)) (`k') (`j')
        
        }
    }
}
frame change results

frame results: save rsi`fnd'_`fnt'.dta, replace
timer off 1
timer list 1

/*风雨倒伏rwi指数设计*/


use "C:\Users\tq06t\OneDrive\气象数据\地面资料日值数据集\陵城区.dta", replace
keep date pre2020 maxwin
gen year=year(date)
gen date1="0801"
tostring year, replace
gen date2=year+date1
gen dat3e=date(date2,"YMD")
rename dat3e date3
gen days=date-date3
save "C:\Users\tq06t\OneDrive\气象数据\地面资料日值数据集\陵城区风雨.dta", replace


cls
clear all
timer clear 1
timer on 1
drop _all
frame create results ra ws taoa taub p start dur
forvalues k=-5/5{
    forvalues j=45/60{
        qui {
        use "C:\Users\tq06t\OneDrive\气象数据\地面资料日值数据集\陵城区风雨.dta", replace
        keep if days>`k' & days<(`k'+`j')
        destring year, replace
        merge m:1 year using "C:\Users\tq06t\OneDrive\气象数据\地面资料日值数据集\陵城区产量.dta"
        drop if _merge==1
        drop yield _merge
        bysort year: movavg ra3=pre2020, lags(3)
        save "C:\Users\tq06t\OneDrive\气象数据\地面资料日值数据集\陵城区风雨temp.dta", replace
       
        }
        forvalues i=270(1)290 {
            forvalues h=70(1)90{
            //h为风俗阈值          
            //i为降水阈值
            qui {
            use "C:\Users\tq06t\OneDrive\气象数据\地面资料日值数据集\陵城区风雨temp.dta", replace    
            gen ra=1 if ra3 >=`i'
            replace ra=0 if pre2020==. | ra==.
            //gen rai=1 if ra3==0.75
            //replace rai=0 if ra3==.
            gen wi=1 if maxwin>=`h'
            replace wi=0 if maxwin==. | wi==.
            gen ws=(maxwin-`h')/10
            gen wf=ra*wi*ws
            bysort year: egen wfi=sum(wf)
            merge m:1 year using "C:\Users\tq06t\OneDrive\气象数据\地面资料日值数据集\陵城区产量.dta", nogenerate
            duplicates drop year , force
            tsset year
          
            }
            ktau  wfi  lr_low
            frame post results  (`i') (`h') (r(tao_a)) (r(tau_b)) (r(p)) (`k') (`j')
            }
        }
    }
}
frame change results
//twoway (line rho htd, sort connect(direct))
frame results: save wfi`fnd'_`fnt'.dta, replace
timer off 1
timer list 1





