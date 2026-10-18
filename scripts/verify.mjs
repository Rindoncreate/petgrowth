import { execFileSync } from 'node:child_process';
import { readFileSync, existsSync, readdirSync, statSync } from 'node:fs';
import { join } from 'node:path';
import assert from 'node:assert/strict';

const moon = process.env.MOON_BIN || join(process.platform === 'win32'
  ? process.env.USERPROFILE : process.env.HOME, '.moon', 'bin', process.platform === 'win32' ? 'moon.exe' : 'moon');
const run = (command, args) => execFileSync(command, args, { stdio: 'inherit' });
run(moon, ['version', '--all']);
run(moon, ['fmt', '--check']);
for (const target of ['js', 'wasm-gc', 'wasm']) {
  run(moon, ['check', '--target', target, '--deny-warn']);
  run(moon, ['test', '--target', target, '--deny-warn']);
}
const example = execFileSync(moon, ['run', 'examples/journal', '--target', 'js'], { encoding: 'utf8' });
const expected = ['Pet: 小橘', 'Diaries: 2', '2026-10-14: 4.125 kg', '2026-10-15: 4.2 kg',
  'Backup roundtrip: true', '小橘：我们已经 3 天没留下新回忆啦。'].join('\n');
assert.equal(example.trim().replace(/\r\n/g, '\n'), expected, 'library example must produce the documented output');
process.stdout.write(example);
run(process.execPath, ['scripts/build.mjs']);
for (const script of ['web/helpers.js', 'web/sw.js', 'scripts/serve.mjs']) {
  run(process.execPath, ['--check', script]);
}
for (const file of ['index.html', 'app.js', 'style.css', 'helpers.js', 'sw.js', 'icon.svg', 'manifest.webmanifest',
  'assets/Yozai-Regular.woff2', 'assets/puppy-growth-v2.png', 'assets/Yozai-OFL.txt']) {
  assert.ok(statSync(join('dist', file)).size > 0, `missing web asset: ${file}`);
}
const manifest = JSON.parse(readFileSync('dist/manifest.webmanifest', 'utf8'));
assert.equal(manifest.display, 'standalone');
assert.equal(manifest.start_url, '/');
assert.ok(existsSync('LICENSE'));
run(moon, ['package']);
const packages = readdirSync('_build/publish').filter(name => name.endsWith('.zip'));
assert.ok(packages.length > 0, 'Mooncakes source package must exist');
console.log('Verification passed: three targets, documented example, PWA assets and Mooncakes source package.');
