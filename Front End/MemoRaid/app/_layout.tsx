import { DarkTheme, DefaultTheme, ThemeProvider } from "@react-navigation/native";
import { useFonts } from "expo-font";
import { Stack } from "expo-router";
import * as SplashScreen from "expo-splash-screen";
import { StatusBar } from "expo-status-bar";
import { useEffect, useState } from "react";
import "react-native-reanimated";

import SplashScreenComponent from "./(tabs)/splashscreen"; // Import your custom SplashScreen
import { useColorScheme } from "@/hooks/useColorScheme";

// Prevent the splash screen from auto-hiding before asset loading is complete.
SplashScreen.preventAutoHideAsync();

export default function RootLayout() {
  const colorScheme = useColorScheme();
  const [loaded] = useFonts({
    SpaceMono: require("../assets/fonts/SpaceMono-Regular.ttf"),
  });

  const [isSplashScreenVisible, setSplashScreenVisible] = useState(true); // Control visibility of custom SplashScreen

  useEffect(() => {
    if (loaded) {
      SplashScreen.hideAsync(); // Hide the expo splash screen
      setTimeout(() => setSplashScreenVisible(false), 3000); // Show custom SplashScreen for 3 seconds
    }
  }, [loaded]);

  // Ensuring that the splash screen is shown while fonts are loading or the splash screen is visible
  if (!loaded || isSplashScreenVisible) {
    return <SplashScreenComponent />;
  }

  // Fallback to DefaultTheme if colorScheme is undefined
  const theme = colorScheme === "dark" ? DarkTheme : DefaultTheme;

  return (
    <ThemeProvider value={theme}>
      <Stack>
        <Stack.Screen name="(tabs)" options={{ headerShown: false }} />
        <Stack.Screen name="+not-found" />
      </Stack>
      <StatusBar style="auto" />
    </ThemeProvider>
  );
}
