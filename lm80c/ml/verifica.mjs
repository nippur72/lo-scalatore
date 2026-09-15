#!/usr/bin/env node
// Verifica i listati BASIC che contengono la routine in linguaggio macchina:
//
//    node verifica.mjs
//
// Controlla, per ogni listato:
//   - i numeri di riga (nessun duplicato, ordine crescente, con la sola eccezione voluta delle
//     DATA 1091-1093 messe prima delle righe 110-116);
//   - la lunghezza delle righe (max 87 caratteri, il limite di input e' 88);
//   - che ogni target di GOSUB/GOTO/THEN/RESTORE esista;
//   - che i DATA della routine siano esattamente lm80c_keys.bin, contatore di lunghezza compreso
//     (se si modifica il .asm e non si aggiornano i DATA, questo e' il controllo che lo dice);
//   - che il listato del gioco chiami la routine con SYS AD (l'ingresso e' il primo byte del
//     binario) e non abbia residui del vecchio
//     input da BASIC (INKEY/INP/K1/K2/K3/KS/SZ/NB/KEY);
//   - che l'offset del blocco di stato usato dal listato (SB=AD+n) coincida con quello calcolato
//     dal binario (il blocco sta IN CODA: bin.length - STATUS_LEN);
//   - il percorso del puntatore dei DATA, simulato come lo vede il BASIC (in ordine di numero di
//     riga): il caricamento della routine ML arriva in fondo all'elenco, quindi deve chiudere con
//     RESTORE, altrimenti i READ del gioco finiscono con OUT OF DATA ERROR;
//   - una stima per eccesso dell'ingombro del programma, da confrontare con l'indirizzo $7800
//     della routine (il listato deve starci sotto, con un margine per variabili e array).
//
// Esce con codice 1 se trova qualcosa da sistemare.

import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const HERE = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.join(HERE, '..', '..');       // radice del repository
const BASE = 0x7800, PROGST = 0x560E;           // routine in ML e inizio area BASIC (64K)
const STATUS_LEN = 11;                          // blocco di stato IN CODA al binario (K+FLAGS+8 righe+SPAZIO)
const LISTATI = ['lm80c/lo_scalatore_lm80c_sprites.bas', 'lm80c/prove/p08-matrice.bas'];

const bin = fs.readFileSync(path.join(HERE, 'lm80c_keys.bin'));
let problemi = 0;
const ko = msg => { problemi++; console.log('KO  ' + msg); };

// Valori di una riga: tutte le DATA, nell'ordine in cui compaiono nella riga.
const valoriData = t => t.split(':').filter(s => s.startsWith('DATA'))
   .flatMap(s => s.slice(4).split(',').map(x => Number(x.trim())));

// Simulatore del puntatore dei DATA. Il BASIC li legge in ordine di numero di riga (non di
// listato), RESTORE senza argomento riporta all'inizio, RESTORE n al primo DATA dalla riga n.
function simulaData(righe) {
   const piatto = [...righe.keys()].sort((a, b) => a - b)
      .flatMap(n => valoriData(righe.get(n)).map(v => ({ riga: n, v })));
   let pos = 0;
   return {
      totale: () => piatto.length,
      restoreDaL(riga) { const i = piatto.findIndex(x => x.riga >= riga); pos = i < 0 ? piatto.length : i; },
      rewind() { pos = 0; },
      read(q) { const out = piatto.slice(pos, pos + q); pos += q; return out; },
   };
}

// Valori consumati da ogni READ nelle righe [da..a], moltiplicando i cicli FOR aperti.
function gruppiRead(righe, da, a) {
   const gruppi = [], cicli = [];
   for (const n of [...righe.keys()].filter(n => n >= da && n <= a).sort((x, y) => x - y)) {
      for (const st of righe.get(n).split(':').map(s => s.trim())) {
         const f = /^FOR\s+\w+\s*=\s*(\d+)\s+TO\s+(\d+)/.exec(st);
         if (f) { cicli.push(Number(f[2]) - Number(f[1]) + 1); continue; }
         if (/^NEXT\b/.test(st)) { cicli.pop(); continue; }
         if (/^READ\b/.test(st)) gruppi.push({ riga: n, quanti: cicli.reduce((x, y) => x * y, 1) });
      }
   }
   return gruppi;
}

