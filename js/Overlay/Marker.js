/**
 * Copyright (c) 2016-present, lovebing.org.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

 import {
  requireNativeComponent,
  View,
  NativeModules,
  Platform,
  DeviceEventEmitter
} from 'react-native';
import resolveAssetSource from 'react-native/Libraries/Image/resolveAssetSource';

import React, { Component } from 'react';
import PropTypes from 'prop-types';

export default class Marker extends Component {
  static propTypes = {
    ...View.propTypes,
    tag: PropTypes.number,
    title: PropTypes.string,
    location: PropTypes.object,
    alpha: PropTypes.number,
    rotate: PropTypes.number,
    flat: PropTypes.bool,
    icon: PropTypes.number,
    visible: PropTypes.bool,
    tag: PropTypes.number
  };

  static defaultProps = {
    tag: -1,
	  visible:true,
    location: {
      latitude: 0,
      longitude: 0
    },
    rotate: 0
  };

  constructor() {
    super();
  }

  render() {
    let icon = this.props.icon;
    if (this.props.icon) {
      icon = resolveAssetSource(this.props.icon) || {};
      icon = icon.uri || this.props.icon;
    }

    return <BaiduMapOverlayMarker {...this.props} icon={icon} />;
  }
}

const BaiduMapOverlayMarker = requireNativeComponent('BaiduMapOverlayMarker', Marker);
