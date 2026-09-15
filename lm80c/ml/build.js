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
// Ricorda: la routine sta a $7800 = 30720 (blocco di stato) e l'ingresso, quello da chiamare con
// SYS, sta 16 byte piu' avanti (AD+16). Lo script controlla che nel binario ci sia davvero
// 'push af' a quell'offset, cioe' che il blocco di stato in testa sia lungo 16 byte.

import { execFileSync } from 'node:child_process';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const HERE = path.dirname(fileURLToPath(import.meta.url));
const ASM = 'lm80c_keys.asm';
const BIN = 'lm80c_keys.bin';
const BASE = 0x7800;          // indirizzo di caricamento (30720)
const ENTRY_OFFSET = 16;      // SYS BASE+16
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
// l'ingresso deve stare a BASE+16 e iniziare con push af / push bc / push de / push hl
if (!code.subarray(ENTRY_OFFSET, ENTRY_OFFSET + 4).equals(Buffer.from([0xF5, 0xC5, 0xD5, 0xE5]))) {
   console.error(`errore: l'ingresso NON e' a +${ENTRY_OFFSET} ` +
                 `(blocco di stato di lunghezza sbagliata?)`);
   process.exit(1);
}

const hex = n => '$' + n.toString(16).toUpperCase().padStart(4, '0');
console.log(`; ${BIN}: ${code.length} byte, da ${hex(BASE)} a ${hex(BASE + code.length - 1)}`);
console.log(`; stato in PEEK(${BASE})... (K, FLAG, 8 righe, SPAZIO precedente) - SYS ${BASE + ENTRY_OFFSET}[,codice]`);
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
