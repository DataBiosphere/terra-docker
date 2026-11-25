import { Widget } from '@lumino/widgets';

import {
  BANNER_CHECK_FAILED,
  BANNER_EDIT,
  BANNER_EDIT_TOOLTIP,
  BANNER_NOT_TRACKED,
  BANNER_NOT_TRACKED_TOOLTIP,
  BANNER_PLAYGROUND,
  BANNER_PLAYGROUND_TOOLTIP
} from './strings';

export type BannerState =
  'none' | 'edit' | 'playground' | 'notTracked' | 'checkFailed';

const CONTENT: Record<
  Exclude<BannerState, 'none'>,
  { text: string; tooltip: string; className: string }
> = {
  edit: {
    text: BANNER_EDIT,
    tooltip: BANNER_EDIT_TOOLTIP,
    className: 'terra-SyncBanner-edit'
  },
  playground: {
    text: BANNER_PLAYGROUND,
    tooltip: BANNER_PLAYGROUND_TOOLTIP,
    className: 'terra-SyncBanner-warning'
  },
  notTracked: {
    text: BANNER_NOT_TRACKED,
    tooltip: BANNER_NOT_TRACKED_TOOLTIP,
    className: 'terra-SyncBanner-warning'
  },
  checkFailed: {
    text: BANNER_CHECK_FAILED,
    tooltip: '',
    className: 'terra-SyncBanner-error'
  }
};

/** Notebook toolbar item showing the Welder sync mode; toolbars exist in both Lab 4 and Notebook 7. */
export class SyncBanner extends Widget {
  constructor() {
    super();
    this.addClass('terra-SyncBanner');
    this.setState('none');
  }

  get state(): BannerState {
    return this._state;
  }

  setState(state: BannerState): void {
    this._state = state;
    this.node.className = 'lm-Widget terra-SyncBanner';
    if (state === 'none') {
      this.node.textContent = '';
      this.node.title = '';
      this.hide();
      return;
    }
    const content = CONTENT[state];
    this.node.classList.add(content.className);
    this.node.textContent = content.text;
    this.node.title = content.tooltip;
    this.show();
  }

  private _state: BannerState = 'none';
}
