// User-facing text, kept identical to the classic edit-mode/safe-mode nbextensions and Terra UI's
// iframe extension.

export const LOCK_CONFLICT_TITLE = 'File is in use';
export const LOCK_CONFLICT_BODY = [
  'This file is currently being edited by another user. ' +
    'Please allow 2-3 minutes after this user has closed the file for it to become available for editing.',
  'You can make a copy, or run it in Playground Mode to explore and execute its contents without saving any changes.'
];

export const SYNC_ISSUE_TITLE = 'File versions out of sync';
export const SYNC_ISSUE_BODY =
  'Your version of this file does not match the version in the workspace. What would you like to do?';
export const SYNC_ISSUE_NOT_FOUND_BODY =
  'This file was either deleted from or was never saved to the workspace.';

export const BUTTON_MAKE_COPY = 'Make a Copy';
export const BUTTON_RELOAD =
  'Reload the workspace version and discard your changes';
export const BUTTON_PLAYGROUND = 'Run in Playground Mode';
export const BUTTON_CONTINUE = 'Continue working';

export const BANNER_EDIT = 'Edit Mode';
export const BANNER_EDIT_TOOLTIP =
  'You have locked this file for editing and your changes are being automatically saved to the workspace.';
export const BANNER_PLAYGROUND = 'Playground Mode (Edits not saved)';
export const BANNER_PLAYGROUND_TOOLTIP =
  'Playground mode allows you to explore, change, and run the notebook, but changes are not saved to the workspace.';
export const BANNER_NOT_TRACKED = 'Remote Save Disabled';
export const BANNER_NOT_TRACKED_TOOLTIP =
  'Your changes are not being saved to the workspace.';
export const BANNER_CHECK_FAILED =
  'Failed to check notebook status, changes may not be saved to workspace. Retrying...';

export const CLOSE_BUTTON_TITLE =
  "Shutdown this notebook's kernel, and close this window";
