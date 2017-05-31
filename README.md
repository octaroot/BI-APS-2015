# BI-APS-2015
## Task #3 - Gaussian elimination
### Zadání
Napište program pro procesor DLX, který bude provádět výpočet horní trojúhelníkové matice pomocí Gaussovy eliminace (bez pivotizace) matice velikosti N x N+1 v pohyblivé řádové čárce (v jednoduché přesnosti). Program optimalizujte k dosažení co nejmenšího počtu taktů pro dané parametry procesoru. 

#### Vstupy

N … konstanta v paměti ,N > 1
A … matice typu N x N+1 uložená jako statické pole v paměti typu float (32-bitové hodnoty) - matice je uložena po řádcích (to znamená, že nejprve je uložen první řádek matice A, za ní následuje druhý řádek matice A, a tak dále). Předpokládejte, že matice je regulární, a navíc při eliminaci vždy najdete na pozici A[k,k] nenulový prvek, a že přesnost výpočtu bude dostatečná bez hledání pivota (tj. neprovádějte pivotizaci).

#### Výstup

Y … matice typu N x N+1 uložená jako statické pole v paměti typu float (32-bitové hodnoty) - matice je uložena po řádcích (stejně jako A). Může být umístěna na stejném místě jako A (tzn. původní matice A se postupně přepíše).

#### Hodnocení výsledků

Počet bodů bude udělen podle dosaženého času pro matice 10 x 11:


| Počet taktů | Bodové ohodnocení |
| -- | -- |
| > 7499 taktů 	| 2 body |
| 6500 … 7499 |	4 body |
| 5500 … 6499 |	6 bodů |
| 5000 … 5499 |	8 bodů |
| 4500 … 4999 |	10 bodů |
| < 4500 taktů |	12 bodů |

### Řešení

4163 CPU cycles (4401 with memcopy)