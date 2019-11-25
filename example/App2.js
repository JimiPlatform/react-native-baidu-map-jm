import React, {Component} from 'react';
import {Platform, StyleSheet, Image, Text, View, Dimensions, Button,TouchableOpacity,NativeModules,NativeEventEmitter} from 'react-native';
import { MapView, MapTypes, Geolocation, Overlay, InfoWindow} from 'react-native-baidu-map-jm';
const {height, width} = Dimensions.get('window');
const {
    BaiduLocationModule
} = NativeModules;

export default class App2 extends Component<Props> {
    state = {
        center:{
            latitude : 22.5801910000,
            longitude : 113.9276540000
        },
        trafficEnabled:true,
        isOpenPanoramic:false,
        mapType:1,
        markers:[
        {
             title:'汽车位置',
             location:{
                 latitude : 22.55373,
                 longitude : 113.925063
             }
        },
        {
             title:'haha，我在这里',
             location:{
                 latitude : 22.580054,
                 longitude : 113.927745
             }
        }],
        isCarLocation:false
    };

    componentWillMount() {
    }

    componentDidMount(){
        // this.location(this.state.isCarLocation);
    }

    componentWillUnmount() {
    }

    //路况
    setTraffic(enabled){
        console.log('Home',"路况：" + enabled);
        this.setState({trafficEnabled:enabled});
    }

    //全景
    panoramic(isOpen){
        console.log('Home',"全景状态：" + isOpen);

    }

    //地图类型
    setMapType(type){
        console.log('Home',"地图类型：" + type);
        this.setState({mapType:type});
    }

    location(isCar){
        if(isCar) {
            console.log('定位车辆位置');
        } else {
            console.log('定位当前位置');
        }
        this.setState({isCarLocation:isCar});
        if(isCar){
            this.getCarLocation();
        }else{
            this.getMyLocation();
        }

        this.InfoWindowFunc.update();
    }

    //自定定位
    autoLocation() {
    }

    //查询车的位置
    getCarLocation(){
       //此处无Car的位置信息，用人的位置代替
      Geolocation.getCurrentPosition().then(data=>{
          console.log('getCarPosition',"latitude:" + data.latitude + " ,longitude:" + data.longitude + " ,address:" + data.address);
          let carPosition = this.state.markers[0];
          let personPosition = this.state.markers[1];
          this.setState({
              markers:[
                 {
                       title:carPosition.title,
                       location:{
                          latitude : data.latitude-0.001000,
                          longitude : data.longitude-0.001000,
                       }
                 },
                 {
                       title:personPosition.title,
                       location:{
                          latitude : personPosition.location.latitude,
                          longitude : personPosition.location.longitude,
                       }
                 }
              ],
              center:{
                        latitude : data.latitude-0.001000,
                        longitude : data.longitude-0.001000
              }
              });
          }).catch(e=>{
            console.log('getCurrentPosition', '获取位置失败:' + e);
        });
    }

    //获取当前人位置
    getMyLocation(){
        Geolocation.getCurrentPosition().then(data=>{
              console.log('getCurrentPosition',"latitude:" + data.latitude + " ,longitude:" + data.longitude + " ,address:" + data.address);
              let carPosition = this.state.markers[0];
              let personPosition = this.state.markers[1];
              this.setState({
                markers:[
                {
                     title:carPosition.title,
                     location:{
                         latitude : carPosition.location.latitude,
                         longitude : carPosition.location.longitude,
                     }
                 },
                 {
                     title:personPosition.title,
                     location:{
                         latitude : data.latitude,
                         longitude : data.longitude,
                     }
                 }
                 ],
                center:{
                    latitude : data.latitude,
                    longitude : data.longitude
                }
            });
        }).catch(e=>{
               console.log('getCurrentPosition', '获取位置失败:' + e);
        });
    }

