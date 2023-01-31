//
// This is a simple wrapper around WebView2 which allows usage from Nim.

#include <wrl.h>
#include <wil/com.h>
#include <atlstr.h>
// <IncludeHeader>
// include WebView2 header
#include "WebView2.h"

using namespace Microsoft::WRL;

// Nim closure type
typedef struct {
	void* nimProc;
	void* nimEnv;
} NimClosure;

// Call nim closure
void callNimClosure(NimClosure* closure, long errorCode, void* output) {
	((void(*)(long errorCode, void* output, void* env)) closure->nimProc) (errorCode, output, closure->nimEnv);
}

// Get version of the installed WebView2 as a string. Host app should free the string when done.
extern "C" __declspec(dllexport) const char* WebView2_GetInstalledVersion() {

	// Get installed version
	LPWSTR versionInfo;
	GetAvailableCoreWebView2BrowserVersionString(nullptr, &versionInfo);
	
	// Convert to char*
	const char* str = CW2A(versionInfo);
	CoTaskMemFree(versionInfo);

	// Copy so memory is not released ... host app should free it when done
	char* copy = (char*) malloc(strlen(str) + 1);
	strcpy_s(copy, strlen(str) + 1, str);
	return copy;

}

// Create environent and return a COM object for it
extern "C" __declspec(dllexport) void WebView2_CreateEnvironment(NimClosure* callback) {

	// Create it
	CreateCoreWebView2EnvironmentWithOptions(nullptr, nullptr, nullptr,
		Callback<ICoreWebView2CreateCoreWebView2EnvironmentCompletedHandler>(
			[&](HRESULT result, ICoreWebView2Environment* env) -> HRESULT {

				// Call callback
				callNimClosure(callback, (long)result, (void*)env);
				return S_OK;

			}).Get());

}

// Asynchronously create a new WebView.
extern "C" __declspec(dllexport) void WebView2_CreateController(HWND parentWindow, ICoreWebView2Environment* env, NimClosure* callback) {

	// Do it
	env->CreateCoreWebView2Controller(parentWindow, Callback<ICoreWebView2CreateCoreWebView2ControllerCompletedHandler>(
		[&](HRESULT result, ICoreWebView2Controller* controller) -> HRESULT {

			// Call callback
			callNimClosure(callback, (long)result, (void*)controller);
			return S_OK;

		}).Get());

}