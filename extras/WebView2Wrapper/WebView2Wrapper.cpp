//
// This is a simple wrapper around WebView2 which allows usage from Nim.

#include <windows.h>
#include <stdlib.h>
#include <string>
#include <tchar.h>
#include <wrl.h>
#include <wil/com.h>
#include <atlstr.h>
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
	unsigned int codepoint;
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