for (const rel of LISTATI) {
   console.log('=== ' + rel);
   const testo = fs.readFileSync(path.join(ROOT, rel), 'utf8');
   if (testo.includes('\r')) ko('contiene CR: le righe devono finire con LF');

   const righe = new Map(), ordine = [];
   for (const raw of testo.split('\n')) {
      if (!raw.trim()) continue;
      const m = /^(\d+) ?(.*)$/.exec(raw);
      if (!m) { ko(`riga senza numero: ${JSON.stringify(raw)}`); continue; }
      const n = Number(m[1]);
      if (righe.has(n)) ko(`numero di riga duplicato: ${n}`);
      righe.set(n, m[2]);
      ordine.push(n);
      if (raw.length > 87) ko(`riga lunga ${raw.length} caratteri: ${raw}`);
   }
   for (let i = 0; i < ordine.length - 1; i++) {
      if (ordine[i] > ordine[i + 1] && !(ordine[i] === 1093 && ordine[i + 1] === 110)) {
         ko(`ordine dei numeri di riga: ${ordine[i]} prima di ${ordine[i + 1]}`);
      }
   }

   for (const n of ordine) {
      for (const t of righe.get(n).matchAll(/\b(?:GOSUB|GOTO|THEN|RESTORE)\s*(\d+)/g)) {
         if (!righe.has(Number(t[1]))) ko(`riga ${n}: salto a ${t[1]} che non esiste`);
      }
   }

   const data = [];
   for (const n of [...righe.keys()].sort((a, b) => a - b)) {
      for (const stmt of righe.get(n).split(':')) {
         if (stmt.startsWith('DATA')) data.push(...stmt.slice(4).split(',').map(Number));
      }
   }
   if (data.length < bin.length + 1) {
      ko('mancano i DATA della routine');
   } else {
      const len = data[data.length - bin.length - 1];
      if (len !== bin.length) ko(`contatore LN = ${len}, atteso ${bin.length}`);
      const coda = Buffer.from(data.slice(-bin.length));
      if (!coda.equals(bin)) ko('i DATA della routine NON corrispondono a lm80c_keys.bin');
      else console.log(`ok  ${bin.length} byte nei DATA = lm80c_keys.bin`);
   }

   // Percorso del puntatore dei DATA: caricamento della routine ML, poi i READ del gioco.
   const car = [...righe].find(([, t]) => /POKE AD\+N,DT/.test(t));
   if (!car) {
      ko('manca la riga che carica la routine ML con POKE AD+N,DT');
   } else {
      if (!/POKE AD\+N,DT:NEXT/.test(car[1])) ko(`riga ${car[0]}: caricamento ML non riconosciuto`);
      // Due RESTORE: il primo sceglie il blocco ML, il secondo riavvolge per i READ del gioco.
      const rs = [...car[1].matchAll(/RESTORE(?:\s*(\d+))?/g)];
      if (rs.length < 2) {
         ko(`riga ${car[0]}: il caricamento della routine ML non chiude con RESTORE, ` +
            'i READ del gioco finirebbero in OUT OF DATA ERROR');
      } else {
         console.log(`ok  riga ${car[0]}: il caricamento della routine ML chiude con ` +
                     `RESTORE${rs[rs.length - 1][1] || ''}`);
      }
      const sim = simulaData(righe);
      const rl = /RESTORE (\d+):READ LN/.exec(car[1]);
      if (!rl) ko(`riga ${car[0]}: RESTORE del blocco ML non riconosciuto`);
      else {
         sim.restoreDaL(Number(rl[1]));
         const ln = sim.read(1)[0];
         if (!ln || ln.v !== bin.length) ko(`contatore LN letto dai DATA = ${ln && ln.v}, atteso ${bin.length}`);
         const corpo = sim.read(ln ? ln.v : bin.length);
         if (corpo.length !== (ln ? ln.v : 0)) {
            ko(`OUT OF DATA ERROR simulato sul caricamento ML (letti ${corpo.length} di ${ln && ln.v} byte)`);
         } else if (!Buffer.from(corpo.map(x => x.v)).equals(bin)) {
            ko('i byte letti dal caricatore non sono lm80c_keys.bin');
         }
      }
      // I READ del gioco ripartono solo se il caricatore riporta il puntatore all'inizio.
      if (rs.length >= 2) {
         const r = rs[rs.length - 1][1];
         if (r === undefined) sim.rewind(); else sim.restoreDaL(Number(r));
      }
      const gruppi = gruppiRead(righe, 110, 116);
      if (gruppi.length) {
         const attesi = [[101], [102, 103, 104, 105, 106, 107, 108], [109], [1091], [1092, 1093]];
         const dove = [];
         for (const g of gruppi) {
            const letti = sim.read(g.quanti);
            if (letti.length !== g.quanti) {
               ko(`riga ${g.riga}: OUT OF DATA ERROR simulato (letti ${letti.length} di ${g.quanti} valori)`);
               break;
            }
            dove.push([...new Set(letti.map(x => x.riga))]);
         }
         if (dove.length === gruppi.length) {
            const espresso = JSON.stringify(dove), voluto = JSON.stringify(attesi);
            if (espresso === voluto) {
               console.log("ok  i READ di 110-115 prendono i DATA 101-109 e 1091-1093, nell'ordine");
            } else {
               ko(`i READ di 110-115 prendono i DATA da ${espresso}, attesi ${voluto}`);
            }
         }
      }
   }

   if (rel.includes('sprites')) {
      for (const [n, t] of righe) {
         if (!t.startsWith('REM') && /\bSYS\b/.test(t) && !/\bSYS AD(?![+\w])/.test(t)) {
            ko(`riga ${n}: SYS che non chiama l'ingresso AD: ${t}`);
         }
      }
      const residui = ['INKEY', 'INP(', 'K1', 'K2', 'K3', 'KS', 'SZ', 'NB', 'KEY 9'];
      for (const [n, t] of righe) {
         for (const r of residui) {
            if (new RegExp(`\\b${r.replace('(', '\\(')}`).test(t)) {
               ko(`riga ${n}: residuo del vecchio input (${r}): ${t}`);
            }
         }
      }
      console.log('ok  nessun residuo di INKEY/INP/K1/K2/K3/KS/SZ/NB/KEY');
   }

   // Il blocco di stato sta in coda al binario: l'offset usato dal listato deve essere quello.
   const atteso = bin.length - STATUS_LEN;
   const mStato = /\bSB=AD\+(\d+)/.exec(testo);
   if (!mStato) ko(`manca SB=AD+${atteso} (offset del blocco di stato in coda al binario)`);
   else if (Number(mStato[1]) !== atteso) {
      ko(`SB=AD+${mStato[1]}: atteso AD+${atteso} (binario ${bin.length} byte - stato ${STATUS_LEN})`);
   } else {
      console.log(`ok  SB=AD+${atteso} = blocco di stato in coda (${bin.length} byte totali)`);
   }

   const ingombro = [...righe.values()].reduce((s, t) => s + t.length + 5, 0);  // stima per eccesso
   console.log(`ok  stima per eccesso del programma: ${ingombro} byte ` +
               `-> fine a $${(PROGST + ingombro).toString(16).toUpperCase()} (routine a $${BASE.toString(16).toUpperCase()})`);
   if (PROGST + ingombro + 600 > BASE) ko(`margine insufficiente sotto $${BASE.toString(16).toUpperCase()}`);
}

console.log(problemi ? `\n${problemi} problemi` : '\nnessun problema');
process.exit(problemi ? 1 : 0);
