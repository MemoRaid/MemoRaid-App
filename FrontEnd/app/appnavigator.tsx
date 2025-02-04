import React from "react";
import { createStackNavigator } from "@react-navigation/stack";
import { NavigationContainer } from "@react-navigation/native";
import SplashScreen from "./(tabs)/splashscreen";
import LoginOrSignUp from "./(tabs)/loginorsignup";


const Stack = createStackNavigator();

const AppNavigator = () => {
  return (
    <NavigationContainer>
      <Stack.Navigator initialRouteName="SplashScreen" screenOptions={{ headerShown: false }}>
        <Stack.Screen name="SplashScreen" component={SplashScreen} />
        <Stack.Screen name="LoginOrSignUp" component={LoginOrSignUp} />
      </Stack.Navigator>
    </NavigationContainer>
  );
};

export default AppNavigator;
