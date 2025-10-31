#!/usr/bin/env bash
# SkyDrop 2.0 project creator (creates an Expo project prototype and zips it)
set -e

OUTDIR="$PWD/sky_drop_2_prototype"
ZIPPATH="$PWD/SkyDrop_2_Prototype.zip"

echo "Creating project at: $OUTDIR"
rm -rf "$OUTDIR" "$ZIPPATH"
mkdir -p "$OUTDIR/screens" "$OUTDIR/assets" "$OUTDIR/.github/workflows"

# package.json
cat > "$OUTDIR/package.json" <<'EOF'
{
  "name": "sky-drop-2-prototype",
  "version": "1.0.0",
  "main": "node_modules/expo/AppEntry.js",
  "scripts": {
    "start": "expo start",
    "android": "expo start --android",
    "ios": "expo start --ios"
  },
  "dependencies": {
    "expo": "~48.0.0",
    "react": "18.2.0",
    "react-native": "0.71.8",
    "react-native-gesture-handler": "^2.9.0",
    "react-native-safe-area-context": "4.5.0",
    "@react-navigation/native": "^6.1.6",
    "@react-navigation/native-stack": "^6.9.12"
  }
}
EOF

# eas.json
cat > "$OUTDIR/eas.json" <<'EOF'
{
  "build": {
    "preview": {
      "workflow": "managed",
      "android": { "buildType": "apk" }
    },
    "production": {
      "workflow": "managed",
      "android": { "buildType": "apk" }
    }
  }
}
EOF

# README
cat > "$OUTDIR/README.md" <<'EOF'
SkyDrop 2.0 — Seller / Distributor (Attractive UI) Prototype

This is an Expo React Native prototype focused on the Seller/Distributor dashboard with an attractive theme.
It is demo-only (mock data) and ready to build with EAS or run locally with Expo Go.

Run locally:
1. Install Node.js and expo-cli: npm install -g expo-cli
2. cd sky_drop_2_prototype
3. npm install
4. expo start
5. Scan QR with Expo Go on your phone
EOF

# BUILD_INSTRUCTIONS
cat > "$OUTDIR/BUILD_INSTRUCTIONS.md" <<'EOF'
Build instructions (short)

1. Install:
   npm install -g expo-cli eas-cli
2. cd sky_drop_2_prototype
3. npm install
4. Expo quick run:
   expo start
5. EAS build:
   eas login
   eas build --platform android --profile preview
EOF

# GitHub Actions workflow
cat > "$OUTDIR/.github/workflows/eas-build-android.yml" <<'EOF'
name: EAS Build Android

on:
  workflow_dispatch:
  push:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 18
      - run: npm install -g eas-cli
      - name: Login to EAS
        env:
          EXPO_TOKEN: ${{ secrets.EXPO_TOKEN }}
        run: |
          eas login --token $EXPO_TOKEN
      - run: npm install
      - name: Build Android APK
        env:
          EXPO_TOKEN: ${{ secrets.EXPO_TOKEN }}
        run: |
          eas build --platform android --profile preview --non-interactive
EOF

# App.js
cat > "$OUTDIR/App.js" <<'EOF'
import React from "react";
import { NavigationContainer } from "@react-navigation/native";
import { createNativeStackNavigator } from "@react-navigation/native-stack";
import Splash from "./screens/Splash";
import Login from "./screens/Login";
import Dashboard from "./screens/Dashboard";
import AssignDrone from "./screens/AssignDrone";
import Analytics from "./screens/Analytics";

const Stack = createNativeStackNavigator();

export default function App() {
  return (
    <NavigationContainer>
      <Stack.Navigator initialRouteName="Splash" screenOptions={{headerShown:false}}>
        <Stack.Screen name="Splash" component={Splash} />
        <Stack.Screen name="Login" component={Login} />
        <Stack.Screen name="Dashboard" component={Dashboard} />
        <Stack.Screen name="AssignDrone" component={AssignDrone} />
        <Stack.Screen name="Analytics" component={Analytics} />
      </Stack.Navigator>
    </NavigationContainer>
  );
}
EOF

