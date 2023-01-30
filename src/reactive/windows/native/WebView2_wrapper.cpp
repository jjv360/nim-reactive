//
// This is wrapper code to use WebView2 from Nim

// #include <string>
// #include <cstdio>
// #include <iostream>
#include <wrl.h>
// #include "inc/wil/com.h"
#include "WebView2.h"

// Nim closure type
typedef struct {
    void* nimProc;
    void* nimEnv;
} NimClosure;

// Module
// HINSTANCE loadedLib = NULL;

// // Dynamic functions
// typedef HRESULT(Type_GetAvailableCoreWebView2BrowserVersionString)(PCWSTR browserExecutableFolder, LPWSTR* versionInfo);
// Type_GetAvailableCoreWebView2BrowserVersionString* var_GetAvailableCoreWebView2BrowserVersionString = NULL;

// Call a Nim closure
// void callNimClosure(NimClosure* closure, void* arg1) {
//     ((void(*)(void* arg1, void* env)) closure->nimProc) (arg1, closure->nimEnv);
// }
void callNimClosure(NimClosure* closure, long errorCode, void* output) {
    ((void(*)(long errorCode, void* output, void* env)) closure->nimProc) (errorCode, output, closure->nimEnv);
}

// The Winim library can handle most interactions with COM objects (such as WebView2), but unfortunately I can't find a way for it to
// call CreateCoreWebView2Environment ... this function wraps a Nim closure into Microsoft's absurd callback format.
extern "C" void WebView2CreateCallbackConverter(NimClosure* closure) {

    // Create it
    Microsoft::WRL::Callback<ICoreWebView2CreateCoreWebView2EnvironmentCompletedHandler>(
        [closure](HRESULT result, ICoreWebView2Environment* env) -> HRESULT {

            // Send env pointer to Nim
            callNimClosure(closure, (long) result, (void*) env);

        }
    )

}

// Initialize the library
// extern "C" bool PrepareWebView2(const char* dllName) {

//     // Load the library
//     printf("Loading: %s\n", dllName);
//     loadedLib = LoadLibrary(TEXT(dllName));
//     if (!loadedLib)
//         return false;

//     // Load functions
//     var_GetAvailableCoreWebView2BrowserVersionString = (Type_GetAvailableCoreWebView2BrowserVersionString*) GetProcAddress(loadedLib, "GetAvailableCoreWebView2BrowserVersionString");

//     // Done
//     return true;

// }

// extern "C" LPWSTR GetWebView2Version() {

//     // Create string buffer
//     LPWSTR str;
//     var_GetAvailableCoreWebView2BrowserVersionString(NULL, &str);
//     return str;

// }

// extern "C" void CreateWebView2Environment(NimClosure* callback) {

//     // See: https://github.com/MicrosoftEdge/WebView2Samples/blob/main/GettingStartedGuides/Win32_GettingStarted/HelloWebView.cpp#L112
//     CreateCoreWebView2EnvironmentWithOptions(nullptr, nullptr, nullptr,
// 		Callback<ICoreWebView2CreateCoreWebView2EnvironmentCompletedHandler>(
// 			[callback](HRESULT result, ICoreWebView2Environment* env) -> HRESULT {

//                 // Here!
//                 callNimClosure(callback, result, (void*) env);

//             }
//         )
//     )

// }