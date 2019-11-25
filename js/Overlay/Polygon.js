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

export default class Polygon extends Component {
  static propTypes = {
    ...View.propTypes,
    points: PropTypes.array,
    fillColor: PropTypes.string,
    stroke: PropTypes.object,
    visible: PropTypes.bool
  };

  static defaultProps = {
    points: [{
      latitude: 0,
      longitude: 0
    }],
    stroke: {
      width: 2,
      color: '#00FF00AA'
    },
    visible: true
  };

  constructor() {
    super();
  }

  render() {
    return <BaiduMapOverlayPolygon {...this.props} />;
  }
}
const BaiduMapOverlayPolygon = requireNativeComponent('BaiduMapOverlayPolygon', Polygon);