# screens/Splash.js
cat > "$OUTDIR/screens/Splash.js" <<'EOF'
import React, {useEffect} from "react";
import { View, Text, Image, StyleSheet } from "react-native";

export default function Splash({ navigation }) {
  useEffect(()=>{ const t = setTimeout(()=> navigation.replace("Login"), 1600); return ()=> clearTimeout(t); },[]);
  return (
    <View style={styles.container}>
      <Image source={require('../assets/logo.png')} style={styles.logo} />
      <Text style={styles.title}>SkyDrop</Text>
      <Text style={styles.subtitle}>Speed Delivery • Drone Powered</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container:{flex:1, backgroundColor:'#067dbd', alignItems:'center', justifyContent:'center'},
  logo:{width:120, height:120, marginBottom:16, borderRadius:20},
  title:{color:'#fff', fontSize:34, fontWeight:'700'},
  subtitle:{color:'#dff6ff', marginTop:6}
});
EOF

# screens/Login.js
cat > "$OUTDIR/screens/Login.js" <<'EOF'
import React from "react";
import { View, Text, TextInput, Button, StyleSheet, Image } from "react-native";

export default function Login({ navigation }) {
  return (
    <View style={styles.container}>
      <Image source={require('../assets/logo.png')} style={styles.logo} />
      <Text style={styles.title}>Welcome, Seller</Text>
      <Text style={styles.subtitle}>Manage drone pickups & deliveries</Text>
      <TextInput placeholder="Email" style={styles.input} keyboardType="email-address" />
      <TextInput placeholder="Password" style={styles.input} secureTextEntry />
      <View style={{height:10}} />
      <Button title="Login (Demo)" color="#067dbd" onPress={() => navigation.replace('Dashboard')} />
    </View>
  );
}

const styles = StyleSheet.create({
  container:{flex:1, alignItems:'center', justifyContent:'center', padding:20, backgroundColor:'#f6fbff'},
  logo:{width:100, height:100, marginBottom:12, borderRadius:16},
  title:{fontSize:22, fontWeight:'700', marginBottom:4},
  subtitle:{color:'#555', marginBottom:12},
  input:{width:'90%', padding:10, borderRadius:8, borderColor:'#ddd', borderWidth:1, marginTop:8, backgroundColor:'#fff'}
});
EOF

# screens/Dashboard.js
cat > "$OUTDIR/screens/Dashboard.js" <<'EOF'
import React from "react";
import { View, Text, Button, StyleSheet, FlatList, TouchableOpacity } from "react-native";

const mock = [
  {id:'P001', name:'Shoes', weight:'0.6kg', status:'Ready', eta:'—'},
  {id:'P002', name:'Phone Case', weight:'0.2kg', status:'Ready', eta:'—'},
  {id:'P003', name:'T-shirt', weight:'0.3kg', status:'Awaiting Pack', eta:'—'}
];

export default function Dashboard({ navigation }) {
  return (
    <View style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.hTitle}>SkyDrop Dashboard</Text>
        <Button title="Analytics" color="#fff" onPress={() => navigation.navigate('Analytics')} />
      </View>
      <Text style={styles.sub}>Quick Actions</Text>
      <View style={styles.actions}>
        <Button title="Schedule Pickup" onPress={() => alert('Schedule (demo)')} />
        <View style={{width:12}} />
        <Button title="Assign Drone" onPress={() => navigation.navigate('AssignDrone')} />
      </View>
      <Text style={styles.section}>Pending Packages</Text>
      <FlatList data={mock} keyExtractor={i=>i.id} renderItem={({item})=>(
        <TouchableOpacity style={styles.card} onPress={()=>alert('Package '+item.id)}>
          <Text style={{fontWeight:'700'}}>{item.name} • {item.weight}</Text>
          <Text>Status: {item.status}</Text>
        </TouchableOpacity>
      )} />
    </View>
  );
}

