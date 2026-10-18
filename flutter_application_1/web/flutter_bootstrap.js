{{flutter_js}}
{{flutter_build_config}}

const puzzleConfig = { canvasKitBaseUrl: new URL('canvaskit/', document.baseURI).href };
_flutter.loader.load({
  config: puzzleConfig,
  onEntrypointLoaded: async function(engineInitializer) {
    const runner = await engineInitializer.initializeEngine(puzzleConfig);
    await runner.runApp();
    document.getElementById('loading')?.remove();
  }
});
