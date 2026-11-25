import { FetchFn, WelderClient } from '../welder';

const urls = { metadata: '/m', lock: '/l', objects: '/o' };

function response(status: number, body: unknown = {}): Response {
  return {
    status,
    ok: status >= 200 && status < 300,
    statusText: `status ${status}`,
    json: async () => body
  } as unknown as Response;
}

describe('WelderClient', () => {
  it('posts the local path as JSON to the metadata endpoint', async () => {
    const fetchFn = jest.fn<ReturnType<FetchFn>, Parameters<FetchFn>>(
      async () => response(200, { syncMode: 'EDIT' })
    );
    const result = await new WelderClient(urls, fetchFn).checkMetadata(
      'ws/edit/a.ipynb'
    );

    expect(result).toEqual({ kind: 'ok', meta: { syncMode: 'EDIT' } });
    expect(fetchFn).toHaveBeenCalledWith('/m', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ localPath: 'ws/edit/a.ipynb' })
    });
  });

  it('maps 412 to notTracked and other failures to error', async () => {
    expect(
      (
        await new WelderClient(urls, async () => response(412)).checkMetadata(
          'a'
        )
      ).kind
    ).toBe('notTracked');
    expect(
      (
        await new WelderClient(urls, async () => response(500)).checkMetadata(
          'a'
        )
      ).kind
    ).toBe('error');
    const throwing: FetchFn = async () => {
      throw new Error('network');
    };
    expect(
      (await new WelderClient(urls, throwing).checkMetadata('a')).kind
    ).toBe('error');
  });

  it('maps lock responses', async () => {
    expect(
      await new WelderClient(urls, async () => response(200)).lock('a')
    ).toBe('ok');
    expect(
      await new WelderClient(urls, async () => response(409)).lock('a')
    ).toBe('conflict');
    expect(
      await new WelderClient(urls, async () => response(500)).lock('a')
    ).toBe('error');
  });

  it('sends a localize action with one entry', async () => {
    const fetchFn = jest.fn<ReturnType<FetchFn>, Parameters<FetchFn>>(
      async () => response(200)
    );
    await new WelderClient(urls, fetchFn).localize(
      'gs://b/notebooks/a.ipynb',
      'ws/edit/a.ipynb'
    );

    expect(JSON.parse(fetchFn.mock.calls[0][1]!.body as string)).toEqual({
      action: 'localize',
      entries: [
        {
          sourceUri: 'gs://b/notebooks/a.ipynb',
          localDestinationPath: 'ws/edit/a.ipynb'
        }
      ]
    });
    expect(fetchFn.mock.calls[0][0]).toBe('/o');
  });
});
