// El worker se genera después de compilar, con el inventario de recursos real.
if ('serviceWorker' in navigator && window.isSecureContext) {
  window.addEventListener('load', async () => {
    try {
      const registration = await navigator.serviceWorker.register(
        new URL('sw.js', document.baseURI), { scope: new URL('.', document.baseURI).href, updateViaCache: 'none' }
      );
      await navigator.serviceWorker.ready;
      if (!registration.active) return;
      const status = document.createElement('div');
      status.id = 'offline-status';
      status.setAttribute('role', 'status');
      status.textContent = 'Listo para jugar sin conexión';
      document.body.appendChild(status);
      setTimeout(() => status.remove(), 4500);
    } catch (error) {
      // En flutter run el worker todavía no existe. El juego sigue disponible en línea.
      console.info('Caché sin conexión no disponible:', error.message);
    }
  });
}
