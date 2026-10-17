(function () {
  function chooseFile(accept, callback) {
    const input = document.createElement('input');
    input.type = 'file';
    input.accept = accept;
    input.style.display = 'none';
    document.body.appendChild(input);
    input.addEventListener('change', () => {
      const file = input.files && input.files[0];
      input.remove();
      if (file) callback(file);
    }, { once: true });
    input.click();
  }

  window.petgrowthPickPhoto = function (callback) {
    chooseFile('image/*', async (file) => {
      try {
        const bitmap = await createImageBitmap(file);
        const scale = Math.min(1, 1200 / Math.max(bitmap.width, bitmap.height));
        const canvas = document.createElement('canvas');
        canvas.width = Math.max(1, Math.round(bitmap.width * scale));
        canvas.height = Math.max(1, Math.round(bitmap.height * scale));
        const ctx = canvas.getContext('2d');
        ctx.drawImage(bitmap, 0, 0, canvas.width, canvas.height);
        bitmap.close();
        callback(file.type === 'image/png'
          ? canvas.toDataURL('image/png')
          : canvas.toDataURL('image/jpeg', 0.72));
      } catch (_) {
        callback('');
      }
    });
  };

  window.petgrowthPickBackup = function (callback) {
    chooseFile('.json,application/json', async (file) => {
      try {
        if (file.size > 15 * 1024 * 1024) throw new Error('too large');
        callback(await file.text());
      } catch (_) {
        callback('');
      }
    });
  };

  window.petgrowthDownloadBackup = function (raw) {
    const blob = new Blob([raw], { type: 'application/json;charset=utf-8' });
    const url = URL.createObjectURL(blob);
    const link = document.createElement('a');
    link.href = url;
    link.download = `petgrowth-backup-${new Date().toISOString().slice(0, 10)}.json`;
    document.body.appendChild(link);
    link.click();
    link.remove();
    setTimeout(() => URL.revokeObjectURL(url), 5000);
  };

  // The deck supports touch, mouse wheel, and keyboard without duplicating state.
  let start = null;
  let lastTurn = 0;
  function turn(direction) {
    const now = Date.now();
    if (now - lastTurn < 380) return;
    const control = document.getElementById(direction > 0 ? 'card-next' : 'card-prev');
    if (control && !control.disabled) {
      control.click();
      lastTurn = now;
    }
  }
  document.addEventListener('pointerdown', event => {
    if (event.target.closest('.diary-deck')) start = { x: event.clientX, y: event.clientY };
  });
  document.addEventListener('pointerup', event => {
    if (!start) return;
    const dx = start.x - event.clientX;
    const dy = start.y - event.clientY;
    start = null;
    if (Math.max(Math.abs(dx), Math.abs(dy)) > 35) {
      turn(Math.abs(dy) > Math.abs(dx) ? dy : dx);
    }
  });
  document.addEventListener('click', event => {
    if (Date.now() - lastTurn < 150 && event.target.closest('.diary-paper')) {
      event.stopPropagation();
      event.preventDefault();
    }
  }, true);
  document.addEventListener('wheel', event => {
    if (!event.target.closest('.diary-deck')) return;
    event.preventDefault();
    if (Math.abs(event.deltaY) > 12) turn(event.deltaY);
  }, { passive: false });
  document.addEventListener('keydown', event => {
    if (event.target.matches('input,textarea,select') || document.querySelector('.modal-layer')) return;
    if (event.key === 'ArrowRight' || event.key === 'ArrowDown') turn(1);
    if (event.key === 'ArrowLeft' || event.key === 'ArrowUp') turn(-1);
  });
})();
