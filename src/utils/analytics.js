export function trackBandSelected(eventName, payload, limit = 3) {
  if (
    typeof window === "undefined" ||
    typeof window.gtag !== "function" ||
    !payload?.band_name
  ) {
    return;
  }

  const normalisedBandName = payload.band_name.trim().toUpperCase();
  const storageKey = `band-selected:${normalisedBandName}`;

  const currentCount = Number(sessionStorage.getItem(storageKey)) || 0;

  if (currentCount >= limit) {
    return;
  }

  window.gtag("event", eventName, {
    ...payload,
    band_name: normalisedBandName,
  });

  sessionStorage.setItem(storageKey, String(currentCount + 1));
}
