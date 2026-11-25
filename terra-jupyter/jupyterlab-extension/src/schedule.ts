// The first periodic check is offset from Jupyter's autosave; later ones keep Welder's lock fresh.
export const INITIAL_SYNC_DELAY_MS = 27000;
export const SYNC_INTERVAL_MS = 60000;

export interface ITimers {
  setTimeout(fn: () => void, ms: number): unknown;
  clearTimeout(handle: unknown): void;
  setInterval(fn: () => void, ms: number): unknown;
  clearInterval(handle: unknown): void;
}

export const browserTimers: ITimers = {
  setTimeout: (fn, ms) => window.setTimeout(fn, ms),
  clearTimeout: handle => window.clearTimeout(handle as number),
  setInterval: (fn, ms) => window.setInterval(fn, ms),
  clearInterval: handle => window.clearInterval(handle as number)
};

export interface ISyncLoop {
  stop(): void;
  readonly stopped: boolean;
}

/**
 * Runs `tick` now, then starts the interval after the initial delay (so the second tick is at
 * initial delay + interval), until stopped.
 */
export function startSyncLoop(
  tick: () => void,
  timers: ITimers,
  initialDelayMs = INITIAL_SYNC_DELAY_MS,
  intervalMs = SYNC_INTERVAL_MS
): ISyncLoop {
  let stopped = false;
  let interval: unknown = undefined;
  const timeout = timers.setTimeout(() => {
    if (stopped) {
      return;
    }
    interval = timers.setInterval(tick, intervalMs);
  }, initialDelayMs);
  tick();
  return {
    stop() {
      stopped = true;
      timers.clearTimeout(timeout);
      if (interval !== undefined) {
        timers.clearInterval(interval);
      }
    },
    get stopped() {
      return stopped;
    }
  };
}
