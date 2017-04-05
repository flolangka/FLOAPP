import React, { Component } from 'react';
import  {
  AppRegistry,
  StyleSheet,
  View,
  ListView,
  Button,
  Text,
}  from 'react-native';
import { StackNavigator } from 'react-navigation';

var dataArr = [];

const FLOReactNativeGuides = ({ navigation }) => (
  <View style={styles.container}>
    <ListView
      dataSource={dataArr} 
      renderRow={(rowData) => _renderCell(rowData)} 
      renderSectionHeader={(rowData) => _renderHeader(rowData)}
    />
  </View>  
);

// 导航栏
FLOReactNativeGuides.navigationOptions = {
  title: 'react-native 中文教程',
  header: ({
    left: (
      <Button title='返回' onPress={()=>navigation.goBack()} color='white'/>
    ),
    tintColor: 'white',
    style: ({
      backgroundColor: 'rgb(15, 191, 235)',        
    }),
  }),
};

const _renderHeader = ({data}) => {
  <Text style={styles.header}> {data.group} </Text>
}

const _renderCell = ({data}) => {
  <View style={styles.cell}>
    <Text style={styles.cellText}> {data.subject} </Text>
    <View style={styles.bottomLine}></View>
  </View>
}

// 请求数据
const requestApiAsync = () => {
  fetch('http://reactnative.cn/static/docs/0.43/indexes.json')
    .then((response) => response.json())
    .then((responseJson) => {
      // 刷新页面
      dataArr = _ds.cloneWithRows(responseJson.contains);
    })
    .catch((error) => {
      console.error(error);
    });
}

const _ds = () => {
  var getSectionData = (dataBlob,sectionID)=>{            
    return dataBlob[sectionID];        
  };        
  var getRowData = (dataBlob,sectionID,rowID) =>{            
    return dataBlob[sectionID + ':' + rowID];        
  };
  // 因为这里我们需要返回区的数据，所以我们需要提供方法来提取行数据和section标题        
  return {            
    dataSource: new ListView.DataSource({                                     
      getSectionData: getSectionData,                
      getRowData: getRowData,                
      rowHasChanged: (r1,r2) => r1 !== r2,                
      sectionHeaderHasChanged: (s1,s2) => s1 !== s2            
    })
  };
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: 'white',
  },
  header: {
    color: 'red',
    height: 20,
    lineHeight: 20,
  },
  cell: {
    height: 40,
  },
  cellText: {
    color: 'black',
  },
  bottomLine: {
    backgroundColor: 'rgb(217, 217, 217)',
    left: 16,
    height: 1,
  }
});

export default FLOReactNativeGuides;