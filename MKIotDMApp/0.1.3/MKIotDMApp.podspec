#
# MKIotDMApp.podspec
# 只拆 2 个 Network 子规格：基础设施 + 业务API
# LoginManager 只依赖 Network（轻量），不碰 NetworkServices
#

Pod::Spec.new do |s|
  s.name             = 'MKIotDMApp'
  s.version          = '0.1.3'
  s.summary          = 'IoT Device Management App framework.'

  s.description      = <<-DESC
IoT Device Management App framework.
Network split into 2 subspecs: Network (infrastructure) + NetworkServices (business APIs).
LoginManager depends on Network only — lightweight for other private libraries.
                       DESC

  s.homepage         = 'git@120.27.8.241:MokoTest/MKIoTDM_iOS.git'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'lovexiaoxia' => 'aadyx2007@163.com' }
  s.source           = { :git => 'git@120.27.8.241:MokoTest/MKIoTDM_iOS.git', :tag => s.version.to_s }

  s.ios.deployment_target = '18.0'

  s.static_framework = true

  s.pod_target_xcconfig = {
    'OTHER_LDFLAGS' => '-ObjC',
    'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES' => 'YES'
  }

  # ⚠️ 无全局依赖，各 subspec 自行声明

  # ================================================================
  # Network 基础设施（登录必需，其他私有库引用 LoginManager 时只拉这个）
  # ================================================================
  s.subspec 'Network' do |net|
    net.source_files = 'MKIotDMApp/Classes/Network/Network/**/*.{h,m}',
                       'MKIotDMApp/Classes/Network/EnvironmentManager/**/*.{h,m}',
                       'MKIotDMApp/Classes/Network/UserManager/**/*.{h,m}',
                       'MKIotDMApp/Classes/Network/Service/MKIDMBaseService.{h,m}',
                       'MKIotDMApp/Classes/Network/Service/Account/**/*.{h,m}'
    net.resource_bundles = {
      'MKIotDMApp' => ['MKIotDMApp/Assets/*.png']
    }
    net.dependency 'MKBaseModuleLibrary'
    net.dependency 'MKCustomUIModule'
  end

  # ================================================================
  # NetworkServices（全部业务 API Service + WebSocket + NetworkManager）
  # 壳工程全量引用，业务模块统一依赖这个
  # ================================================================
  s.subspec 'NetworkServices' do |svc|
    svc.source_files = 'MKIotDMApp/Classes/Network/Service/Alarm/**/*.{h,m}',
                       'MKIotDMApp/Classes/Network/Service/Beacon/**/*.{h,m}',
                       'MKIotDMApp/Classes/Network/Service/Cellular/**/*.{h,m}',
                       'MKIotDMApp/Classes/Network/Service/Dashboard/**/*.{h,m}',
                       'MKIotDMApp/Classes/Network/Service/Gateway/**/*.{h,m}',
                       'MKIotDMApp/Classes/Network/Service/LoRa/**/*.{h,m}',
                       'MKIotDMApp/Classes/Network/Service/MQTTServer/**/*.{h,m}',
                       'MKIotDMApp/Classes/Network/Service/Sensor/**/*.{h,m}',
                       'MKIotDMApp/Classes/Network/Service/System/**/*.{h,m}',
                       'MKIotDMApp/Classes/Network/Service/Tracker/**/*.{h,m}',
                       'MKIotDMApp/Classes/Network/WebSocketManager/**/*.{h,m}',
                       'MKIotDMApp/Classes/Network/MKIDMNetworkManager.{h,m}'
    svc.dependency 'MKIotDMApp/Network'
  end

  # ================================================================
  # Expand（业务通用组件）
  # ================================================================
  s.subspec 'Expand' do |exp|
    exp.source_files = 'MKIotDMApp/Classes/Expand/**/*.{h,m}'
    exp.dependency 'MKBaseModuleLibrary'
    exp.dependency 'MKCustomUIModule'
    exp.dependency 'FMDB'
  end

  # ================================================================
  # LoginManager（对外弹窗入口，轻量级，只依赖 Network）
  # 注意：不包含 MKIDMLoginAlertView（壳工程无环境切换弹窗，依赖 MainTabBar）
  # 子组件用带环境切换的 MKIDMLoginAlertWithEnvView
  # ================================================================
  s.subspec 'LoginManager' do |alert|
    alert.source_files = 'MKIotDMApp/Classes/Functions/LoginManager/MKIDMLoginManager.{h,m}',
                         'MKIotDMApp/Classes/Functions/LoginManager/MKIDMLoginAlertWithEnvView.{h,m}',
                         'MKIotDMApp/Classes/Functions/LoginManager/MKIDMExitAccountAlert.{h,m}'
    alert.dependency 'MKIotDMApp/Network'
    alert.dependency 'HHTransition'
    alert.dependency 'MLInputDodger'
  end

  # ================================================================
  # Login（账号管理页面 + 服务器配置页面，壳工程用）
  # ================================================================
  s.subspec 'Login' do |login|
    login.source_files = 'MKIotDMApp/Classes/Functions/Login/**/*.{h,m}'
    login.dependency 'MKIotDMApp/Network'
    login.dependency 'MKIotDMApp/Expand'
    login.dependency 'HHTransition'
    login.dependency 'MLInputDodger'
  end

  # ================================================================
  # 共享功能模块
  # ================================================================
  s.subspec 'FilterPages' do |filter|
    filter.source_files = 'MKIotDMApp/Classes/Functions/FilterPages/**/*.{h,m}'
    filter.dependency 'MKIotDMApp/Expand'
  end

  s.subspec 'PathDisplayPage' do |path|
    path.source_files = 'MKIotDMApp/Classes/Functions/PathDisplayPage/**/*.{h,m}'
    path.dependency 'MKIotDMApp/Expand'
  end

  s.subspec 'PositionPages' do |position|
    position.source_files = 'MKIotDMApp/Classes/Functions/PositionPages/**/*.{h,m}'
    position.dependency 'MKIotDMApp/Expand'
    position.dependency 'MKIotDMApp/Network'
    position.dependency 'MKIotDMApp/PathDisplayPage'
  end

  s.subspec 'UnreadStateManager' do |unread|
    unread.source_files = 'MKIotDMApp/Classes/Functions/UnreadStateManager/**/*.{h,m}'
    unread.dependency 'MKIotDMApp/Network'
  end

  # ================================================================
  # 业务模块（source_files 只写 Functions/，API 通过 NetworkServices 依赖）
  # ================================================================
  s.subspec 'Alarm' do |alarm|
    alarm.source_files = 'MKIotDMApp/Classes/Functions/Alarm/**/*.{h,m}'
    alarm.dependency 'MKIotDMApp/Expand'
    alarm.dependency 'MKIotDMApp/NetworkServices'
  end

  s.subspec 'Beacon' do |beacon|
    beacon.source_files = 'MKIotDMApp/Classes/Functions/Beacon/**/*.{h,m}'
    beacon.dependency 'MKIotDMApp/Expand'
    beacon.dependency 'MKIotDMApp/NetworkServices'
  end

  s.subspec 'LoRa' do |lora|
    lora.source_files = 'MKIotDMApp/Classes/Functions/LoRa/**/*.{h,m}'
    lora.dependency 'MKIotDMApp/Expand'
    lora.dependency 'MKIotDMApp/NetworkServices'
    lora.dependency 'MKIotDMApp/PathDisplayPage'
  end

  s.subspec 'Cellular' do |cellular|
    cellular.source_files = 'MKIotDMApp/Classes/Functions/Cellular/**/*.{h,m}'
    cellular.dependency 'MKIotDMApp/Expand'
    cellular.dependency 'MKIotDMApp/NetworkServices'
    cellular.dependency 'MKIotDMApp/FilterPages'
    cellular.dependency 'MKIotDMApp/PositionPages'
    cellular.dependency 'BRPickerView'
  end

  s.subspec 'Gateway' do |gateway|
    gateway.source_files = 'MKIotDMApp/Classes/Functions/Gateway/**/*.{h,m}'
    gateway.dependency 'MKIotDMApp/Expand'
    gateway.dependency 'MKIotDMApp/NetworkServices'
    gateway.dependency 'MKIotDMApp/FilterPages'
    gateway.dependency 'SGQRCode', '~> 4.1.0'
    gateway.dependency 'BRPickerView'
  end

  s.subspec 'Tracker' do |tracker|
    tracker.source_files = 'MKIotDMApp/Classes/Functions/Tracker/**/*.{h,m}'
    tracker.dependency 'MKIotDMApp/Expand'
    tracker.dependency 'MKIotDMApp/NetworkServices'
    tracker.dependency 'MKIotDMApp/Alarm'
    tracker.dependency 'MKIotDMApp/PositionPages'
  end

  s.subspec 'Sensor' do |sensor|
    sensor.source_files = 'MKIotDMApp/Classes/Functions/sensor/**/*.{h,m}'
    sensor.dependency 'MKIotDMApp/Expand'
    sensor.dependency 'MKIotDMApp/NetworkServices'
  end

  # ================================================================
  # DashboardPage（聚合所有业务模块）
  # ================================================================
  s.subspec 'DashboardPage' do |dashboard|
    dashboard.source_files = 'MKIotDMApp/Classes/Functions/DashboardPage/**/*.{h,m}'
    dashboard.dependency 'MKIotDMApp/Expand'
    dashboard.dependency 'MKIotDMApp/Alarm'
    dashboard.dependency 'MKIotDMApp/Beacon'
    dashboard.dependency 'MKIotDMApp/Cellular'
    dashboard.dependency 'MKIotDMApp/Gateway'
    dashboard.dependency 'MKIotDMApp/LoRa'
    dashboard.dependency 'MKIotDMApp/Tracker'
    dashboard.dependency 'MKIotDMApp/Sensor'
    dashboard.dependency 'MKIotDMApp/UnreadStateManager'
  end

  # ================================================================
  # MainTabBar
  # ================================================================
  s.subspec 'MainTabBar' do |main|
    main.source_files = 'MKIotDMApp/Classes/Functions/MainTabBar/**/*.{h,m}'
    main.dependency 'MKIotDMApp/DashboardPage'
    main.dependency 'MKIotDMApp/Login'
    main.dependency 'MKIotDMApp/LoginManager'
    main.dependency 'MKIotDMApp/UnreadStateManager'
  end

  # ================================================================
  # Full（全功能聚合）
  # ================================================================
  s.subspec 'Full' do |full|
    full.dependency 'MKIotDMApp/MainTabBar'
    full.dependency 'MKIotDMApp/PathDisplayPage'
    full.dependency 'MKIotDMApp/PositionPages'
    full.dependency 'MKIotDMApp/UnreadStateManager'
    full.dependency 'MKIotDMApp/LoginManager'
    full.dependency 'MKIotDMApp/NetworkServices'
    full.dependency 'GoogleMaps'
    full.dependency 'RSColorPicker'
  end

  # ================================================================
  # Core（最小功能集）
  # ================================================================
  s.subspec 'Core' do |core|
    core.dependency 'MKIotDMApp/Network'
    core.dependency 'MKIotDMApp/Expand'
  end

  s.default_subspecs = ['Full']
end
