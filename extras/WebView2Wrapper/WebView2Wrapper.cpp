//
// This is a simple wrapper around WebView2 which allows usage from Nim.
// All strings are UTF8-encoded

//#define CINTERFACE
#include <windows.h>
#include <stdlib.h>
#include <string>
#include <tchar.h>
#include <wrl.h>
#include <wil/com.h>
#include <atlstr.h>
#include <vector> 
#include <comdef.h>
#include <iostream>
//#include <format>
#include "WebView2.h"

using namespace Microsoft::WRL;

// Vars to hold in memory
std::vector<wil::com_ptr<ICoreWebView2Controller>> webviewControllers;

// Convert a COM error code to a string
extern "C" __declspec(dllexport) const char* WebView2_GetErrorString(HRESULT hr) {

	// Check for known error codes
	switch (hr) {
		case HRESULT_FROM_WIN32(ERROR_FILE_NOT_FOUND): return "Couldn't find Edge WebView2 Runtime. Do you have a version installed?";
		case HRESULT_FROM_WIN32(ERROR_FILE_EXISTS): return "User data folder cannot be created because a file with the same name already exists.";
		case E_ACCESSDENIED: return "Unable to create user data folder, Access Denied.";
		case E_FAIL: return "Edge runtime unable to start";
	}

	// Get error string
	_com_error err(hr);
	const char* str = CW2A(err.ErrorMessage());

	// Copy so memory is not released ... host app should free it when done
	if (strlen(str) <= 0) return "";
	char* copy = (char*)malloc(strlen(str) + 1);
	if (!copy) return "";
	strcpy_s(copy, strlen(str) + 1, str);
	return copy;

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
	if (strlen(str) <= 0) return "";
	char* copy = (char*) malloc(strlen(str) + 1);
	if (!copy) return "";
	strcpy_s(copy, strlen(str) + 1, str);
	return copy;

}

// Create a web view and attach to a window
extern "C" __declspec(dllexport) HRESULT WebView2_CreateAndAttach(HWND parentWindow, _Out_ ICoreWebView2Environment * outEnv) {

	// Prepare
	outEnv = nullptr;
	bool exitLoop = false;
	HRESULT returnCode = S_FALSE;

	// Initialize COM
	auto result = CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);
	if (result != S_OK && result != S_FALSE)		// <-- False if it's already initialized
		return result;

	// Create the environment
	CreateCoreWebView2Environment(
		Callback<ICoreWebView2CreateCoreWebView2EnvironmentCompletedHandler>(
			[&](HRESULT result, ICoreWebView2Environment* env) -> HRESULT {

				// Check output
				if (result != S_OK) {
					exitLoop = true;
					returnCode = result;
					return S_OK;
				}
				
				// Create the web view
				env->CreateCoreWebView2Controller(parentWindow, Callback<ICoreWebView2CreateCoreWebView2ControllerCompletedHandler>(
					[&](HRESULT result, ICoreWebView2Controller* controller) -> HRESULT {

						// Check output
						if (result != S_OK) {
							exitLoop = true;
							returnCode = result;
							return S_OK;
						}

						// Store it
						webviewControllers.push_back(controller);

						// Call callback
						//char buff[100];
						//snprintf(buff, sizeof(buff), "H2 cb=%lli context=%lli controller=%lli", cb, context, controller);
						//MessageBoxA(0, buff, "Hello", 0);

						// Set default size
						RECT bounds;
						GetClientRect(parentWindow, &bounds);
						controller->put_IsVisible(true);
						controller->put_Bounds(bounds);

						//static wil::com_ptr<ICoreWebView2> webview;
						wil::com_ptr<ICoreWebView2> webview;
						controller->get_CoreWebView2(&webview);
						webview->Navigate(L"https://www.bing.com/");

						// Done
						exitLoop = true;
						returnCode = result;
						return S_OK;

					}).Get());
	
				return S_OK;

			}).Get());

	// Run event loop until we're done
	MSG msg;
	while (!exitLoop && GetMessage(&msg, NULL, 0, 0)) {
		TranslateMessage(&msg);
		DispatchMessage(&msg);
	}

	// Return code
	return returnCode;

}

// NimClosure
typedef struct {
	void* nimProc;
	void* nimEnv;
} NimClosure;

