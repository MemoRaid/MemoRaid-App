import React from "react";
import { Image, StyleSheet, View, Text, Pressable, ViewStyle, TextStyle } from "react-native";

// Define prop types
interface SplashScreenProps {
  onNext: () => void;
}

const SplashScreen: React.FC<SplashScreenProps> = ({ onNext }) => {
  return (
    <View style={styles.splashScreen}>
      <Image
        style={styles.whatsappImage}
        resizeMode="cover"
        source={require("../../assets/images/splash.png")} // Ensure this file exists
      />
      <View style={styles.homeIndicator} />
      <Pressable
        style={styles.buttonPrimary}
        onPress={onNext} // Pass the onPress action as a prop
      >
        <Text style={[styles.button, styles.wiFiTypo]}>Next</Text>
      </Pressable>
      <View style={[styles.splashScreenInner, styles.splashScreenInnerLayout]}>
        <View style={[styles.iosStatusBarParent, styles.splashScreenInnerLayout]}>
          <View style={styles.action}>
            <Text style={[styles.time, styles.timeClr]}>9:41</Text>
          </View>
          <View style={styles.container}>
            <Text style={[styles.battery, styles.timeClr]}>􀛨</Text>
            <Text style={[styles.wiFi, styles.timeClr]}>􀙇</Text>
          </View>
        </View>
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  wiFiTypo: {
    fontSize: 14,
    textAlign: "left",
  },
  splashScreenInnerLayout: {
    height: 44,
    width: 360,
    position: "absolute",
  },
  timeClr: {
    color: "#1f2024",
    fontFamily: "SF Pro Text",
    position: "absolute",
  },
  whatsappImage: {
    top: -5,
    left: -9,
    width: 379,
    height: 810,
    position: "absolute",
  },
  homeIndicator: {
    marginLeft: -67,
    bottom: 4,
    borderRadius: 3,
    backgroundColor: "#1f2024",
    width: 133,
    height: 6,
    left: "50%",
    position: "absolute",
  },
  button: {
    fontFamily: "Inter-SemiBold",
    color: "#fff",
    textAlign: "left",
    fontWeight: "600",
  },
  buttonPrimary: {
    marginTop: 270,
    marginLeft: -164,
    borderRadius: 25,
    backgroundColor: "#0d3445",
    width: 327,
    height: 48,
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "center",
    top: "50%",
    left: "50%",
    position: "absolute",
  },
  time: {
    fontSize: 15,
    fontWeight: "600",
    textAlign: "center",
    width: 54,
    top: "50%",
    left: 0,
  },
  action: {
    height: "40.91%",
    width: "14.33%",
    top: "31.82%",
    left: "5.31%",
    position: "absolute",
  },
  battery: {
    top: -3,
    left: 41,
    fontSize: 17,
    textAlign: "left",
  },
  wiFi: {
    top: -1,
    left: 21,
    textAlign: "left",
    fontSize: 14,
  },
  container: {
    marginTop: -6,
    right: 14,
    width: 68,
    height: 14,
    position: "absolute",
  },
  iosStatusBarParent: {
    marginLeft: -180,
    top: 0,
    left: "50%",
  },
  splashScreenInner: {
    top: 7,
    left: 0,
  },
  splashScreen: {
    flex: 1,
    width: "100%",
    height: "100%",
    backgroundColor: "transparent",
  },
});

export default SplashScreen;
