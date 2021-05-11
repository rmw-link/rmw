let imports = {};
let wasm;

let cachegetUint8Memory0 = null;
function getUint8Memory0() {
    if (cachegetUint8Memory0 === null || cachegetUint8Memory0.buffer !== wasm.memory.buffer) {
        cachegetUint8Memory0 = new Uint8Array(wasm.memory.buffer);
    }
    return cachegetUint8Memory0;
}

let WASM_VECTOR_LEN = 0;

function passArray8ToWasm0(arg, malloc) {
    const ptr = malloc(arg.length * 1);
    getUint8Memory0().set(arg, ptr / 1);
    WASM_VECTOR_LEN = arg.length;
    return ptr;
}

let cachegetInt32Memory0 = null;
function getInt32Memory0() {
    if (cachegetInt32Memory0 === null || cachegetInt32Memory0.buffer !== wasm.memory.buffer) {
        cachegetInt32Memory0 = new Int32Array(wasm.memory.buffer);
    }
    return cachegetInt32Memory0;
}

function getArrayU8FromWasm0(ptr, len) {
    return getUint8Memory0().subarray(ptr / 1, ptr / 1 + len);
}
/**
* @param {Uint8Array} v
* @returns {Uint8Array}
*/
const hash = function(v) {
    var ptr0 = passArray8ToWasm0(v, wasm.__wbindgen_malloc);
    var len0 = WASM_VECTOR_LEN;
    wasm.hash(8, ptr0, len0);
    var r0 = getInt32Memory0()[8 / 4 + 0];
    var r1 = getInt32Memory0()[8 / 4 + 1];
    var v1 = getArrayU8FromWasm0(r0, r1).slice();
    wasm.__wbindgen_free(r0, r1 * 1);
    return v1;
};
export { hash };

import * as path from 'https://deno.land/std/path/mod.ts';
import WASI from 'https://deno.land/std/wasi/snapshot_preview1.ts';
const __dirname = path.dirname(new URL(import.meta.url).pathname);
const wasi = new WASI({
    args: Deno.args,
    env: Deno.env.toObject(),
    preopens: {
        '/': __dirname
    }
});
imports = { wasi_snapshot_preview1: wasi.exports };

const p = path.join(__dirname, 'blake3_bg.wasm');
const bytes = Deno.readFileSync(p);
const wasmModule = new WebAssembly.Module(bytes);
const wasmInstance = new WebAssembly.Instance(wasmModule, imports);
wasm = wasmInstance.exports;

wasi.memory = wasmInstance.exports.memory;

