# SQL_Project

### 1. Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?

  <sup>Hodnoty mezd jsou nejprve seskupeny podle odvětví, let a jednotlivých dnů za jednotlivá čtvrtletí v každém roce, kde pro každou uvedenou skupinu jsou hodnoty zprůměrovány pomocí agregační funkce ```avg()```.</sup>
  <sup>Následně je celé období rozděleno na 2 poloviny (2006 - 2012 a 2012 - 2018, kde první polovina roku 2012 patří prvnímu období, a ta druhá druhému období).</sup>
  <sup>Poté jsou data znovu seskupena podle jednotlivých odvětví a obou období, kde hodnoty mezd v každém odvětví a období jsou zprůměrovány opět pomocí agregační funkce ```avg()```.</sup>
  <sup>Dle výsledků celého dotazu pak můžeme vidět průměr mezd v každém odvětví za obě období. V případě, že průměrná mzda ve druhém období (2012 - 2018) je v daném odvětví vyšší, než průměrná mzda v tom prvním období, pak je zřejmé, že mzdy v tomto odvětví v průběhu let rostou.</sup>
  
- Odpověď: Mzdy rostou v průběhu let ve všech odvětvích.

### 2. Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?
  
  #### První srovnatelné období (02-01-2006 - 08-01-2006):
      
   <sup>V tomto období byla průměrná mzda (vypočítána ze všech dostupných odvětví) 19.633,32 Kč.</sup>
   <sup>Průměrná cena za 1 kg chleba v tomhle období byla 14,9 Kč a za 1 litr mléka 14,27 Kč.</sup>
   <sup>V případě, že by člověk pobírající tuhle průměrnou mzdu nakoupil pouze chleba a mléko, mohl by si koupit 1317 kg chleba a 1375 litrů mléka.</sup>
   
  #### Poslední srovnatelné období (10-12-2018 - 16-12-2018):
      
   <sup>V tomto období byla průměrná mzda (vypočítána ze všech dostupných odvětví) 34.502,82 Kč.</sup>
   <sup>Průměrná cena za 1 kg chleba v tomhle období byla 24,74 Kč a za 1 litr mléka 19,55 Kč.</sup>
   <sup>V případě, že by člověk pobírající tuhle průměrnou mzdu nakoupil pouze chleba a mléko, mohl by si koupit 1394 kg chleba a 1764 litrů mléka.</sub>
   
- Odpověď: Za první srovnatelné období je možné si koupit 1317 kg chleba a 1375 litrů mléka. 
           Za poslední srovnatelné období je možné si koupit 1394 kg chleba a 1764 litrů mléka.
    
### 3. Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?

   <sup>Nejprve je vypočítán percentuální nárust cen všech kategoríí potravin pro každý rok (jednotlivé měsíce a dny).</sup>
   <sup>Následně jsou tyto hodnoty sečteny v každém roce pro jednotlivé kategorie.</sup>
   <sup>Jako poslední krok jsou sečtené hodnoty zprůměrovány v každém roce pro všechny kategorie potravin pomocí agregační funkce ```avg()```, kde vybereme pouze první hodnotu ze vzestupně seřazených dat podle sloupce z výslednými hodnotami. Z výsledku vidíme kategorii '118101' (Cukr krystalový), který nemá nárust ceny v průběhu let, nýbrž pokles průměrně o 1,75 % ročně.</sup>

- Odpověď: Nejméně zdražuje kategorie potravin '118101' (Cukr krystalový). Z výsledného dotazu je zřejmé, že cena této kategorie nemá meziroční nárust, nýbrž průměrný meziroční pokles o 1,75 %. Od roku 2006 do roku 2018 z původních 21,68 Kč/1Kg postupně rostla/klesala cena na konečných 15,75 Kč/1Kg (21,68 Kč - průměrná cena za 1 kg v roce 2006, 15,75 Kč - průměrná cena za 1 kg v roce 2018).

### 4. Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?

   <sup>Nejprve jsou zprůměrovány ceny potravin podle jednotlivých kategorií a let.</sup>
   <sup>Následně jsou tyhle hodnoty seskupeny podle stejných let, kde je vypočítán jejich průměr pomocí agregační funkce ```avg()```.</sup>
   <sup>Nakonec je vypočítán meziroční percentuální nárust cen potravin pro všechny roky. Z výsledného dotazu pak můžeme vidět, že nejvyšší procentní nárůst potravin byl v roce 2017, kdy ceny vzrostly oproti minulému roku o 9,63 %.</sup>

- Odpověď: Ne, tento rok neexistuje. Z výsledného dotazu je zřejmé, že nejvyšší procentní nárůst potravin byl v roce 2017, kdy oproti předchozímu roku ceny potravin vzrostly o 9,63 %.

### 5. Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách ve stejném nebo násdujícím roce výraznějším růstem?

   <sup>Nejprve je vypočítán percentuální nárust HDP pro všechny evropské státy v jednotlivých letech.</sup>
   <sup>Následně jsou tyto hodnoty zprůměrovány pomocí agregační funkce ```avg()``` a seskupeny podle stejných let.</sup>
   <sup>Z výsledného dotazu pak můžeme vidět, o kolik % se zvýšila (nebo snížila) míra HDP v každém roce.</sup>
   <sup>Stejným způsobem je vypočítán nárust cen potravin a mezd v každém roce, kde jejich procentní navýšení, nebo pokles můžeme vidět ve stejném výsledku (výsledném dotazu) jako míru HDP.</sup>

- Odpověď: Míra HDP nejvýrazněji vzrostla v roce 2008, kdy její nárust oproti minulému roku byl o 7,5 %. Ceny potravin ve stejném roce vzrostly o 6,19 %, další rok (2009) pak klesly o 6,41 %. Mzdy ve stejném roce vzrostly o 7,87 %, další rok (2009) pak vzrostly o 3,16 %. Ceny potravin nejvýrazněji vzrostly v roce 2017, kdy její nárust byl oproti minulému roku o 9,63 %. Tento rok nárust HDP byl pouze o 3,8 %. Nejvyšší nárust mezd byl zaznamenaný právě v roce 2008.

- Jestliže míra HDP vzroste výrazněji v jednom roce, pak se to projeví výrazněji na růstu mezd ve stejném roce.
