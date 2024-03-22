# Prelucrarea imaginilor

  În vederea implementării automatului finit, am utilizat un bloc always în cadrul căruia variabilele 
state, row, și col sunt actualizate prin asignarea valorilor corespunzătoare ale variabilelor next_state, 
next_row, și next_col. Acest bloc este activat la fiecare front pozitiv al semnalului de ceas clk și are ca obiectiv 
sincronizarea și actualizarea stărilor și a variabilelor în cadrul circuitului, aceasta reprezentând partea 
secvențială, în timp ce partea combinațională este descrisă de cel de-al doilea bloc always.

## Cerința 1:
  Transformarea imaginii prin oglindire are ca principiu de bază inversarea valorilor poziționate pe liniile 
complementare din cadrul matricei de pixeli. În procesul de interschimbare, am utilizat două variabile auxiliare: "pix1" 
și "pix2". "pix1" memorează valoarea pixelului asociat liniei și coloanei pe care ne aflăm inițial, urmând ca în "pix2" să 
memorăm valoarea valoarea simetrică față de jumătatea matricei. 
Acest salt între linii se face prin "next_row = 63 – row". În urma memorării celor două valori, le asignăm 
corespunzător, utilizând "out_pix" pentru scriere și saltul descris anterior pentru poziționare. După finalizarea 
interschimbării, ne deplasăm către următorul pixel, repetând procesul pentru toate elementele jumătății superioare a 
matricei.

## Cerința 2:
  Pentru realizarea echivalentului imaginii în grayscale, am definit 3 variabile: "R", "G" și "B", în care am memorat 
octeții corespunzători fiecărei culori din componența pixelilor. Am calculat valoarea minimă, respectiv maximă dintre 
cele 3 valori, urmând să suprascriu porțiunea de biți aferentă canalului "G" cu valoarea obținută în urma aplicării 
formulei: (min + max)/2.
  După finalizarea acestei operațiuni, am setat valorile canalelor "R" și "B" la zero, urmând să parcurg în 
totalitate matricea, repetând pașii descriși anterior.

## Cerința 3:
  Întrucât implementarea filtrului necesită memorarea valorilor pixelilor înainte de a fi prelucrați și având în 
vedere restricția impusă de cerință și anume: să nu salvăm matricea în cadrul modulului pentru procesare ulterioară, 
am utilizat spațiul "liber" din pixeli, respectiv zonele rezervate culorilor roșu și albastru pentru a stoca temporar "copii" 
ale acestor valori. Am avut în vedere faptul că, dacă un element este în afara matricei, valorile liniei și ale coloanei pe 
care se află acesta vor fi complementare "valorii reale" și astfel, am aplicat matricea de convoluție fiecărui pixel.
