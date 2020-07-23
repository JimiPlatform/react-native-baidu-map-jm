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

export default class Arc extends Component {
  static propTypes = {
    ...View.propTypes,
    color: PropTypes.string,
    width: PropTypes.number,
    points: PropTypes.array,
    visible: PropTypes.bool
  };

  static defaultProps = {
    points: [{latitude: 0, longitude: 0}, {latitude: 0, longitude: 0}, {latitude: 0, longitude: 0}],
    color: '#FF0088',
    width: 1,
    visible: true
  };
  
  constructor() {
    super();
  }

  render() {
    return <BaiduMapOverlayArc {...this.props} />;
  }
}
const BaiduMapOverlayArc = requireNativeComponent('BaiduMapOverlayArc', Arc);
