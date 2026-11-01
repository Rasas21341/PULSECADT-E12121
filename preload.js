const { contextBridge } = require('electron');

contextBridge.exposeInMainWorld('pulseCad', {
  platform: process.platform,
  version: process.versions.electron
});
