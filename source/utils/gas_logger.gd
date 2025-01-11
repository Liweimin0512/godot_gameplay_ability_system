class_name GASLogger
extends Object

## 日志工具

## 日志级别
enum LogLevel {
	DEBUG,
	INFO,
	WARNING,
	ERROR
}

## 日志颜色
const LOG_COLORS = {
	"DEBUG": "#7F7F7F",    # 灰色
	"INFO": "#FFFFFF",     # 白色
	"WARNING": "#FFA500",  # 橙色
	"ERROR": "#FF0000",     # 红色
}

## 当前日志级别
static var _current_level := LogLevel.INFO

## 设置日志级别
static func set_log_level(level: LogLevel) -> void:
	_current_level = level

## 调试日志
static func debug(message: String, context: Object = null) -> void:
	if _current_level <= LogLevel.DEBUG:
		_log("DEBUG", message, context)

## 信息日志
static func info(message: String, context: Object = null) -> void:
	if _current_level <= LogLevel.INFO:
		_log("INFO", message, context)

## 警告日志
static func warning(message: String, context: Object = null) -> void:
	if _current_level <= LogLevel.WARNING:
		_log("WARNING", message, context)

## 错误日志
static func error(message: String, context: Object = null) -> void:
	if _current_level <= LogLevel.ERROR:
		_log("ERROR", message, context)

## 日志实现
static func _log(level: String, message: String, context: Object) -> void:
	if OS.is_debug_build():
		# 调试版本 - 打印到输出窗口并写入日志文件
		var context_info = "[%s]" % context.get_path() if context else ""
		var color = LOG_COLORS.get(level, LOG_COLORS.DEBUG)
		var log_message = "[color=%s][GAS-%s]%s: %s%s" % [
			color,
			level,
			context_info,
			message,
			"[/color]"
		]
		print_rich(log_message)
		
		# 写入日志文件（不包含颜色代码）
		var file = FileAccess.open("user://gas_debug.log", FileAccess.WRITE_READ)
		if file:
			file.seek_end()
			var timestamp = Time.get_datetime_string_from_system()
			file.store_line("[%s] [GAS-%s]%s: %s" % [
				timestamp,
				level,
				context_info,
				message
			])
			file.close()
	else:
		# 发布版本 - 不输出日志
		pass
