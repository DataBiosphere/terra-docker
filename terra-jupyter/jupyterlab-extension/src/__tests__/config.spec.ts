import { parseBaseUrl, readConfig, welderUrls } from '../config';

describe('parseBaseUrl', () => {
  it('reads project and runtime from the Leo notebooks base URL', () => {
    expect(parseBaseUrl('/notebooks/my-project/my-runtime/')).toEqual({
      googleProject: 'my-project',
      clusterName: 'my-runtime',
      welderEnabled: false
    });
  });

  it('accepts an absolute URL', () => {
    expect(
      parseBaseUrl('https://leo.example.org/notebooks/p1/r1/').clusterName
    ).toBe('r1');
  });

  it('returns empty names for other base URLs', () => {
    expect(parseBaseUrl('/')).toEqual({
      googleProject: '',
      clusterName: '',
      welderEnabled: false
    });
  });
});

describe('readConfig', () => {
  it('accepts the server config', () => {
    expect(
      readConfig({ googleProject: 'p', clusterName: 'r', welderEnabled: true })
    ).toEqual({
      googleProject: 'p',
      clusterName: 'r',
      welderEnabled: true
    });
  });

  it("accepts the classic string 'true'", () => {
    expect(
      readConfig({
        googleProject: 'p',
        clusterName: 'r',
        welderEnabled: 'true'
      })?.welderEnabled
    ).toBe(true);
  });

  it('treats anything else as Welder disabled', () => {
    expect(
      readConfig({ googleProject: 'p', clusterName: 'r' })?.welderEnabled
    ).toBe(false);
  });

  it('rejects malformed responses', () => {
    expect(readConfig(null)).toBeNull();
    expect(readConfig({ googleProject: 1, clusterName: 'r' })).toBeNull();
  });
});

describe('welderUrls', () => {
  it('builds the Welder endpoints behind the Leo proxy', () => {
    expect(
      welderUrls({ googleProject: 'p', clusterName: 'r', welderEnabled: true })
    ).toEqual({
      metadata: '/proxy/p/r/welder/objects/metadata',
      lock: '/proxy/p/r/welder/objects/lock',
      objects: '/proxy/p/r/welder/objects'
    });
  });
});