const styles = StyleSheet.create({
  container:{flex:1, backgroundColor:'#f0f8ff', padding:16},
  header:{flexDirection:'row', justifyContent:'space-between', alignItems:'center', backgroundColor:'#067dbd', padding:12, borderRadius:10},
  hTitle:{color:'#fff', fontSize:18, fontWeight:'700'},
  sub:{marginTop:12, fontSize:16, fontWeight:'600'},
  actions:{flexDirection:'row', marginTop:8, marginBottom:12},
  section:{marginTop:10, fontSize:16, fontWeight:'700'},
  card:{padding:12, backgroundColor:'#fff', borderRadius:8, marginTop:8, elevation:2}
});
EOF

# screens/AssignDrone.js
cat > "$OUTDIR/screens/AssignDrone.js" <<'EOF'
import React from "react";
import { View, Text, FlatList, TouchableOpacity, StyleSheet } from "react-native";

const drones = [
  {id:'D1', name:'SkyLite 2kg', status:'Available'},
  {id:'D2', name:'Swift 1.5kg', status:'Available'},
  {id:'D3', name:'Bolt 3kg', status:'In Flight'}
];

export default function AssignDrone(){
  return (
    <View style={styles.container}>
      <Text style={styles.title}>Assign Drone to Package</Text>
      <FlatList data={drones} keyExtractor={d=>d.id} renderItem={({item})=>(
        <TouchableOpacity style={styles.card} onPress={()=>alert('Assigned '+item.name)}>
          <Text style={{fontWeight:'700'}}>{item.name}</Text>
          <Text>Status: {item.status}</Text>
        </TouchableOpacity>
      )} />
    </View>
  );
}

const styles = StyleSheet.create({
  container:{flex:1, padding:16, backgroundColor:'#f6fbff'},
  title:{fontSize:20, fontWeight:'700', marginBottom:8},
  card:{padding:12, backgroundColor:'#eaf8ff', borderRadius:8, marginTop:8}
});
EOF

# screens/Analytics.js
cat > "$OUTDIR/screens/Analytics.js" <<'EOF'
import React from "react";
import { View, Text, StyleSheet } from "react-native";

export default function Analytics(){
  return (
    <View style={styles.container}>
      <Text style={styles.title}>Delivery Analytics (Demo)</Text>
      <Text style={styles.item}>Total Deliveries Today: 34</Text>
      <Text style={styles.item}>Average Delivery Time: 14 mins</Text>
      <Text style={styles.item}>Active Drones: 12</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container:{flex:1, padding:16, backgroundColor:'#fff'},
  title:{fontSize:20, fontWeight:'700', marginBottom:12},
  item:{fontSize:16, marginTop:6}
});
EOF

# assets (small placeholder icon as base64)
cat > "$OUTDIR/assets/logo.png" <<'BASE64'
iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAABGElEQVR4nO3SQQ3AIBDEsPz/6c7kQ2Q2aWk7j4cQe6gqM0gQYAAAAAAAAAAAAAAD4u6We1e8n4b6q/4m0v3n3P6rXx2q9u9v9y3r7b7v3Lcvp7b7v3b7b7v3b7b7v3b7b7v3b7b7v3b7b7v3b7b7v3b7b7v3b7b7v3b7b7v3b7b7v3b7b7v3b7b7v3b7b7v3b7b7v3b7b7v3b7b7v3b7b7v3b7b7v3b7b7v3b7b7v3b7b7v3b7b7v3b7b7v3b7b7v3b7b7v3b7b7v3b7b7v3b7b7v3b7b7v3b7b7v3b7b7v3b7b7v3b7b7v3b7b7v3b7b7v3b7b7v3b7b7v3b7b7v3b7b7v3b7b7v3b7b7v3b7b7v3b7b7v3b7b7v3b7b7v3b7b7v3b7b7v3b7b7v3b7b7v3b7b7v3b7b7v3Yy8CEf3X1TgAAAABJRU5ErkJggg==
BASE64

# create zip
echo "Zipping project into: $ZIPPATH"
cd "$OUTDIR"
zip -r "$ZIPPATH" . >/dev/null
cd - >/dev/null

echo "Done. Zip created at: $ZIPPATH"
echo "To run locally: cd $OUTDIR && npm install && expo start"
