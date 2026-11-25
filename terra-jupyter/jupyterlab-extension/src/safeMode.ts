// Playground (safe) mode hides the controls that save or copy the notebook. The CSS in
// style/base.css keys off this class and the menu and toolbar items' data-command attributes.
const PLAYGROUND_CLASS = 'terra-playground-mode';

export function setPlaygroundControlsHidden(hidden: boolean): void {
  document.body.classList.toggle(PLAYGROUND_CLASS, hidden);
}
