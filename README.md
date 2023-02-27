🧪 Maestro fastlane plugin

[![fastlane Plugin Badge](https://rawcdn.githack.com/fastlane/fastlane/master/fastlane/assets/plugin-badge.svg)](https://rubygems.org/gems/fastlane-plugin-maestro)

## Getting Started

This project is a [_fastlane_](https://github.com/fastlane/fastlane) plugin. To get started
with `fastlane-plugin-maestro`, add it to your project by adding the following line to your `Pluginfile`:

```ruby
gem "fastlane-plugin-maestro", git: "https://github.com/inf2381/fastlane-plugin-maestro.git", branch: "main"
```

## About this plugin

fastlane plugin for [maestro](https://github.com/mobile-dev-inc/maestro).
You can directly pass the options to maestro or provide them in the file `fastlane/Maestrofile`

Additionally to the maestro action, this plugin provides an action to start an iOS simulator and install a given .app
file to it.

## Examples

Create a simulator, install a .app file on it and patch the device for testing

```ruby
app = File.realpath(Dir["../**/*.app"].first)

device = launch_simulator(
  app_path: app,
  device_name: "iPhone 14",
  language: "en-US"
)
```

Run all flows defined in the folder .maestro/screenshot

```ruby
maestro(
  command: 'test',
  directory: '.maestro/screenshot',
  report_type: 'junit'
)
```

Install maestro

```ruby
maestro(
  command: 'install'
)
```

Download the samples

```ruby
maestro(
  command: 'download_samples'
)
```

For other examples, please have a look at the [Fastfile of this repository](./fastlane/Fastfile)

## Issues and Feedback

For any other issues and feedback about this plugin, please submit it to this repository.

## Troubleshooting

If you have trouble using plugins, check out
the [Plugins Troubleshooting](https://docs.fastlane.tools/plugins/plugins-troubleshooting/) guide.

## Using _fastlane_ Plugins

For more information about how the `fastlane` plugin system works, check out
the [Plugins documentation](https://docs.fastlane.tools/plugins/create-plugin/).

## About _fastlane_

_fastlane_ is the easiest way to automate beta deployments and releases for your iOS and Android apps. To learn more,
check out [fastlane.tools](https://fastlane.tools).
