import React from "react";
import { NavigationContainer } from "@react-navigation/native";
import { createStackNavigator } from "@react-navigation/stack";

import SplashScreen from "./splashscreen";
import LoginOrSignUp from "./loginorsignup";
const Stack = createStackNavigator();

const App = () => {
  return (
    <NavigationContainer>
      <Stack.Navigator screenOptions={{ headerShown: false }}>
        <Stack.Screen name="SplashScreen" component={SplashScreen} />
        <Stack.Screen name="LoginOrSignUp" component={LoginOrSignUp} />
        
      </Stack.Navigator>
    </NavigationContainer>
  );

};
export default App;

