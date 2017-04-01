import React, { Component } from 'react';
import  {
  AppRegistry,
  StyleSheet,
  View,
  Button,
  Text,
  NativeModules,
}  from 'react-native';
import { StackNavigator } from 'react-navigation';

// React-Native 与原生系统通信工具
var RNModules = NativeModules.RTModule;

// 第一个页面
class FLOReactNativeHomeScreen extends Component {

  getApiAsync() {
    fetch('http://bangumi.bilibili.com/jsonp/season_rank_list/global/3.ver?callback=bangumiRankCallback')
      .then((response) => {
        console.log(response);
      })
      .catch((error) => {
        console.error(error);
      });
  }

  static navigationOptions = {
    title: 'react-native',

    header: ({
      left: (
        <Button title='首页' onPress={()=>RNModules.RNBridgeMessage('DismissReactNativeVC')} color='white'/>
      ),
      tintColor: 'white',
      style: ({
        backgroundColor: 'rgb(15, 191, 235)',        
      }),
    })
  };

  render() {
    return (
      <View style={styles.container}>
        <Button title='fetch' onPress={this.getApiAsync} color='black'/>
        <Text>fetch('http://bangumi.bilibili.com/jsonp/season_rank_list/global/3.ver?callback=bangumiRankCallback')</Text>
      </View>
    );
  }

}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: 'white',
  },
});


// 导航配置
const FLOReactNative = StackNavigator({
  Profile: {
    screen: FLOReactNativeHomeScreen,

  },
});

AppRegistry.registerComponent('FLOReactNative', () => FLOReactNative);