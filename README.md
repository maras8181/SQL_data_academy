# SQL_Project

### 1. Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?

  <sup>Nejprve je vypočítán průměr všech mezd pro každé odvětví za jednotlivé roky a čtvrtletí v dostupných letech.</sup>
  <sup>Následně je vypočítán průmer mezd v každém roce pro všechna odvětví zvlášť.</sup>
  <sup>Z výsledného dotazu můžeme vidět průměrnou mzdu v každém roce pro všechna jednotlivá odvětví.</sup> 
  
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

   <sup>Nejprve je vypočítán průměr ceny všech kategorií za všechny jednotlivé roky zvlášť.</sup>
   <sup>Následně je vypočítán percentuální nárust v každém roce pro všechny dostupné kategorie.</sup>
   <sup>Jako poslední krok jsou hodnoty percentuálního nárustu zprůměrovány pro všechny jednotlivé kategorie potravin pomocí agregační funkce ```avg()```, kde vybereme pouze první hodnotu ze vzestupně seřazených dat podle sloupce z výslednými hodnotami. Z výsledku vidíme kategorii '118101' (Cukr krystalový), který nemá nárust ceny v průběhu let, nýbrž pokles průměrně o 1,77 % ročně.</sup>

- Odpověď: Nejméně zdražuje kategorie potravin '118101' (Cukr krystalový). Z výsledného dotazu je zřejmé, že cena této kategorie nemá meziroční nárust, nýbrž průměrný meziroční pokles o 1,77 %. Od roku 2006 do roku 2018 z původních 21,63 Kč/1Kg postupně rostla/klesala cena na konečných 15,65 Kč/1Kg (21,63 Kč - průměrná cena za 1 kg v roce 2006, 15,65 Kč - průměrná cena za 1 kg v roce 2018).

### 4. Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?

   <sup>Nejprve jsou zprůměrovány ceny potravin podle jednotlivých kategorií a let.</sup>
   <sup>Následně jsou tyhle hodnoty seskupeny podle stejných let, kde je vypočítán jejich průměr pomocí agregační funkce ```avg()```.</sup>
   <sup>Nakonec je vypočítán meziroční percentuální nárust cen potravin pro všechny roky. Z výsledného dotazu pak můžeme vidět, že nejvyšší procentní nárůst potravin byl v roce 2017, kdy ceny vzrostly oproti minulému roku o 9,63 %.</sup>

- Odpověď: Ne, tento rok neexistuje. Z výsledného dotazu je zřejmé, že nejvyšší procentní nárůst potravin byl v roce 2017, kdy oproti předchozímu roku ceny potravin vzrostly o 9,63 %.

### 5. Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách ve stejném nebo násdujícím roce výraznějším růstem?

   <sup>Nejprve je vypočítán průměr míry HDP pro všechny evropské státy v jednotlivých letech.</sup>
   <sup>Následně je vypočítán percentuální nárust pro všechny jednotlivé roky.</sup>
   <sup>Stejným způsobem je vypočítán nárust mezd. Růst cen potravin je vypočítán stejným způsobem jako v předchozí otázce (otázka 4).</sup>
   <sup>Z výsledného dotazu pak můžeme vidět, o kolik % se zvýšila (nebo snížila) míra HDP v každém roce.</sup>

- Odpověď: Míra HDP nejvýrazněji vzrostla v roce 2011, kdy její nárust oproti minulému roku byl o 6,77 %. Ceny potravin ve stejném roce vzrostly o 3,35 %, další rok (2012) pak klesly o 6,73 %. Mzdy ve stejném roce vzrostly o 2,30 %, další rok (2012) pak vzrostly o 3,03 %. Ceny potravin nejvýrazněji vzrostly v roce 2017, kdy její nárust byl oproti minulému roku o 9,63 %. Tento rok nárust HDP byl pouze o 2,53 %. Nejvyšší nárust mezd byl zaznamenaný v roce 2008.

- Jestliže míra HDP vzroste výrazněji v jednom roce, pak se to projeví výrazněji na růstu potravin v následujícím roce.
