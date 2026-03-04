/**
 * Opens the appropriate maps app based on the user's device/platform
 * - iOS devices: Apple Maps
 * - Android devices: Google Maps
 * - Desktop/Other: Google Maps (web)
 */
export function openMapsApp(location: string) {
  const encodedLocation = encodeURIComponent(location);
  
  // Detect iOS devices
  const isIOS = /iPad|iPhone|iPod/.test(navigator.userAgent);
  
  // Detect Android devices
  const isAndroid = /Android/.test(navigator.userAgent);
  
  if (isIOS) {
    // Use Apple Maps for iOS devices
    window.location.href = `maps://maps.apple.com/?q=${encodedLocation}`;
  } else if (isAndroid) {
    // Use Google Maps app for Android devices
    window.location.href = `geo:0,0?q=${encodedLocation}`;
  } else {
    // Use Google Maps web for desktop/other devices
    window.open(`https://www.google.com/maps/search/?api=1&query=${encodedLocation}`, '_blank');
  }
}

/**
 * Returns the name of the maps app for the current platform
 */
export function getMapsAppName(): string {
  const isIOS = /iPad|iPhone|iPod/.test(navigator.userAgent);
  return isIOS ? 'Apple Maps' : 'Google Maps';
}
