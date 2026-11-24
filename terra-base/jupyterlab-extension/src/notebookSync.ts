import { NotebookPanel } from '@jupyterlab/notebook';
import { Contents } from '@jupyterlab/services';

import { SyncBanner } from './banner';
import { promptUserWithModal } from './dialogs';
import { ISyncLoop, ITimers, startSyncLoop } from './schedule';
import {
  BUTTON_CONTINUE,
  BUTTON_MAKE_COPY,
  BUTTON_PLAYGROUND,
  BUTTON_RELOAD,
  LOCK_CONFLICT_BODY,
  LOCK_CONFLICT_TITLE,
  SYNC_ISSUE_BODY,
  SYNC_ISSUE_NOT_FOUND_BODY,
  SYNC_ISSUE_TITLE
} from './strings';
import {
  IWelderMetadata,
  classifySyncStatus,
  isEditMode,
  isInDirectory,
  playgroundPath,
  remoteSourceUri,
  splitPath
} from './sync';
import { WelderClient } from './welder';

/** `unknown` means the status check failed; the controls stay visible, as in the classic UI. */
export type NotebookMode = 'edit' | 'playground' | 'unknown';

export interface INotebookSyncDeps {
  welder: WelderClient;
  contents: Contents.IManager;
  timers: ITimers;
  /** Opens a file in place of the current one (Notebook 7) or in a new tab (Lab). */
  openFile: (path: string) => Promise<void>;
  onModeChanged: (panel: NotebookPanel, mode: NotebookMode) => void;
}

/** Per-notebook port of the classic edit-mode nbextension. */
export class NotebookSyncController {
  constructor(
    private readonly panel: NotebookPanel,
    private readonly deps: INotebookSyncDeps
  ) {
    this.banner = new SyncBanner();
    panel.toolbar.insertItem(0, 'terraSyncMode', this.banner);
    panel.disposed.connect(() => this.dispose());
  }

  readonly banner: SyncBanner;

  get mode(): NotebookMode {
    return this._mode;
  }

  start(): void {
    this.loop = startSyncLoop(() => void this.tick(), this.deps.timers);
  }

  dispose(): void {
    this.loop?.stop();
  }

  private get path(): string {
    return this.panel.context.path;
  }

  private setMode(mode: NotebookMode): void {
    this._mode = mode;
    this.deps.onModeChanged(this.panel, mode);
  }

  private async tick(): Promise<void> {
    const result = await this.deps.welder.checkMetadata(this.path);
    if (this.loop?.stopped) {
      return;
    }
    switch (result.kind) {
      case 'notTracked':
        console.warn('detected 412 from /objects/metadata. stopping loop');
        this.banner.setState('notTracked');
        this.loop?.stop();
        this.setMode('unknown');
        return;
      case 'error':
        console.error(result.error);
        this.banner.setState('checkFailed');
        this.setMode('unknown');
        return;
      case 'ok': {
        const editMode = isEditMode(result.meta);
        if (editMode) {
          this.handleSyncStatus(result.meta);
          await this.takeLock(result.meta);
        }
        this.banner.setState(editMode ? 'edit' : 'playground');
        this.setMode(editMode ? 'edit' : 'playground');
        return;
      }
    }
  }

  private handleSyncStatus(meta: IWelderMetadata): void {
    switch (classifySyncStatus(meta.syncStatus)) {
      case 'healthy':
        console.info('healthy sync status detected: ', meta.syncStatus);
        return;
      case 'saveNeeded':
        // Autosave delocalizes these changes on its next tick.
        console.info(
          'detected that we have changes that have not been delocalized.'
        );
        return;
      case 'notFound':
        void promptUserWithModal(
          SYNC_ISSUE_TITLE,
          [SYNC_ISSUE_NOT_FOUND_BODY],
          [{ label: BUTTON_CONTINUE, primary: true, action: () => undefined }]
        );
        return;
      case 'outOfSync':
        void promptUserWithModal(
          SYNC_ISSUE_TITLE,
          [SYNC_ISSUE_BODY],
          [
            {
              label: BUTTON_MAKE_COPY,
              primary: true,
              action: () => this.makeCopy()
            },
            {
              label: BUTTON_RELOAD,
              action: () => this.reloadFromWorkspace(meta)
            }
          ]
        );
        return;
    }
  }

  private async takeLock(meta: IWelderMetadata): Promise<void> {
    const lock = await this.deps.welder.lock(this.path);
    if (lock === 'conflict') {
      void promptUserWithModal(LOCK_CONFLICT_TITLE, LOCK_CONFLICT_BODY, [
        {
          label: BUTTON_PLAYGROUND,
          primary: true,
          action: () => this.openPlaygroundMode(meta)
        },
        { label: BUTTON_MAKE_COPY, action: () => this.makeCopy() }
      ]);
    } else if (lock === 'error') {
      console.error('failed to acquire the Welder lock for', this.path);
    }
  }

  private async makeCopy(): Promise<void> {
    // The contents API picks a free name next to the original.
    const copy = await this.deps.contents.copy(
      this.path,
      splitPath(this.path).dir
    );
    await this.deps.openFile(copy.path);
  }

  private async openPlaygroundMode(meta: IWelderMetadata): Promise<void> {
    const safeModeDir = meta.storageLink.localSafeModeBaseDirectory;
    if (isInDirectory(this.path, safeModeDir)) {
      console.warn(
        'Attempted to navigate to enter safe mode while already in safe mode. Exitting.'
      );
      return;
    }
    const target = playgroundPath(meta, this.path);
    const copy = await this.deps.contents.copy(this.path, safeModeDir);
    try {
      await this.deps.contents.rename(copy.path, target);
    } catch (error) {
      // An earlier playground copy keeps the name; the classic extension opened it anyway.
      console.warn('could not rename playground copy', error);
    }
    await this.deps.openFile(target);
  }

  private async reloadFromWorkspace(meta: IWelderMetadata): Promise<void> {
    await this.deps.welder.localize(
      remoteSourceUri(meta, this.path),
      this.path
    );
    await this.panel.context.revert();
  }

  private loop: ISyncLoop | undefined;
  private _mode: NotebookMode = 'unknown';
}
