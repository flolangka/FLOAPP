import React, { Component } from 'react';
import {
  StyleSheet,
  View,
  ScrollView,
  Button,
  Text,
  Image,
  TouchableHighlight,
  NativeModules
}  from 'react-native';
import { StackNavigator } from 'react-navigation';

// import 其他页面
import FLOReactNativeGuides from './reactNativeGuides';

// 首页
const FLOReactNativeHomeScreen = ({ navigation }) => (
  <ScrollView style={styles.container}>
    <TouchableHighlight underlayColor='#d3d3d3' onPress={() => navigation.navigate('Guides')}>
      <View style={styles.cell}>
        <Text style={styles.cellText}>React-Native 中文教程</Text>
        <Image source={{uri: 'gofoward'}} resizeMode='stretch' style={styles.rightImg} />
        <View style={styles.bottomLine}></View>
      </View>
    </TouchableHighlight>
  </ScrollView>
);

// 导航栏
FLOReactNativeHomeScreen.navigationOptions = {
  title: 'react-native',

  header: ({
    left: (
      <Button title='首页' onPress={()=>NativeModules.RTModule.RNBridgeMessage('DismissReactNativeVC')} color='white'/>
    ),
    tintColor: 'white',
    style: ({
      backgroundColor: 'rgb(15, 191, 235)',        
    }),
  })
};

// 样式
const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: 'white',
  },
  cell: {
    height: 40,
  },
  cellText: {
    color: 'black',
    left: 16,
    height: 39,
    lineHeight: 39,
  },
  rightImg: {
    width: 7,
    height: 13,
    right: 16,
    top: 13.5,
    tintColor: 'gray',
    position: 'absolute',
  },
  bottomLine: {
    backgroundColor: 'rgb(217, 217, 217)',
    left: 16,
    height: 1,
  }
});

// 导航Stack(堆栈)
const RNNavigator = StackNavigator({
  Home: {
    screen: FLOReactNativeHomeScreen,
  },
  Guides: {
    screen: FLOReactNativeGuides,
  },
}, {
  initialRouteName: 'Home',
});

export default () => <RNNavigator />;