define(function(require) {
  return function(jQuery) {
    /*
     * Translated default messages for the jQuery validation plugin.
     * Locale: TW (Taiwan - Traditional Chinese)
     */
    jQuery.extend(jQuery.validator.messages, {
      required: "不能为空",
      remote: "您输入的有误",
      email: "请输入正确的邮箱地址",
      url: "请输入合法的URL",
      date: "请输入合法的日期",
      dateISO: "请输入合法的日期 (ISO).",
      number: "请输入数字",
      digits: "请输入整数",
      creditcard: "请输入合法的信用卡号码",
      equalTo: "请重复输入密码",
      accept: "请输入有效的后缀",
      maxlength: jQuery.validator.format("长度不能大于 {0}"),
      minlength: jQuery.validator.format("长度不能小于 {0}"),
      rangelength: jQuery.validator.format("请输入长度介于  {0} 和 {1} 之间"),
      range: jQuery.validator.format("请输入  {0} 和 {1} 之间的数字"),
      max: jQuery.validator.format("请输入小于 {0}的数字"),
      min: jQuery.validator.format("请输入大于 {0}的数字")
    });
  }
});