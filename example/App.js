import React from 'react';
import { View, Text } from 'react-native';
import {createBottomTabNavigator,createAppContainer} from 'react-navigation';
import App1 from './App1';
import App2 from './App2';

const AppNavigator = createBottomTabNavigator({
App1Screen: {
    screen: App1,
},
App2Screen: {
    screen: App2,
    },
});

export default createAppContainer(AppNavigator);