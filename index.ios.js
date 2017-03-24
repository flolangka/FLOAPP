import React, { Component } from 'react';
import  {
  AppRegistry,
  StyleSheet,
  View
}  from 'react-native';

export default class FLOReactNative extends Component {
  render() {
    return (
      <View style={styles.container}>
      </View>
    );
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#123456',
  }
});

AppRegistry.registerComponent('FLOReactNative', () => FLOReactNative);