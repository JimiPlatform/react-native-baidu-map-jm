/**
 * Copyright (c) 2016-present, lovebing.org.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import ReactNative, {
  requireNativeComponent,
  View,
  NativeModules,
  Platform,
  DeviceEventEmitter,
  UIManager
} from 'react-native';
import React, { Component } from 'react';
import PropTypes from 'prop-types';
import MapTypes from './MapTypes';
import Marker from './Overlay/Marker';
import resolveAssetSource from 'react-native/Libraries/Image/resolveAssetSource';

export default class MapView extends Component {
  static propTypes = {
    ...View.propTypes,
    zoomControlsVisible: PropTypes.bool,
    trafficEnabled: PropTypes.bool,
    baiduHeatMapEnabled: PropTypes.bool,
    mapType: PropTypes.number,
    zoom: PropTypes.number,
    center: PropTypes.object,
    buildingsEnabled: PropTypes.bool,
    overlookEnabled: PropTypes.bool,
    trackPlayInfo: PropTypes.object,
    visualRange: PropTypes.array,
    correctPerspective:PropTypes.object,
    onMapStatusChangeStart: PropTypes.func,
    onMapStatusChange: PropTypes.func,
    onMapStatusChangeFinish: PropTypes.func,
    onMapLoaded: PropTypes.func,
    onMapClick: PropTypes.func,
    onMapDoubleClick: PropTypes.func,
    onMarkerClick: PropTypes.func,
    onMapPoiClick: PropTypes.func,
    onBubbleOfMarkerClick: PropTypes.func
  };

  static defaultProps = {
    zoomControlsVisible: false,
    trafficEnabled: false,
    baiduHeatMapEnabled: false,
    buildingsEnabled: true,
    overlookEnabled: true,
    mapType: MapTypes.NORMAL,
    center: null,
    zoom: 10,
    showTrack: false,
    trackPlayInfo: null,
    visualRange: []
  };

  constructor() {
    super();
  }

  _onChange(event) {
    if (typeof this.props[event.nativeEvent.type] === 'function') {
      this.props[event.nativeEvent.type](event.nativeEvent.params);
    }
  }

  renderIOS() {
    let number = 0;
    const children = this.props.children ? this.props.children : [];
    const markerMap = {};
    for (let i = 0; i < children.length; i++) {
      for (let p in children[i]) {
        if (children[i].type === Marker) {
          const props = children[i].props;
          let icon = resolveAssetSource(props.icon) || {};
          if (typeof(props.icon) === 'string') {
            icon = props.icon
          }
          markerMap[props.location.latitude + ":" + props.location.longitude + ":" + props.icon+i] = {
            tag: props.tag,
            title: props.title,
            latitude: props.location.latitude,
            longitude: props.location.longitude,
            isIteration:props.isIteration,
            alpha: props.alpha,
            icon: icon,
            rotate: props.rotate,
            flat: props.flat,
            visible: props.visible
          };
        } else if (Array.isArray(children[i])){
          let childrenArr = children[i];
          for (let index = 0; index < childrenArr.length; index++) {
            const element = childrenArr[index];
            if (element.type === Marker) {
              const props = element.props;
              let icon = resolveAssetSource(props.icon) || {};
              if (typeof(props.icon) === 'string') {
                icon = props.icon
              }
              markerMap[props.location.latitude + ":" + props.location.longitude + ":" + props.icon+index] = {
                tag: props.tag,
                title: props.title,
                latitude: props.location.latitude,
                longitude: props.location.longitude,
                isIteration:props.isIteration,
                alpha: props.alpha,
                icon: icon,
                rotate: props.rotate,
                flat: props.flat,
                visible: props.visible
              };
            }
          }
        }
      }
      number = 0;
    }
    const markers = [];
    for (let p in markerMap) {
      markers.push(markerMap[p]);
    }
    
    // console.log("+++markers = ",markers)
    // console.log("this.props.children = ",children)
    return <BaiduMapView {...this.props} markers={markers} onChange={this._onChange.bind(this)}
            ref={(component) => this.mapViewRef = component}
           />;
  }

  renderAndroid() {

    return <BaiduMapView {...this.props} onChange={this._onChange.bind(this)}
            ref={(component) => this.mapViewRef = component}
          />;
  }

  reloadView() {
    if (Platform.OS === 'android') {
        UIManager.dispatchViewManagerCommand(ReactNative.findNodeHandle(this.mapViewRef), 1024, null);
    }
  }

  render() {
    if (Platform.OS === 'ios') {
      return this.renderIOS();
    }
    return this.renderAndroid();
  }
}

const BaiduMapView = requireNativeComponent('BaiduMapView', MapView, {
  nativeOnly: {onChange: true}
});

