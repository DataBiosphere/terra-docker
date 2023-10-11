/*
 * This library is designed to run as a Jupyter/JupyterLab extension to refresh the user's
 * Google credentials while using a notebook. This flow is described in more detail here:
 * https://github.com/DataBiosphere/leonardo/wiki/Connecting-to-a-Leo-Notebook#token-refresh
 *
 * Note since this runs inside both Jupyter and JupyterLab, it should not use any
 * libraries/functionality that exists in one but not the other. Examples: node, requireJS.
 */


// define default values for config parameters
const params = {
  loginHint: '',
  googleClientId: '',
  googleProject: '',
  clusterName: ''
};

// update params with any specified in the server's config file,
// or retrieve that info from the url if we cannot access it (as is the case in terminal view)
function updateParams() {
  if (!Jupyter.notebook || !Jupyter.notebook.config || !Jupyter.notebook.config.data) {
    console.warn('Unable to read notebook config. This is expected in terminal view, but not elsewhere. Attempting to read fallback config.');
    readFallbackConfig();
  } else {
    readNotebookConfig(Jupyter.notebook.config.data);
  }
}

function readNotebookConfig(config) {
  for (const key in params) {
    if (config.hasOwnProperty(key)) {
      params[key] = config[key];
    }
  }
}

// here we attempt to parse the url for the googleProject and the clusterName
function readFallbackConfig() {
  const url = window.location.href;
  const initialSearch = 'proxy/';

  const projectSubstringStartLocation = url.search(initialSearch) + initialSearch.length;
  const projectSubstring = url.substring(projectSubstringStartLocation, url.length);
  const projectEndLocation = projectSubstring.search('/');
  const googleProject = projectSubstring.substring(0, projectEndLocation);

  // we add 1 for the slash between project and cluster
  const clusterSubstring = projectSubstring.substring(projectEndLocation + 1, projectSubstring.length);
  const clusterEndLocation = clusterSubstring.search('/');
  const clusterName = clusterSubstring.substring(0, clusterEndLocation);

  console.info(`Attempted to parse the url for a fallback configuration. 
                         Found googleProject: '${googleProject}' and clusterName '${clusterName}'`);

  params.googleProject = googleProject;
  params.clusterName = clusterName;

  fallbackReadNotebookConfig(googleProject, clusterName);
}

function fallbackReadNotebookConfig(googleProject, clusterName) {
  const url = `/proxy/${googleProject}/${clusterName}/jupyter/api/config/notebook`;
  xhttpGet(url, (res) => {
    readNotebookConfig(res);
  });
}

function receive(event) {
  if (event.data.type == 'bootstrap-auth.response') {
    if (event.source !== window.opener) {
      return;
    }
    params.googleClientId = event.data.body.googleClientId;
  } else if (event.data.type == 'bootstrap-auth.request') {
    if (event.origin !== window.origin) {
      return;
    }
    if (!params.googleClientId) {
      return;
    }
    event.source.postMessage({
      'type': 'bootstrap-auth.response',
      'body': {
        'googleClientId': params.googleClientId
      }
    }, event.origin);
  }
}

// https://developer.mozilla.org/en-US/docs/Web/API/XMLHttpRequest/response
function xhttpGet(url, callback) {
  const xhr = new XMLHttpRequest();

  xhr.onreadystatechange = function() {
    if (xhr.readyState === 4 && xhr.status == 200) {
      const jsonResp = JSON.parse(xhr.responseText);
      callback(jsonResp);
    }
  };

  xhr.open('GET', url, true);
  xhr.send('');
}

function startTimer() {
  loadGapi('auth2', function() {
    function doAuth() {
      if (params.googleClientId) {
        gapi.auth2.authorize({
          'client_id': params.googleClientId,
          'scope': 'openid profile email',
          'login_hint': params.loginHint,
          'prompt': 'none'
        }, function(result) {
          if (result.error) {
            console.error('Error occurred authorizing with Google: ' + result.error);
            return;
          }
          setCookie(result.access_token, result.expires_in);
        });
      }
    }

    // refresh token every 3 minutes
    console.log('Starting token refresh timer');
    setInterval(doAuth, 180000);
  });

  function statusCheck() {
    const url = `/proxy/${params.googleProject}/${params.clusterName}/jupyter/api/status`;
    // logging the statusCheck can be noisy, and it will tell us in the console if it fails
    xhttpGet(url, () => {});
  }

  setInterval(statusCheck, 60000);
}

// Note: this should match
// https://github.com/DataBiosphere/leonardo/blob/develop/http/src/main/scala/org/broadinstitute/dsde/workbench/leonardo/util/CookieHelper.scala
function setCookie(token, expiresIn) {
  document.cookie = 'LeoToken=' + token + '; Max-Age=' + expiresIn + '; Path=/; Secure; SameSite=None';
}

function loadGapi(googleLib, continuation) {
  console.log('Loading Google APIs');
  // Get the gapi script from Google.
  const gapiScript = document.createElement('script');
  gapiScript.src = 'https://apis.google.com/js/api.js';
  gapiScript.type = 'text/javascript';
  gapiScript.async = true;

  // Load requested API scripts onto the page.
  gapiScript.onload = function() {
    console.log('Loading Google library \'' + googleLib + '\'');
    gapi.load(googleLib, continuation);
  };
  gapiScript.onerror = function() {
    console.error('Unable to load Google APIs');
  };
  document.head.appendChild(gapiScript);
}

function init() {
  console.log('Starting google_sign_in extension');
  updateParams();
  startTimer();
  window.addEventListener('message', receive);
  if (!params.googleClientId && window.opener) {
    window.opener.postMessage({'type': 'bootstrap-auth.request'}, '*');
  }
}

init();
