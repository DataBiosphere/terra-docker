import {
  JupyterFrontEnd,
  JupyterFrontEndPlugin
} from '@jupyterlab/application';
import { PageConfig, URLExt } from '@jupyterlab/coreutils';
import { IDocumentManager } from '@jupyterlab/docmanager';
import { IMainMenu } from '@jupyterlab/mainmenu';
import { INotebookTracker, NotebookPanel } from '@jupyterlab/notebook';
import { ServerConnection } from '@jupyterlab/services';

import { ITerraConfig, parseBaseUrl, readConfig, welderUrls } from './config';
import { setUpIframeIntegration } from './iframe';
import { NotebookMode, NotebookSyncController } from './notebookSync';
import { setPlaygroundControlsHidden } from './safeMode';
import { browserTimers } from './schedule';
import { WelderClient } from './welder';

async function loadConfig(): Promise<ITerraConfig> {
  const settings = ServerConnection.makeSettings();
  try {
    const response = await ServerConnection.makeRequest(
      URLExt.join(settings.baseUrl, 'api', 'terra', 'config'),
      { method: 'GET' },
      settings
    );
    if (response.ok) {
      const config = readConfig(await response.json());
      if (config) {
        return config;
      }
    }
    console.warn('unexpected response from api/terra/config', response.status);
  } catch (error) {
    console.warn('failed to load api/terra/config', error);
  }
  return parseBaseUrl(settings.baseUrl);
}

const plugin: JupyterFrontEndPlugin<void> = {
  id: 'terra-jupyterlab-extension:plugin',
  description:
    'Terra edit mode, playground mode and Terra UI iframe integration.',
  autoStart: true,
  requires: [INotebookTracker, IDocumentManager],
  optional: [IMainMenu],
  activate: async (
    app: JupyterFrontEnd,
    tracker: INotebookTracker,
    docManager: IDocumentManager,
    mainMenu: IMainMenu | null
  ) => {
    setUpIframeIntegration(app, tracker, docManager, mainMenu);

    const config = await loadConfig();
    if (!config.welderEnabled) {
      console.info('welder is not enabled');
      return;
    }

    const isNotebook7 = app.name === 'Jupyter Notebook';
    // Notebook 7 shows one document per page and would open others in a new browser tab, which
    // breaks inside Terra UI's iframe; navigate in place like the classic extension did.
    const openFile = async (path: string) => {
      if (isNotebook7) {
        window.location.href = URLExt.join(
          PageConfig.getBaseUrl(),
          'notebooks',
          URLExt.encodeParts(path)
        );
      } else {
        docManager.openOrReveal(path);
      }
    };

    const controllers = new WeakMap<NotebookPanel, NotebookSyncController>();
    const applySafeMode = (mode: NotebookMode) =>
      setPlaygroundControlsHidden(mode === 'playground');
    const onModeChanged = (panel: NotebookPanel, mode: NotebookMode) => {
      if (tracker.currentWidget === panel) {
        applySafeMode(mode);
      }
    };
    tracker.currentChanged.connect((_, panel) => {
      applySafeMode(
        panel ? (controllers.get(panel)?.mode ?? 'unknown') : 'unknown'
      );
    });

    const welder = new WelderClient(welderUrls(config), (input, init) =>
      fetch(input, init)
    );
    const track = (panel: NotebookPanel) => {
      if (controllers.has(panel)) {
        return;
      }
      const controller = new NotebookSyncController(panel, {
        welder,
        contents: app.serviceManager.contents,
        timers: browserTimers,
        openFile,
        onModeChanged
      });
      controllers.set(panel, controller);
      void panel.context.ready.then(() => controller.start());
    };
    tracker.widgetAdded.connect((_, panel) => track(panel));
    tracker.forEach(track);
  }
};

export default plugin;