  render() {
    return (
      <View style={styles.container}>
        <MapView
          mapType={this.state.mapType}
          trafficEnabled={this.state.trafficEnabled}
          width={width}
          height={height}
          zoom={18}
          center={this.state.center}

          onMapStatusChange={(params)=>{
//            console.log("onMapStatusChange->params:" + params.target.longitude)
          }}

          onMapLoaded={(params)=>{
            console.log("onMapLoaded->params:")
          }}

          onMapClick={(params)=>{
            console.log("onMapClick->位置:" + params.longitude + "," + params.latitude)
          }}

          onMapDoubleClick={(params)=>{
              console.log("onMapPoiClick->params:" + " ,位置:" + params.longitude + "," + params.latitude)
          }}

          onMapPoiClick={(params)=>{
            console.log("onMapPoiClick->Name:" + params.name + " ,uid:" + params.uid + " ,位置:" + params.longitude + "," + params.latitude)
          }}

          onMarkerClick={(params) => {
            console.log("onMarkerClick->标题:", params.title + " ,位置:" + params.position.longitude + "," + params.position.latitude)
          }}

          onBubbleOfMarkerClick={(params) => {
            console.log("onBubbleOfMarkerClick->标题:", params.title + " ,位置:" + params.position.longitude + "," + params.position.latitude)
            }}
        >
            
          <Overlay.Marker
            tag={0}
            title={this.state.markers[0].title}
            location={this.state.markers[0].location}
            icon={require('./res/image/icon_car.png')}
            rotate={90}
          />

          <Overlay.Marker
            tag={1}
            title={this.state.markers[1].title}
            location={this.state.markers[1].location}
            icon={require('./res/image/home_icon_locat.png')}
            rotate={90}
          />

        <Overlay.InfoWindow
            ref={(e)=>{this.InfoWindowFunc=e}}
            style={{width:100, height:100, backgroundColor:'#F5FCFF', borderRadius:6}}
            tag={this.state.isCarLocation? 0 : 1}
            visible={true}
            >

            <View
            style={{width:50, height:50, backgroundColor:'red', borderRadius:6, paddingTop:50,paddingRight:50}}
            >
            <Text style={{backgroundColor:'#F5BBBF'}}>
                {this.state.isCarLocation ? "This is a Infowindow1" : "This is a Infowindow2"}{'\n'}
            </Text>
            </View>

            <Image
                source={require('./res/image/home_icon_car.png')}>
            </Image>
        </Overlay.InfoWindow>

          <Overlay.Circle
            center={this.state.markers[1].location}
            radius={30}
            fillColor='AA0000FF'
          />

          <Overlay.Polygon
            points={[{
                      latitude: this.state.markers[0].location.latitude-0.0005,
                      longitude: this.state.markers[0].location.longitude-0.0005
                     },
                     {
                      latitude: this.state.markers[0].location.latitude-0.0005,
                      longitude: this.state.markers[0].location.longitude+0.0005
                     },
                     {
                      latitude: this.state.markers[0].location.latitude+0.0005,
                      longitude: this.state.markers[0].location.longitude+0.0005
                     },
                     {
                      latitude: this.state.markers[0].location.latitude+0.0005,
                      longitude: this.state.markers[0].location.longitude-0.0005
                     }]}
          />

          <Overlay.Polyline
            width={3}
            points={[{
                latitude: this.state.markers[0].location.latitude-0.0005,
                longitude: this.state.markers[0].location.longitude-0.0005
               },
               {
                latitude: this.state.markers[0].location.latitude+0.0005,
                longitude: this.state.markers[0].location.longitude+0.0005
               }]}
            visible={false}
            />

            <Overlay.Arc
            points={[{
                      latitude: this.state.markers[0].location.latitude,
                      longitude: this.state.markers[0].location.longitude
                     },
                     {
                      latitude: this.state.markers[0].location.latitude,
                      longitude: this.state.markers[1].location.longitude
                     },
                     {
                      latitude: this.state.markers[1].location.latitude,
                      longitude: this.state.markers[1].location.longitude
                     }
                     ]}
          />

        </MapView>

        <TouchableOpacity style={{position:'absolute',bottom:20,start:20}} onPress={()=>{this.location(!this.state.isCarLocation)}}>
            <Image
            source={this.state.isCarLocation ? require('./res/image/home_icon_car.png'):require('./res/image/home_icon_location.png')}>
            </Image>
        </TouchableOpacity>

        <View style={{flexDirection:'column' , justifyContent:'space-between' ,width:30 ,height:90 ,position:'absolute',top:40,end:20}}>
            <TouchableOpacity onPress={()=>{this.setTraffic(!this.state.trafficEnabled)}}>
                <Image
                source={this.state.trafficEnabled ? require('./res/image/icon_traffic_selected.png'):require('./res/image/icon_traffic_unselected.png')}>
                </Image>
            </TouchableOpacity>
            <TouchableOpacity onPress={()=>{
                let type = this.state.mapType == 1 ? 2 : 1;
                this.setMapType(type);
                }}>
                <Image
                    source={this.state.mapType == 1 ? require('./res/image/icon_layer_unselected.png'):require('./res/image/icon_layer_selected.png')}>
                </Image>
            </TouchableOpacity>
        </View>

        <TouchableOpacity style={{position:'absolute',bottom:20,start:20}} onPress={()=>{this.location(!this.state.isCarLocation)}}>
            <Image
            source={this.state.isCarLocation ? require('./res/image/home_icon_location.png'):require('./res/image/home_icon_car.png')}>
            </Image>
        </TouchableOpacity>

      </View>
    );
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#F5FCFF',
  }
});
