import { createServer } from 'node:http';
import { readFile, stat } from 'node:fs/promises';
import { extname, join, normalize } from 'node:path';

const root = join(process.cwd(), 'dist');
const types = { '.html': 'text/html', '.js': 'text/javascript', '.css': 'text/css', '.svg': 'image/svg+xml', '.png': 'image/png', '.woff2': 'font/woff2', '.webmanifest': 'application/manifest+json' };
createServer(async (request, response) => {
  const path = normalize(decodeURIComponent(new URL(request.url, 'http://localhost').pathname)).replace(/^[/\\]+/, '');
  const target = join(root, path || 'index.html');
  if (!target.startsWith(root)) { response.writeHead(403).end(); return; }
  try {
    if (!(await stat(target)).isFile()) throw new Error('not a file');
    const bytes = await readFile(target);
    response.writeHead(200, { 'content-type': `${types[extname(target)] || 'application/octet-stream'}; charset=utf-8` });
    response.end(bytes);
  } catch (_) {
    response.writeHead(404).end('Not found');
  }
}).listen(Number(process.env.PORT || 4173), '127.0.0.1', () => console.log('http://127.0.0.1:4173'));
