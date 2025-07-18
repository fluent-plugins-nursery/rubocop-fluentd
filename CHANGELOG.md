## [Unreleased]

## 0.2.2 - 2025-07-18

* `Lint/FluentdPluginLogScope`: Add `AssumeConfigLogLevel` property (`info` by default)
  It suppress useless warning against `log.info` if `log_level` is same as it.

## 0.2.1 - 2025-07-15

* Transfer ownership to https://github.com/fluent-plugins-nursery/rubocop-fluentd
* Warn string interpolation which might contains too long message.

## 0.2.0 - 2025-07-10

* Support autocorrect for the following custom cop
  - Lint/FluentdPluginConfigParamDefaultTime
  - Lint/FluentdPluginLogScope

## 0.1.1 - 2025-07-09

* Add Lint/FluentdPluginConfigParamDefaultTime

## 0.1.0 - 2025-07-07

* Initial release
  - Add Lint/FluentdPluginLogScope
  - Add Performance/FluentdPluginLogStringInterpolation
