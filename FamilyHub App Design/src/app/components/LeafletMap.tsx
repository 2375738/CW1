import { useEffect, useRef } from 'react';
import L from 'leaflet';
import 'leaflet/dist/leaflet.css';

// Fix for default marker icons in Leaflet
delete (L.Icon.Default.prototype as any)._getIconUrl;
L.Icon.Default.mergeOptions({
  iconRetinaUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/images/marker-icon-2x.png',
  iconUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/images/marker-icon.png',
  shadowUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/images/marker-shadow.png',
});

interface FamilyLocation {
  id: number;
  name: string;
  role: string;
  avatar: string;
  location: string | null;
  address: string | null;
  lastUpdated: string | null;
  sharing: boolean;
  sharingUntil: string | null;
  coordinates: { lat: number; lng: number } | null;
}

interface LeafletMapProps {
  locations: FamilyLocation[];
}

export function LeafletMap({ locations }: LeafletMapProps) {
  const mapRef = useRef<L.Map | null>(null);
  const mapContainerRef = useRef<HTMLDivElement>(null);
  const markersRef = useRef<L.Marker[]>([]);

  useEffect(() => {
    if (!mapContainerRef.current) return;

    // Initialize map only once
    if (!mapRef.current) {
      const activeLocations = locations.filter((loc) => loc.sharing && loc.coordinates);
      const center: [number, number] = activeLocations.length > 0
        ? [activeLocations[0].coordinates!.lat, activeLocations[0].coordinates!.lng]
        : [51.6214, -3.9436];

      mapRef.current = L.map(mapContainerRef.current).setView(center, 13);

      L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors',
      }).addTo(mapRef.current);
    }

    // Clear existing markers
    markersRef.current.forEach(marker => marker.remove());
    markersRef.current = [];

    // Add markers for active locations
    const activeLocations = locations.filter((loc) => loc.sharing && loc.coordinates);
    
    activeLocations.forEach((location) => {
      if (!mapRef.current) return;

      const marker = L.marker([location.coordinates!.lat, location.coordinates!.lng])
        .addTo(mapRef.current);

      const popupContent = `
        <div style="min-width: 200px;">
          <div style="display: flex; align-items: center; gap: 8px; margin-bottom: 8px;">
            <img
              src="${location.avatar}"
              alt="${location.name}"
              style="width: 40px; height: 40px; border-radius: 50%; object-fit: cover;"
            />
            <div>
              <p style="font-weight: 600; margin: 0; font-size: 14px;">${location.name}</p>
              <p style="font-size: 12px; color: #666; margin: 0;">${location.role}</p>
            </div>
          </div>
          <p style="font-weight: 500; color: #374151; margin: 4px 0; font-size: 13px;">${location.location}</p>
          <p style="font-size: 12px; color: #6b7280; margin: 4px 0;">${location.address}</p>
          <p style="font-size: 11px; color: #9ca3af; margin-top: 4px;">Updated: ${location.lastUpdated}</p>
        </div>
      `;

      marker.bindPopup(popupContent);
      markersRef.current.push(marker);
    });

    // Cleanup function
    return () => {
      // Don't destroy the map on every update, only on unmount
    };
  }, [locations]);

  // Cleanup on unmount
  useEffect(() => {
    return () => {
      if (mapRef.current) {
        mapRef.current.remove();
        mapRef.current = null;
      }
    };
  }, []);

  return (
    <div 
      ref={mapContainerRef} 
      style={{ height: '320px', width: '100%' }}
      className="z-0"
    />
  );
}