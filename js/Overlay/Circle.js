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

import React, { Component } from 'react';
import PropTypes from 'prop-types';

export default class Circle extends Component {
  static propTypes = {
    ...View.propTypes,
    radius: PropTypes.number,
    fillColor: PropTypes.string,
    stroke: PropTypes.object,
    center: PropTypes.object,
    visible: PropTypes.bool
  };

  static defaultProps = {
    center: {
      latitude: 0,
      longitude: 0
    },
    stroke: {
      width: 2,
      color: '#0000FFAA'
    },
    visible: true
  };

  constructor() {
    super();
  }

  render() {
    return <BaiduMapOverlayCircle {...this.props} />;
  }
}
const BaiduMapOverlayCircle = requireNativeComponent('BaiduMapOverlayCircle', Circle);
