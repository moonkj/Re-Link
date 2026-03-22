import Flutter
import UIKit

class SceneDelegate: FlutterSceneDelegate {
  // 카카오 로그인 등 외부 URL 콜백 처리 (iOS 13+ SceneDelegate)
  override func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
    super.scene(scene, openURLContexts: URLContexts)
  }
}
