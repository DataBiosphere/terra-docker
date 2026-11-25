import { Dialog, showDialog } from '@jupyterlab/apputils';
import { Widget } from '@lumino/widgets';

export interface IModalButton {
  label: string;
  primary?: boolean;
  action: () => void | Promise<void>;
}

// The classic extension never stacked dialogs; the sync loop can ask for one every minute.
let modalOpen = false;

export function isModalOpen(): boolean {
  return modalOpen;
}

export async function promptUserWithModal(
  title: string,
  paragraphs: string[],
  buttons: IModalButton[]
): Promise<void> {
  if (modalOpen) {
    return;
  }
  modalOpen = true;
  try {
    const body = new Widget();
    for (const text of paragraphs) {
      const p = document.createElement('p');
      p.textContent = text;
      body.node.appendChild(p);
    }
    const result = await showDialog({
      title,
      body,
      hasClose: false,
      buttons: buttons.map(button =>
        button.primary
          ? Dialog.okButton({ label: button.label })
          : Dialog.cancelButton({ label: button.label })
      )
    });
    // Escape resolves with Lab's own cancel button, whose label matches none of ours.
    const clicked = buttons.find(
      button => button.label === result.button.label
    );
    if (clicked) {
      await clicked.action();
    }
  } finally {
    modalOpen = false;
  }
}
