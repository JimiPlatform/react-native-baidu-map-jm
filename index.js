/**
 * Copyright (c) 2016-present, lovebing.org.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import _MapView from './js/MapView';
import _MapTypes from './js/MapTypes';
import _Geolocation from './js/Geolocation';
import _MapApp from './js/MapApp';
import _Overlay from './js/Overlay/index';
import _MapSearch from './js/MapSearch';

export const MapView = _MapView;
export const MapTypes = _MapTypes;
export const Geolocation = _Geolocation;
export const Overlay = _Overlay;
export const MapApp = _MapApp;
export const MapSearch = _MapSearch;

export {default as Arc} from './js/Overlay/Arc';
export {default as Marker} from './js/Overlay/Marker';
export {default as Polygon} from './js/Overlay/Polygon';
export {default as Polyline} from './js/Overlay/Polyline';
export {default as Circle} from './js/Overlay/Circle';
export {default as InfoWindow} from './js/Overlay/InfoWindow';
/*export {default as TextMarker} from './js/Overlay/Text';*/
