export type SyncMode = 'EDIT' | 'SAFE' | string;

export interface IStorageLink {
  localBaseDirectory: string;
  localSafeModeBaseDirectory: string;
  cloudStorageDirectory: string;
  pattern?: string;
}

/** Welder's `/objects/metadata` response; only the fields this extension reads. */
export interface IWelderMetadata {
  syncMode: SyncMode;
  syncStatus?: string;
  storageLink: IStorageLink;
}

export type SyncStatusAction =
  'healthy' | 'notFound' | 'saveNeeded' | 'outOfSync';

/**
 * Maps Welder's syncStatus to what the edit mode UI does. Unknown statuses count as out of sync,
 * so a status Welder adds later is not silently treated as healthy.
 */
export function classifySyncStatus(
  syncStatus: string | undefined
): SyncStatusAction {
  switch (syncStatus) {
    case 'LIVE':
      return 'healthy';
    case 'REMOTE_NOT_FOUND':
      return 'notFound';
    case 'LOCAL_CHANGED':
      return 'saveNeeded';
    default:
      return 'outOfSync';
  }
}

export function isEditMode(meta: IWelderMetadata): boolean {
  return meta.syncMode === 'EDIT';
}

/** Splits a contents-API path into its directory and file name. */
export function splitPath(path: string): { dir: string; name: string } {
  const index = path.lastIndexOf('/');
  return index < 0
    ? { dir: '', name: path }
    : { dir: path.slice(0, index), name: path.slice(index + 1) };
}

export function joinPath(dir: string, name: string): string {
  return dir ? `${dir.replace(/\/+$/, '')}/${name}` : name;
}

export function isInDirectory(path: string, dir: string): boolean {
  return path.includes(dir);
}

/** The playground copy keeps the original file name inside the safe-mode directory. */
export function playgroundPath(
  meta: IWelderMetadata,
  notebookPath: string
): string {
  return joinPath(
    meta.storageLink.localSafeModeBaseDirectory,
    splitPath(notebookPath).name
  );
}

export function remoteSourceUri(
  meta: IWelderMetadata,
  notebookPath: string
): string {
  return `${meta.storageLink.cloudStorageDirectory}/${splitPath(notebookPath).name}`;
}
