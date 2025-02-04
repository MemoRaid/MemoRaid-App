import React from "react";
import { StyleSheet, View, Text, Image, Pressable } from "react-native";
import { useNavigation } from "@react-navigation/native";

const LoginOrSignUp = () => {
    const navigation = useNavigation();

    return (
        <View style={styles.container}>
            <View style={styles.homeIndicator} />
            <Image style={styles.logo} resizeMode="cover" source={require("./assets/logo.png")} />
            <Text style={styles.title}>Create your</Text>
            <Text style={styles.subtitle}>MemoRaid account</Text>
            <Text style={styles.description}>
                We help you reconnect with cherished memories, restoring your story and honoring your unique journey.
            </Text>
            <Pressable style={[styles.button, styles.signUpButton]} onPress={() => navigation.navigate("")}> 
                <Text style={styles.buttonText}>Sign up</Text>
            </Pressable>
            <Pressable style={[styles.button, styles.loginButton]} onPress={() => navigation.navigate("")}> 
                <Text style={styles.loginButtonText}>Log in</Text>
            </Pressable>
            <Pressable style={styles.termsContainer}>
                <Text style={styles.termsText}>
                    By continuing you accept our {" "}
                    <Text style={styles.linkText}>Terms and Conditions</Text> and {" "}
                    <Text style={styles.linkText}>Privacy Policy</Text>
                </Text>
            </Pressable>
        </View>
    );
};

const styles = StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: "#fff",
        alignItems: "center",
        justifyContent: "center",
        paddingHorizontal: 20,
    },
    homeIndicator: {
        position: "absolute",
        bottom: 10,
        width: 100,
        height: 5,
        borderRadius: 3,
        backgroundColor: "#1f2024",
    },
    logo: {
        width: 200,
        height: 200,
        marginBottom: 20,
    },
    title: {
        fontSize: 24,
        fontWeight: "800",
        textAlign: "center",
        color: "#000",
    },
    subtitle: {
        fontSize: 24,
        fontWeight: "800",
        textAlign: "center",
        color: "#000",
        marginBottom: 10,
    },
    description: {
        fontSize: 12,
        textAlign: "center",
        color: "rgba(0, 0, 0, 0.7)",
        marginBottom: 20,
        paddingHorizontal: 10,
    },
    button: {
        width: "100%",
        paddingVertical: 12,
        borderRadius: 12,
        alignItems: "center",
        marginVertical: 5,
    },
    signUpButton: {
        backgroundColor: "#0d3445",
    },
    loginButton: {
        backgroundColor: "#fff",
        borderWidth: 1,
        borderColor: "#0d3445",
    },
    buttonText: {
        fontSize: 14,
        fontWeight: "700",
        color: "#fff",
    },
    loginButtonText: {
        fontSize: 14,
        fontWeight: "700",
        color: "#0d3445",
    },
    termsContainer: {
        marginTop: 20,
    },
    termsText: {
        fontSize: 12,
        textAlign: "center",
        color: "#71727a",
    },
    linkText: {
        textDecorationLine: "underline",
        fontWeight: "600",
        color: "#0d3445",
    },
});

export default LoginOrSignUp;
