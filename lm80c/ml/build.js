#!/usr/bin/env node
// Assembla lm80c_keys.asm con z88dk e stampa il blocco DATA per il listato BASIC.
//
// Uso:
//    node build.js                       (usa z80asm trovato nel PATH)
//    Z80ASM=/percorso/z80asm node build.js
//
// Il blocco stampato va incollato in fondo al listato BASIC: il primo valore e' la lunghezza (LN),
// poi ci sono i byte della routine, 16 per riga. Il listato carica il tutto con
//
//    AD=30720:RESTORE 1094:READ LN:FOR N=0 TO LN-1:READ DT:POKE AD+N,DT:NEXT
//
// Ricorda: la routine sta a $7800 = 30720 e l'ingresso (quello da chiamare con SYS) e' il PRIMO
// byte, cioe' AD. Il blocco di stato (K, FLAGS, righe, SPAZIO precedente) sta invece IN CODA:
// il suo indirizzo e' AD + tanti byte quanti ne occupano codice e dati, e lo script lo calcola e
// lo stampa (va usato nel PEEK del listato). Lo script controlla anche che nel binario ci sia
// davvero 'push af' al primo byte, cioe' che il codice non sia stato spostato.

import { execFileSync } from 'node:child_process';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const HERE = path.dirname(fileURLToPath(import.meta.url));
const ASM = 'lm80c_keys.asm';
const BIN = 'lm80c_keys.bin';
const BASE = 0x7800;          // indirizzo di caricamento (30720)
const ENTRY_OFFSET = 0;       // SYS BASE (l'ingresso e' il primo byte)
const STATUS_LEN = 11;        // K + FLAGS + 8 righe + SPAZIO precedente (in coda al binario)
const FIRST_DATA_LINE = 1094; // primo numero di riga BASIC dei DATA
const PER_LINE = 16;          // byte per riga DATA

const z80asm = process.env.Z80ASM || 'z80asm';
try {
   execFileSync(z80asm, ['-b', ASM], { cwd: HERE, stdio: 'inherit' });
} catch (e) {
   if (e.code === 'ENOENT') {
      console.error(`z80asm non trovato (${z80asm}): mettilo nel PATH o usa Z80ASM=/percorso/z80asm`);
   }
   process.exit(1);
}

fs.rmSync(path.join(HERE, 'lm80c_keys.o'), { force: true });   // z80asm lascia anche il .o
const code = fs.readFileSync(path.join(HERE, BIN));
// l'ingresso deve stare a BASE e iniziare con push af / push bc / push de / push hl
if (!code.subarray(ENTRY_OFFSET, ENTRY_OFFSET + 4).equals(Buffer.from([0xF5, 0xC5, 0xD5, 0xE5]))) {
   console.error(`errore: l'ingresso NON e' a +${ENTRY_OFFSET} ` +
                 `(il codice non inizia al primo byte?)`);
   process.exit(1);
}
const st = BASE + code.length - STATUS_LEN;    // blocco di stato in coda

const hex = n => '$' + n.toString(16).toUpperCase().padStart(4, '0');
console.log(`; ${BIN}: ${code.length} byte, da ${hex(BASE)} a ${hex(BASE + code.length - 1)}`);
console.log(`; ingresso: SYS ${BASE}  -  blocco di stato SB = ${BASE + code.length - STATUS_LEN} ` +
            `(${hex(st)}): PEEK(SB) = K, PEEK(SB+1) = FLAGS, PEEK(SB+2+R) = riga, PEEK(SB+10) = SPAZIO`);
console.log(`; listato: 20 PAUSE DL:SYS AD:K=PEEK(SB)   con  SB=AD+${code.length - STATUS_LEN}`);
let riga = FIRST_DATA_LINE, col = 0, out = `${riga} DATA ${code.length}`;
for (let i = 0; i < code.length; i++) {
   if (col === PER_LINE) {
      riga += 1;
      col = 0;
      out += `\n${riga} DATA `;
   } else {
      out += ',';
   }
   out += code[i];
   col += 1;
}
console.log(out);
