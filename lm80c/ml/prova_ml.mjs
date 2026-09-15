// Prova della routine di input sul core wasm dell'emulatore LM80C, SENZA aprire il browser.
//
// Uso:
//    node prova_ml.mjs /percorso/di/lm80c-emu
//    EMU=/percorso/di/lm80c-emu node prova_ml.mjs
//
// Serve un checkout di https://github.com/nippur72/lm80c-emu con `emscripten_module.js` e
// `emscripten_module.wasm` (quelli committati nel repo); nessun altro prerequisito, niente browser.
// Lo script carica lm80c_keys.bin nell'emulatore, preme i tasti con la tastiera vera dell'emulatore
// (keyboard_press) ed esegue la routine istruzione per istruzione (lm80c_tick) leggendo poi il
// blocco di stato dalla RAM.
import fs from 'node:fs';
import path from 'node:path';
import { pathToFileURL } from 'node:url';

const EMU = process.argv[2] || process.env.EMU;
if (!EMU) {
   console.error('uso: node prova_ml.mjs /percorso/di/lm80c-emu   (oppure EMU=... node prova_ml.mjs)');
   process.exit(2);
}
const HERE = path.dirname(new URL(import.meta.url).pathname.replace(/^\/([A-Za-z]:)/, '$1'));

const { default: emscripten } = await import(
   pathToFileURL(path.join(EMU, 'emscripten_module.js')).href);
const wasmBinary = fs.readFileSync(path.join(EMU, 'emscripten_module.wasm'));
const m = await emscripten({ wasmBinary });

const AD = 0x7800, SENTINEL = 0x7F00;
const bin = fs.readFileSync(path.join(HERE, 'lm80c_keys.bin'));
const STATUS_LEN = 11;                          // blocco di stato in coda al binario
const ST = AD + bin.length - STATUS_LEN;        // ST+0 K, +1 FLAGS, +2..+9 righe, +10 SPAZIO
const ENTRY = AD;                               // l'ingresso e' il primo byte del binario

m._cpu_init();                 // collega il tick del Z80
m._cpu_reset();
m._lm80c_init(1);              // modello 64K
m._io_write(1, 0);             // ROM fuori, RAM su tutto lo spazio (come a runtime)
m._psg_init();
m._psg_write(0x40, 7); m._psg_write(0x41, 0xBF);   // reg.7 come initPSG (port A in, port B out)
m._keyboard_reset();
for (let i = 0; i < bin.length; i++) m._mem_write(AD + i, bin[i]);
m._mem_write(SENTINEL, 0xC3); m._mem_write(SENTINEL + 1, 0x00); m._mem_write(SENTINEL + 2, 0x7F);

const press = (row, col) => m._keyboard_press(row, col);
const reset = () => m._keyboard_reset();

// simula SYS AD[,param]: mette un indirizzo di ritorno finto sullo stack, riempie i registri con
// valori noti e verifica che la routine li restituisca tutti come li ha trovati (il BASIC ci conta).
function call(param) {
   const SP = 0x7F20;
   m._mem_write(SP, SENTINEL & 0xFF); m._mem_write(SP + 1, SENTINEL >> 8);
   m._set_z80_sp(SP);
   m._set_z80_bc(0x1234); m._set_z80_de(0x5678); m._set_z80_hl(0x9ABC);
   m._set_z80_ix(0x1111); m._set_z80_iy(0x2222);
   m._set_z80_a(param); m._set_z80_pc(ENTRY);
   let istruzioni = 0, cicli = 0;
   while (m._get_z80_pc() !== SENTINEL && istruzioni++ < 20000) cicli += m._lm80c_tick();
   if (istruzioni >= 20000) throw new Error('la routine non e\' tornata all\'indirizzo di ritorno');
   return {
      k: m._mem_read(ST), flags: m._mem_read(ST + 1),
      rows: Array.from({ length: 8 }, (_, r) => m._mem_read(ST + 2 + r)),
      spz: m._mem_read(ST + 10),
      ritorno_ok: m._get_z80_pc() === SENTINEL && m._get_z80_sp() === SP + 2,
      registri_ok: m._get_z80_bc() === 0x1234 && m._get_z80_de() === 0x5678 &&
                   m._get_z80_hl() === 0x9ABC && m._get_z80_ix() === 0x1111 &&
                   m._get_z80_iy() === 0x2222,
      istruzioni, cicli,
   };
}

