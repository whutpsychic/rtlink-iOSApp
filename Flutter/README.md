# rtlink-Flutter
**自 2024-12-25 起，移动端的 flutter 框架仅支持iOS端使用（如果 Android 端也要用则无法保证 <input type="file" /> 正常运作）。同时，这也是最后一个基于 flutter 的框架，采用的是极简风格，只保留必要的功能。**

## 最先要做的事

要核对好 flutter 的版本号，然后再进行初始化操作，并在初始化项目之前先记录所使用的 flutter 版本。



## 步骤一：创建 Flutter 初始项目

```
flutter create iosapp --org com.rtzl
```



## 步骤二：复制所有依赖包

找到 pubspec.yaml 将关键部位一抄

## 步骤三：复制所有 /lib 下的代码

就是简单粗暴地全部替换

## 步骤四：照抄 info.plist

抄下关键部位

## 步骤五：替换桌面图标和启动画面

将对好尺寸的画面一替

## 步骤六：尝试运行和打包项目

```
flutter run
flutter run --release
flutter build apk
flutter build ios
```

