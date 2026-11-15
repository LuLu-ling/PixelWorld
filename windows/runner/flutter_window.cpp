#include "flutter_window.h"

#include <commctrl.h>

#include <optional>

#include "flutter/generated_plugin_registrant.h"

#pragma comment(lib, "comctl32.lib")

namespace {

// Only expose the Flutter accessibility tree while a screen reader is running.
//
// The engine's UIA/MSAA hit testing (FlutterPlatformNodeDelegate::HitTestSync)
// dereferences a null delegate when a child node disappears while the
// semantics tree is changing, which crashes the whole app. Tools that probe
// the element under the mouse all the time (word-lookup translators, touch
// keyboard, remote desktop) trigger it while a slider is dragged or the
// wallpaper is changed. They don't need our tree, so without a screen reader
// they get the default result for a plain window; Narrator, NVDA and other
// screen readers still get the full tree.
bool ScreenReaderOn() {
  BOOL on = FALSE;
  return SystemParametersInfo(SPI_GETSCREENREADER, 0, &on, 0) && on;
}

LRESULT CALLBACK ViewSubclassProc(HWND hwnd, UINT message, WPARAM wparam,
                                  LPARAM lparam, UINT_PTR id, DWORD_PTR) {
  switch (message) {
    case WM_GETOBJECT:
      if (!ScreenReaderOn()) {
        return DefWindowProc(hwnd, message, wparam, lparam);
      }
      break;
    case WM_NCDESTROY:
      RemoveWindowSubclass(hwnd, ViewSubclassProc, id);
      break;
  }
  return DefSubclassProc(hwnd, message, wparam, lparam);
}

}  // namespace

FlutterWindow::FlutterWindow(const flutter::DartProject& project)
    : project_(project) {}

FlutterWindow::~FlutterWindow() {}

bool FlutterWindow::OnCreate() {
  if (!Win32Window::OnCreate()) {
    return false;
  }

  RECT frame = GetClientArea();

  // The size here must match the window dimensions to avoid unnecessary surface
  // creation / destruction in the startup path.
  flutter_controller_ = std::make_unique<flutter::FlutterViewController>(
      frame.right - frame.left, frame.bottom - frame.top, project_);
  // Ensure that basic setup of the controller was successful.
  if (!flutter_controller_->engine() || !flutter_controller_->view()) {
    return false;
  }
  RegisterPlugins(flutter_controller_->engine());
  SetChildContent(flutter_controller_->view()->GetNativeWindow());
  SetWindowSubclass(flutter_controller_->view()->GetNativeWindow(),
                    ViewSubclassProc, 1, 0);

  flutter_controller_->engine()->SetNextFrameCallback([&]() {
    this->Show();
  });

  // Flutter can complete the first frame before the "show window" callback is
  // registered. The following call ensures a frame is pending to ensure the
  // window is shown. It is a no-op if the first frame hasn't completed yet.
  flutter_controller_->ForceRedraw();

  return true;
}

void FlutterWindow::OnDestroy() {
  if (flutter_controller_) {
    flutter_controller_ = nullptr;
  }

  Win32Window::OnDestroy();
}

LRESULT
FlutterWindow::MessageHandler(HWND hwnd, UINT const message,
                              WPARAM const wparam,
                              LPARAM const lparam) noexcept {
  // Give Flutter, including plugins, an opportunity to handle window messages.
  if (flutter_controller_) {
    std::optional<LRESULT> result =
        flutter_controller_->HandleTopLevelWindowProc(hwnd, message, wparam,
                                                      lparam);
    if (result) {
      return *result;
    }
  }

  switch (message) {
    case WM_FONTCHANGE:
      flutter_controller_->engine()->ReloadSystemFonts();
      break;
  }

  return Win32Window::MessageHandler(hwnd, message, wparam, lparam);
}
