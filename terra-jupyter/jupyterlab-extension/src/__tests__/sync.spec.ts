import {
  IWelderMetadata,
  classifySyncStatus,
  isEditMode,
  isInDirectory,
  joinPath,
  playgroundPath,
  remoteSourceUri,
  splitPath
} from '../sync';

const meta: IWelderMetadata = {
  syncMode: 'EDIT',
  syncStatus: 'LIVE',
  storageLink: {
    localBaseDirectory: 'ws/edit',
    localSafeModeBaseDirectory: 'ws/safe',
    cloudStorageDirectory: 'gs://bucket/notebooks'
  }
};

describe('classifySyncStatus', () => {
  it.each([
    ['LIVE', 'healthy'],
    ['REMOTE_NOT_FOUND', 'notFound'],
    ['LOCAL_CHANGED', 'saveNeeded'],
    ['DESYNCHRONIZED', 'outOfSync'],
    ['REMOTE_CHANGED', 'outOfSync'],
    ['SOMETHING_NEW', 'outOfSync'],
    [undefined, 'outOfSync']
  ])('%s -> %s', (status, action) => {
    expect(classifySyncStatus(status)).toBe(action);
  });
});

describe('paths', () => {
  it('splits paths', () => {
    expect(splitPath('ws/edit/a.ipynb')).toEqual({
      dir: 'ws/edit',
      name: 'a.ipynb'
    });
    expect(splitPath('a.ipynb')).toEqual({ dir: '', name: 'a.ipynb' });
  });

  it('joins paths', () => {
    expect(joinPath('ws/safe/', 'a.ipynb')).toBe('ws/safe/a.ipynb');
    expect(joinPath('', 'a.ipynb')).toBe('a.ipynb');
  });

  it('puts the playground copy in the safe-mode directory with the original name', () => {
    expect(playgroundPath(meta, 'ws/edit/a.ipynb')).toBe('ws/safe/a.ipynb');
  });

  it('detects files already in the safe-mode directory', () => {
    expect(isInDirectory('ws/safe/a.ipynb', 'ws/safe')).toBe(true);
    expect(isInDirectory('ws/edit/a.ipynb', 'ws/safe')).toBe(false);
  });

  it('builds the workspace source URI from the file name', () => {
    expect(remoteSourceUri(meta, 'ws/edit/a.ipynb')).toBe(
      'gs://bucket/notebooks/a.ipynb'
    );
  });

  it('reads the sync mode', () => {
    expect(isEditMode(meta)).toBe(true);
    expect(isEditMode({ ...meta, syncMode: 'SAFE' })).toBe(false);
  });
});
