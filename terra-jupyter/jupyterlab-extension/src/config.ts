export interface ITerraConfig {
  googleProject: string;
  clusterName: string;
  welderEnabled: boolean;
}

export interface IWelderUrls {
  metadata: string;
  lock: string;
  objects: string;
}

/**
 * Reads the project and runtime name from Leo's Jupyter base URL, `/notebooks/{project}/{runtime}/`.
 * Used when the server's config endpoint is unavailable; Welder is then treated as disabled.
 */
export function parseBaseUrl(baseUrl: string): ITerraConfig {
  const path = baseUrl.replace(/^[a-z]+:\/\/[^/]+/i, '');
  const match = path.match(/\/notebooks\/([^/]+)\/([^/]+)\/?/);
  return {
    googleProject: match ? decodeURIComponent(match[1]) : '',
    clusterName: match ? decodeURIComponent(match[2]) : '',
    welderEnabled: false
  };
}

/** Accepts the config endpoint's JSON, or returns null if it is not the expected shape. */
export function readConfig(json: unknown): ITerraConfig | null {
  if (typeof json !== 'object' || json === null) {
    return null;
  }
  const value = json as Record<string, unknown>;
  if (
    typeof value.googleProject !== 'string' ||
    typeof value.clusterName !== 'string'
  ) {
    return null;
  }
  return {
    googleProject: value.googleProject,
    clusterName: value.clusterName,
    // The classic frontend config stored this as the string 'true'.
    welderEnabled:
      value.welderEnabled === true || value.welderEnabled === 'true'
  };
}

/** Welder runs behind Leo's proxy on the same origin as Jupyter. */
export function welderUrls(config: ITerraConfig): IWelderUrls {
  const base = `/proxy/${config.googleProject}/${config.clusterName}/welder`;
  return {
    metadata: `${base}/objects/metadata`,
    lock: `${base}/objects/lock`,
    objects: `${base}/objects`
  };
}
