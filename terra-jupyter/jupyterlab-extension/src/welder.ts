import { IWelderUrls } from './config';
import { IWelderMetadata } from './sync';

export type FetchFn = (input: string, init?: RequestInit) => Promise<Response>;

/** `notTracked`: Welder answered 412, the file has no storage link and is not synced. */
export type MetadataResult =
  | { kind: 'ok'; meta: IWelderMetadata }
  | { kind: 'notTracked' }
  | { kind: 'error'; error: unknown };

export type LockResult = 'ok' | 'conflict' | 'error';

const JSON_HEADERS = { 'Content-Type': 'application/json' };

export class WelderClient {
  constructor(
    private readonly urls: IWelderUrls,
    private readonly fetchFn: FetchFn
  ) {}

  async checkMetadata(localPath: string): Promise<MetadataResult> {
    try {
      const response = await this.post(this.urls.metadata, { localPath });
      if (response.status === 412) {
        return { kind: 'notTracked' };
      }
      if (!response.ok) {
        return { kind: 'error', error: new Error(response.statusText) };
      }
      return { kind: 'ok', meta: (await response.json()) as IWelderMetadata };
    } catch (error) {
      return { kind: 'error', error };
    }
  }

  async lock(localPath: string): Promise<LockResult> {
    try {
      const response = await this.post(this.urls.lock, { localPath });
      if (response.status === 409) {
        return 'conflict';
      }
      return response.ok ? 'ok' : 'error';
    } catch {
      return 'error';
    }
  }

  async localize(
    sourceUri: string,
    localDestinationPath: string
  ): Promise<void> {
    await this.post(this.urls.objects, {
      action: 'localize',
      entries: [{ sourceUri, localDestinationPath }]
    });
  }

  private post(url: string, body: unknown): Promise<Response> {
    return this.fetchFn(url, {
      method: 'POST',
      headers: JSON_HEADERS,
      body: JSON.stringify(body)
    });
  }
}