// Create environent and return a COM object for it
typedef void(WebVew2_CreateEnvironment_Callback)(HRESULT result, ICoreWebView2Environment* env, void* context);
extern "C" __declspec(dllexport) void WebView2_CreateEnvironment(void* context, WebVew2_CreateEnvironment_Callback* cb) {

	// Initialize COM
	auto result = CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);
	if (result != S_OK && result != S_FALSE) {	// <-- False if it's already initialized
		cb(result, nullptr, context);
		return;
	}

	// Create it
	CreateCoreWebView2Environment(
		Callback<ICoreWebView2CreateCoreWebView2EnvironmentCompletedHandler>(
			[&](HRESULT result, ICoreWebView2Environment* env) -> HRESULT {

				// Call callback
				//typedef void(FuncType)(HRESULT result, ICoreWebView2Environment* env, void* nimEnv);
				//webviewEnv = env;
				cb(result, env, context);
				return S_OK;

			}).Get());

}

// Asynchronously create a new WebView.
typedef void(WebVew2_CreateController_Callback)(HRESULT result, ICoreWebView2Controller* controller, void* context);
extern "C" __declspec(dllexport) void WebView2_CreateController(ICoreWebView2Environment* env, HWND parentWindow, void* context, WebVew2_CreateController_Callback* cb) {

	// Do it
	env->CreateCoreWebView2Controller(parentWindow, Callback<ICoreWebView2CreateCoreWebView2ControllerCompletedHandler>(
		[&](HRESULT result, ICoreWebView2Controller* controller) -> HRESULT {

			// Store it
			webviewControllers.push_back(controller);

			// Call callback
			//char buff[100];
			//snprintf(buff, sizeof(buff), "H2 cb=%lli context=%lli controller=%lli", cb, context, controller);
			//MessageBoxA(0, buff, "Hello", 0);

			// Set default size
			RECT bounds;
			GetClientRect(parentWindow, &bounds);
			controller->put_IsVisible(true);
			controller->put_Bounds(bounds);

			//static wil::com_ptr<ICoreWebView2> webview;
			wil::com_ptr<ICoreWebView2> webview;
			controller->get_CoreWebView2(&webview);
			webview->Navigate(L"https://www.bing.com/");

			//cb(result, controller, context);
			return S_OK;

		}).Get());

	MSG msg;
	while (GetMessage(&msg, NULL, 0, 0))
	{
		TranslateMessage(&msg);
		DispatchMessage(&msg);
	}

}

// Drain the event queue once
extern "C" __declspec(dllexport) void WebView2_MessageLoop() {

	// Run it
	MSG msg;
	while (PeekMessage(&msg, NULL, 0, 0, PM_REMOVE) != 0) {
		TranslateMessage(&msg);
		DispatchMessage(&msg);
	}

}

// Set WebView bounds within the parent window
extern "C" __declspec(dllexport) void WebView2_SetBounds(ICoreWebView2Controller* controller, long x, long y, long width, long height) {
	RECT bounds;
	bounds.left = x;
	bounds.top = y;
	bounds.right = width - x;
	bounds.bottom = height - y;
	controller->put_Bounds(bounds);
}

// Convert UTF8 string to UTF16
// Source: https://stackoverflow.com/a/148766/1008736
std::wstring UTF8_to_wchar(const char* in)
{
	std::wstring out;
	unsigned int codepoint = 0;
	while (*in != 0)
	{
		unsigned char ch = static_cast<unsigned char>(*in);
		if (ch <= 0x7f)
			codepoint = ch;
		else if (ch <= 0xbf)
			codepoint = (codepoint << 6) | (ch & 0x3f);
		else if (ch <= 0xdf)
			codepoint = ch & 0x1f;
		else if (ch <= 0xef)
			codepoint = ch & 0x0f;
		else
			codepoint = ch & 0x07;
		++in;
		if (((*in & 0xc0) != 0x80) && (codepoint <= 0x10ffff))
		{
			if (sizeof(wchar_t) > 2)
				out.append(1, static_cast<wchar_t>(codepoint));
			else if (codepoint > 0xffff)
			{
				out.append(1, static_cast<wchar_t>(0xd800 + (codepoint >> 10)));
				out.append(1, static_cast<wchar_t>(0xdc00 + (codepoint & 0x03ff)));
			}
			else if (codepoint < 0xd800 || codepoint >= 0xe000)
				out.append(1, static_cast<wchar_t>(codepoint));
		}
	}
	return out;
}

// Navigate to page
extern "C" __declspec(dllexport) void WebView2_Navigate(ICoreWebView2Controller* controller, const char* url) {

	// Get WebView
	wil::com_ptr<ICoreWebView2> webview;
	controller->get_CoreWebView2(&webview);

	// Navigate
	auto wstr = UTF8_to_wchar(url);
	webview->Navigate(wstr.c_str());

}