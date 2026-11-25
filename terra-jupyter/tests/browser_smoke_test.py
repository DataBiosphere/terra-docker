"""Loads Notebook 7 and JupyterLab in a headless browser and checks terra-jupyterlab-extension.

Run by browser_smoke_test.sh. The extension's Welder metadata check fails there (nothing serves
Leonardo's proxy path), so it shows its failure banner, which proves it loaded.
"""
import sys

from playwright.sync_api import sync_playwright

SERVER = sys.argv[1]  # e.g. http://terra-jupyter:8000/notebooks/test-project/test-runtime
FAILURE_BANNER = 'Failed to check notebook status'
CLOSE_TITLE = "Shutdown this notebook's kernel, and close this window"


def check(description, ok):
  print(('PASS: ' if ok else 'FAIL: ') + description)
  if not ok:
    sys.exit(1)


# Stock Notebook 7.6.5 raises this on load, with no extensions installed; the page still works.
KNOWN_UPSTREAM_ERRORS = {"Cannot read properties of undefined (reading 'schema')"}


def page_errors(page):
  errors = []
  page.on('pageerror', lambda e: None if str(e) in KNOWN_UPSTREAM_ERRORS else errors.append(str(e)))
  # Violations of Leonardo's Content-Security-Policy are only reported on the console.
  page.on('console', lambda m: errors.append(m.text) if 'Content Security Policy' in m.text else None)
  return errors


with sync_playwright() as p:
  browser = p.chromium.launch()

  def check_ui(name, url):
    page = browser.new_page()
    errors = page_errors(page)
    page.goto(url)
    page.get_by_text(FAILURE_BANNER).first.wait_for(timeout=120000)
    check(f'{name}: extension shows the Welder failure banner', True)
    check(f'{name}: no uncaught page errors ({errors})', not errors)
    page.close()

  check_ui('Notebook 7', f'{SERVER}/notebooks/test.ipynb')

  # Terra UI embeds Notebook 7 in an iframe and talks to it with postMessage.
  page = browser.new_page()
  errors = page_errors(page)
  # Jupyter only allows framing from its own origin (Leonardo's proxy handles Terra UI's origin), so
  # the parent is a same-origin page; api/ responses forbid framing, the tree view does not.
  page.goto(f'{SERVER}/tree')
  page.evaluate(f"""() => {{
    window.received = [];
    window.addEventListener('message', e => window.received.push(e.data));
    const frame = document.createElement('iframe');
    frame.id = 'nb';
    frame.style.cssText = 'position: fixed; top: 0; left: 0; z-index: 10000; background: white;';
    frame.style.width = '1200px';
    frame.style.height = '800px';
    frame.src = '{SERVER}/notebooks/test.ipynb';
    document.body.appendChild(frame);
  }}""")
  frame = page.frame_locator('#nb')
  frame.locator(f'[title="{CLOSE_TITLE}"]').first.wait_for(timeout=120000)
  check('iframe: close button is shown', True)

  frame.locator('.jp-Cell .cm-content').first.click()
  page.keyboard.type('1 + 1')
  page.wait_for_function("() => window.received.includes('dirty')", timeout=30000)
  check("iframe: editing posts 'dirty' to the parent", True)

  page.evaluate("() => document.getElementById('nb').contentWindow.postMessage('save', '*')")
  page.wait_for_function("() => window.received.includes('saved')", timeout=30000)
  check("iframe: 'save' from the parent saves and posts 'saved'", True)

  frame.locator(f'[title="{CLOSE_TITLE}"]').first.click()
  page.wait_for_function("() => window.received.includes('close')", timeout=30000)
  check("iframe: close button posts 'close'", True)
  check(f'iframe: no uncaught page errors ({errors})', not errors)

  check_ui('JupyterLab', f'{SERVER}/lab/tree/test.ipynb')

  browser.close()

print('All browser checks passed')
