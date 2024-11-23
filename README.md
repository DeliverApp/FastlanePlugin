# 🚀 Fastlane Plugin: DeliverApp

The **DeliverApp Fastlane plugin** simplifies the process of managing app builds and deployment. This plugin allows seamless integration with your Fastlane setup and provides powerful features for automating your app delivery process.

---

## 📥 Installation

To get started with the DeliverApp plugin, follow these steps:

### 1. Add the Plugin to Your `Pluginfile`
In your Fastlane project, open the `Pluginfile` and add the following line:
```ruby
gem 'fastlane-plugin-deliverapp', git: 'https://github.com/DeliverApp/FastlanePlugin.git'
```
and in your bash console
```bash
bundle install
```

## 🔧 Setup

Once installed, you can start using the DeliverApp plugin in your Fastlane setup. Make sure to configure your Fastfile to use the plugin.

Here’s a quick example:
```yml
lane :deploy do
    deliverapp(
      binary: "./app/build/outputs/apk/rec/release/app-rec-release.apk",
      appKey: "fb1b7dda-572c-484a-b632-2b055bc6bb79"
    )
end
```

## 💬 Support

If you encounter any issues or have feature requests, feel free to write an email at contact@deliverapp.io or to open an issue in this repository.