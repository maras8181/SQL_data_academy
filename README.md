# SQL_Project

### 1. Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?

  <sup>Hodnoty mezd jsou nejprve seskupeny podle odvětví, let a jednotlivých čtvrtletích, kde pro každou uvedenou skupinu jsou hodnoty zprůměrovány pomocí agregační funkce ```avg()```.</sup>
  <sup>Následně je celé období rozděleno na 2 poloviny (2006 - 2012 a 2012 - 2018, kde první polovina roku 2012 patří prvnímu období, a ta druhá druhému období).</sup>
  <sup>Poté jsou data znovu seskupena podle jednotlivých odvětví a obou období, kde hodnoty mezd v každém odvětví a období jsou zprůměrovány opět pomocí agregační funkce ```avg()```.</sup>
  <sup>Z finálního dotazu pak můžeme vidět průměr mezd v každém odvětví za obě období. V případě, že průměrná mzda v jednotlivém období je vetší, než mzda v tom prvním období, pak je zřejmé, že mzdy v průběhu let rostou.</sup>
  
- Odpověď: Mzdy rostou v průběhu let ve všech odvětvích.

### 2. Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?
  
  #### První srovnatelné období (02-01-2006 - 08-01-2006):
      
   <sup>V tomto období byla průměrná mzda (vypočítána ze všech dostupných odvětví) 20.753,78 Kč.</sup>
   <sup>Průměrná cena za 1 kg chleba v tomhle období byla 14,9 Kč a za 1 litr mléka 14,27 Kč.</sup>
   <sup>V případě, že by člověk pobírající tuhle průměrnou mzdu nakoupil pouze chleba a mléko, mohl by si koupit 1393 kg chleba a 1454 litrů mléka.</sup>
   
  #### Poslední srovnatelné období (10-12-2018 - 16-12-2018):
      
   <sup>V tomto období byla průměrná mzda (vypočítána ze všech dostupných odvětví) 32.535,86 Kč.</sup>
   <sup>Průměrná cena za 1 kg chleba v tomhle období byla 24,74 Kč a za 1 litr mléka 19,55 Kč.</sup>
   <sup>V případě, že by člověk pobírající tuhle průměrnou mzdu nakoupil pouze chleba a mléko, mohl by si koupit 1315 kg chleba a 1664 litrů mléka.</sub>
   
- Odpověď: Za první srovnatelné období je možné si koupit 1393 kg chleba a 1454 litrů mléka. 
           Za poslední srovnatelné období je možné si koupit 1315 kg chleba a 1664 litrů mléka.
    
### 3. Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?

   <sup>Nejprve je vypočítán percentuální nárust cen potravin pro každý rok (jednotlivé měsíce a dny).</sup>
   <sup>Následně jsou tyto hodnoty sečteny v každém roce pro jednotlivé kategorie.</sup>
   <sup>Jako poslední krok jsou sečtené hodnoty zprůměrovány v každém roce pro všechny kategorie potravin pomocí agregační funkce ```avg()```, kde vybereme pouze první hodnotu ze vzestupně seřazených dat podle sloupce z výslednými hodnotami. Z výsledku vidíme kategorii '117101' (Rajská jablka červená kulatá), která nemá meziroční nárust, nýbrž pokles ceny v průběhu let.</sup>

- Odpověď: Nejméně zdražuje kategorie potravin '117101' (Rajská jablka červená kulatá). Z výsledného dotazu je zřejmé že tahle kategorie nemá v průběhu let nárust ceny, nýbrž pokles o 26,6 %. Od roku 2006 do roku 2018 z původních 57,97 Kč/1Kg postupně klesala cena na konečných 44,5 Kč/1Kg (57,97 Kč - průměrná cena za 1 kg v roce 2006, 44,5 Kč - průměrná cena za 1 kg v roce 2018).

### 4. Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?

   <sup>Nejprve jsou zprůměrovány ceny všech kategorií potravin za jednotlivé roky.</sup>
   <sup>Následně jsou tyhle hodnoty seskupeny podle stejných let, kde je vypočítán jejich průměr pomocí agregační funkce ```avg()```.</sup>
   <sup>Nakonec je vypočítán meziroční percentuální nárust cen potravin pro všechny roky. Z výsledného dotazu pak můžeme vidět, že nejvyšší procentní nárůst potravin byl v roce 2017, kdy ceny vzrostly o 8,78 %.</sup>

- Odpověď: Tento rok neexistuje. Z výsledného dotazu je zřejmé, že nejvyšší procentní nárůst potravin byl v roce 2017, kdy cena potravin vzrostla o 8,78 %.

### 5. Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách ve stejném nebo násdujícím roce výraznějším růstem?

- Odpověď: Výška HDP vliv na změny ve mzdách a cenách potravin nemá. Jakmile vzroste výrazněji výška HDP (nejvíce o 8 %), pak ve stejném, nebo následujícím roce
            se vzrůst mezd a cen potravin výraznějším růstem neprojeví.
