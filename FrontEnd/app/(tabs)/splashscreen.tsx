import React, { useEffect } from "react";
import { Image, StyleSheet, View } from "react-native";
import { useNavigation } from "@react-navigation/native";
import { StackNavigationProp } from "@react-navigation/stack";

type RootStackParamList = {
  SplashScreen: undefined;
  LoginOrSignUp: undefined;
};

type SplashScreenNavigationProp = StackNavigationProp<RootStackParamList, "SplashScreen">;

const SplashScreen: React.FC = () => {
  const navigation = useNavigation<SplashScreenNavigationProp>();

  useEffect(() => {
    const timer = setTimeout(() => {
      navigation.navigate("LoginOrSignUp"); // Navigate to LoginOrSignUp after 3 seconds
    }, 3000);

    return () => clearTimeout(timer); // Cleanup the timer on unmount
  }, [navigation]);

  return (
    <View style={styles.splashScreen}>
      <Image
        style={styles.whatsappImage}
        resizeMode="cover"
        source={require("../../assets/images/splash.png")}
      />
    </View>
  );
};

const styles = StyleSheet.create({
  splashScreen: { flex: 1, justifyContent: "center", alignItems: "center", backgroundColor: "#fff" },
  whatsappImage: { width: 300, height: 300 },
});

export default SplashScreen;
