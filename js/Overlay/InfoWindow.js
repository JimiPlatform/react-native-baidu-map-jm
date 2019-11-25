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

export default class InfoWindow extends Component {
  static propTypes = {
    ...View.propTypes,
    tag: PropTypes.number,
    location: PropTypes.object,
    visible: PropTypes.bool
  };

  static defaultProps = {
    tag: -1,
    location: {
      latitude: 0,
      longitude: 0
    },
    visible: true
  };

  constructor() {
    super();
  }

  update() {
      if (Platform.OS === 'android') {
          UIManager.dispatchViewManagerCommand(ReactNative.findNodeHandle(this.infoWindowRef), 1024, null);
      }
  }

  render() {
    return <BaiduMapOverlayInfoWindow {...this.props}
      ref={(component) => this.infoWindowRef = component}
          />;
  }
}

const BaiduMapOverlayInfoWindow = requireNativeComponent('BaiduMapOverlayInfoWindow', InfoWindow);
