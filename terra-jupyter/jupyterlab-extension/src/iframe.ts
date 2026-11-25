import { JupyterFrontEnd } from '@jupyterlab/application';
import { ToolbarButton } from '@jupyterlab/apputils';
import { IDocumentManager } from '@jupyterlab/docmanager';
import { IMainMenu } from '@jupyterlab/mainmenu';
import { INotebookTracker, NotebookPanel } from '@jupyterlab/notebook';
import { closeIcon } from '@jupyterlab/ui-components';

import { CLOSE_BUTTON_TITLE } from './strings';

// Terra UI's AnalysisLauncher listens for exactly these messages and sends 'save'.
export const MESSAGE_CLOSE = 'close';
export const MESSAGE_DIRTY = 'dirty';
export const MESSAGE_SAVED = 'saved';
export const MESSAGE_SAVE = 'save';

export const CLOSE_COMMAND = 'terra:close-and-shutdown';
const AUTOSAVE_INTERVAL_SECONDS = 15;
// The CSS in style/base.css hides the New/Open entries and the stock close command under this class.
const IFRAME_CLASS = 'terra-in-iframe';

export function isInIframe(): boolean {
  return window.parent !== window;
}

/** Port of Terra UI's classic jupyter-iframe-extension.js. Does nothing outside an iframe. */
export function setUpIframeIntegration(
  app: JupyterFrontEnd,
  tracker: INotebookTracker,
  docManager: IDocumentManager,
  mainMenu: IMainMenu | null
): void {
  if (!isInIframe()) {
    return;
  }
  document.body.classList.add(IFRAME_CLASS);

  // Set after restore so the docmanager settings, loaded earlier, don't overwrite it.
  void app.restored.then(() => {
    docManager.autosaveInterval = AUTOSAVE_INTERVAL_SECONDS;
  });

  app.commands.addCommand(CLOSE_COMMAND, {
    label: 'Close and Shut Down Notebook',
    caption: CLOSE_BUTTON_TITLE,
    isEnabled: () => tracker.currentWidget !== null,
    execute: async () => {
      // The classic extension shut the kernel down without asking.
      await tracker.currentWidget?.sessionContext.shutdown();
      window.parent.postMessage(MESSAGE_CLOSE, '*');
    }
  });
  mainMenu?.fileMenu.addItem({ command: CLOSE_COMMAND, rank: 1 });

  tracker.widgetAdded.connect((_, panel) => addCloseButton(app, panel));
  tracker.forEach(panel => addCloseButton(app, panel));

  let watched: NotebookPanel | null = null;
  const onStateChanged = (
    _: unknown,
    change: { name: string; newValue: unknown }
  ) => {
    if (change.name === 'dirty') {
      window.parent.postMessage(
        change.newValue ? MESSAGE_DIRTY : MESSAGE_SAVED,
        '*'
      );
    }
  };
  const watch = (panel: NotebookPanel | null) => {
    watched?.context.model.stateChanged.disconnect(onStateChanged);
    watched = panel;
    panel?.context.model.stateChanged.connect(onStateChanged);
  };
  tracker.currentChanged.connect((_, panel) => watch(panel));
  watch(tracker.currentWidget);

  window.addEventListener('message', event => {
    if (event.data === MESSAGE_SAVE) {
      void tracker.currentWidget?.context.save();
    }
  });
}

function addCloseButton(app: JupyterFrontEnd, panel: NotebookPanel): void {
  const button = new ToolbarButton({
    icon: closeIcon,
    tooltip: CLOSE_BUTTON_TITLE,
    className: 'terra-CloseButton',
    onClick: () => void app.commands.execute(CLOSE_COMMAND)
  });
  panel.toolbar.addItem('terraClose', button);
}
