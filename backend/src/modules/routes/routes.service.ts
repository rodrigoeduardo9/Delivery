import { Client } from '@googlemaps/google-maps-services-js';
import { config } from '../../config';

const client = new Client({});

interface RouteResult {
  distance: { text: string; value: number };
  duration: { text: string; value: number };
  polyline?: string;
  steps?: any[];
}

export async function getRouteOptimization(
  origin: { lat: number; lng: number },
  destination: { lat: number; lng: number },
  waypoints: { lat: number; lng: number }[] = []
): Promise<{ routes: RouteResult[] }> {
  const response = await client.directions({
    params: {
      origin: [origin.lat, origin.lng],
      destination: [destination.lat, destination.lng],
      waypoints: waypoints.map((w) => ({ location: { lat: w.lat, lng: w.lng } })) as any,
      optimize: waypoints.length > 0,
      key: config.googleMaps.apiKey,
    },
  });

  const routes: RouteResult[] = response.data.routes.map((route) => ({
    distance: {
      text: route.legs.reduce((sum, leg) => sum + leg.distance.text, ''),
      value: route.legs.reduce((sum, leg) => sum + leg.distance.value, 0),
    },
    duration: {
      text: route.legs.reduce((sum, leg) => sum + leg.duration.text, ''),
      value: route.legs.reduce((sum, leg) => sum + leg.duration.value, 0),
    },
    polyline: route.overview_polyline?.points,
    steps: route.legs.flatMap((leg) => leg.steps.map((step) => ({
      instruction: step.html_instructions,
      distance: step.distance,
      duration: step.duration,
      polyline: step.polyline?.points,
    }))),
  }));

  return { routes };
}

export async function getETA(
  origin: { lat: number; lng: number },
  destination: { lat: number; lng: number }
): Promise<{ eta_seconds: number; eta_text: string; distance_meters: number; distance_text: string }> {
  const response = await client.distancematrix({
    params: {
      origins: [{ lat: origin.lat, lng: origin.lng }],
      destinations: [{ lat: destination.lat, lng: destination.lng }],
      key: config.googleMaps.apiKey,
      departure_time: new Date(),
    },
  });

  const element = response.data.rows[0]?.elements[0];
  if (!element) {
    throw new Error('No route found between the specified points');
  }

  return {
    eta_seconds: element.duration.value,
    eta_text: element.duration.text,
    distance_meters: element.distance.value,
    distance_text: element.distance.text,
  };
}

export async function getDirections(
  origin: string,
  destination: string
): Promise<any> {
  const response = await client.directions({
    params: {
      origin,
      destination,
      key: config.googleMaps.apiKey,
      alternatives: true,
    },
  });

  return response.data;
}
