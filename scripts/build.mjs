import { execFileSync } from 'node:child_process';
import { cpSync, mkdirSync, copyFileSync } from 'node:fs';
import { join } from 'node:path';

const moon = process.env.MOON_BIN || (process.platform === 'win32'
  ? join(process.env.USERPROFILE, '.moon', 'bin', 'moon.exe')
  : join(process.env.HOME, '.moon', 'bin', 'moon'));

execFileSync(moon, ['build', 'app', '--target', 'js', '--release', '--deny-warn'], { stdio: 'inherit' });
mkdirSync('dist', { recursive: true });
cpSync('web', 'dist', { recursive: true, force: true });
copyFileSync(join('_build', 'js', 'release', 'build', 'app', 'app.js'), join('dist', 'app.js'));
console.log('Built dist/ with MoonBit application and PWA assets.');
