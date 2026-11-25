import {
  INITIAL_SYNC_DELAY_MS,
  SYNC_INTERVAL_MS,
  ITimers,
  startSyncLoop
} from '../schedule';

const realTimers: ITimers = {
  setTimeout: (fn, ms) => setTimeout(fn, ms),
  clearTimeout: handle => clearTimeout(handle as ReturnType<typeof setTimeout>),
  setInterval: (fn, ms) => setInterval(fn, ms),
  clearInterval: handle =>
    clearInterval(handle as ReturnType<typeof setInterval>)
};

describe('startSyncLoop', () => {
  beforeEach(() => jest.useFakeTimers());
  afterEach(() => jest.useRealTimers());

  it('ticks on start, then every interval once the initial delay has passed', () => {
    const tick = jest.fn();
    startSyncLoop(tick, realTimers);
    expect(tick).toHaveBeenCalledTimes(1);

    jest.advanceTimersByTime(INITIAL_SYNC_DELAY_MS);
    expect(tick).toHaveBeenCalledTimes(1);

    jest.advanceTimersByTime(SYNC_INTERVAL_MS);
    expect(tick).toHaveBeenCalledTimes(2);

    jest.advanceTimersByTime(SYNC_INTERVAL_MS);
    expect(tick).toHaveBeenCalledTimes(3);
  });

  it('never starts the interval if stopped during the initial delay', () => {
    const tick = jest.fn();
    const loop = startSyncLoop(tick, realTimers);
    loop.stop();
    jest.advanceTimersByTime(INITIAL_SYNC_DELAY_MS + 5 * SYNC_INTERVAL_MS);
    expect(tick).toHaveBeenCalledTimes(1);
    expect(loop.stopped).toBe(true);
  });

  it('stops a running interval', () => {
    const tick = jest.fn();
    const loop = startSyncLoop(tick, realTimers);
    jest.advanceTimersByTime(INITIAL_SYNC_DELAY_MS + SYNC_INTERVAL_MS);
    loop.stop();
    jest.advanceTimersByTime(5 * SYNC_INTERVAL_MS);
    expect(tick).toHaveBeenCalledTimes(2);
  });
});
