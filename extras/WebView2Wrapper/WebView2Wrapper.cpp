//
// This is a simple wrapper around WebView2 which allows usage from Nim.
// All strings are UTF8-encoded

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

// Created environments held in memory
//std::vector

// Create environent and return a COM object for it
typedef void(WebView2_CreateEnvironment_Callback)(HRESULT result, ICoreWebView2Environment* env, void* userData);
extern "C" __declspec(dllexport) void WebView2_CreateEnvironment(void* userData, WebView2_CreateEnvironment_Callback * callback) {

	// Initialize COM
	auto result = CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);
	if (result != S_OK && result != S_FALSE) {	// <-- False if it's already initialized
		callback(result, nullptr, userData);
		return;
	}

	// Create it
	CreateCoreWebView2Environment(
		Callback<ICoreWebView2CreateCoreWebView2EnvironmentCompletedHandler>(
			[&](HRESULT result, ICoreWebView2Environment* env) -> HRESULT {

				// Call callback
				callback(result, env, userData);
				return S_OK;

			}).Get());

}

//  FUNCTION: WndProc(HWND, UINT, WPARAM, LPARAM)
//
//  PURPOSE:  Processes messages for the main window.
//
//  WM_DESTROY  - post a quit message and return
LRESULT CALLBACK WndProc(HWND hWnd, UINT message, WPARAM wParam, LPARAM lParam)
{
	TCHAR greeting[] = _T("Hello, Windows desktop!");

	switch (message)
	{
	case WM_SIZE:
		break;
	case WM_DESTROY:
		PostQuitMessage(0);
		break;
	default:
		return DefWindowProc(hWnd, message, wParam, lParam);
		break;
	}

	return 0;
}

// Asynchronously create a new WebView.
typedef void(WebView2_CreateController_Callback)(HRESULT result, ICoreWebView2Controller* env, void* userData);
extern "C" __declspec(dllexport) void WebView2_CreateController(ICoreWebView2Environment* env, void* userData, HWND parentWindow, WebView2_CreateController_Callback * callback) {

	// Do it
	//char buff[100];
	//snprintf(buff, sizeof(buff), "HWND %lli", parentWindow);
	//MessageBoxA(0, buff, "Hello", 0);

	HWND hWnd = CreateWindow(
		L"NimReactiveWindowClass",
		L"Hello",
		WS_OVERLAPPEDWINDOW,
		CW_USEDEFAULT, CW_USEDEFAULT,
		1200, 900,
		NULL,
		NULL,
		NULL,
		NULL
	);

	env->CreateCoreWebView2Controller(hWnd, Callback<ICoreWebView2CreateCoreWebView2ControllerCompletedHandler>(
		[&](HRESULT result, ICoreWebView2Controller* controller) -> HRESULT {

			// Call callback
			callback(result, controller, userData);
			return S_OK;

		}).Get());

}

// Set WebView bounds within the parent window
extern "C" __declspec(dllexport) void WebView2_SetBounds(ICoreWebView2Controller* controller, long x, long y, long width, long height) {
	RECT bounds;
	bounds.left = x;
	bounds.top = y;
	bounds.right = width - x;
	bounds.bottom = height = y;
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