const FF = [255, 255, 255, 255, 255, 255, 255, 255];
let ko = 0, n = 0, maxistr = 0, cicliscan = 0;
function check(nome, got, want) {
   const ok = JSON.stringify(got) === JSON.stringify(want);
   n++;
   if (!ok) ko++;
   console.log(`${ok ? 'ok  ' : 'KO  '} ${nome}: ${JSON.stringify(got)}` +
               (ok ? '' : `  (atteso ${JSON.stringify(want)})`));
}

let r = (reset(), call(0));
check('a riposo: K, FLAG, righe', [r.k, r.flags, r.rows], [0, 0, FF]);
check('ritorno: stack, registri, ingresso', [r.ritorno_ok, r.registri_ok], [true, true]);

for (const [nome, row, col, k, flag] of [
   ['cursore SINISTRA', 6, 0, 28, 4], ['cursore DESTRA', 6, 7, 29, 1],
   ['cursore SU', 5, 7, 30, 2], ['cursore GIU\'', 5, 0, 31, 8],
   ['alias J = SINISTRA', 4, 2, 28, 4], ['alias L = DESTRA', 5, 2, 29, 1],
   ['alias I = SU', 4, 1, 30, 2], ['alias K = GIU\'', 4, 5, 31, 8]]) {
   reset(); press(row, col);
   r = call(0);
   maxistr = Math.max(maxistr, r.istruzioni);
   cicliscan = r.cicli;
   check(nome, [r.k, r.flags], [k, flag]);
   check('  riga ' + row + ' senza il bit ' + col, (r.rows[row] & (1 << col)) === 0, true);
}

reset(); r = call(0); press(0, 4);
r = call(0); check('SPAZIO (fronte)', [r.k, r.flags], [32, 16]);
r = call(0); check('SPAZIO tenuto: nessun salto', [r.k, r.spz], [0, 16]);
reset(); r = call(0); check('SPAZIO rilasciato', [r.k, r.spz], [0, 0]);
press(0, 4); r = call(0); check('premuto di nuovo: nuovo fronte', r.k, 32);
reset(); r = call(0); press(1, 4);
r = call(0); check('alias Z = SPAZIO (fronte)', [r.k, r.flags], [32, 16]);

reset(); press(6, 0); press(5, 7);
r = call(0); check('SINISTRA + SU -> SINISTRA', r.k, 28);
reset(); press(6, 0); press(5, 0);
r = call(0); check('SINISTRA + GIU\' -> GIU\'', r.k, 31);
reset(); press(6, 0); r = call(0); press(0, 4);
r = call(0); check('SINISTRA + SPAZIO -> SPAZIO (salto camminando)', [r.k, r.flags], [32, 20]);
r = call(0); check('  e subito dopo cammina', r.k, 28);
reset(); press(6, 7); press(6, 0);
r = call(0); check('DESTRA + SINISTRA -> SINISTRA', r.k, 28);

reset(); press(4, 2);
check('modo test 28 (SINISTRA) con J premuto', call(28).k, 1);
check('modo test 29 (DESTRA) con J premuto', call(29).k, 0);
check('modo test 106 (codice di J): non e\' un comando', call(106).k, 0);
reset(); press(1, 4);
check('modo test 32 (SPAZIO) con Z premuto', call(32).k, 1);
reset();
check('modo test 32 a riposo', call(32).k, 0);

console.log(`\nbinario: ${bin.length} byte a $${AD.toString(16).toUpperCase()}, ingresso a $${ENTRY.toString(16).toUpperCase()}`);
// 1 ciclo = 1 periodo di clock: il Z80 del LM80C gira a 3,6864 MHz
console.log(`una chiamata completa (SYS AD senza parametro): ${maxistr} istruzioni, ` +
            `${cicliscan} cicli = ${(cicliscan / 3.6864).toFixed(0)} us`);
console.log(ko ? `${n} controlli, ${ko} FALLITI` : `${n} controlli, tutti superati`);
process.exit(ko ? 1 : 0);
